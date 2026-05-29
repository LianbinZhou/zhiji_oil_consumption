// 智记油耗 - 车辆数据模型
// 这个文件定义了"车辆"的数据结构

/// 车辆数据类
/// 
/// 用于存储一辆车的基本信息
/// 使用普通类(而不是data class),方便新手理解
class Vehicle {
  /// 车辆的唯一标识符(ID)
  /// 每辆车都有一个唯一的ID,用于区分不同的车辆
  final int id;
  
  /// 车辆品牌(如:丰田、本田、大众等)
  final String brand;
  
  /// 车辆型号(如:卡罗拉、雅阁、帕萨特等)
  final String model;
  
  /// 车牌号码(可选,用户可以不填)
  final String? licensePlate;
  
  /// 车辆颜色(可选)
  final String? color;
  
  /// 备注信息(可选,用户可以记录其他信息)
  final String? notes;
  
  /// 车辆类型(可选,如:轿车、SUV、MPV、面包车、皮卡等)
  final String? vehicleType;
  
  /// 是否为默认车辆
  /// 默认车辆会在首页显示,方便用户快速记录
  final bool isDefault;
  
  /// 创建时间(记录这辆车是什么时候添加到应用中的)
  final DateTime createdAt;
  
  /// 更新时间(最后一次修改这辆车信息的时间)
  final DateTime updatedAt;

  /// 构造函数
  /// 
  /// 创建一辆新车时,需要提供所有必填参数
  /// [id] 可以传0,数据库会自动分配
  /// [createdAt] 和 [updatedAt] 如果不传,会使用当前时间
  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    this.licensePlate,
    this.color,
    this.notes,
    this.vehicleType,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 创建一个副本,但可以修改某些字段
  /// 
  /// 这个方法用于更新车辆信息时,保持其他字段不变
  /// 例如: vehicle.copyWith(brand: '新品牌') 只会修改品牌,其他字段保持不变
  Vehicle copyWith({
    int? id,
    String? brand,
    String? model,
    String? licensePlate,
    String? color,
    String? notes,
    String? vehicleType,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      vehicleType: vehicleType ?? this.vehicleType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 将车辆对象转换为Map
  /// 
  /// 这个方法用于保存到数据库或传输数据时使用
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'license_plate': licensePlate,
      'color': color,
      'notes': notes,
      'vehicle_type': vehicleType,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch, // 转为毫秒时间戳
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 从Map创建车辆对象
  /// 
  /// 这个方法用于从数据库读取数据时使用
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int,
      brand: map['brand'] as String,
      model: map['model'] as String,
      licensePlate: map['license_plate'] as String?,
      color: map['color'] as String?,
      notes: map['notes'] as String?,
      vehicleType: map['vehicle_type'] as String?,
      isDefault: (map['is_default'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// 重写toString方法,方便调试时打印车辆信息
  @override
  String toString() {
    return 'Vehicle(id: $id, brand: $brand, model: $model, licensePlate: $licensePlate, vehicleType: $vehicleType, isDefault: $isDefault)';
  }

  /// 重写equals方法,用于比较两辆车是否相同
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Vehicle &&
        other.id == id &&
        other.brand == brand &&
        other.model == model &&
        other.licensePlate == licensePlate;
  }

  /// 重写hashCode方法,配合equals使用
  @override
  int get hashCode {
    return id.hashCode ^ brand.hashCode ^ model.hashCode;
  }
}
