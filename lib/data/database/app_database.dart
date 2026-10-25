// 智记能耗 - Drift 数据库主类（v4）
// 负责：数据库实例、schema 迁移、所有数据操作方法
//
// 2026-10-25 升级到 v4：
//   - fuel_records → energy_records（4 列改名 + 2 列新增）
//   - vehicles 新增 energy_type
//   - 新增 expenses 表
//   - 迁移逻辑按"逐列 + 幂等"实现，且不再吞异常

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database.g.dart';

/// 应用数据库类
@DriftDatabase(tables: [Vehicles, EnergyRecords, Expenses])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 4) {
          // 把整段迁移包进事务：SQLite 的 DDL 是事务性的，
          // 这样"要么全改完、要么原样回滚"，不会留下半迁移状态
          await transaction(() async {
            await _migrateToV4();
          });
        }
        if (from < 5) {
          await transaction(() async {
            await _migrateToV5();
          });
        }
      },
    );
  }


  // ==================== v4 → v5 迁移 ====================

  /// v4 → v5：加「优惠金额」列
  ///
  /// 为什么单独存优惠而不是存机显金额：
  ///   amount 已经表示"实付"，统计全用它；机显金额 = amount + discount 可以推算。
  ///   只加一列，三个数都能还原，也不会出现"三列互相矛盾"的状态。
  Future<void> _migrateToV5() async {
    await _ensureColumn(
      'energy_records',
      'discount',
      'REAL NOT NULL DEFAULT 0',
    );
  }

  // ==================== v3 → v4 迁移 ====================

  /// 逐列、幂等地把老库升到 v4
  ///
  /// 设计要点：
  /// - 每一步都先检查现状，已做过就跳过（幂等），所以中途失败后重跑是安全的
  /// - 不吞异常：任何一步失败都会抛出，由外层终止升级并提示用户
  /// - 不能用 Drift 的 addColumn 做改名（那是"加新列"，旧数据留在旧列里）
  Future<void> _migrateToV4() async {
    // ① 老表还在 → 先补齐 v2 可能缺失的列，再改名
    if (await _tableExists('fuel_records')) {
      await _ensureColumn('fuel_records', 'is_light_on',
          'INTEGER NOT NULL DEFAULT 0');
      await _ensureColumn('fuel_records', 'fuel_type', 'TEXT');
      await _ensureColumn('fuel_records', 'station_name', 'TEXT');
      await customStatement(
          'ALTER TABLE fuel_records RENAME TO energy_records');
    }

    // ② 四个列改名（幂等）
    await _renameColumnIfExists('energy_records', 'fuel_amount', 'quantity');
    await _renameColumnIfExists('energy_records', 'total_price', 'amount');
    await _renameColumnIfExists(
        'energy_records', 'price_per_liter', 'unit_price');
    await _renameColumnIfExists('energy_records', 'is_full_tank', 'is_full');

    // ③ 能源记录新增列
    await _ensureColumn(
        'energy_records', 'energy_type', "TEXT NOT NULL DEFAULT 'gasoline'");
    await _ensureColumn('energy_records', 'charge_method', 'TEXT');

    // ④ 车辆新增能源类型
    await _ensureColumn(
        'vehicles', 'energy_type', "TEXT NOT NULL DEFAULT 'gasoline'");

    // ⑤ 新表 expenses
    await customStatement('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL REFERENCES vehicles (id),
        date INTEGER NOT NULL,
        kind TEXT NOT NULL,
        category TEXT NOT NULL,
        items TEXT NULL,
        mileage REAL NULL,
        amount REAL NOT NULL,
        notes TEXT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // ⑥ 按所属车辆的类型回填历史记录的能源类型
    await customStatement('''
      UPDATE energy_records
      SET energy_type = (
        SELECT v.energy_type FROM vehicles v WHERE v.id = energy_records.vehicle_id
      )
      WHERE energy_type = 'gasoline'
        AND EXISTS (SELECT 1 FROM vehicles v WHERE v.id = energy_records.vehicle_id
                    AND v.energy_type IN ('gasoline', 'electric'))
    ''');
  }

  /// 表是否存在
  Future<bool> _tableExists(String name) async {
    final rows = await customSelect(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(name)],
    ).get();
    return rows.isNotEmpty;
  }

  /// 取某张表的列名列表（表不存在时返回空）
  Future<List<String>> _columnsOf(String table) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.map((r) => r.read<String>('name')).toList();
  }

  /// 列不存在才加（幂等）
  Future<void> _ensureColumn(
      String table, String column, String definition) async {
    final cols = await _columnsOf(table);
    if (cols.isEmpty) return; // 表不存在，交给 createAll
    if (cols.contains(column)) return;
    await customStatement('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  /// 列改名（已改过或本来就没有则跳过，幂等）
  Future<void> _renameColumnIfExists(
      String table, String oldName, String newName) async {
    final cols = await _columnsOf(table);
    if (cols.contains(newName)) return;
    if (!cols.contains(oldName)) return;
    await customStatement(
        'ALTER TABLE $table RENAME COLUMN $oldName TO $newName');
  }

  // ==================== 车辆 ====================

  Stream<List<Vehicle>> watchAllVehicles() {
    return (select(vehicles)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<Vehicle>> getAllVehicles() {
    return (select(vehicles)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Vehicle?> getVehicleById(int id) {
    return (select(vehicles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertVehicle(VehiclesCompanion vehicle) {
    return into(vehicles).insert(vehicle);
  }

  Future<bool> updateVehicle(VehiclesCompanion vehicle) {
    return update(vehicles).replace(vehicle);
  }

  Future<bool> deleteVehicle(int id) async {
    // 先清掉这辆车的记录与支出，避免留下孤儿数据
    await (delete(energyRecords)..where((t) => t.vehicleId.equals(id))).go();
    await (delete(expenses)..where((t) => t.vehicleId.equals(id))).go();
    final n = await (delete(vehicles)..where((t) => t.id.equals(id))).go();
    return n > 0;
  }

  Future<int> getVehicleCount() async {
    final list = await select(vehicles).get();
    return list.length;
  }

  // ==================== 能源记录（加油 / 充电） ====================

  Stream<List<EnergyRecord>> watchEnergyRecordsForVehicle(int vehicleId) {
    return (select(energyRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.odometer),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  /// 按时间正序（旧 → 新）取全部记录，能耗算法需要这个顺序
  Future<List<EnergyRecord>> getEnergyRecordsForVehicle(int vehicleId) {
    return (select(energyRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.odometer),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Future<EnergyRecord?> getEnergyRecordById(int id) {
    return (select(energyRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertEnergyRecord(EnergyRecordsCompanion record) {
    return into(energyRecords).insert(record);
  }

  /// 更新一条能耗记录
  ///
  /// 用 write(companion) 而不是 replace(companion)：
  /// replace 会校验"所有非空列都必须有值"，而编辑时我们刻意不带 createdAt
  /// （编辑不该改变创建时间），于是会抛 InvalidDataException。
  /// write 的语义是"只改 companion 里出现的列"，absent 的列保持原值。
  Future<bool> updateEnergyRecord(EnergyRecordsCompanion record) async {
    if (!record.id.present) {
      throw ArgumentError('updateEnergyRecord 需要带 id');
    }
    final n = await (update(energyRecords)
          ..where((t) => t.id.equals(record.id.value)))
        .write(record);
    return n > 0;
  }

  Future<bool> deleteEnergyRecord(int id) async {
    final n =
        await (delete(energyRecords)..where((t) => t.id.equals(id))).go();
    return n > 0;
  }

  Future<int> getEnergyRecordCount(int vehicleId) async {
    final list = await (select(energyRecords)
          ..where((t) => t.vehicleId.equals(vehicleId)))
        .get();
    return list.length;
  }

  Future<EnergyRecord?> getLatestEnergyRecord(int vehicleId) {
    return (select(energyRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  // ==================== 其他支出（保养 / 费用） ====================

  Stream<List<Expense>> watchExpensesForVehicle(int vehicleId) {
    return (select(expenses)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<List<Expense>> getExpensesForVehicle(int vehicleId) {
    return (select(expenses)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.date),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  /// 更新一条支出记录
  ///
  /// 同能耗记录：用 write 而不是 replace —— replace 要求所有非空列都有值，
  /// 而编辑时刻意不带 createdAt（不该改创建时间）。
  Future<bool> updateExpense(ExpensesCompanion expense) async {
    if (!expense.id.present) {
      throw ArgumentError('updateExpense 需要带 id');
    }
    final n = await (update(expenses)
          ..where((t) => t.id.equals(expense.id.value)))
        .write(expense);
    return n > 0;
  }

  Future<bool> deleteExpense(int id) async {
    final n = await (delete(expenses)..where((t) => t.id.equals(id))).go();
    return n > 0;
  }

  // ==================== 聚合查询 ====================

  /// 某辆车「能源花费」合计（加油 + 充电）
  Future<double> getTotalEnergyCost(int vehicleId) async {
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.amount.sum()])
      ..where(energyRecords.vehicleId.equals(vehicleId));
    final row = await q.getSingle();
    return row.read(energyRecords.amount.sum()) ?? 0;
  }

  /// 某辆车「其他支出」合计（保养 + 费用）
  Future<double> getTotalExpenseCost(int vehicleId) async {
    final q = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.vehicleId.equals(vehicleId));
    final row = await q.getSingle();
    return row.read(expenses.amount.sum()) ?? 0;
  }

  /// 某辆车某类支出合计（maintenance / other）
  Future<double> getTotalExpenseCostByKind(int vehicleId, String kind) async {
    final q = selectOnly(expenses)
      ..addColumns([expenses.amount.sum()])
      ..where(expenses.vehicleId.equals(vehicleId))
      ..where(expenses.kind.equals(kind));
    final row = await q.getSingle();
    return row.read(expenses.amount.sum()) ?? 0;
  }

  /// 某辆车全部花费 = 能源 + 其他支出
  Future<double> getTotalCostAll(int vehicleId) async {
    final a = await getTotalEnergyCost(vehicleId);
    final b = await getTotalExpenseCost(vehicleId);
    return a + b;
  }

  /// 某辆车的最高单次能源花费
  Future<double> getMaxSingleCost(int vehicleId) async {
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.amount.max()])
      ..where(energyRecords.vehicleId.equals(vehicleId));
    final row = await q.getSingle();
    return row.read(energyRecords.amount.max()) ?? 0;
  }

  /// 某辆车的最低单价（仅同一种能源有意义）
  Future<double?> getMinUnitPrice(int vehicleId, String energyType) async {
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.unitPrice.min()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.energyType.equals(energyType));
    final row = await q.getSingle();
    return row.read(energyRecords.unitPrice.min());
  }

  Future<double?> getMaxUnitPrice(int vehicleId, String energyType) async {
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.unitPrice.max()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.energyType.equals(energyType));
    final row = await q.getSingle();
    return row.read(energyRecords.unitPrice.max());
  }

  /// 某辆车有记录的年份（降序）
  Future<List<int>> getRecordYears(int vehicleId) async {
    final records = await getEnergyRecordsForVehicle(vehicleId);
    final years = records
        .map((r) => DateTime.fromMillisecondsSinceEpoch(r.date).year)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  /// 某辆车的最小 / 最大里程（用于"总里程"）
  Future<({double min, double max})?> getOdometerRange(int vehicleId) async {
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.odometer.min(), energyRecords.odometer.max()])
      ..where(energyRecords.vehicleId.equals(vehicleId));
    final row = await q.getSingle();
    final min = row.read(energyRecords.odometer.min());
    final max = row.read(energyRecords.odometer.max());
    if (min == null || max == null) return null;
    return (min: min, max: max);
  }

  /// 某辆车某类能源的总量（油：升 / 电：kWh）
  Future<double> getTotalEnergyQuantity(
      int vehicleId, String energyType) async {
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.quantity.sum()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.energyType.equals(energyType));
    final row = await q.getSingle();
    return row.read(energyRecords.quantity.sum()) ?? 0;
  }

  /// 某月总花费（能源）
  Future<double> getMonthlyTotalCost(int vehicleId, int year, int month) async {
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 1).millisecondsSinceEpoch;
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.amount.sum()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.date.isBiggerOrEqualValue(start))
      ..where(energyRecords.date.isSmallerThanValue(end));
    final row = await q.getSingle();
    return row.read(energyRecords.amount.sum()) ?? 0;
  }

  /// 某月某类能源的总量
  Future<double> getMonthlyTotalQuantity(
      int vehicleId, int year, int month, String energyType) async {
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 1).millisecondsSinceEpoch;
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.quantity.sum()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.date.isBiggerOrEqualValue(start))
      ..where(energyRecords.date.isSmallerThanValue(end))
      ..where(energyRecords.energyType.equals(energyType));
    final row = await q.getSingle();
    return row.read(energyRecords.quantity.sum()) ?? 0;
  }

  /// 某月记录数
  Future<int> getMonthlyRecordCount(
      int vehicleId, int year, int month) async {
    final start = DateTime(year, month, 1).millisecondsSinceEpoch;
    final end = DateTime(year, month + 1, 1).millisecondsSinceEpoch;
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.id.count()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.date.isBiggerOrEqualValue(start))
      ..where(energyRecords.date.isSmallerThanValue(end));
    final row = await q.getSingle();
    return row.read(energyRecords.id.count()) ?? 0;
  }

  /// 某年总花费（能源）
  Future<double> getYearlyTotalCost(int vehicleId, int year) async {
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year + 1, 1, 1).millisecondsSinceEpoch;
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.amount.sum()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.date.isBiggerOrEqualValue(start))
      ..where(energyRecords.date.isSmallerThanValue(end));
    final row = await q.getSingle();
    return row.read(energyRecords.amount.sum()) ?? 0;
  }

  /// 某年某类能源的总量
  Future<double> getYearlyTotalQuantity(
      int vehicleId, int year, String energyType) async {
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year + 1, 1, 1).millisecondsSinceEpoch;
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.quantity.sum()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.date.isBiggerOrEqualValue(start))
      ..where(energyRecords.date.isSmallerThanValue(end))
      ..where(energyRecords.energyType.equals(energyType));
    final row = await q.getSingle();
    return row.read(energyRecords.quantity.sum()) ?? 0;
  }

  /// 某年记录数
  Future<int> getYearlyRecordCount(int vehicleId, int year) async {
    final start = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final end = DateTime(year + 1, 1, 1).millisecondsSinceEpoch;
    final q = selectOnly(energyRecords)
      ..addColumns([energyRecords.id.count()])
      ..where(energyRecords.vehicleId.equals(vehicleId))
      ..where(energyRecords.date.isBiggerOrEqualValue(start))
      ..where(energyRecords.date.isSmallerThanValue(end));
    final row = await q.getSingle();
    return row.read(energyRecords.id.count()) ?? 0;
  }

  /// 把所有车辆取消默认（导入前用，避免出现多个默认车）
  Future<void> clearAllDefaultVehicles() async {
    await customStatement('UPDATE vehicles SET is_default = 0');
  }

  // ==================== 数据清理 ====================

  Future<int> deleteAllEnergyRecords() => delete(energyRecords).go();

  Future<int> deleteAllExpenses() => delete(expenses).go();

  Future<int> deleteAllVehicles() => delete(vehicles).go();
}

/// 数据库单例
AppDatabase? _databaseInstance;

AppDatabase getDatabaseInstance() {
  _databaseInstance ??= AppDatabase(_openConnection());
  return _databaseInstance!;
}

/// 重置实例（错误恢复用）
void resetDatabaseInstance() {
  _databaseInstance = null;
}

/// 数据库文件路径
Future<File> getDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'zhiji_oil.db'));
}

/// 打开连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await getDatabaseFile();
    return NativeDatabase(file);
  });
}
