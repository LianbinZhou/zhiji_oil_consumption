// 智记能耗 - 统计图表页面
// 展示车辆的总体/月度/年度油耗统计数据和图表

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../providers/statistics_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/utils/unit_converter.dart';
import '../../vehicles/providers/vehicles_provider.dart';

/// 月度费用分布饼图当前选中的年份（null = 最新一年）
final selectedPieYearProvider = StateProvider<int?>((ref) => null);

class StatisticsScreen extends ConsumerWidget {
  final int vehicleId;

  const StatisticsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStats = ref.watch(overallStatsProvider(vehicleId));
    final monthlyStats = ref.watch(monthlyStatsProvider(vehicleId));
    final yearlyStats = ref.watch(yearlyStatsProvider(vehicleId));
    final pieChartData = ref.watch(costPieChartDataProvider(vehicleId));
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);
    final vehicleName = vehiclesAsync.when(
      data: (vehicles) {
        final v = vehicles.where((v) => v.id == vehicleId).firstOrNull;
        return v != null ? '${v.brand} ${v.model} 统计' : '数据统计';
      },
      loading: () => '数据统计',
      error: (_, __) => '数据统计',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicleName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回',
          onPressed: () => context.go('/records/$vehicleId'),
        ),
      ),
      body: overallStats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 12),
                Text('数据加载失败', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('$err', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (stats) {
          if (stats == null) {
            return _buildNoDataCard(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(overallStatsProvider(vehicleId));
              ref.invalidate(monthlyStatsProvider(vehicleId));
              ref.invalidate(yearlyStatsProvider(vehicleId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallStatsCard(context, ref, stats),

                  // 年度统计（柱状图 + 汇总表）
                  yearlyStats.when(
                    data: (yearlyList) {
                      if (yearlyList.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildYearlyBarChart(context, yearlyList),
                          const SizedBox(height: 16),
                          _buildYearlySummaryTable(context, ref, yearlyList),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 16),

                  // 月度趋势
                  monthlyStats.when(
                    data: (statsList) {
                      if (statsList.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          _buildFuelTrendChart(context, statsList),
                          const SizedBox(height: 16),
                          if (pieChartData.isNotEmpty)
                            _buildCostPieChart(context, ref, pieChartData),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataCard(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insights_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无统计数据',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请先添加能耗记录',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 总体统计卡片 ====================
  Widget _buildOverallStatsCard(
      BuildContext context, WidgetRef ref, OverallStats stats) {
    final settings = ref.watch(settingsProvider).settings;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('总体统计', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),

            // ===== 全部花费（能源 + 保养 + 费用）=====
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('全部花费',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    '¥${_formatMoney(stats.totalCostAll)}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '能源 ¥${_formatMoney(stats.totalCost)}'
                    ' · 保养/费用 ¥${_formatMoney(stats.expenseCost)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildStatItem(context, '总记录数', '${stats.totalRecords}条', Icons.receipt_long, null),
                _buildStatItem(context, '能源花费', '¥${_formatMoney(stats.totalCost)}', Icons.attach_money, const Color(0xFFEF5350)),
                // 纯电车没有加油记录，这一格显示 0L 会让人以为数据错了 —— 干脆不显示
                if (stats.totalFuel > 0)
                  _buildStatItem(context, '总加油量', '${UnitConverter.volume(stats.totalFuel, settings.fuelUnit).toStringAsFixed(0)}${UnitConverter.volumeSymbol(settings.fuelUnit)}', Icons.local_gas_station, const Color(0xFF42A5F5)),
                _buildStatItem(
                  context,
                  stats.consumptionMethod == null
                      ? '平均油耗'
                      : '油耗·${stats.consumptionMethod == 'full' ? '加满法' : '亮灯法'}',
                  stats.averageFuelConsumption != null
                      ? '${UnitConverter.consumption(stats.averageFuelConsumption!, settings.distanceUnit).toStringAsFixed(2)}${UnitConverter.consumptionLabel('gasoline', settings.distanceUnit)}'
                      : '--',
                  Icons.speed,
                  stats.averageFuelConsumption != null
                      ? _getFuelConsumptionColor(stats.averageFuelConsumption!)
                      : null,
                ),
                _buildStatItem(
                  context,
                  '每公里成本',
                  stats.averageCostPerKm != null
                      ? '¥${stats.averageCostPerKm!.toStringAsFixed(2)}'
                      : '--',
                  Icons.money,
                  const Color(0xFFFFA726),
                ),
                if (stats.avgElectricConsumption != null)
                  _buildStatItem(
                    context,
                    '电耗·充满法',
                    '${UnitConverter.consumption(stats.avgElectricConsumption!, settings.distanceUnit, isElectric: true).toStringAsFixed(1)}${UnitConverter.consumptionLabel('electric', settings.distanceUnit)}',
                    Icons.battery_charging_full,
                    const Color(0xFF2EC4B6),
                  ),
                _buildStatItem(context, '最高单次', '¥${_formatMoney(stats.maxSingleCost)}', Icons.trending_up, const Color(0xFFAB47BC)),
              ],
            ),
            const SizedBox(height: 8),
            // 纯电车没有油价数据，显示 ¥0.00 - ¥0.00/L 是误导，直接不显示
            if (stats.minPricePerLiter > 0 || stats.maxPricePerLiter > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.price_change, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('油价范围:', style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    Text(
                      '¥${stats.minPricePerLiter.toStringAsFixed(2)} - ¥${stats.maxPricePerLiter.toStringAsFixed(2)}/L',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color? valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== 年度费用柱状图 ====================
  Widget _buildYearlyBarChart(BuildContext context, List<YearlyStats> yearlyList) {
    if (yearlyList.isEmpty) return const SizedBox.shrink();
    if (yearlyList.length < 2) {
      final y = yearlyList.first;
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(children: [
                Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('年度费用对比', style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 24),
              Text('${y.year}年总花费', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text('¥${_formatMoney(y.totalCost)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      );
    }

    final sorted = List<YearlyStats>.from(yearlyList)
      ..sort((a, b) => a.year.compareTo(b.year));

    final maxCost = sorted.map((y) => y.totalCost).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('年度费用对比', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: sorted.length > 1 ? BarChartAlignment.spaceAround : BarChartAlignment.center,
                  // 组间距：不加的话柱子会挨在一起，看着像一整块
                  groupsSpace: 18,
                  maxY: maxCost * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final yearly = sorted[group.x.toInt()];
                        return BarTooltipItem(
                          '${yearly.year}年\n',
                          TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '¥${_formatMoney(yearly.totalCost)}',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sorted.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(
                                '${sorted[index].year}',
                                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              '${(value / 10000).toStringAsFixed(1)}万',
                              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxCost * 1.2 / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                      left: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                  ),
                  barGroups: sorted.asMap().entries.map((entry) {
                    final index = entry.key;
                    final yearly = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: yearly.totalCost,
                          // 按年份顺序循环调色，相邻年份保证不同色
                          color: _getBarColorByIndex(index),
                          width: 26,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 逐年循环取色：相邻年份必然不同色
  /// （原来的实现按花费比例分 4 档，连续几年落在同一档就变成一样的颜色）
  Color _getBarColorByIndex(int index) {
    const palette = [
      Color(0xFF42A5F5), // 蓝
      Color(0xFFFFA726), // 橙
      Color(0xFF66BB6A), // 绿
      Color(0xFFEF5350), // 红
      Color(0xFFAB47BC), // 紫
      Color(0xFF26C6DA), // 青
    ];
    return palette[index % palette.length];
  }

  // ==================== 年度汇总表 ====================
  Widget _buildYearlySummaryTable(
      BuildContext context, WidgetRef ref, List<YearlyStats> yearlyList) {
    final settings = ref.watch(settingsProvider).settings;
    final sorted = List<YearlyStats>.from(yearlyList)
      ..sort((a, b) => b.year.compareTo(a.year));

    // 年份多了以后表格会很长，做成可折叠（默认收起，副标题显示年份范围）
    final yearRange = sorted.isEmpty
        ? ''
        : (sorted.length == 1
            ? '${sorted.first.year}年'
            : '${sorted.last.year}–${sorted.first.year} 年，共 ${sorted.length} 年');

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.table_chart,
              color: Theme.of(context).colorScheme.primary),
          title: Text('年度明细',
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: yearRange.isEmpty
              ? null
              : Text(yearRange,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                ),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('年份', style: TextStyle(fontWeight: FontWeight.w600))),
                  DataColumn(label: Text('花费', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                  DataColumn(label: Text('加油量', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                  DataColumn(label: Text('油耗', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                  DataColumn(label: Text('里程', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                  DataColumn(label: Text('次数', style: TextStyle(fontWeight: FontWeight.w600)), numeric: true),
                ],
                rows: sorted.map((y) {
                  return DataRow(cells: [
                    DataCell(Text('${y.year}年', style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text('¥${_formatMoney(y.totalCost)}')),
                    DataCell(Text('${UnitConverter.volume(y.totalFuel, settings.fuelUnit).toStringAsFixed(0)}${UnitConverter.volumeSymbol(settings.fuelUnit)}')),
                    DataCell(Text(
                      y.averageFuelConsumption != null
                          ? '${y.averageFuelConsumption!.toStringAsFixed(1)}L'
                          : '--',
                      style: TextStyle(
                        color: y.averageFuelConsumption != null
                            ? _getFuelConsumptionColor(y.averageFuelConsumption!)
                            : null,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                    DataCell(Text(y.totalDistance > 0 ? '${(y.totalDistance / 1000).toStringAsFixed(1)}k km' : '--')),
                    DataCell(Text('${y.recordCount}次')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 月度油耗趋势折线图 ====================
  Widget _buildFuelTrendChart(BuildContext context, List<MonthlyStats> monthlyStats) {
    final validMonths = monthlyStats.where((s) => s.averageFuelConsumption != null).toList();
    if (validMonths.isEmpty) return const SizedBox.shrink();

    if (validMonths.length < 2) {
      final m = validMonths.first;
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(children: [
                Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('月度油耗趋势', style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 24),
              Text(_formatMonth(m.yearMonth), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text('${m.averageFuelConsumption!.toStringAsFixed(1)} L/100km', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: _getFuelConsumptionColor(m.averageFuelConsumption!))),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('月度油耗趋势', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(_createLineChartData(context, monthlyStats)),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createLineChartData(BuildContext context, List<MonthlyStats> monthlyStats) {
    final validMonths = monthlyStats.where((s) => s.averageFuelConsumption != null).toList();

    if (validMonths.isEmpty) {
      return LineChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      );
    }

    final reversedMonths = validMonths.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < reversedMonths.length; i++) {
      spots.add(FlSpot(i.toDouble(), reversedMonths[i].averageFuelConsumption!));
    }

    final monthLabels = reversedMonths.map((s) => _formatMonthShort(s.yearMonth)).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 2,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < monthLabels.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    monthLabels[index],
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 2,
                strokeColor: Theme.of(context).colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final monthIndex = spot.x.toInt();
              if (monthIndex >= 0 && monthIndex < reversedMonths.length) {
                final month = reversedMonths[monthIndex];
                return LineTooltipItem(
                  '${_formatMonth(month.yearMonth)}\n',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '${spot.y.toStringAsFixed(2)} L/100km',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  // ==================== 月度费用饼图 ====================
  Widget _buildCostPieChart(
      BuildContext context, WidgetRef ref, List<PieChartDataItem> pieData) {
    if (pieData.isEmpty) return const SizedBox.shrink();

    // 从 "2026年10月" 里提取年份，供下拉选择
    final years = <int>{};
    for (final item in pieData) {
      final m = RegExp(r'(\d{4})').firstMatch(item.name);
      if (m != null) years.add(int.parse(m.group(1)!));
    }
    if (years.isEmpty) return const SizedBox.shrink();
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    final selected =
        ref.watch(selectedPieYearProvider) ?? sortedYears.first;

    // 只保留选中那一年的数据
    final data = pieData.where((item) {
      final m = RegExp(r'(\d{4})').firstMatch(item.name);
      return m != null && int.parse(m.group(1)!) == selected;
    }).toList();
    if (data.isEmpty) return const SizedBox.shrink();

    if (data.length < 2) {
      final item = data.first;
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(children: [
                Icon(Icons.pie_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('月度费用分布', style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 24),
              Text(item.name, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text('¥${item.value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('月度费用分布',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                // 年份选择：可以回看往年的月度分布
                DropdownButton<int>(
                  value: selected,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  items: sortedYears
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y年'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(selectedPieYearProvider.notifier).state = v;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _createPieChartSections(context, data),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 270,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.map((item) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getPieChartColor(item.colorIndex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.name}: ¥${item.value.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    BuildContext context,
    List<PieChartDataItem> data,
  ) {
    if (data.isEmpty) return [];

    final totalValue = data.fold<double>(0, (sum, item) => sum + item.value);

    return data.asMap().entries.map((entry) {
      final item = entry.value;
      final percentage = (item.value / totalValue * 100);

      return PieChartSectionData(
        color: _getPieChartColor(item.colorIndex),
        value: item.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        badgeWidget: Text(
          _formatMonthShort(item.name),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          softWrap: false,
        ),
        badgePositionPercentageOffset: 1.4,
      );
    }).toList();
  }

  Color _getPieChartColor(int index) {
    const colors = [
      Color(0xFF42A5F5),
      Color(0xFF66BB6A),
      Color(0xFFFFA726),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF26C6DA),
      Color(0xFFFFEE58),
      Color(0xFF8D6E63),
    ];
    return colors[index % colors.length];
  }

  Color _getFuelConsumptionColor(double consumption) {
    if (consumption < 7) return const Color(0xFF66BB6A);
    if (consumption < 9) return const Color(0xFFFFA726);
    return const Color(0xFFEF5350);
  }

  /// 把 "2026-10" 或 "2026年10月" 都转成 "10月"
  ///
  /// 注意：饼图数据的 name 已经是 _formatMonth 处理过的 "2026年10月"，
  /// 直接按 '-' 拆会拿到长度 1 的数组 -> RangeError（2026-10-25 线上崩溃的根因）
  String _formatMonthShort(String yearMonth) {
    final byMonth = RegExp(r'(\d{1,2})月').firstMatch(yearMonth);
    if (byMonth != null) return '${int.parse(byMonth.group(1)!)}月';

    final parts = yearMonth.split('-');
    if (parts.length < 2) return yearMonth;
    return '${int.parse(parts[1])}月';
  }

  String _formatMonth(String yearMonth) {
    final byMonth = RegExp(r'(\d{1,2})月').firstMatch(yearMonth);
    if (byMonth != null) {
      final year = RegExp(r'(\d{4})').firstMatch(yearMonth);
      return '${year?.group(1) ?? ''}年${int.parse(byMonth.group(1)!)}月';
    }

    final parts = yearMonth.split('-');
    if (parts.length < 2) return yearMonth;
    return '${parts[0]}年${int.parse(parts[1])}月';
  }

  String _formatMoney(double value) {
    final intPart = value.toInt();
    if (intPart >= 10000) {
      return '${(intPart ~/ 10000)}.${((intPart % 10000) ~/ 1000)}万';
    }
    return intPart.toString();
  }
}
