// 智记油耗 - Drift数据库主类
// 这个文件创建数据库实例,并提供所有数据操作方法

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// 导入表定义
import 'tables.dart';

// 告诉Drift要生成哪些代码
part 'app_database.g.dart';

/// 应用数据库类
/// 
/// 这个类管理整个应用的数据库连接
/// 使用@DriftDatabase注解指定要包含的表
@DriftDatabase(tables: [Vehicles, FuelRecords])
class AppDatabase extends _$AppDatabase {
  /// 构造函数
  /// 
  /// [e] 是查询执行器,负责实际执行SQL语句
  AppDatabase(QueryExecutor e) : super(e);

  /// 获取数据库版本
  /// 用于数据库迁移(后续升级时使用)
  @override
  int get schemaVersion => 3;

  /// 数据库迁移策略
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          try {
            await m.addColumn(fuelRecords, fuelRecords.isLightOn);
          } catch (_) {}
          try {
            await m.addColumn(fuelRecords, fuelRecords.fuelType);
          } catch (_) {}
          try {
            await m.addColumn(fuelRecords, fuelRecords.stationName);
          } catch (_) {}
        }
        if (from < 3) {
          // v3: schema alignment, no new columns added
        }
      },
    );
  }

  // ==================== 车辆相关操作 ====================

  /// 查询所有车辆(Drift原生类型)
  /// 
  /// 返回一个Stream,当数据库中的数据变化时会自动更新
  Stream<List<Vehicle>> watchAllVehiclesNative() {
    return (select(vehicles)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  /// 查询所有车辆(Drift原生类型,一次性获取)
  Future<List<Vehicle>> getAllVehiclesNative() {
    return (select(vehicles)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// 根据ID查询单个车辆(Drift原生类型)
  Future<Vehicle?> getVehicleByIdNative(int id) {
    return (select(vehicles)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 插入一辆新车
  Future<int> insertVehicle(VehiclesCompanion vehicle) {
    return into(vehicles).insert(vehicle);
  }

  /// 更新车辆信息
  Future<bool> updateVehicle(VehiclesCompanion vehicle) {
    return update(vehicles).replace(vehicle);
  }

  /// 删除车辆
  Future<bool> deleteVehicle(int id) {
    return (delete(vehicles)..where((t) => t.id.equals(id))).go().then(
          (value) => value > 0,
        );
  }

  /// 统计车辆总数
  Future<int> getVehicleCount() {
    return select(vehicles).get().then((list) => list.length);
  }

  // ==================== 油耗记录相关操作 ====================

  /// 查询某辆车的所有油耗记录(Drift原生类型)
  Stream<List<FuelRecord>> watchFuelRecordsForVehicleNative(int vehicleId) {
    return (select(fuelRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  /// 查询某辆车的所有油耗记录(一次性获取)
  Future<List<FuelRecord>> getFuelRecordsForVehicleNative(int vehicleId) {
    return (select(fuelRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// 根据ID查询单条油耗记录
  Future<FuelRecord?> getFuelRecordByIdNative(int id) {
    return (select(fuelRecords)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 插入一条油耗记录
  Future<int> insertFuelRecord(FuelRecordsCompanion record) {
    return into(fuelRecords).insert(record);
  }

  /// 更新油耗记录
  Future<bool> updateFuelRecord(FuelRecordsCompanion record) {
    return update(fuelRecords).replace(record);
  }

  /// 删除一条油耗记录
  Future<bool> deleteFuelRecord(int id) {
    return (delete(fuelRecords)..where((t) => t.id.equals(id)))
        .go()
        .then((value) => value > 0);
  }

  /// 统计某辆车的记录数
  Future<int> getFuelRecordCount(int vehicleId) {
    return (select(fuelRecords)..where((t) => t.vehicleId.equals(vehicleId)))
        .get()
        .then((list) => list.length);
  }

  /// 获取某辆车的最新一条记录
  Future<FuelRecord?> getLatestFuelRecord(int vehicleId) {
    return (select(fuelRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
  }

  // ==================== SQL聚合查询优化 ====================

  /// 计算某辆车某月的总花费（SQL聚合）
  Future<double> getMonthlyTotalCost(int vehicleId, int year, int month) {
    final startTimestamp = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year, month + 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.totalPrice.sum()])
      ..where(fuelRecords.vehicleId.equals(vehicleId))
      ..where(fuelRecords.date.isBiggerOrEqualValue(startTimestamp))
      ..where(fuelRecords.date.isSmallerThanValue(endTimestamp));

    return query.getSingle().then((row) => row.read(fuelRecords.totalPrice.sum()) ?? 0);
  }

  /// 计算某辆车某月的记录数（SQL聚合）
  Future<int> getMonthlyRecordCount(int vehicleId, int year, int month) {
    final startTimestamp = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year, month + 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.id.count()])
      ..where(fuelRecords.vehicleId.equals(vehicleId))
      ..where(fuelRecords.date.isBiggerOrEqualValue(startTimestamp))
      ..where(fuelRecords.date.isSmallerThanValue(endTimestamp));

    return query.getSingle().then((row) => row.read(fuelRecords.id.count()) ?? 0);
  }

  /// 计算某辆车某月的第一条和最后一条记录（用于计算里程）
  Future<Map<String, FuelRecord?>> getMonthFirstLastRecord(
    int vehicleId,
    int year,
    int month,
  ) async {
    final startTimestamp = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year, month + 1, 1).millisecondsSinceEpoch;

    final firstRecord = await (select(fuelRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.date.isBiggerOrEqualValue(startTimestamp))
          ..where((t) => t.date.isSmallerThanValue(endTimestamp))
          ..orderBy([(t) => OrderingTerm.asc(t.date)])
          ..limit(1))
        .getSingleOrNull();

    final lastRecord = await (select(fuelRecords)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.date.isBiggerOrEqualValue(startTimestamp))
          ..where((t) => t.date.isSmallerThanValue(endTimestamp))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();

    return {'first': firstRecord, 'last': lastRecord};
  }

  /// 计算某辆车某月的总加油量（SQL聚合）
  Future<double> getMonthlyTotalFuel(int vehicleId, int year, int month) {
    final startTimestamp = DateTime(year, month, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year, month + 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.fuelAmount.sum()])
      ..where(fuelRecords.vehicleId.equals(vehicleId))
      ..where(fuelRecords.date.isBiggerOrEqualValue(startTimestamp))
      ..where(fuelRecords.date.isSmallerThanValue(endTimestamp));

    return query.getSingle().then((row) => row.read(fuelRecords.fuelAmount.sum()) ?? 0);
  }

  /// 计算某辆车的总花费（SQL聚合）
  Future<double> getTotalCost(int vehicleId) {
    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.totalPrice.sum()])
      ..where(fuelRecords.vehicleId.equals(vehicleId));

    return query.getSingle().then((row) => row.read(fuelRecords.totalPrice.sum()) ?? 0);
  }

  /// 计算某辆车的总加油量（SQL聚合）
  Future<double> getTotalFuel(int vehicleId) {
    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.fuelAmount.sum()])
      ..where(fuelRecords.vehicleId.equals(vehicleId));

    return query.getSingle().then((row) => row.read(fuelRecords.fuelAmount.sum()) ?? 0);
  }

  /// 计算某辆车的最高单次加油金额（SQL聚合）
  Future<double> getMaxSingleCost(int vehicleId) {
    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.totalPrice.max()])
      ..where(fuelRecords.vehicleId.equals(vehicleId));

    return query.getSingle().then((row) => row.read(fuelRecords.totalPrice.max()) ?? 0);
  }

  /// 计算某辆车的最低油价（SQL聚合）
  Future<double> getMinPricePerLiter(int vehicleId) {
    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.pricePerLiter.min()])
      ..where(fuelRecords.vehicleId.equals(vehicleId));

    return query.getSingle().then((row) => row.read(fuelRecords.pricePerLiter.min()) ?? 0);
  }

  /// 计算某辆车的最高油价（SQL聚合）
  Future<double> getMaxPricePerLiter(int vehicleId) {
    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.pricePerLiter.max()])
      ..where(fuelRecords.vehicleId.equals(vehicleId));

    return query.getSingle().then((row) => row.read(fuelRecords.pricePerLiter.max()) ?? 0);
  }

  // ==================== 年度统计聚合查询 ====================

  /// 计算某辆车某年的总花费
  Future<double> getYearlyTotalCost(int vehicleId, int year) {
    final startTimestamp = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year + 1, 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.totalPrice.sum()])
      ..where(fuelRecords.vehicleId.equals(vehicleId))
      ..where(fuelRecords.date.isBiggerOrEqualValue(startTimestamp))
      ..where(fuelRecords.date.isSmallerThanValue(endTimestamp));

    return query.getSingle().then((row) => row.read(fuelRecords.totalPrice.sum()) ?? 0);
  }

  /// 计算某辆车某年的总加油量
  Future<double> getYearlyTotalFuel(int vehicleId, int year) {
    final startTimestamp = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year + 1, 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.fuelAmount.sum()])
      ..where(fuelRecords.vehicleId.equals(vehicleId))
      ..where(fuelRecords.date.isBiggerOrEqualValue(startTimestamp))
      ..where(fuelRecords.date.isSmallerThanValue(endTimestamp));

    return query.getSingle().then((row) => row.read(fuelRecords.fuelAmount.sum()) ?? 0);
  }

  /// 计算某辆车某年的记录数
  Future<int> getYearlyRecordCount(int vehicleId, int year) {
    final startTimestamp = DateTime(year, 1, 1).millisecondsSinceEpoch;
    final endTimestamp = DateTime(year + 1, 1, 1).millisecondsSinceEpoch;

    final query = selectOnly(fuelRecords)
      ..addColumns([fuelRecords.id.count()])
      ..where(fuelRecords.vehicleId.equals(vehicleId))
      ..where(fuelRecords.date.isBiggerOrEqualValue(startTimestamp))
      ..where(fuelRecords.date.isSmallerThanValue(endTimestamp));

    return query.getSingle().then((row) => row.read(fuelRecords.id.count()) ?? 0);
  }

  /// 获取某辆车有记录的所有年份
  Future<List<int>> getRecordYears(int vehicleId) async {
    final records = await getFuelRecordsForVehicleNative(vehicleId);
    final years = records.map((r) {
      return DateTime.fromMillisecondsSinceEpoch(r.date).year;
    }).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  // ==================== 数据清理操作 ====================

  /// 删除所有加油记录
  Future<int> deleteAllFuelRecords() {
    return delete(fuelRecords).go();
  }

  /// 删除所有车辆
  Future<int> deleteAllVehicles() {
    return delete(vehicles).go();
  }
}

/// 创建数据库实例的单例函数
AppDatabase? _databaseInstance;

AppDatabase getDatabaseInstance() {
  if (_databaseInstance == null) {
    _databaseInstance = AppDatabase(_openConnection());
  }
  return _databaseInstance!;
}

/// 重置数据库实例（用于错误恢复）
void resetDatabaseInstance() {
  _databaseInstance = null;
}

/// 打开数据库连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'zhiji_oil.db'));
    return NativeDatabase(file);
  });
}
