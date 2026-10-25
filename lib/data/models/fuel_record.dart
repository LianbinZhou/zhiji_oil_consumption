// 智记能耗 - 油耗记录数据模型
// 这个文件定义了"油耗记录"的数据结构

/// 油耗记录数据类
/// 
/// 用于存储一次加油的完整信息
class FuelRecordModel {
  /// 记录的唯一标识符(ID)
  final int id;
  
  /// 关联的车辆ID
  /// 这条记录属于哪辆车
  final int vehicleId;
  
  /// 加油日期
  final DateTime date;
  
  /// 加油量(升)
  /// 例如:50.5表示加了50.5升油
  final double fuelAmount;
  
  /// 总金额(元)
  /// 例如:350.00表示花了350元
  final double totalPrice;
  
  /// 单价(元/升)
  /// 例如:6.93表示每升6.93元
  final double pricePerLiter;

  /// 优惠金额（元）：机显金额 - 实付金额
  final double discount;
  
  /// 当前里程数(公里)
  /// 加油时车辆的总行驶里程
  final double odometer;
  
  /// 是否加满油
  /// true表示加满了,false表示只加了一部分
  final bool isFullTank;
  
  /// 这条记录是油还是电：gasoline / electric
  final String energyType;

  /// 是否油灯亮了
  /// 用于"亮灯法"计算油耗
  final bool isLightOn;
  
  /// 充电方式：fast / slow / home（仅充电记录，存英文枚举）
  final String? chargeMethod;

  /// 油品类型(92#/95#/98#/柴油等)
  final String? fuelType;
  
  /// 加油站名称
  final String? stationName;
  
  /// 备注信息(可选)
  final String? notes;
  
  /// 创建时间
  final DateTime createdAt;

  /// 构造函数
  FuelRecordModel({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.fuelAmount,
    required this.totalPrice,
    required this.pricePerLiter,
    required this.odometer,
    required this.isFullTank,
    this.isLightOn = false,
    this.energyType = 'gasoline',
    this.chargeMethod,
    this.fuelType,
    this.stationName,
    this.notes,
    this.discount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 创建一个副本,但可以修改某些字段
  FuelRecordModel copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? fuelAmount,
    double? totalPrice,
    double? pricePerLiter,
    double? discount,
    double? odometer,
    bool? isFullTank,
    bool? isLightOn,
    String? energyType,
    String? chargeMethod,
    String? fuelType,
    String? stationName,
    String? notes,
    DateTime? createdAt,
  }) {
    return FuelRecordModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      discount: discount ?? this.discount,
      odometer: odometer ?? this.odometer,
      isFullTank: isFullTank ?? this.isFullTank,
      isLightOn: isLightOn ?? this.isLightOn,
      energyType: energyType ?? this.energyType,
      chargeMethod: chargeMethod ?? this.chargeMethod,
      fuelType: fuelType ?? this.fuelType,
      stationName: stationName ?? this.stationName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FuelRecordModel(id: $id, date: $date, fuelAmount: $fuelAmount, totalPrice: $totalPrice)';
  }
}
