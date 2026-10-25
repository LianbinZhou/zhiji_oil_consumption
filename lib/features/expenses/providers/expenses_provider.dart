// 智记能耗 - 其他支出 Provider（保养 + 费用）
//
// 保养与费用合用一张 expenses 表，用 kind 区分：
//   kind = maintenance  → 保养（有 items 项目多选、mileage 当时里程）
//   kind = other        → 费用（保险、停车、洗车、罚款…）

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../vehicles/providers/vehicles_provider.dart';

/// 某辆车的支出记录（按日期倒序）
final expensesStreamProvider =
    StreamProvider.family<List<Expense>, int>((ref, vehicleId) {
  final db = ref.watch(databaseProvider);
  return db.watchExpensesForVehicle(vehicleId);
});

/// 某辆车某类支出合计（maintenance / other）
final expenseTotalByKindProvider =
    FutureProvider.family<double, (int, String)>((ref, arg) async {
  final db = ref.watch(databaseProvider);
  return db.getTotalExpenseCostByKind(arg.$1, arg.$2);
});

/// 某辆车支出总额（保养 + 费用）
final expenseTotalProvider =
    FutureProvider.family<double, int>((ref, vehicleId) async {
  final db = ref.watch(databaseProvider);
  return db.getTotalExpenseCost(vehicleId);
});

/// 支出写操作
class ExpensesNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  Future<void> addExpense({
    required int vehicleId,
    required DateTime date,
    required String kind,
    required String category,
    String? items,
    double? mileage,
    required double amount,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    await db.insertExpense(ExpensesCompanion(
      vehicleId: drift.Value(vehicleId),
      date: drift.Value(date.millisecondsSinceEpoch),
      kind: drift.Value(kind),
      category: drift.Value(category),
      items: drift.Value(items),
      mileage: drift.Value(mileage),
      amount: drift.Value(amount),
      notes: drift.Value(notes),
      // 新增必须给 createdAt（该列 NOT NULL 且无默认值，漏了 Drift 直接抛 InvalidDataException）
      createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> updateExpense({
    required int id,
    required int vehicleId,
    required DateTime date,
    required String kind,
    required String category,
    String? items,
    double? mileage,
    required double amount,
    String? notes,
  }) async {
    final db = ref.read(databaseProvider);
    await db.updateExpense(ExpensesCompanion(
      id: drift.Value(id),
      vehicleId: drift.Value(vehicleId),
      date: drift.Value(date.millisecondsSinceEpoch),
      kind: drift.Value(kind),
      category: drift.Value(category),
      items: drift.Value(items),
      mileage: drift.Value(mileage),
      amount: drift.Value(amount),
      notes: drift.Value(notes),
      // 编辑不该改创建时间（不传 createdAt，由 updateExpense 的 write 保持原值）
    ));
  }

  Future<void> deleteExpense(int id) async {
    final db = ref.read(databaseProvider);
    final ok = await db.deleteExpense(id);
    if (!ok) throw Exception('删除失败');
  }
}

final expensesNotifierProvider =
    NotifierProvider.autoDispose<ExpensesNotifier, void>(
  ExpensesNotifier.new,
);

/// 供界面用的默认分类清单
class ExpenseCatalog {
  static const maintenanceCategories = <String>[
    '机油',
    '机油滤芯',
    '空气滤芯',
    '空调滤芯',
    '火花塞',
    '刹车片',
    '刹车油',
    '变速箱油',
    '防冻液',
    '轮胎',
    '电瓶',
    '四轮定位',
  ];

  static const otherCategories = <String>[
    '保险',
    '停车费',
    '洗车',
    '过路费',
    '罚款',
    '维修',
    '年检',
    '其他',
  ];

  static List<String> byKind(String kind) =>
      kind == ExpenseKinds.maintenance ? maintenanceCategories : otherCategories;

  static String kindLabel(String kind) =>
      kind == ExpenseKinds.maintenance ? '保养' : '费用';
}
