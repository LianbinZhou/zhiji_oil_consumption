// 智记能耗 - 统计总览（跨车辆）
//
// 数据口径见 overview_stats_provider.dart。
// 页面为滚动式，四个区块依次排列：总览 / 费用构成 / 年度 / 车辆对比 / 里程。

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/overview_stats_provider.dart';

class StatisticsOverviewScreen extends ConsumerWidget {
  const StatisticsOverviewScreen({super.key});

  String _money(double v) => v.toStringAsFixed(v >= 10000 ? 0 : 2);

  String _distance(double km) => '${km.toStringAsFixed(0)} km';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('统计总览')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (stats) {
          if (stats == null) return _empty(context);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              _buildSummaryCard(context, stats),
              const SizedBox(height: 16),
              _buildCostBreakdownCard(context, stats.breakdown),
              const SizedBox(height: 16),
              _buildYearlyCard(context, ref),
              const SizedBox(height: 16),
              _buildVehicleCompareCard(context, ref),
              const SizedBox(height: 16),
              _buildMileageCard(context, ref),
            ],
          );
        },
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          const Text('还没有可统计的数据'),
          const SizedBox(height: 8),
          Text('先添加车辆并记录几次加油/充电',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }

  // ==================== ① 总览 ====================

  Widget _buildSummaryCard(BuildContext context, OverviewStats s) {
    final theme = Theme.of(context);

    Widget item(String label, String value, {String? sub}) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            if (sub != null)
              Text(sub,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('全部花费',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text('¥${_money(s.totalCost)}',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '能源 ¥${_money(s.energyCost)} · 保养/费用 ¥${_money(s.expenseCost)}',
              style: theme.textTheme.bodySmall,
            ),
            const Divider(height: 24),
            Row(children: [
              item('记录里程', _distance(s.totalDistance)),
              item('记录数', '${s.recordCount} 条'),
              item('车辆', '${s.vehicleCount} 辆'),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              item(
                '平均油耗',
                s.averageConsumption != null
                    ? '${s.averageConsumption!.toStringAsFixed(1)} L/100km'
                    : '—',
              ),
              item(
                '每公里成本',
                s.costPerKm != null ? '¥${s.costPerKm!.toStringAsFixed(2)}' : '—',
              ),
            ]),
            if (s.vehicleCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '口径：里程按每辆车「最大里程 − 最小里程」累计，只统计你实际录入的数据',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== ② 费用构成 ====================

  Widget _buildCostBreakdownCard(BuildContext context, CostBreakdown b) {
    final theme = Theme.of(context);
    final total = b.total;

    final items = <(String, double, Color)>[
      ('加油', b.fuel, const Color(0xFFFF6B35)),
      ('充电', b.electric, const Color(0xFF2EC4B6)),
      ('保养', b.maintenance, const Color(0xFF42A5F5)),
      ('其他费用', b.other, const Color(0xFFAB47BC)),
    ].where((e) => e.$2 > 0).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, Icons.pie_chart_outline, '费用构成'),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Text('暂无费用数据', style: theme.textTheme.bodySmall)
            else ...[
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 46,
                    startDegreeOffset: 270,
                    sections: [
                      for (final it in items)
                        PieChartSectionData(
                          value: it.$2,
                          color: it.$3,
                          radius: 42,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final it in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: it.$3, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(it.$1, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Text(
                        '¥${_money(it.$2)}  ${total > 0 ? (it.$2 / total * 100).toStringAsFixed(0) : 0}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== ③ 年度报告 ====================

  Widget _buildYearlyCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final yearlyAsync = ref.watch(overviewYearlyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, Icons.calendar_month, '年度报告'),
            const SizedBox(height: 12),
            yearlyAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('加载失败：$e'),
              data: (list) {
                if (list.isEmpty) {
                  return Text('暂无数据', style: theme.textTheme.bodySmall);
                }
                final maxCost = list
                    .map((e) => e.cost)
                    .fold<double>(0, (a, b) => a > b ? a : b);

                return Column(
                  children: [
                    for (var i = list.length - 1; i >= 0; i--)
                      _yearRow(context, list[i], maxCost, list, i),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _yearRow(BuildContext context, YearlyPoint p, double maxCost,
      List<YearlyPoint> all, int index) {
    final theme = Theme.of(context);
    final ratio = maxCost > 0 ? (p.cost / maxCost).clamp(0.0, 1.0) : 0.0;

    // 与上一年同比
    String? yoy;
    if (index > 0) {
      final prev = all[index - 1];
      if (prev.cost > 0) {
        final delta = (p.cost - prev.cost) / prev.cost * 100;
        yoy = '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${p.year} 年',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (yoy != null)
                Text('同比 $yoy',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: yoy.startsWith('-')
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    )),
              const Spacer(),
              Text('¥${_money(p.cost)}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '里程 ${_distance(p.distance)} · 能耗 ${p.energyQuantity.toStringAsFixed(0)}',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ==================== ④ 车辆对比 ====================

  Widget _buildVehicleCompareCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final compareAsync = ref.watch(vehicleComparisonProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, Icons.compare_arrows, '车辆对比'),
            const SizedBox(height: 4),
            Text('按每公里成本从低到高排序',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 12),
            compareAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('加载失败：$e'),
              data: (list) {
                if (list.isEmpty) {
                  return Text('暂无数据', style: theme.textTheme.bodySmall);
                }
                return Column(
                  children: [
                    for (var i = 0; i < list.length; i++)
                      _vehicleRow(context, list[i], i == 0 && list.length > 1,
                          i == list.length - 1 && list.length > 1),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleRow(
      BuildContext context, VehicleComparison v, bool cheapest, bool priciest) {
    final theme = Theme.of(context);

    Color? badgeColor;
    String? badge;
    if (cheapest) {
      badgeColor = const Color(0xFF2E7D32);
      badge = '最省';
    } else if (priciest && v.costPerKm != null) {
      badgeColor = const Color(0xFFC62828);
      badge = '最费';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(v.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badge,
                      style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                v.distanceKnown ? _distance(v.distance) : '里程不足',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Text('¥${_money(v.totalCost)}',
                  style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                v.costPerKm != null
                    ? '¥${v.costPerKm!.toStringAsFixed(2)}/km'
                    : '—',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          if (v.averageConsumption != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '平均能耗 ${v.averageConsumption!.toStringAsFixed(1)} '
                '${v.energyType == 'electric' ? 'kWh' : 'L'}/100km',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== ⑤ 里程统计 ====================

  Widget _buildMileageCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final monthlyAsync = ref.watch(overviewMonthlyProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, Icons.route, '里程统计'),
            const SizedBox(height: 4),
            Text('近 12 个月，按每辆车「最大里程 − 最小里程」计算',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 12),
            monthlyAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('加载失败：$e'),
              data: (list) {
                if (list.isEmpty) {
                  return Text('暂无数据', style: theme.textTheme.bodySmall);
                }
                final maxDist = list
                    .map((e) => e.distance)
                    .fold<double>(0, (a, b) => a > b ? a : b);

                return Column(
                  children: [
                    for (final p in list.reversed)
                      _monthRow(context, p, maxDist),
                    const SizedBox(height: 6),
                    Text(
                      '灰色月份表示当月记录少于 2 条，无法计算里程（不代表没开车）',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthRow(BuildContext context, MonthlyPoint p, double maxDist) {
    final theme = Theme.of(context);
    final ratio =
        maxDist > 0 ? (p.distance / maxDist).clamp(0.0, 1.0) : 0.0;
    final parts = p.yearMonth.split('-');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text('${parts[1]}月',
                style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.distanceKnown ? ratio : 0,
                minHeight: 14,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  theme.colorScheme.primary.withValues(
                    alpha: p.distanceKnown ? 1 : 0.2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              p.distanceKnown ? _distance(p.distance) : '—',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
