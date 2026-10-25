// 保养 / 费用记录的增删改测试
//
// 为什么单独写这个文件：v1.1.2 的 P0-1 是「addExpense 漏了 createdAt」，
// 数据库层直接抛 InvalidDataException，保养/费用功能完全不可用。
// 而当时 test/ 下没有任何 expenses 的测试——这类"某个字段从写库路径里漏掉"
// 的回归只能靠"真的插一次再读回来"来拦住。

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zhiji_oil_consumption/data/database/app_database.dart';
import 'package:zhiji_oil_consumption/data/database/tables.dart';
import 'package:zhiji_oil_consumption/features/vehicles/providers/vehicles_provider.dart';
import 'package:zhiji_oil_consumption/features/expenses/providers/expenses_provider.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);

    vehicleId = await db.insertVehicle(VehiclesCompanion(
      brand: const Value('测试'),
      model: const Value('车'),
      energyType: const Value(EnergyTypes.gasoline),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('addExpense 能成功落库（P0-1 回归：漏 createdAt 会抛 InvalidDataException）',
      () async {
    final notifier = container.read(expensesNotifierProvider.notifier);

    await notifier.addExpense(
      vehicleId: vehicleId,
      date: DateTime(2026, 10, 26),
      kind: ExpenseKinds.maintenance,
      category: '机油',
      items: '机油',
      mileage: 12000,
      amount: 380,
      notes: '测试',
    );

    final list = await db.getExpensesForVehicle(vehicleId);
    expect(list.length, 1, reason: '记录必须真的写进去');
    final e = list.first;
    expect(e.amount, closeTo(380, 0.01));
    expect(e.category, '机油');
    expect(e.createdAt, greaterThan(0), reason: 'createdAt 必须被写入');
  });

  test('updateExpense 能成功更新，且不改 created_at', () async {
    final notifier = container.read(expensesNotifierProvider.notifier);

    await notifier.addExpense(
      vehicleId: vehicleId,
      date: DateTime(2026, 10, 26),
      kind: ExpenseKinds.maintenance,
      category: '机油',
      amount: 380,
    );

    final before = (await db.getExpensesForVehicle(vehicleId)).first;

    await notifier.updateExpense(
      id: before.id,
      vehicleId: vehicleId,
      date: DateTime(2026, 10, 27),
      kind: ExpenseKinds.maintenance,
      category: '机油+机滤',
      amount: 450,
    );

    final after = (await db.getExpensesForVehicle(vehicleId)).first;
    expect(after.amount, closeTo(450, 0.01), reason: '金额已更新');
    expect(after.category, '机油+机滤');
    expect(after.createdAt, before.createdAt, reason: '创建时间不能被覆盖');
  });

  test('deleteExpense 能删掉', () async {
    final notifier = container.read(expensesNotifierProvider.notifier);

    await notifier.addExpense(
      vehicleId: vehicleId,
      date: DateTime(2026, 10, 26),
      kind: ExpenseKinds.other,
      category: '停车费',
      amount: 20,
    );

    final e = (await db.getExpensesForVehicle(vehicleId)).first;
    await notifier.deleteExpense(e.id);

    expect((await db.getExpensesForVehicle(vehicleId)).length, 0);
  });
}
