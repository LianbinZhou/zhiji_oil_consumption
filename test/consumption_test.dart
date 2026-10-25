// 能耗公式单元测试
//
// 被测函数：weightedConsumption（区间求和 + 加权平均）
// 这是全 App 最核心的一段计算，之前零覆盖。审核报告 M5 要求补齐。

import 'package:flutter_test/flutter_test.dart';

import 'package:zhiji_oil_consumption/data/database/app_database.dart';
import 'package:zhiji_oil_consumption/data/database/tables.dart';
import 'package:zhiji_oil_consumption/features/statistics/providers/statistics_provider.dart';

EnergyRecord rec({
  required int id,
  required double odometer,
  required double quantity,
  bool isFull = false,
  bool isLightOn = false,
  String energyType = EnergyTypes.gasoline,
}) {
  return EnergyRecord(
    id: id,
    vehicleId: 1,
    energyType: energyType,
    date: 1700000000000 + id * 86400000,
    quantity: quantity,
    amount: quantity * 7.5,
    discount: 0,
    unitPrice: 7.5,
    odometer: odometer,
    isFull: isFull,
    isLightOn: isLightOn,
    fuelType: null,
    chargeMethod: null,
    stationName: null,
    notes: null,
    createdAt: 1700000000000,
  );
}

void main() {
  group('加权能耗（加满法）', () {
    test('加满 → 未加满 20L → 加满 15L，500km ⇒ 7.0（区间求和，不漏算）', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10250, quantity: 20, isFull: false),
        rec(id: 3, odometer: 10500, quantity: 15, isFull: true),
      ];
      // 锚点 1 与 3；区间 (1,3] 油量 = 20 + 15 = 35；里程 500
      final c = weightedConsumption(list, useLightAnchor: false);
      expect(c, closeTo(7.0, 0.001));
    });

    test('中间那条如果被漏掉，结果会变成 3.0（证明区间求和确实生效）', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 3, odometer: 10500, quantity: 15, isFull: true),
      ];
      final c = weightedConsumption(list, useLightAnchor: false);
      // 只有 15L（旧算法的结果），不是 7.0
      expect(c, closeTo(3.0, 0.001));
    });

    test('里程倒退 ⇒ null', () {
      final list = [
        rec(id: 1, odometer: 10500, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10000, quantity: 30, isFull: true),
      ];
      expect(weightedConsumption(list, useLightAnchor: false), isNull);
    });

    test('只有一个锚点 ⇒ null', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10500, quantity: 20, isFull: false),
      ];
      expect(weightedConsumption(list, useLightAnchor: false), isNull);
    });

    test('没有任何锚点 ⇒ null', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40),
        rec(id: 2, odometer: 10500, quantity: 20),
      ];
      expect(weightedConsumption(list, useLightAnchor: false), isNull);
    });

    test('只有一条记录 ⇒ null', () {
      final list = [rec(id: 1, odometer: 10000, quantity: 40, isFull: true)];
      expect(weightedConsumption(list, useLightAnchor: false), isNull);
    });

    test('里程差为 0 ⇒ null（不能除零）', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10000, quantity: 20, isFull: true),
      ];
      expect(weightedConsumption(list, useLightAnchor: false), isNull);
    });
  });

  group('亮灯法', () {
    test('用亮灯作锚点时，结果与加满法不同', () {
      // 加满锚点：1 和 3（区间 2、3 共 35L / 500km = 7.0）
      // 亮灯锚点：2 和 4（区间 3、4 共 25L / 600km）
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10250, quantity: 20, isLightOn: true),
        rec(id: 3, odometer: 10500, quantity: 15, isFull: true),
        rec(id: 4, odometer: 10850, quantity: 10, isLightOn: true),
      ];
      final byFull = weightedConsumption(list, useLightAnchor: false);
      final byLight = weightedConsumption(list, useLightAnchor: true);

      expect(byFull, closeTo(7.0, 0.001));
      // 亮灯区间 (2,4]：15 + 10 = 25L，里程 10850-10250 = 600
      expect(byLight, closeTo(25 / 600 * 100, 0.001));
      expect(byLight, isNot(closeTo(byFull!, 0.001)),
          reason: '两种锚点必须算出不同的值，否则亮灯法等于没生效');
    });

    test('没有亮灯记录 ⇒ 亮灯法返回 null', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10500, quantity: 15, isFull: true),
      ];
      expect(weightedConsumption(list, useLightAnchor: true), isNull);
    });
  });

  group('油电隔离', () {
    test('传入同一能源类型的列表才算得对（调用方负责过滤）', () {
      // 纯电记录
      final electric = [
        rec(
            id: 1,
            odometer: 20000,
            quantity: 50,
            isFull: true,
            energyType: EnergyTypes.electric),
        rec(
            id: 2,
            odometer: 20300,
            quantity: 45,
            isFull: true,
            energyType: EnergyTypes.electric),
      ];
      // 45 kWh / 300 km × 100 = 15 kWh/100km
      expect(weightedConsumption(electric, useLightAnchor: false),
          closeTo(15.0, 0.001));

      // 油记录
      final fuel = [
        rec(id: 3, odometer: 20000, quantity: 40, isFull: true),
        rec(id: 4, odometer: 20500, quantity: 35, isFull: true),
      ];
      // 35 L / 500 km × 100 = 7.0 L/100km
      expect(weightedConsumption(fuel, useLightAnchor: false),
          closeTo(7.0, 0.001));
    });
  });

  group('口径自洽', () {
    test('分段相加等于一次聚合（否则列表页和统计页会对不上）', () {
      final list = [
        rec(id: 1, odometer: 10000, quantity: 40, isFull: true),
        rec(id: 2, odometer: 10500, quantity: 35, isFull: true),
        rec(id: 3, odometer: 11000, quantity: 30, isFull: true),
      ];

      final whole = consumptionDetail(list, useLightAnchor: false)!;

      // 拆成两段分别算
      final seg1 =
          consumptionDetail(list.sublist(0, 2), useLightAnchor: false)!;
      final seg2 =
          consumptionDetail(list.sublist(1, 3), useLightAnchor: false)!;

      // 油量与里程都可累加
      expect(whole.quantity, closeTo(seg1.quantity + seg2.quantity, 1e-9));
      expect(whole.distance, closeTo(seg1.distance + seg2.distance, 1e-9));

      // 合并后再除，与一次性算的结果一致
      final merged =
          (seg1.quantity + seg2.quantity) / (seg1.distance + seg2.distance) * 100;
      expect(merged, closeTo(whole.quantity / whole.distance * 100, 1e-9));
      expect(merged, closeTo(6.5, 1e-9));
    });
  });
}
