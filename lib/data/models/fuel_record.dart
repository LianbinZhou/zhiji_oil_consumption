// 智记油耗 - 油耗记录数据模型
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
  
  /// 当前里程数(公里)
  /// 加油时车辆的总行驶里程
  final double odometer;
  
  /// 是否加满油
  /// true表示加满了,false表示只加了一部分
  final bool isFullTank;
  
  /// 是否油灯亮了
  /// 用于"亮灯法"计算油耗
  final bool isLightOn;
  
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
    this.fuelType,
    this.stationName,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 计算每公里成本(元/公里)
  /// 
  /// 这个方法需要配合上一条记录的里程数来计算
  /// 如果这是第一条记录,返回null
  double? calculateCostPerKm(double? previousOdometer) {
    if (previousOdometer == null || previousOdometer >= odometer) {
      return null;
    }
    double distance = odometer - previousOdometer;
    return totalPrice / distance;
  }

  /// 计算实际油耗(升/100公里)
  ///
  /// 这个方法需要配合上一条记录来计算
  /// 公式: 加油量 / 行驶距离 * 100
  double? calculateFuelConsumption(double? previousOdometer) {
    if (previousOdometer == null || previousOdometer >= odometer) {
      return null;
    }
    double distance = odometer - previousOdometer;
    return (fuelAmount / distance) * 100; // 升/100公里
  }

  /// 创建一个副本,但可以修改某些字段
  FuelRecordModel copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? fuelAmount,
    double? totalPrice,
    double? pricePerLiter,
    double? odometer,
    bool? isFullTank,
    bool? isLightOn,
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
      odometer: odometer ?? this.odometer,
      isFullTank: isFullTank ?? this.isFullTank,
      isLightOn: isLightOn ?? this.isLightOn,
      fuelType: fuelType ?? this.fuelType,
      stationName: stationName ?? this.stationName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 将对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'date': date.millisecondsSinceEpoch,
      'fuel_amount': fuelAmount,
      'total_price': totalPrice,
      'price_per_liter': pricePerLiter,
      'odometer': odometer,
      'is_full_tank': isFullTank ? 1 : 0,
      'is_light_on': isLightOn ? 1 : 0,
      'fuel_type': fuelType,
      'station_name': stationName,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  /// 从Map创建对象
  factory FuelRecordModel.fromMap(Map<String, dynamic> map) {
    return FuelRecordModel(
      id: map['id'] as int,
      vehicleId: map['vehicle_id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      fuelAmount: (map['fuel_amount'] as num).toDouble(),
      totalPrice: (map['total_price'] as num).toDouble(),
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      odometer: (map['odometer'] as num).toDouble(),
      isFullTank: (map['is_full_tank'] as int) == 1,
      isLightOn: (map['is_light_on'] as int?) == 1,
      fuelType: map['fuel_type'] as String?,
      stationName: map['station_name'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  String toString() {
    return 'FuelRecordModel(id: $id, date: $date, fuelAmount: $fuelAmount, totalPrice: $totalPrice)';
  }
}
