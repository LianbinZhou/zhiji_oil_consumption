import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/fuel_record.dart' as model;
import '../../../data/database/app_database.dart';
import '../../vehicles/providers/vehicles_provider.dart';

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
  final double totalCost;
  final double totalFuel;
  final double? averageFuelConsumption;
  final double? averageCostPerKm;
  final double maxSingleCost;
  final double minPricePerLiter;
  final double maxPricePerLiter;

  OverallStats({
    required this.totalRecords,
    required this.totalCost,
    required this.totalFuel,
    required this.averageFuelConsumption,
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

model.FuelRecordModel _convertFuelRecord(FuelRecord data) {
  return model.FuelRecordModel(
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

final overallStatsProvider = FutureProvider.family<OverallStats?, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);

  try {
    final recordsNative = await database.getFuelRecordsForVehicleNative(vehicleId);
    if (recordsNative.isEmpty) return null;

    final records = recordsNative.map(_convertFuelRecord).toList();
    final sortedRecords = List<model.FuelRecordModel>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final results = await Future.wait([
      database.getTotalCost(vehicleId),
      database.getTotalFuel(vehicleId),
      database.getMaxSingleCost(vehicleId),
      database.getMinPricePerLiter(vehicleId),
      database.getMaxPricePerLiter(vehicleId),
    ]);

    final totalCost = results[0];
    final totalFuel = results[1];
    final maxSingleCost = results[2];
    final minPricePerLiter = results[3];
    final maxPricePerLiter = results[4];

    double? averageFuelConsumption;
    final fullTankRecords = sortedRecords.where((r) => r.isFullTank).toList();
    if (fullTankRecords.length >= 2) {
      double totalConsumption = 0;
      int count = 0;
      for (int i = 1; i < fullTankRecords.length; i++) {
        final consumption = fullTankRecords[i].calculateFuelConsumption(fullTankRecords[i - 1].odometer);
        if (consumption != null) {
          totalConsumption += consumption;
          count++;
        }
      }
      if (count > 0) averageFuelConsumption = totalConsumption / count;
    }

    double? averageCostPerKm;
    if (sortedRecords.length >= 2) {
      final distance = sortedRecords.last.odometer - sortedRecords.first.odometer;
      if (distance > 0) averageCostPerKm = totalCost / distance;
    }

    return OverallStats(
      totalRecords: sortedRecords.length,
      totalCost: totalCost,
      totalFuel: totalFuel,
      averageFuelConsumption: averageFuelConsumption,
      averageCostPerKm: averageCostPerKm,
      maxSingleCost: maxSingleCost,
      minPricePerLiter: minPricePerLiter,
      maxPricePerLiter: maxPricePerLiter,
    );
  } catch (e) {
    return null;
  }
});

final monthlyStatsProvider = FutureProvider.family<List<MonthlyStats>, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);

  try {
    final recordsNative = await database.getFuelRecordsForVehicleNative(vehicleId);
    if (recordsNative.isEmpty) return [];

    final records = recordsNative.map(_convertFuelRecord).toList();
    final Map<String, List<model.FuelRecordModel>> monthlyGroups = {};

    for (final record in records) {
      final yearMonth = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      monthlyGroups.putIfAbsent(yearMonth, () => []).add(record);
    }

    final monthlyStatsList = <MonthlyStats>[];

    for (final entry in monthlyGroups.entries) {
      final yearMonth = entry.key;
      final monthRecords = entry.value;
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final results = await Future.wait([
        database.getMonthlyTotalCost(vehicleId, year, month),
        database.getMonthlyTotalFuel(vehicleId, year, month),
        database.getMonthlyRecordCount(vehicleId, year, month),
      ]);

      final totalCost = results[0] as double;
      final totalFuel = results[1] as double;
      final recordCount = results[2] as int;

      double? averageFuelConsumption;
      final sortedMonthRecords = List<model.FuelRecordModel>.from(monthRecords)
        ..sort((a, b) => a.date.compareTo(b.date));
      final fullTankMonthRecords = sortedMonthRecords.where((r) => r.isFullTank).toList();
      if (fullTankMonthRecords.length >= 2) {
        double totalConsumption = 0;
        int count = 0;
        for (int i = 1; i < fullTankMonthRecords.length; i++) {
          final consumption = fullTankMonthRecords[i].calculateFuelConsumption(fullTankMonthRecords[i - 1].odometer);
          if (consumption != null) {
            totalConsumption += consumption;
            count++;
          }
        }
        if (count > 0) averageFuelConsumption = totalConsumption / count;
      }

      monthlyStatsList.add(MonthlyStats(
        yearMonth: yearMonth,
        totalCost: totalCost,
        totalFuel: totalFuel,
        averageFuelConsumption: averageFuelConsumption,
        recordCount: recordCount,
      ));
    }

    monthlyStatsList.sort((a, b) => b.yearMonth.compareTo(a.yearMonth));
    return monthlyStatsList.take(6).toList();
  } catch (e) {
    return [];
  }
});

final costPieChartDataProvider = Provider.family<List<PieChartDataItem>, int>((ref, vehicleId) {
  final monthlyStats = ref.watch(monthlyStatsProvider(vehicleId));

  return monthlyStats.when(
    data: (stats) {
      if (stats.isEmpty) return [];
      final pieDataItems = <PieChartDataItem>[];
      for (int i = 0; i < stats.length; i++) {
        if (stats[i].totalCost > 0) {
          pieDataItems.add(PieChartDataItem(
            name: _formatMonth(stats[i].yearMonth),
            value: stats[i].totalCost,
            colorIndex: i,
          ));
        }
      }
      return pieDataItems;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

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

final yearlyStatsProvider = FutureProvider.family<List<YearlyStats>, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);

  try {
    final recordsNative = await database.getFuelRecordsForVehicleNative(vehicleId);
    if (recordsNative.isEmpty) return [];

    final records = recordsNative.map(_convertFuelRecord).toList();
    final sortedRecords = List<model.FuelRecordModel>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final years = await database.getRecordYears(vehicleId);
    final yearlyStatsList = <YearlyStats>[];

    for (final year in years) {
      final yearRecords = sortedRecords.where((r) => r.date.year == year).toList();

      final totalCost = await database.getYearlyTotalCost(vehicleId, year);
      final totalFuel = await database.getYearlyTotalFuel(vehicleId, year);
      final recordCount = await database.getYearlyRecordCount(vehicleId, year);

      double totalDistance = 0;
      if (yearRecords.length >= 2) {
        final sorted = List<model.FuelRecordModel>.from(yearRecords)
          ..sort((a, b) => a.date.compareTo(b.date));
        final distance = sorted.last.odometer - sorted.first.odometer;
        if (distance > 0) totalDistance = distance;
      }

      double? averageFuelConsumption;
      final fullTankRecords = yearRecords.where((r) => r.isFullTank).toList();
      if (fullTankRecords.length >= 2) {
        double totalConsumption = 0;
        int count = 0;
        for (int i = 1; i < fullTankRecords.length; i++) {
          final consumption = fullTankRecords[i].calculateFuelConsumption(fullTankRecords[i - 1].odometer);
          if (consumption != null) {
            totalConsumption += consumption;
            count++;
          }
        }
        if (count > 0) averageFuelConsumption = totalConsumption / count;
      }

      double? averageCostPerKm;
      if (totalDistance > 0) averageCostPerKm = totalCost / totalDistance;

      yearlyStatsList.add(YearlyStats(
        year: year,
        totalCost: totalCost,
        totalFuel: totalFuel,
        averageFuelConsumption: averageFuelConsumption,
        averageCostPerKm: averageCostPerKm,
        recordCount: recordCount,
        totalDistance: totalDistance,
      ));
    }

    return yearlyStatsList;
  } catch (e) {
    return [];
  }
});

String _formatMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  return '${parts[0]}年${int.parse(parts[1])}月';
}
