// 记录写入-读回测试
//
// 为什么要这一类测试：B1（v1.1.0）就是"参数加了、Companion 漏了"——
// 界面上显示全对，只有真正读回来才能发现字段没落库。
//
// 用内存库，不碰真实数据。

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;

import 'package:zhiji_oil_consumption/data/database/app_database.dart';
import 'package:zhiji_oil_consumption/data/database/tables.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('优惠金额能写入并读回（B1 回归）', () async {
    final vid = await db.insertVehicle(VehiclesCompanion(
      brand: const Value('测试'),
      model: const Value('车'),
      energyType: const Value(EnergyTypes.gasoline),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    await db.insertEnergyRecord(EnergyRecordsCompanion(
      vehicleId: Value(vid),
      energyType: const Value(EnergyTypes.gasoline),
      date: Value(DateTime(2026, 10, 26).millisecondsSinceEpoch),
      quantity: const Value(100.0),
      amount: const Value(700.0), // 实付
      discount: const Value(43.0), // 优惠（机显 743 - 实付 700）
      unitPrice: const Value(7.43),
      odometer: const Value(10000.0),
      isFull: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    final records = await db.getEnergyRecordsForVehicle(vid);
    expect(records.length, 1);

    final r = records.first;
    expect(r.amount, closeTo(700.0, 0.001), reason: '实付金额');
    expect(r.discount, closeTo(43.0, 0.001), reason: '优惠金额必须落库');
    // 机显金额 = 实付 + 优惠，能推算回来
    expect(r.amount + r.discount, closeTo(743.0, 0.001), reason: '机显金额可还原');
  });

  test('不传 discount 时默认 0', () async {
    final vid = await db.insertVehicle(VehiclesCompanion(
      brand: const Value('测试'),
      model: const Value('车'),
      energyType: const Value(EnergyTypes.gasoline),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    await db.insertEnergyRecord(EnergyRecordsCompanion(
      vehicleId: Value(vid),
      energyType: const Value(EnergyTypes.gasoline),
      date: Value(DateTime(2026, 10, 26).millisecondsSinceEpoch),
      quantity: const Value(50.0),
      amount: const Value(375.0),
      unitPrice: const Value(7.5),
      odometer: const Value(20000.0),
      isFull: const Value(true),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    final records = await db.getEnergyRecordsForVehicle(vid);
    expect(records.first.discount, 0.0);
  });

  test('编辑记录不覆盖 created_at（m2 回归）', () async {
    final vid = await db.insertVehicle(VehiclesCompanion(
      brand: const Value('测试'),
      model: const Value('车'),
      energyType: const Value(EnergyTypes.gasoline),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    final created = DateTime(2020, 1, 1).millisecondsSinceEpoch;
    await db.insertEnergyRecord(EnergyRecordsCompanion(
      vehicleId: Value(vid),
      energyType: const Value(EnergyTypes.gasoline),
      date: Value(DateTime(2026, 10, 26).millisecondsSinceEpoch),
      quantity: const Value(50.0),
      amount: const Value(375.0),
      unitPrice: const Value(7.5),
      odometer: const Value(20000.0),
      isFull: const Value(true),
      createdAt: Value(created),
    ));

    final id = (await db.getEnergyRecordsForVehicle(vid)).first.id;

    // 模拟更新：companion 里不带 createdAt（和 updateRecord 一致）
    await db.updateEnergyRecord(EnergyRecordsCompanion(
      id: Value(id),
      amount: const Value(300.0),
      discount: const Value(75.0),
    ));

    final after = (await db.getEnergyRecordsForVehicle(vid)).first;
    expect(after.amount, closeTo(300.0, 0.001), reason: '金额已更新');
    expect(after.discount, closeTo(75.0, 0.001), reason: '优惠已更新');
    expect(after.createdAt, created, reason: '创建时间不能被覆盖');
  });
}
