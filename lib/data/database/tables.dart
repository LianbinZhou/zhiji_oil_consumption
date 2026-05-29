// 智记油耗 - Drift数据库表定义
// 这个文件定义了应用中所有的数据表结构
// Drift会根据这些定义自动生成类型安全的数据库操作代码

import 'package:drift/drift.dart';

// ==================== 车辆表 ====================

/// 车辆数据表
/// 
/// 这个类定义了"vehicles"表的结构
/// 每一行代表一辆车的信息
class Vehicles extends Table {
  /// 主键ID
  /// autoIncrement()表示ID会自动递增,不需要手动设置
  IntColumn get id => integer().autoIncrement()();
  
  /// 车辆品牌(必填)
  /// text()表示这是文本类型
  /// minLength(1)确保品牌名称不能为空
  TextColumn get brand => text().withLength(min: 1, max: 50)();
  
  /// 车辆型号(必填)
  TextColumn get model => text().withLength(min: 1, max: 50)();
  
  /// 车牌号码(可选)
  /// nullable()表示这个字段可以为空
  TextColumn get licensePlate => text().withLength(min: 1, max: 20).nullable()();
  
  /// 车辆颜色(可选)
  TextColumn get color => text().withLength(min: 1, max: 20).nullable()();
  
  /// 备注信息(可选)
  /// longerText()表示可以存储更长的文本
  TextColumn get notes => text().nullable()();
  
  /// 车辆类型(可选,如:轿车、SUV、MPV等)
  TextColumn get vehicleType => text().withLength(min: 1, max: 20).nullable()();
  
  /// 是否为默认车辆
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  
  /// 创建时间
  /// 存储为整数(毫秒时间戳)
  IntColumn get createdAt => integer()();
  
  /// 更新时间
  IntColumn get updatedAt => integer()();
}

// ==================== 油耗记录表(预留,后续实现) ====================

/// 油耗记录表
/// 
/// 这个表用于存储每次加油的记录
class FuelRecords extends Table {
  /// 记录ID
  IntColumn get id => integer().autoIncrement()();
  
  /// 关联的车辆ID
  /// references()表示这是一个外键,关联到Vehicles表的id字段
  IntColumn get vehicleId => integer().references(Vehicles, #id)();
  
  /// 加油日期
  IntColumn get date => integer()();
  
  /// 加油量(升)
  RealColumn get fuelAmount => real()();
  
  /// 总金额(元)
  RealColumn get totalPrice => real()();
  
  /// 单价(元/升)
  RealColumn get pricePerLiter => real()();
  
  /// 当前里程数(公里)
  RealColumn get odometer => real()();
  
  /// 是否加满油
  BoolColumn get isFullTank => boolean().withDefault(const Constant(false))();
  
  /// 是否油灯亮了（亮灯法计算油耗）
  BoolColumn get isLightOn => boolean().withDefault(const Constant(false))();
  
  /// 油品类型(92#/95#/98#/0#柴油等)
  TextColumn get fuelType => text().withLength(max: 10).nullable()();
  
  /// 加油站名称
  TextColumn get stationName => text().withLength(max: 50).nullable()();
  
  /// 备注
  TextColumn get notes => text().nullable()();
  
  /// 创建时间
  IntColumn get createdAt => integer()();
}
