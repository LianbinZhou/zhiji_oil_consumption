// 智记能耗 - 车辆数据模型
// 这个文件定义了"车辆"的数据结构

/// 车辆数据类
///
/// 用于存储一辆车的基本信息
/// 使用普通类(而不是data class),方便新手理解
class Vehicle {
  /// 车辆的唯一标识符(ID)
  final int id;

  /// 车辆品牌(如:丰田、本田、大众等)
  final String brand;

  /// 车辆型号(如:卡罗拉、雅阁、帕萨特等)
  final String model;

  /// 车牌号码(可选)
  final String? licensePlate;

  /// 车辆颜色(可选)
  final String? color;

  /// 备注信息(可选)
  final String? notes;

  /// 车辆类型(车身材质类别:轿车、SUV、MPV、面包车、皮卡等)
  final String? vehicleType;

  /// 【v4 新增】能源类型：gasoline(油) / electric(电) / hybrid(混动)
  ///
  /// 决定录入界面显示哪些字段、统计用哪套指标。
  /// 取值与数据库 `vehicles.energy_type` 一致，默认汽油。
  final String energyType;

  /// 是否为默认车辆
  final bool isDefault;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 默认能源类型（与数据库默认值保持一致）
  static const String defaultEnergyType = 'gasoline';

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    this.licensePlate,
    this.color,
    this.notes,
    this.vehicleType,
    this.energyType = defaultEnergyType,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 创建一个副本,但可以修改某些字段
  Vehicle copyWith({
    int? id,
    String? brand,
    String? model,
    String? licensePlate,
    String? color,
    String? notes,
    String? vehicleType,
    String? energyType,
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
      energyType: energyType ?? this.energyType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// 能源类型的中文名
  String get energyTypeLabel {
    switch (energyType) {
      case 'electric':
        return '纯电';
      case 'hybrid':
        return '混动';
      default:
        return '油车';
    }
  }

  /// 是否纯电（纯电车没有"加油"，只有"充电"）
  bool get isElectric => energyType == 'electric';

  /// 是否混动（既有加油也有充电）
  bool get isHybrid => energyType == 'hybrid';

  @override
  String toString() {
    return 'Vehicle(id: $id, brand: $brand, model: $model, '
        'vehicleType: $vehicleType, energyType: $energyType, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Vehicle &&
        other.id == id &&
        other.brand == brand &&
        other.model == model &&
        other.licensePlate == licensePlate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ brand.hashCode ^ model.hashCode;
  }
}
