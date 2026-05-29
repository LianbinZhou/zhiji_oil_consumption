// 智记油耗 - 油耗记录Provider
// 这个文件使用Riverpod管理油耗记录的业务逻辑

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

// 导入数据库和Provider
import '../../../data/database/app_database.dart';
import '../../vehicles/providers/vehicles_provider.dart';
// 导入自定义油耗记录模型
import '../../../data/models/fuel_record.dart' as model;

// ==================== 数据转换辅助函数 ====================

/// 将Drift的FuelRecord转换为自定义model.FuelRecordModel
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

// ==================== 油耗记录列表Provider ====================

/// 指定车辆的油耗记录StreamProvider
/// 
/// [vehicleId] 车辆ID
/// 返回该车辆的所有油耗记录,按日期倒序排列
final recordsStreamProvider = StreamProvider.family<List<model.FuelRecordModel>, int>((ref, vehicleId) {
  final database = ref.watch(databaseProvider);
  
  // 获取Drift原生类型的Stream,然后转换为自定义模型
  return database.watchFuelRecordsForVehicleNative(vehicleId).map((records) {
    return records.map(_convertFuelRecord).toList();
  });
});

// ==================== 最新记录Provider ====================

/// 获取某辆车的最新一条油耗记录
final latestRecordProvider = FutureProvider.family<model.FuelRecordModel?, int>((ref, vehicleId) async {
  final database = ref.watch(databaseProvider);
  final record = await database.getLatestFuelRecord(vehicleId);
  return record != null ? _convertFuelRecord(record) : null;
});

// ==================== 记录操作Provider ====================

/// 油耗记录操作Notifier
class RecordsNotifier extends AutoDisposeNotifier<List<model.FuelRecordModel>> {
  @override
  List<model.FuelRecordModel> build() {
    return [];
  }

  /// 添加一条油耗记录
  Future<void> addRecord({
    required int vehicleId,
    required DateTime date,
    required double fuelAmount,
    required double totalPrice,
    required double pricePerLiter,
    required double odometer,
    required bool isFullTank,
    bool isLightOn = false,
    String? fuelType,
    String? stationName,
    String? notes,
  }) async {
    final database = ref.read(databaseProvider);
    
    final record = FuelRecordsCompanion(
      vehicleId: drift.Value(vehicleId),
      date: drift.Value(date.millisecondsSinceEpoch),
      fuelAmount: drift.Value(fuelAmount),
      totalPrice: drift.Value(totalPrice),
      pricePerLiter: drift.Value(pricePerLiter),
      odometer: drift.Value(odometer),
      isFullTank: drift.Value(isFullTank),
      isLightOn: drift.Value(isLightOn),
      fuelType: drift.Value(fuelType),
      stationName: drift.Value(stationName),
      notes: drift.Value(notes),
      createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    );
    
    await database.insertFuelRecord(record);
  }

  /// 更新油耗记录
  Future<void> updateRecord({
    required int id,
    required int vehicleId,
    required DateTime date,
    required double fuelAmount,
    required double totalPrice,
    required double pricePerLiter,
    required double odometer,
    required bool isFullTank,
    bool isLightOn = false,
    String? fuelType,
    String? stationName,
    String? notes,
  }) async {
    final database = ref.read(databaseProvider);
    
    final record = FuelRecordsCompanion(
      id: drift.Value(id),
      vehicleId: drift.Value(vehicleId),
      date: drift.Value(date.millisecondsSinceEpoch),
      fuelAmount: drift.Value(fuelAmount),
      totalPrice: drift.Value(totalPrice),
      pricePerLiter: drift.Value(pricePerLiter),
      odometer: drift.Value(odometer),
      isFullTank: drift.Value(isFullTank),
      isLightOn: drift.Value(isLightOn),
      fuelType: drift.Value(fuelType),
      stationName: drift.Value(stationName),
      notes: drift.Value(notes),
      createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
    );
    
    await database.updateFuelRecord(record);
  }

  /// 删除油耗记录
  Future<void> deleteRecord(int id) async {
    final database = ref.read(databaseProvider);
    
    final success = await database.deleteFuelRecord(id);
    
    if (!success) {
      throw Exception('删除失败');
    }
  }
}

/// 油耗记录操作Provider
final recordsNotifierProvider = NotifierProvider.autoDispose<RecordsNotifier, List<model.FuelRecordModel>>(
  RecordsNotifier.new,
);
