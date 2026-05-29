// 智记油耗 - 车辆管理Provider
// 这个文件使用Riverpod管理车辆数据的业务逻辑

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

// 导入数据库(包含Drift生成的Vehicle类)
import '../../../data/database/app_database.dart';
// 导入自定义车辆模型,使用别名避免命名冲突
import '../../../data/models/vehicle.dart' as model;

// ==================== 数据库Provider ====================

/// 数据库单例Provider
/// 
/// 这个Provider提供全局唯一的数据库实例
/// 其他Provider可以通过ref.watch(databaseProvider)来获取数据库
final databaseProvider = Provider<AppDatabase>((ref) {
  return getDatabaseInstance();
});

// ==================== 数据转换辅助函数 ====================

/// 将Drift的Vehicle转换为自定义model.Vehicle
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

// ==================== 车辆列表Provider ====================

/// 车辆列表StreamProvider
/// 
/// StreamProvider会自动监听数据变化并更新UI
final vehiclesStreamProvider = StreamProvider<List<model.Vehicle>>((ref) {
  final database = ref.watch(databaseProvider);
  
  // 获取Drift原生类型的Stream,然后转换为自定义模型
  return database.watchAllVehiclesNative().map((vehicles) {
    return vehicles.map(_convertVehicle).toList();
  });
});

// ==================== 车辆操作Provider ====================

/// 车辆操作Notifier
/// 
/// Notifier用于管理需要执行异步操作的状态
/// 这里提供添加、更新、删除车辆的方法
class VehiclesNotifier extends AutoDisposeNotifier<List<model.Vehicle>> {
  @override
  List<model.Vehicle> build() {
    // 初始状态:空列表
    // 实际数据通过vehiclesStreamProvider获取
    return [];
  }

  /// 添加一辆新车
  /// 
  /// [brand] 车辆品牌(必填)
  /// [modelName] 车辆型号(必填)
  /// [licensePlate] 车牌号码(可选)
  /// [color] 车辆颜色(可选)
  /// [notes] 备注信息(可选)
  Future<void> addVehicle({
    required String brand,
    required String modelName,
    String? licensePlate,
    String? color,
    String? notes,
    String? vehicleType,
  }) async {
    final database = ref.read(databaseProvider);
    
    // 如果是第一辆车,自动设为默认
    final count = await database.getVehicleCount();
    final shouldBeDefault = count == 0;
    
    final now = DateTime.now();
    final vehicle = VehiclesCompanion(
      brand: drift.Value(brand),
      model: drift.Value(modelName),
      licensePlate: drift.Value(licensePlate),
      color: drift.Value(color),
      notes: drift.Value(notes),
      vehicleType: drift.Value(vehicleType),
      isDefault: drift.Value(shouldBeDefault),
      createdAt: drift.Value(now.millisecondsSinceEpoch),
      updatedAt: drift.Value(now.millisecondsSinceEpoch),
    );
    
    await database.insertVehicle(vehicle);
  }

  /// 更新车辆信息
  /// 
  /// [id] 车辆ID
  /// [brand] 新的品牌名称
  /// [modelName] 新的型号
  /// [licensePlate] 新的车牌号码
  /// [color] 新的颜色
  /// [notes] 新的备注
  Future<void> updateVehicle({
    required int id,
    required String brand,
    required String modelName,
    String? licensePlate,
    String? color,
    String? notes,
    String? vehicleType,
  }) async {
    final database = ref.read(databaseProvider);
    
    final existingVehicle = await database.getVehicleByIdNative(id);
    if (existingVehicle == null) {
      throw Exception('车辆不存在');
    }
    
    final now = DateTime.now();
    final vehicle = VehiclesCompanion(
      id: drift.Value(id),
      brand: drift.Value(brand),
      model: drift.Value(modelName),
      licensePlate: drift.Value(licensePlate),
      color: drift.Value(color),
      notes: drift.Value(notes),
      vehicleType: drift.Value(vehicleType),
      isDefault: drift.Value(existingVehicle.isDefault),
      createdAt: drift.Value(existingVehicle.createdAt),
      updatedAt: drift.Value(now.millisecondsSinceEpoch),
    );
    
    await database.updateVehicle(vehicle);
  }

  /// 设为默认车辆
  /// 
  /// 将指定车辆设为默认,同时取消其他车辆的默认状态
  Future<void> setDefaultVehicle(int vehicleId) async {
    final database = ref.read(databaseProvider);
    
    // 先取消所有车辆的默认状态
    final allVehicles = await database.getAllVehiclesNative();
    for (final v in allVehicles) {
      if (v.isDefault) {
        await database.updateVehicle(VehiclesCompanion(
          id: drift.Value(v.id),
          isDefault: const drift.Value(false),
          brand: drift.Value(v.brand),
          model: drift.Value(v.model),
          licensePlate: drift.Value(v.licensePlate),
          color: drift.Value(v.color),
          notes: drift.Value(v.notes),
          vehicleType: drift.Value(v.vehicleType),
          createdAt: drift.Value(v.createdAt),
          updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
        ));
      }
    }
    
    // 将指定车辆设为默认
    final targetVehicle = await database.getVehicleByIdNative(vehicleId);
    if (targetVehicle != null) {
      await database.updateVehicle(VehiclesCompanion(
        id: drift.Value(vehicleId),
        isDefault: const drift.Value(true),
        brand: drift.Value(targetVehicle.brand),
        model: drift.Value(targetVehicle.model),
        licensePlate: drift.Value(targetVehicle.licensePlate),
        color: drift.Value(targetVehicle.color),
        notes: drift.Value(targetVehicle.notes),
        vehicleType: drift.Value(targetVehicle.vehicleType),
        createdAt: drift.Value(targetVehicle.createdAt),
        updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ));
    }
  }

  /// 删除车辆
  /// 
  /// [id] 要删除的车辆ID
  Future<void> deleteVehicle(int id) async {
    final database = ref.read(databaseProvider);
    
    // 从数据库中删除
    final success = await database.deleteVehicle(id);
    
    if (!success) {
      throw Exception('删除失败');
    }
  }
}

/// 车辆操作Provider
/// 
/// 使用这个Provider来调用添加、更新、删除方法
/// 例如: ref.read(vehiclesNotifierProvider.notifier).addVehicle(...)
final vehiclesNotifierProvider = NotifierProvider.autoDispose<VehiclesNotifier, List<model.Vehicle>>(
  VehiclesNotifier.new,
);

// ==================== 便捷方法Provider ====================

/// 车辆数量Provider
/// 
/// 用于显示"共X辆车"这样的统计信息
final vehicleCountProvider = FutureProvider<int>((ref) async {
  final database = ref.watch(databaseProvider);
  return await database.getVehicleCount();
});
