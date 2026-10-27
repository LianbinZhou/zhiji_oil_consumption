import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/vehicle.dart' as model;
import '../../../data/models/fuel_record.dart' as model_record;
import '../../vehicles/providers/vehicles_provider.dart';
import '../../records/providers/records_provider.dart';
import '../../statistics/providers/statistics_provider.dart'
    show weightedConsumption, consumptionDetail;
import '../../../data/database/tables.dart' show EnergyTypes;

class VehicleOverview {
  final model.Vehicle vehicle;
  final DateTime? lastFuelDate;
  final double? lastOdometer;
  final double? recentFuelConsumption;
  final double monthlyCost;
  final int totalRecords;

  VehicleOverview({
    required this.vehicle,
    this.lastFuelDate,
    this.lastOdometer,
    this.recentFuelConsumption,
    required this.monthlyCost,
    required this.totalRecords,
  });
}

class DashboardSummary {
  final int totalVehicles;
  final double monthlyTotalCost;
  final double monthlyTotalDistance;
  final double? averageFuelConsumption;
  final int monthlyRecordCount;

  DashboardSummary({
    required this.totalVehicles,
    required this.monthlyTotalCost,
    required this.monthlyTotalDistance,
    required this.averageFuelConsumption,
    required this.monthlyRecordCount,
  });
}

String _ymOf(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  return '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

model_record.FuelRecordModel _convertFuelRecord(EnergyRecord data) {
  return model_record.FuelRecordModel(
    id: data.id,
    vehicleId: data.vehicleId,
    date: DateTime.fromMillisecondsSinceEpoch(data.date),
    fuelAmount: data.quantity,
    totalPrice: data.amount,
    pricePerLiter: data.unitPrice,
    odometer: data.odometer,
    isFullTank: data.isFull,
    isLightOn: data.isLightOn,
    energyType: data.energyType,
    chargeMethod: data.chargeMethod,
    fuelType: data.fuelType,
    stationName: data.stationName,
    notes: data.notes,
    createdAt: DateTime.fromMillisecondsSinceEpoch(data.createdAt),
  );
}

model.Vehicle _convertVehicle(Vehicle data) {
  return model.Vehicle(
    id: data.id,
    brand: data.brand,
    model: data.model,
    licensePlate: data.licensePlate,
    color: data.color,
    notes: data.notes,
    vehicleType: data.vehicleType,
    energyType: data.energyType,
    isDefault: data.isDefault,
    createdAt: DateTime.fromMillisecondsSinceEpoch(data.createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(data.updatedAt),
  );
}

/// 首页当前选中的年月（默认当月）
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final dashboardSummaryProvider =
    FutureProvider.family<DashboardSummary?, DateTime>((ref, month) async {
  try {
    // 记录变化时重算（这个 provider 是一次性 FutureProvider，不 watch 就用旧值）
    ref.watch(energyRecordsVersionProvider);

    final database = ref.watch(databaseProvider);
    final vehiclesNative = await database.getAllVehicles();

    if (vehiclesNative.isEmpty) {
      return null;
    }

    final currentYearMonth =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';

    double monthlyTotalCost = 0;
    double monthlyTotalDistance = 0;
    int monthlyRecordCount = 0;
    // 跨车加权用的累加器（MI1：统一为总油量 ÷ 总里程）
    double totalFuelQuantityForConsumption = 0;
    double totalDistanceForConsumption = 0;

    for (final vehicle in vehiclesNative) {
      final v = _convertVehicle(vehicle);
      List<EnergyRecord> recordsNative = [];
      try {
        recordsNative = await database.getEnergyRecordsForVehicle(v.id);
      } catch (_) {
        recordsNative = [];
      }
      final records =
          recordsNative.map(_convertFuelRecord).toList();

      if (records.isEmpty) continue;

      for (final record in records) {
        final recordYearMonth = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
        if (recordYearMonth == currentYearMonth) {
          monthlyTotalCost += record.totalPrice;
          monthlyRecordCount++;
        }
      }

      final thisMonthRecords = records.where((r) {
        final rym = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}';
        return rym == currentYearMonth;
      }).toList()..sort((a, b) => a.date.compareTo(b.date));

      if (thisMonthRecords.length >= 2) {
        final distance = thisMonthRecords.last.odometer - thisMonthRecords.first.odometer;
        if (distance > 0) {
          monthlyTotalDistance += distance;
        }
      }

      // 口径统一：油耗也只算「所选月份」的，不能拿全时段平均冒充当月
      // （和统计页同一个函数：区间求和 + 加权）
      final monthFuel = recordsNative
          .where((r) =>
              r.energyType == EnergyTypes.gasoline &&
              _ymOf(r.date) == currentYearMonth)
          .toList()
        ..sort((a, b) {
          final c = a.date.compareTo(b.date);
          return c != 0 ? c : a.odometer.compareTo(b.odometer);
        });
      final detail = consumptionDetail(monthFuel, useLightAnchor: false) ??
          consumptionDetail(monthFuel, useLightAnchor: true);
      if (detail != null) {
        totalFuelQuantityForConsumption += detail.quantity;
        totalDistanceForConsumption += detail.distance;
      }
    }

    // 跨车平均必须是「总油量 ÷ 总里程」，不能把各车平均值再平均
    // （否则跑得少的车和跑得多的车权重相同，结果会偏）
    double? averageFuelConsumption;
    if (totalFuelQuantityForConsumption > 0 &&
        totalDistanceForConsumption > 0) {
      averageFuelConsumption =
          totalFuelQuantityForConsumption / totalDistanceForConsumption * 100;
    }

    return DashboardSummary(
      totalVehicles: vehiclesNative.length,
      monthlyTotalCost: monthlyTotalCost,
      monthlyTotalDistance: monthlyTotalDistance,
      averageFuelConsumption: averageFuelConsumption,
      monthlyRecordCount: monthlyRecordCount,
    );
  } catch (e, stack) {
    throw Exception('加载仪表盘数据失败: $e\n$stack');
  }
});

final vehicleOverviewsProvider = FutureProvider<List<VehicleOverview>>((ref) async {
  try {
    // 监听车辆列表的变化：新增/删除车辆后自动重算
    // （不 watch 的话这个 FutureProvider 只查一次，加完车首页要退出重进才显示）
    ref.watch(vehiclesStreamProvider);
    // 记录变化时也重算（每辆车的最近记录/总里程/平均油耗都依赖它）
    ref.watch(energyRecordsVersionProvider);

    final database = ref.watch(databaseProvider);
    final vehiclesNative = await database.getAllVehicles();

    if (vehiclesNative.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    final currentYearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final overviews = <VehicleOverview>[];

    for (final vehicle in vehiclesNative) {
      final v = _convertVehicle(vehicle);
      List<EnergyRecord> recordsNative = [];
      try {
        recordsNative = await database.getEnergyRecordsForVehicle(v.id);
      } catch (_) {
        recordsNative = [];
      }
      final records =
          recordsNative.map(_convertFuelRecord).toList();

      if (records.isEmpty) {
        overviews.add(VehicleOverview(
          vehicle: v,
          monthlyCost: 0,
          totalRecords: 0,
        ));
        continue;
      }

      final sortedRecords = List<model_record.FuelRecordModel>.from(records)
        ..sort((a, b) => b.date.compareTo(a.date));

      final lastFuelDate = sortedRecords.first.date;
      final lastOdometer = sortedRecords.first.odometer;

      // 与统计页同一个函数（区间求和 + 加权平均）
      double? recentFuelConsumption;
      final fuelOnly = recordsNative
          .where((r) => r.energyType == EnergyTypes.gasoline)
          .toList()
        ..sort((a, b) {
          final c = a.date.compareTo(b.date);
          return c != 0 ? c : a.odometer.compareTo(b.odometer);
        });
      recentFuelConsumption =
          weightedConsumption(fuelOnly, useLightAnchor: false);
      recentFuelConsumption ??=
          weightedConsumption(fuelOnly, useLightAnchor: true);

      double monthlyCost = 0;
      for (final record in records) {
        final recordYearMonth = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
        if (recordYearMonth == currentYearMonth) {
          monthlyCost += record.totalPrice;
        }
      }

      overviews.add(VehicleOverview(
        vehicle: v,
        lastFuelDate: lastFuelDate,
        lastOdometer: lastOdometer,
        recentFuelConsumption: recentFuelConsumption,
        monthlyCost: monthlyCost,
        totalRecords: records.length,
      ));
    }

    return overviews;
  } catch (e, stack) {
    throw Exception('加载车辆概览失败: $e\n$stack');
  }
});