// 智记能耗 - 跨车统计总览 Provider
//
// 数据口径（2026-10-25 与作者确认）：
//   里程 = 每辆车「最大里程 − 最小里程」，各车相加
//   —— 只统计用户实际录入的里程，中间漏记不特殊处理（缺口天然被首末差值覆盖）
//   —— 表显里程（最新一条的原值）不参与任何统计，只在车辆卡片显示

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../vehicles/providers/vehicles_provider.dart';
import '../../statistics/providers/statistics_provider.dart';

// ==================== 数据类 ====================

/// 费用构成
class CostBreakdown {
  final double fuel;
  final double electric;
  final double maintenance;
  final double other;

  CostBreakdown({
    required this.fuel,
    required this.electric,
    required this.maintenance,
    required this.other,
  });

  double get total => fuel + electric + maintenance + other;
}

/// 单车对比
class VehicleComparison {
  final int vehicleId;
  final String name;
  final String energyType;
  final double distance;
  final double totalCost;
  final double? averageConsumption;
  final double? costPerKm;
  final int recordCount;
  final int expenseCount;

  VehicleComparison({
    required this.vehicleId,
    required this.name,
    required this.energyType,
    required this.distance,
    required this.totalCost,
    required this.averageConsumption,
    required this.costPerKm,
    required this.recordCount,
    required this.expenseCount,
  });

  bool get distanceKnown => recordCount >= 2;
}

/// 月度点
class MonthlyPoint {
  final String yearMonth;
  final double cost;
  final double distance;
  final bool distanceKnown;

  MonthlyPoint({
    required this.yearMonth,
    required this.cost,
    required this.distance,
    required this.distanceKnown,
  });
}

/// 年度点
class YearlyPoint {
  final int year;
  final double cost;
  final double distance;
  final double energyQuantity;

  YearlyPoint({
    required this.year,
    required this.cost,
    required this.distance,
    required this.energyQuantity,
  });
}

/// 总览
class OverviewStats {
  final double totalCost;
  final double energyCost;
  final double expenseCost;
  final double totalDistance;
  final double totalFuelQuantity;
  final double totalElectricQuantity;
  final int vehicleCount;
  final int recordCount;
  final double? averageConsumption;
  final double? costPerKm;
  final CostBreakdown breakdown;

  OverviewStats({
    required this.totalCost,
    required this.energyCost,
    required this.expenseCost,
    required this.totalDistance,
    required this.totalFuelQuantity,
    required this.totalElectricQuantity,
    required this.vehicleCount,
    required this.recordCount,
    required this.averageConsumption,
    required this.costPerKm,
    required this.breakdown,
  });
}

// ==================== 聚合 ====================

class _VehicleData {
  final Vehicle vehicle;
  final List<EnergyRecord> records;
  final List<Expense> expenses;

  _VehicleData(this.vehicle, this.records, this.expenses);

  String get name => '${vehicle.brand} ${vehicle.model}';

  /// 记录里程 = max - min（少于 2 条为 0）
  double get distance {
    if (records.length < 2) return 0;
    final odo = records.map((r) => r.odometer).toList()..sort();
    final d = odo.last - odo.first;
    return d > 0 ? d : 0;
  }

  double get energyCost =>
      records.fold<double>(0, (s, r) => s + r.amount);

  double get expenseCost =>
      expenses.fold<double>(0, (s, e) => s + e.amount);

  double get totalCost => energyCost + expenseCost;

  List<EnergyRecord> ofType(String type) {
    final list = records.where((r) => r.energyType == type).toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.odometer.compareTo(b.odometer);
      });
    return list;
  }
}

/// 一次性把所有车的记录读出来，供下面各 provider 复用
final _allVehicleDataProvider = FutureProvider<List<_VehicleData>>((ref) async {
  final db = ref.watch(databaseProvider);
  final vehicles = await db.getAllVehicles();

  final result = <_VehicleData>[];
  for (final v in vehicles) {
    final records = await db.getEnergyRecordsForVehicle(v.id);
    final expenses = await db.getExpensesForVehicle(v.id);
    result.add(_VehicleData(v, records, expenses));
  }
  return result;
});

// ==================== 总览 ====================

final overviewStatsProvider = FutureProvider<OverviewStats?>((ref) async {
  final data = await ref.watch(_allVehicleDataProvider.future);
  if (data.isEmpty) return null;

  double fuelCost = 0;
  double electricCost = 0;
  double maintenanceCost = 0;
  double otherCost = 0;
  double totalDistance = 0;
  double fuelQty = 0;
  double electricQty = 0;
  int recordCount = 0;

  for (final v in data) {
    for (final r in v.records) {
      recordCount++;
      if (r.energyType == EnergyTypes.electric) {
        electricCost += r.amount;
        electricQty += r.quantity;
      } else {
        fuelCost += r.amount;
        fuelQty += r.quantity;
      }
    }
    for (final e in v.expenses) {
      if (e.kind == ExpenseKinds.maintenance) {
        maintenanceCost += e.amount;
      } else {
        otherCost += e.amount;
      }
    }
    totalDistance += v.distance;
  }

  final breakdown = CostBreakdown(
    fuel: fuelCost,
    electric: electricCost,
    maintenance: maintenanceCost,
    other: otherCost,
  );

  // 跨车加权油耗：总油量 ÷ 总里程（只算有里程的车）
  double distanceWithFuel = 0;
  double fuelForConsumption = 0;
  for (final v in data) {
    final fuel = v.ofType(EnergyTypes.gasoline);
    if (fuel.length < 2) continue;
    final c = weightedConsumption(fuel, useLightAnchor: false);
    final d = v.distance;
    if (c != null && d > 0) {
      distanceWithFuel += d;
      fuelForConsumption += d * c / 100;
    }
  }

  final avgConsumption = distanceWithFuel > 0
      ? fuelForConsumption / distanceWithFuel * 100
      : null;

  final totalCost = breakdown.total;

  return OverviewStats(
    totalCost: totalCost,
    energyCost: fuelCost + electricCost,
    expenseCost: maintenanceCost + otherCost,
    totalDistance: totalDistance,
    totalFuelQuantity: fuelQty,
    totalElectricQuantity: electricQty,
    vehicleCount: data.length,
    recordCount: recordCount,
    averageConsumption: avgConsumption,
    costPerKm: totalDistance > 0 ? totalCost / totalDistance : null,
    breakdown: breakdown,
  );
});

// ==================== 月度 ====================

final overviewMonthlyProvider =
    FutureProvider<List<MonthlyPoint>>((ref) async {
  final data = await ref.watch(_allVehicleDataProvider.future);
  if (data.isEmpty) return [];

  final Map<String, double> costMap = {};
  // 每月每车的里程区间
  final Map<String, Map<int, List<double>>> odoMap = {};

  for (final v in data) {
    for (final r in v.records) {
      final d = DateTime.fromMillisecondsSinceEpoch(r.date);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      costMap[key] = (costMap[key] ?? 0) + r.amount;
      odoMap.putIfAbsent(key, () => {}).putIfAbsent(v.vehicle.id, () => [])
          .add(r.odometer);
    }
    for (final e in v.expenses) {
      final d = DateTime.fromMillisecondsSinceEpoch(e.date);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      costMap[key] = (costMap[key] ?? 0) + e.amount;
    }
  }

  final keys = costMap.keys.toList()..sort();

  final result = <MonthlyPoint>[];
  for (final key in keys) {
    double dist = 0;
    bool known = false;
    final perVehicle = odoMap[key] ?? {};
    perVehicle.forEach((_, list) {
      if (list.length >= 2) {
        final sorted = list.toList()..sort();
        final d = sorted.last - sorted.first;
        if (d > 0) {
          dist += d;
          known = true;
        }
      }
    });

    result.add(MonthlyPoint(
      yearMonth: key,
      cost: costMap[key] ?? 0,
      distance: dist,
      distanceKnown: known,
    ));
  }

  // 只保留最近 12 个月
  if (result.length > 12) {
    return result.sublist(result.length - 12);
  }
  return result;
});

// ==================== 年度 ====================

final overviewYearlyProvider = FutureProvider<List<YearlyPoint>>((ref) async {
  final data = await ref.watch(_allVehicleDataProvider.future);
  if (data.isEmpty) return [];

  final Map<int, double> costMap = {};
  final Map<int, Map<int, List<double>>> odoMap = {};
  final Map<int, double> qtyMap = {};

  for (final v in data) {
    for (final r in v.records) {
      final year = DateTime.fromMillisecondsSinceEpoch(r.date).year;
      costMap[year] = (costMap[year] ?? 0) + r.amount;
      qtyMap[year] = (qtyMap[year] ?? 0) + r.quantity;
      odoMap.putIfAbsent(year, () => {}).putIfAbsent(v.vehicle.id, () => [])
          .add(r.odometer);
    }
    for (final e in v.expenses) {
      final year = DateTime.fromMillisecondsSinceEpoch(e.date).year;
      costMap[year] = (costMap[year] ?? 0) + e.amount;
    }
  }

  final years = costMap.keys.toList()..sort();

  return [
    for (final year in years)
      YearlyPoint(
        year: year,
        cost: costMap[year] ?? 0,
        distance: (odoMap[year] ?? {}).entries.fold<double>(0, (s, entry) {
          final list = entry.value;
          if (list.length < 2) return s;
          final sorted = list.toList()..sort();
          final d = sorted.last - sorted.first;
          return s + (d > 0 ? d : 0);
        }),
        energyQuantity: qtyMap[year] ?? 0,
      )
  ];
});

// ==================== 车辆对比 ====================

final vehicleComparisonProvider =
    FutureProvider<List<VehicleComparison>>((ref) async {
  final data = await ref.watch(_allVehicleDataProvider.future);
  if (data.isEmpty) return [];

  final list = <VehicleComparison>[];
  for (final v in data) {
    final fuel = v.ofType(EnergyTypes.gasoline);
    final electric = v.ofType(EnergyTypes.electric);

    double? consumption;
    if (fuel.length >= 2) {
      consumption = weightedConsumption(fuel, useLightAnchor: false);
    }
    if (consumption == null && electric.length >= 2) {
      consumption = weightedConsumption(electric, useLightAnchor: false);
    }

    list.add(VehicleComparison(
      vehicleId: v.vehicle.id,
      name: v.name,
      energyType: v.vehicle.energyType,
      distance: v.distance,
      totalCost: v.totalCost,
      averageConsumption: consumption,
      costPerKm: v.distance > 0 ? v.totalCost / v.distance : null,
      recordCount: v.records.length,
      expenseCount: v.expenses.length,
    ));
  }

  // 有每公里成本的排前面，按从低到高（越省越前）
  list.sort((a, b) {
    final ca = a.costPerKm;
    final cb = b.costPerKm;
    if (ca == null && cb == null) return 0;
    if (ca == null) return 1;
    if (cb == null) return -1;
    return ca.compareTo(cb);
  });

  return list;
});
