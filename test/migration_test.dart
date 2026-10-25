// v3 → v4 数据库迁移测试
//
// 目的：验证老用户升级后数据一条不少、列名已正确改名、能源类型已回填。
// 这是整个重构里唯一"不可挽回"的事故类型（没有云端可恢复）。

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import 'package:zhiji_oil_consumption/data/database/app_database.dart';

/// 用原始 SQL 造一个 v3 的数据库文件
void buildV3Database(String path) {
  final db = sql.sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE vehicles (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        license_plate TEXT NULL,
        color TEXT NULL,
        notes TEXT NULL,
        vehicle_type TEXT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    db.execute('''
      CREATE TABLE fuel_records (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL REFERENCES vehicles (id),
        date INTEGER NOT NULL,
        fuel_amount REAL NOT NULL,
        total_price REAL NOT NULL,
        price_per_liter REAL NOT NULL,
        odometer REAL NOT NULL,
        is_full_tank INTEGER NOT NULL DEFAULT 0,
        is_light_on INTEGER NOT NULL DEFAULT 0,
        fuel_type TEXT NULL,
        station_name TEXT NULL,
        notes TEXT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // 两辆车（其中一辆是默认车）
    db.execute('''
      INSERT INTO vehicles (brand, model, license_plate, is_default, created_at, updated_at)
      VALUES ('比亚迪', '秦PLUS', '京A12345', 1, 1700000000000, 1700000000000)
    ''');
    db.execute('''
      INSERT INTO vehicles (brand, model, is_default, created_at, updated_at)
      VALUES ('丰田', '卡罗拉', 0, 1700000001000, 1700000001000)
    ''');

    // 4 条加油记录（车上里程递增，带一条未加满）
    final records = [
      (1, 1700100000000, 40.0, 300.0, 7.5, 10000.0, 1, 0, '95#'),
      (1, 1700200000000, 20.0, 150.0, 7.5, 10500.0, 0, 0, '95#'),
      (1, 1700300000000, 15.0, 112.5, 7.5, 11000.0, 1, 1, '95#'),
      (2, 1700400000000, 35.0, 262.5, 7.5, 20000.0, 1, 0, '92#'),
    ];
    for (final r in records) {
      db.execute(
        'INSERT INTO fuel_records (vehicle_id, date, fuel_amount, total_price, '
        'price_per_liter, odometer, is_full_tank, is_light_on, fuel_type, created_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [r.$1, r.$2, r.$3, r.$4, r.$5, r.$6, r.$7, r.$8, r.$9, r.$2],
      );
    }

    // 标记为 v3
    db.execute('PRAGMA user_version = 3');
  } finally {
    db.dispose();
  }
}

void main() {
  test('v3 库升级到 v4：数据不丢、列已改名、能源类型已回填', () async {
    final tmpDir = Directory.systemTemp.createTempSync('zhiji_migration_');
    final dbPath = '${tmpDir.path}/zhiji_oil.db';

    try {
      // 1) 造 v3 库
      buildV3Database(dbPath);

      // 2) 用 AppDatabase 打开（会触发 v3 → v4 迁移）
      final db = AppDatabase(NativeDatabase(File(dbPath)));
      addTearDown(() async {
        await db.close();
        if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
      });

      // 3) 车辆数没变，且默认车还在
      final vehicles = await db.getAllVehicles();
      expect(vehicles.length, 2, reason: '车辆应一条不少');
      expect(vehicles.where((v) => v.isDefault).length, 1, reason: '默认车标记应保留');
      // 新列有默认值
      expect(vehicles.every((v) => v.energyType == 'gasoline'), isTrue,
          reason: 'vehicles.energy_type 应默认 gasoline');

      // 4) 能源记录数与内容
      final records = await db.getEnergyRecordsForVehicle(1);
      expect(records.length, 3, reason: '车辆1 的 3 条记录应全部保留');

      // 5) 改名后的列值正确（对应旧的 fuel_amount / total_price / is_full_tank）
      final first = records.first;
      expect(first.quantity, 40.0, reason: 'fuel_amount → quantity');
      expect(first.amount, 300.0, reason: 'total_price → amount');
      expect(first.unitPrice, 7.5, reason: 'price_per_liter → unit_price');
      expect(first.isFull, isTrue, reason: 'is_full_tank → is_full');
      expect(first.fuelType, '95#', reason: '普通列应原样保留');

      // 6) 新列 energy_type 已按车辆类型回填
      expect(records.every((r) => r.energyType == 'gasoline'), isTrue,
          reason: 'energy_type 应回填为所属车辆的类型');

      // 7) expenses 表已建好（能查即证明存在）
      final expenses = await db.getExpensesForVehicle(1);
      expect(expenses, isEmpty, reason: '新表应为空但不报错');

      // 8) 聚合查询可用（用新列名）
      final totalCost = await db.getTotalEnergyCost(1);
      expect(totalCost, closeTo(300.0 + 150.0 + 112.5, 0.01));

      // 9) 第 2 条记录是"未加满"，改名后 is_full 必须仍是 false
      expect(records[1].isFull, isFalse, reason: '未加满状态不能被迁移改错');
    } finally {
      // 兜底清理
    }
  });

  test('迁移是幂等的：连开两次不报错、数据不翻倍', () async {
    final tmpDir = Directory.systemTemp.createTempSync('zhiji_migration2_');
    final dbPath = '${tmpDir.path}/zhiji_oil.db';

    try {
      buildV3Database(dbPath);

      // 第一次打开 → 迁移
      var db = AppDatabase(NativeDatabase(File(dbPath)));
      final count1 = (await db.getEnergyRecordsForVehicle(1)).length;
      await db.close();

      // 第二次打开 → 不应再次执行改名（列已存在），数据量不变
      db = AppDatabase(NativeDatabase(File(dbPath)));
      final count2 = (await db.getEnergyRecordsForVehicle(1)).length;
      await db.close();

      expect(count1, 3);
      expect(count2, 3, reason: '二次打开不能重复迁移或丢数据');
    } finally {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    }
  });
}
