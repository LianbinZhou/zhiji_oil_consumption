// 智记油耗 - 统计图表页面
// 展示车辆的总体/月度/年度油耗统计数据和图表

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../providers/statistics_provider.dart';
import '../../vehicles/providers/vehicles_provider.dart';

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
                  _buildOverallStatsCard(context, stats),

                  // 年度统计（柱状图 + 汇总表）
                  yearlyStats.when(
                    data: (yearlyList) {
                      if (yearlyList.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildYearlyBarChart(context, yearlyList),
                          const SizedBox(height: 16),
                          _buildYearlySummaryTable(context, yearlyList),
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
                            _buildCostPieChart(context, pieChartData),
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
                '请先添加加油记录',
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
  Widget _buildOverallStatsCard(BuildContext context, OverallStats stats) {
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildStatItem(context, '总记录数', '${stats.totalRecords}条', Icons.receipt_long, null),
                _buildStatItem(context, '总花费', '¥${_formatMoney(stats.totalCost)}', Icons.attach_money, const Color(0xFFEF5350)),
                _buildStatItem(context, '总加油量', '${stats.totalFuel.toStringAsFixed(0)}L', Icons.local_gas_station, const Color(0xFF42A5F5)),
                _buildStatItem(
                  context,
                  '平均油耗',
                  stats.averageFuelConsumption != null
                      ? '${stats.averageFuelConsumption!.toStringAsFixed(2)}L/100km'
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
                _buildStatItem(context, '最高单次', '¥${_formatMoney(stats.maxSingleCost)}', Icons.trending_up, const Color(0xFFAB47BC)),
              ],
            ),
            const SizedBox(height: 8),
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
                    final ratio = maxCost > 0 ? yearly.totalCost / maxCost : 0.0;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: yearly.totalCost,
                          color: _getBarColor(ratio),
                          width: 28,
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

  Color _getBarColor(double ratio) {
    if (ratio > 0.8) return const Color(0xFFEF5350);
    if (ratio > 0.5) return const Color(0xFFFFA726);
    if (ratio > 0.3) return const Color(0xFF42A5F5);
    return const Color(0xFF66BB6A);
  }

  // ==================== 年度汇总表 ====================
  Widget _buildYearlySummaryTable(BuildContext context, List<YearlyStats> yearlyList) {
    final sorted = List<YearlyStats>.from(yearlyList)
      ..sort((a, b) => b.year.compareTo(a.year));

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('年度明细', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
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
                    DataCell(Text('${y.totalFuel.toStringAsFixed(0)}L')),
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
              Text('${_formatMonth(m.yearMonth)}', style: Theme.of(context).textTheme.bodyLarge),
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
  Widget _buildCostPieChart(BuildContext context, List<PieChartDataItem> pieData) {
    if (pieData.isEmpty) return const SizedBox.shrink();

    if (pieData.length < 2) {
      final item = pieData.first;
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
              Text('${item.name}', style: Theme.of(context).textTheme.bodyLarge),
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
                Text('月度费用分布', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _createPieChartSections(context, pieData),
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
              children: pieData.map((item) {
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
    List<PieChartDataItem> pieData,
  ) {
    if (pieData.isEmpty) return [];

    final totalValue = pieData.fold<double>(0, (sum, item) => sum + item.value);

    return pieData.asMap().entries.map((entry) {
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

  String _formatMonthShort(String yearMonth) {
    final parts = yearMonth.split('-');
    return '${int.parse(parts[1])}月';
  }

  String _formatMonth(String yearMonth) {
    final parts = yearMonth.split('-');
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
