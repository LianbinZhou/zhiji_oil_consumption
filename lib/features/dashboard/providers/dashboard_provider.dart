import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../data/database/app_database.dart';
import '../../../data/models/vehicle.dart' as model;
import '../../../data/models/fuel_record.dart' as model_record;
import '../../vehicles/providers/vehicles_provider.dart';

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

model_record.FuelRecordModel _convertFuelRecord(FuelRecord data) {
  return model_record.FuelRecordModel(
    id: data.id,
    vehicleId: data.vehicleId,
    date: DateTime.fromMillisecondsSinceEpoch(data.date),
    fuelAmount: data.fuelAmount,
    totalPrice: data.totalPrice,
    pricePerLiter: data.pricePerLiter,
    odometer: data.odometer,
    isFullTank: data.isFullTank,
    isLightOn: data.isLightOn,
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
    isDefault: data.isDefault,
    createdAt: DateTime.fromMillisecondsSinceEpoch(data.createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(data.updatedAt),
  );
}

final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  try {
    final database = ref.watch(databaseProvider);
    final vehiclesNative = await database.getAllVehiclesNative();

    if (vehiclesNative.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final currentYearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    double monthlyTotalCost = 0;
    double monthlyTotalDistance = 0;
    int monthlyRecordCount = 0;
    final List<double> fuelConsumptions = [];

    for (final vehicle in vehiclesNative) {
      final v = _convertVehicle(vehicle);
      List<model_record.FuelRecordModel> records;
      try {
        final recordsNative = await database.getFuelRecordsForVehicleNative(v.id);
        records = recordsNative.map(_convertFuelRecord).toList();
      } catch (_) {
        records = [];
      }

      if (records.isEmpty) continue;

      final sortedRecords = List<model_record.FuelRecordModel>.from(records)
        ..sort((a, b) => b.date.compareTo(a.date));

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

      final fullTankRecords = sortedRecords.where((r) => r.isFullTank).toList();
      if (fullTankRecords.length >= 2) {
        double totalConsumption = 0;
        int count = 0;

        for (int i = 1; i < fullTankRecords.length; i++) {
          final current = fullTankRecords[i];
          final previous = fullTankRecords[i - 1];
          final consumption = current.calculateFuelConsumption(previous.odometer);
          if (consumption != null) {
            totalConsumption += consumption;
            count++;
          }
        }

        if (count > 0) {
          fuelConsumptions.add(totalConsumption / count);
        }
      }
    }

    double? averageFuelConsumption;
    if (fuelConsumptions.isNotEmpty) {
      averageFuelConsumption = fuelConsumptions.reduce((a, b) => a + b) / fuelConsumptions.length;
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
    final database = ref.watch(databaseProvider);
    final vehiclesNative = await database.getAllVehiclesNative();

    if (vehiclesNative.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    final currentYearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final overviews = <VehicleOverview>[];

    for (final vehicle in vehiclesNative) {
      final v = _convertVehicle(vehicle);
      List<model_record.FuelRecordModel> records;
      try {
        final recordsNative = await database.getFuelRecordsForVehicleNative(v.id);
        records = recordsNative.map(_convertFuelRecord).toList();
      } catch (_) {
        records = [];
      }

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

      double? recentFuelConsumption;
      final fullTankRecords = sortedRecords.where((r) => r.isFullTank).toList();
      if (fullTankRecords.length >= 2) {
        recentFuelConsumption = fullTankRecords[0].calculateFuelConsumption(
          fullTankRecords[1].odometer,
        );
      }

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