// 智记能耗 - 统计 Provider
//
// 2026-10-25 重构要点（项 2 + 项 4）：
//   1. 能耗算法改为「区间求和」：锚点之间的所有加油量都计入，不再只取单条
//      （旧实现遇到"中途没加满"会把那次油量丢掉，导致油耗被低估）
//   2. 平均油耗改为「加权平均」= 总能耗 ÷ 总里程
//      （旧实现是各段比值的算术平均，短途权重大，结果偏大）
//   3. 统一按 energyType 过滤：加油与充电各自配对，绝不跨类型
//
// 口径（与功能规格 §5 一致）：
//   总里程 = 最后一个锚点.odometer − 第一个锚点.odometer
//   总能耗 = 该区间内同能源类型的 quantity 之和（含未加满）
//   能耗   = 总能耗 / 总里程 × 100

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../vehicles/providers/vehicles_provider.dart';

// ==================== 数据类 ====================

class MonthlyStats {
  final String yearMonth;
  final double totalCost;
  final double totalFuel;
  final double? averageFuelConsumption;

  final int recordCount;

  MonthlyStats({
    required this.yearMonth,
    required this.totalCost,
    required this.totalFuel,
    required this.averageFuelConsumption,
    required this.recordCount,
  });
}

class OverallStats {
  final int totalRecords;

  /// 能源花费（加油 + 充电）
  final double totalCost;

  /// 保养 + 费用（其他支出）
  final double expenseCost;

  /// 用车总花费 = totalCost + expenseCost
  final double totalCostAll;

  final double totalFuel;
  final double? averageFuelConsumption;

  /// 平均电耗 kWh/100km（纯电或混动才有值）
  final double? avgElectricConsumption;

  /// 油耗用的是哪种锚点：'full' 加满法 / 'light' 亮灯法 / null 数据不足
  final String? consumptionMethod;

  final double? averageCostPerKm;
  final double maxSingleCost;
  final double minPricePerLiter;
  final double maxPricePerLiter;

  OverallStats({
    required this.totalRecords,
    required this.totalCost,
    required this.expenseCost,
    required this.totalCostAll,
    required this.totalFuel,
    required this.averageFuelConsumption,
    this.avgElectricConsumption,
    this.consumptionMethod,
    required this.averageCostPerKm,
    required this.maxSingleCost,
    required this.minPricePerLiter,
    required this.maxPricePerLiter,
  });
}

class PieChartDataItem {
  final String name;
  final double value;
  final int colorIndex;

  PieChartDataItem({
    required this.name,
    required this.value,
    required this.colorIndex,
  });
}

class YearlyStats {
  final int year;
  final double totalCost;
  final double totalFuel;
  final double? averageFuelConsumption;
  final double? averageCostPerKm;
  final int recordCount;
  final double totalDistance;

  YearlyStats({
    required this.year,
    required this.totalCost,
    required this.totalFuel,
    required this.averageFuelConsumption,
    required this.averageCostPerKm,
    required this.recordCount,
    required this.totalDistance,
  });
}

// ==================== 核心算法 ====================

/// 按锚点区间求加权能耗（L/100km 或 kWh/100km）
///
/// [sorted] 必须是同一能源类型、且已按 (date, odometer, id) 升序排列
/// [useLightAnchor] true = 用"亮灯"做锚点，false = 用"加满/充满"
///
/// 返回 null 表示数据不足（锚点少于 2 个，或里程没有增加）
/// 锚点区间的「油量 + 里程」明细
///
/// 这是全 App 唯一的能耗计算入口，三种用法都由它派生：
///   - 整体加权：`weightedConsumption`
///   - 逐段明细：`intervalConsumptionById`
///   - 跨车汇总：调用方累加 quantity / distance 后再相除（保证加权口径一致）
({double quantity, double distance})? consumptionDetail(
  List<EnergyRecord> sorted, {
  required bool useLightAnchor,
}) {
  if (sorted.length < 2) return null;

  final anchors =
      sorted.where((r) => useLightAnchor ? r.isLightOn : r.isFull).toList();
  if (anchors.length < 2) return null;

  final first = anchors.first;
  final last = anchors.last;
  final distance = last.odometer - first.odometer;
  if (distance <= 0) return null;

  final firstIdx = sorted.indexOf(first);
  final lastIdx = sorted.indexOf(last);
  if (lastIdx <= firstIdx) return null;

  double quantity = 0;
  for (var i = firstIdx + 1; i <= lastIdx; i++) {
    quantity += sorted[i].quantity;
  }
  return (quantity: quantity, distance: distance);
}

/// 加权能耗（L/100km 或 kWh/100km）
///
/// 口径：锚点区间内所有同能源类型的量求和 ÷ 里程差 × 100
/// （包含中途没加满的那次，不会漏算）
double? weightedConsumption(
  List<EnergyRecord> sorted, {
  required bool useLightAnchor,
}) {
  final d = consumptionDetail(sorted, useLightAnchor: useLightAnchor);
  if (d == null || d.distance <= 0) return null;
  return d.quantity / d.distance * 100;
}

/// 取某辆车的单向记录（按能源类型过滤，升序）
List<EnergyRecord> _ofType(List<EnergyRecord> records, String energyType) {
  return records.where((r) => r.energyType == energyType).toList()
    ..sort((a, b) {
      final c = a.date.compareTo(b.date);
      if (c != 0) return c;
      final o = a.odometer.compareTo(b.odometer);
      if (o != 0) return o;
      return a.id.compareTo(b.id);
    });
}



String _ym(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

// ==================== 总体统计 ====================

final overallStatsProvider =
    FutureProvider.family<OverallStats?, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);

  final records = await database.getEnergyRecordsForVehicle(vehicleId);
  if (records.isEmpty) return null;

  final fuel = _ofType(records, EnergyTypes.gasoline);

  final totalCost = await database.getTotalEnergyCost(vehicleId);
  final totalQuantity =
      await database.getTotalEnergyQuantity(vehicleId, EnergyTypes.gasoline);
  final maxSingleCost = await database.getMaxSingleCost(vehicleId);
  final minPrice =
      await database.getMinUnitPrice(vehicleId, EnergyTypes.gasoline) ?? 0;
  final maxPrice =
      await database.getMaxUnitPrice(vehicleId, EnergyTypes.gasoline) ?? 0;

  // 加权平均油耗：优先加满法，数据不足再退亮灯法；
  // 并把「实际用了哪种」传给界面，避免用户不知道自己在看哪个口径
  final byFull = weightedConsumption(fuel, useLightAnchor: false);
  final byLight = weightedConsumption(fuel, useLightAnchor: true);
  final avgConsumption = byFull ?? byLight;
  final method = byFull != null ? 'full' : (byLight != null ? 'light' : null);

  // 每公里成本：总花费 ÷ 总里程
  double? costPerKm;
  final range = await database.getOdometerRange(vehicleId);
  if (range != null) {
    final distance = range.max - range.min;
    if (distance > 0) costPerKm = totalCost / distance;
  }

  // 电耗（纯电 / 混动的充电记录）
  final electricRecords = _ofType(records, EnergyTypes.electric);
  final avgElec = weightedConsumption(electricRecords, useLightAnchor: false);

  // 保养 + 费用
  final expenseCost = await database.getTotalExpenseCost(vehicleId);

  return OverallStats(
    totalRecords: records.length,
    totalCost: totalCost,
    expenseCost: expenseCost,
    totalCostAll: totalCost + expenseCost,
    totalFuel: totalQuantity,
    averageFuelConsumption: avgConsumption,
    avgElectricConsumption: avgElec,
    consumptionMethod: method,
    averageCostPerKm: costPerKm,
    maxSingleCost: maxSingleCost,
    minPricePerLiter: minPrice,
    maxPricePerLiter: maxPrice,
  );
});

// ==================== 月度统计 ====================

final monthlyStatsProvider =
    FutureProvider.family<List<MonthlyStats>, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);

  final records = await database.getEnergyRecordsForVehicle(vehicleId);
  if (records.isEmpty) return [];

  final fuel = _ofType(records, EnergyTypes.gasoline);

  final Map<String, List<EnergyRecord>> groups = {};
  for (final r in records) {
    groups
        .putIfAbsent(_ym(DateTime.fromMillisecondsSinceEpoch(r.date)), () => [])
        .add(r);
  }

  final result = <MonthlyStats>[];
  for (final entry in groups.entries) {
    final parts = entry.key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    final cost = await database.getMonthlyTotalCost(vehicleId, year, month);
    final quantity = await database.getMonthlyTotalQuantity(
        vehicleId, year, month, EnergyTypes.gasoline);
    final count = await database.getMonthlyRecordCount(vehicleId, year, month);

    final monthFuel = fuel
        .where((r) =>
            _ym(DateTime.fromMillisecondsSinceEpoch(r.date)) == entry.key)
        .toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.odometer.compareTo(b.odometer);
      });

    double? consumption =
        weightedConsumption(monthFuel, useLightAnchor: false);
    consumption ??= weightedConsumption(monthFuel, useLightAnchor: true);

    result.add(MonthlyStats(
      yearMonth: entry.key,
      totalCost: cost,
      totalFuel: quantity,
      averageFuelConsumption: consumption,
      recordCount: count,
    ));
  }

  result.sort((a, b) => b.yearMonth.compareTo(a.yearMonth));
  return result.take(6).toList();
});

// ==================== 饼图数据 ====================

final costPieChartDataProvider =
    Provider.family<List<PieChartDataItem>, int>((ref, vehicleId) {
  final monthlyStats = ref.watch(monthlyStatsProvider(vehicleId));

  return monthlyStats.when(
    data: (stats) {
      if (stats.isEmpty) return [];
      final items = <PieChartDataItem>[];
      for (var i = 0; i < stats.length; i++) {
        if (stats[i].totalCost > 0) {
          items.add(PieChartDataItem(
            name: _formatMonth(stats[i].yearMonth),
            value: stats[i].totalCost,
            colorIndex: i,
          ));
        }
      }
      return items;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ==================== 年度统计 ====================

final yearlyStatsProvider =
    FutureProvider.family<List<YearlyStats>, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);

  final records = await database.getEnergyRecordsForVehicle(vehicleId);
  if (records.isEmpty) return [];

  final fuel = _ofType(records, EnergyTypes.gasoline);
  final years = await database.getRecordYears(vehicleId);
  final result = <YearlyStats>[];

  for (final year in years) {
    final cost = await database.getYearlyTotalCost(vehicleId, year);
    final quantity = await database.getYearlyTotalQuantity(
        vehicleId, year, EnergyTypes.gasoline);
    final count = await database.getYearlyRecordCount(vehicleId, year);

    final yearFuel = fuel
        .where((r) => DateTime.fromMillisecondsSinceEpoch(r.date).year == year)
        .toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.odometer.compareTo(b.odometer);
      });

    double distance = 0;
    if (yearFuel.length >= 2) {
      final d = yearFuel.last.odometer - yearFuel.first.odometer;
      if (d > 0) distance = d;
    }

    double? consumption = weightedConsumption(yearFuel, useLightAnchor: false);
    consumption ??= weightedConsumption(yearFuel, useLightAnchor: true);

    result.add(YearlyStats(
      year: year,
      totalCost: cost,
      totalFuel: quantity,
      averageFuelConsumption: consumption,
      averageCostPerKm: distance > 0 ? cost / distance : null,
      recordCount: count,
      totalDistance: distance,
    ));
  }

  return result;
});

String _formatMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  return '${parts[0]}年${int.parse(parts[1])}月';
}
