// 智记能耗 - Drift 数据库表定义
// 这个文件定义了应用中所有的数据表结构
// Drift 会根据这些定义自动生成类型安全的数据库操作代码
//
// v4 变更（2026-10-25）：
//   - Vehicles 新增 energy_type（油车/纯电/混动）
//   - FuelRecords 升级为 EnergyRecords（支持加油 + 充电）
//       列改名：fuel_amount→quantity、total_price→amount、
//               price_per_liter→unit_price、is_full_tank→is_full
//       新增列：energy_type、charge_method
//   - 新增 Expenses 表（保养 + 费用合并，用 kind 区分）

import 'package:drift/drift.dart';

// ==================== 能源类型常量 ====================

/// 能源类型取值（同时用于 vehicles.energy_type 与 energy_records.energy_type）
class EnergyTypes {
  static const String gasoline = 'gasoline'; // 油
  static const String electric = 'electric'; // 电
  static const String hybrid = 'hybrid'; // 混动（仅用于车辆）

  static const List<String> vehicles = [gasoline, electric, hybrid];
  static const List<String> records = [gasoline, electric];
}

/// 充电方式取值（所有充电记录适用，含混动车的充电）
class ChargeMethods {
  static const String fast = 'fast'; // 快充
  static const String slow = 'slow'; // 慢充
  static const String home = 'home'; // 家充

  static const List<String> all = [fast, slow, home];
}

/// 支出类型判别（expenses.kind）
class ExpenseKinds {
  static const String maintenance = 'maintenance'; // 保养
  static const String other = 'other'; // 费用
}

/// 保养项目预设（写入 expenses.items，逗号分隔）
const List<String> kMaintenanceItems = [
  '机油',
  '机油滤芯',
  '空气滤芯',
  '空调滤芯',
  '火花塞',
  '刹车片',
  '刹车油',
  '变速箱油',
  '防冻液',
  '轮胎',
  '电瓶',
  '四轮定位',
];

/// 费用类型预设（写入 expenses.category，同时 kind = other）
const List<String> kExpenseCategories = [
  '保险',
  '停车费',
  '洗车',
  '过路费',
  '罚款',
  '维修',
  '年检',
  '其他',
];

/// 判断某个 category 是否属于"保养"（决定 kind）
bool isMaintenanceCategory(String category) => category == '保养';

// ==================== 车辆表 ====================

/// 车辆数据表
class Vehicles extends Table {
  /// 主键 ID
  IntColumn get id => integer().autoIncrement()();

  /// 车辆品牌
  TextColumn get brand => text().withLength(min: 1, max: 50)();

  /// 车辆型号
  TextColumn get model => text().withLength(min: 1, max: 50)();

  /// 车牌号码
  TextColumn get licensePlate =>
      text().withLength(min: 1, max: 20).nullable()();

  /// 车辆颜色
  TextColumn get color => text().withLength(min: 1, max: 20).nullable()();

  /// 备注
  TextColumn get notes => text().nullable()();

  /// 车辆类型（轿车/SUV/MPV 等，说的是车身材质，不是能源）
  TextColumn get vehicleType => text().withLength(min: 1, max: 20).nullable()();

  /// 是否为默认车辆
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// 【v4 新增】能源类型：gasoline / electric / hybrid
  /// 决定录入界面显示哪些字段、统计用哪套指标
  TextColumn get energyType =>
      text().withDefault(const Constant(EnergyTypes.gasoline))();

  /// 创建时间（毫秒时间戳）
  IntColumn get createdAt => integer()();

  /// 更新时间（毫秒时间戳）
  IntColumn get updatedAt => integer()();
}

// ==================== 能源记录表（原油耗记录表） ====================

/// 能源记录表：一次加油或一次充电
///
/// 表的物理名由 Drift 生成为 `energy_records`（旧名 `fuel_records`，迁移时 RENAME）
class EnergyRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 关联车辆
  IntColumn get vehicleId => integer().references(Vehicles, #id)();

  /// 【v4 新增】这条记录是油还是电：gasoline / electric
  /// 注意：这是记录的"事实属性"，录入时按当时车辆类型写入，车辆改类型不回改历史
  TextColumn get energyType =>
      text().withDefault(const Constant(EnergyTypes.gasoline))();

  /// 日期（毫秒时间戳）
  IntColumn get date => integer()();

  /// 数量：升（油）或 kWh（电）
  /// 【v4 改名】原 fuelAmount
  RealColumn get quantity => real()();

  /// 实付金额（元）—— 统计（每公里成本、均价、总花费）都用这个
  /// 【v4 改名】原 totalPrice
  RealColumn get amount => real()();

  /// 【v5 新增】优惠金额（元）
  /// 油站标价 743、实际付 700 → amount=700, discount=43
  /// 机显金额 = amount + discount（不单独存，避免三列互相矛盾）
  RealColumn get discount =>
      real().withDefault(const Constant(0.0))();

  /// 单价：元/升 或 元/kWh
  /// 【v4 改名】原 pricePerLiter
  RealColumn get unitPrice => real()();

  /// 当前里程（公里）
  RealColumn get odometer => real()();

  /// 是否加满 / 充满（锚点标记，能耗算法靠它分段）
  /// 【v4 改名】原 isFullTank
  BoolColumn get isFull => boolean().withDefault(const Constant(false))();

  /// 是否油灯亮（仅油车，亮灯法锚点）
  BoolColumn get isLightOn => boolean().withDefault(const Constant(false))();

  /// 油品标号（92#/95#/98#/柴油），仅油车
  TextColumn get fuelType => text().withLength(max: 10).nullable()();

  /// 【v4 新增】充电方式：fast / slow / home，仅充电记录
  TextColumn get chargeMethod => text().withLength(max: 10).nullable()();

  /// 加油站 / 充电站名称
  TextColumn get stationName => text().withLength(max: 50).nullable()();

  /// 备注
  TextColumn get notes => text().nullable()();

  /// 创建时间（毫秒时间戳）
  IntColumn get createdAt => integer()();
}

// ==================== 其他支出表（保养 + 费用） ====================

/// 其他支出表：保养与费用合用一张表，用 kind 区分
///
/// 为什么合用：两者都是"某天花了一笔钱在车身上 + 一个类型 + 可能有个备注"，
/// 结构高度一致，分两张表等于把同一套增删改查写两遍。
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 关联车辆
  IntColumn get vehicleId => integer().references(Vehicles, #id)();

  /// 日期（毫秒时间戳）
  IntColumn get date => integer()();

  /// 判别列：maintenance（保养）/ other（费用）
  TextColumn get kind => text().withLength(max: 20)();

  /// 细分类型
  /// - kind=maintenance 时：机油 / 刹车片 / 轮胎 ...（见 kMaintenanceItems）
  /// - kind=other 时：保险 / 停车费 / 维修 ...（见 kExpenseCategories）
  TextColumn get category => text().withLength(max: 30)();

  /// 保养项目，逗号分隔（仅保养用）
  TextColumn get items => text().nullable()();

  /// 当时里程（仅保养用）
  RealColumn get mileage => real().nullable()();

  /// 金额
  RealColumn get amount => real()();

  /// 备注
  TextColumn get notes => text().nullable()();

  /// 创建时间（毫秒时间戳）
  IntColumn get createdAt => integer()();
}
