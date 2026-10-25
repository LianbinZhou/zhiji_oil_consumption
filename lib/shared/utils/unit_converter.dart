// 智记能耗 - 单位换算工具
//
// 铁律：**存储永远用公制**（公里、升、kWh），只在展示层换算。
// 否则往返换算会累积误差，而且导出/导入会变得不可逆。
//
// 英制换算方向说明：
//   油耗用「L/100km」与「gal/100mi」两种，都是**越小越省**，方向一致。
//   刻意不支持 MPG（越大越省），避免同一界面里方向看反。

import '../../features/settings/providers/settings_provider.dart';

class UnitConverter {
  /// 公里 → 英里
  static const double _kmToMi = 0.621371;

  /// 升 → 加仑（美制）
  static const double _lToGal = 0.264172;

  /// L/100km → gal/100mi
  static const double _l100kmToGal100mi = 0.425144;

  // ==================== 距离 ====================

  /// 把公里值换算成当前设置的单位
  static double distance(double km, DistanceUnit unit) =>
      unit == DistanceUnit.miles ? km * _kmToMi : km;

  /// 距离单位符号：km / mi
  static String distanceSymbol(DistanceUnit unit) =>
      unit == DistanceUnit.miles ? 'mi' : 'km';

  // ==================== 数量（升 / 加仑） ====================

  static double volume(double liters, FuelUnit unit) =>
      unit == FuelUnit.gallons ? liters * _lToGal : liters;

  static String volumeSymbol(FuelUnit unit) =>
      unit == FuelUnit.gallons ? 'gal' : 'L';

  // ==================== 能耗 ====================

  /// 能耗换算：L/100km → gal/100mi；kWh/100km → kWh/100mi
  static double consumption(double per100km, DistanceUnit unit,
      {bool isElectric = false}) {
    if (unit != DistanceUnit.miles) return per100km;
    // 油：L/100km → gal/100mi 用 0.425144
    // 电：kWh/100km → kWh/100mi 用 1.60934（1 英里 = 1.60934 公里）
    // 之前两种能源都乘了油的系数，是错的。目前单位切换已下线，此路径不生效。
    return per100km * (isElectric ? 1.60934 : _l100kmToGal100mi);
  }

  /// 能耗单位标签
  ///
  /// [energyType] gasoline → L 或 gal；electric → kWh（英里制下只是分母变 100mi）
  static String consumptionLabel(String energyType, DistanceUnit unit) {
    final isElectric = energyType == 'electric';
    if (unit == DistanceUnit.miles) {
      return isElectric ? 'kWh/100mi' : 'gal/100mi';
    }
    return isElectric ? 'kWh/100km' : 'L/100km';
  }

  /// 单价的单位标签（注意：**单价不跟随切换**，固定按公制报）
  ///
  /// 现实中油价就是按升报的（7.5 元/升），换算成 28 元/gal 反而没人认识。
  static String unitPriceLabel(String energyType) =>
      energyType == 'electric' ? '元/kWh' : '元/L';
}
