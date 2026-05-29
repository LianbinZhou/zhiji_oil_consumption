import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/dashboard_provider.dart';
import '../../vehicles/presentation/vehicle_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final overviewsAsync = ref.watch(vehicleOverviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_gas_station,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text('智记油耗'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: '添加车辆',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VehicleDialog(),
              );
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildErrorState(context, ref, err),
        data: (summary) {
          if (summary == null || summary.totalVehicles == 0) {
            return _buildEmptyState(context, ref);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(vehicleOverviewsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 本月概览卡片
                  _buildMonthlyOverviewCard(context, summary),
                  const SizedBox(height: 20),

                  // 我的车辆标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '我的车辆',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/vehicles'),
                        child: const Text('管理'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 车辆卡片列表
                  overviewsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('加载失败', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    ),
                    data: (overviews) {
                      return Column(
                        children: overviews.map((overview) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildVehicleCard(context, overview),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // 快速记录悬浮按钮
      floatingActionButton: summaryAsync.whenOrNull(
        data: (summary) {
          if (summary == null || summary.totalVehicles == 0) return null;
          return FloatingActionButton.extended(
            onPressed: () {
              overviewsAsync.whenData((overviews) {
                if (overviews.length == 1) {
                  context.go('/records/${overviews.first.vehicle.id}');
                } else {
                  _showQuickAddDialog(context, overviews);
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('记录加油'),
          );
        },
      ),
    );
  }

  // 错误状态
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('数据加载失败', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$err',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(dashboardSummaryProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
            ),
          ],
        ),
      ),
    );
  }

  // 空状态 - 引导用户添加第一辆车
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 大图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_filled,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '欢迎使用智记油耗',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '轻松记录每次加油,了解你的用车成本',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),

            // 功能介绍（可点击跳转）
            _buildFeatureRow(
              context,
              Icons.local_gas_station,
              '加油记录',
              '简单几步记录加油数据',
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => const VehicleDialog(),
                );
                // 添加车辆后刷新
                ref.invalidate(vehicleOverviewsProvider);
                ref.invalidate(dashboardSummaryProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('车辆添加成功，点击底部"+"记录加油')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              context,
              Icons.insights,
              '智能统计',
              '自动计算油耗和费用趋势',
              onTap: () {
                // 未添加车辆时提示
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请先添加车辆后查看统计数据')),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              context,
              Icons.savings,
              '省心省钱',
              '帮你发现最佳加油策略',
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const VehicleDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('添加我的第一辆车'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String desc, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      desc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 本月概览卡片 - 渐变背景
  Widget _buildMonthlyOverviewCard(BuildContext context, DashboardSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                '${DateTime.now().year}年${DateTime.now().month}月',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 本月花费 - 大字
          Text(
            '¥${summary.monthlyTotalCost.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const Text(
            '本月花费',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),

          const SizedBox(height: 20),

          // 底部三项统计
          Row(
            children: [
              _buildOverviewStat('加油', '${summary.monthlyRecordCount}次'),
              _buildOverviewDivider(),
              _buildOverviewStat('里程', '${summary.monthlyTotalDistance.toStringAsFixed(0)}km'),
              _buildOverviewDivider(),
              _buildOverviewStat(
                '油耗',
                summary.averageFuelConsumption != null
                    ? '${summary.averageFuelConsumption!.toStringAsFixed(1)}L'
                    : '--',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white24,
    );
  }

  // 车辆卡片
  Widget _buildVehicleCard(BuildContext context, VehicleOverview overview) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/records/${overview.vehicle.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 顶部：车辆信息
              Row(
                children: [
                  // 车辆图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.directions_car,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 车辆名称和车牌
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${overview.vehicle.brand} ${overview.vehicle.model}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (overview.vehicle.licensePlate != null &&
                            overview.vehicle.licensePlate!.isNotEmpty)
                          Text(
                            overview.vehicle.licensePlate!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 箭头
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 底部：统计数据
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildVehicleStat(
                      context,
                      '最近加油',
                      overview.lastFuelDate != null
                          ? '${overview.lastFuelDate!.month}/${overview.lastFuelDate!.day}'
                          : '-',
                    ),
                    _buildVehicleStatDivider(context),
                    _buildVehicleStat(
                      context,
                      '总里程',
                      overview.lastOdometer != null
                          ? '${overview.lastOdometer!.toStringAsFixed(0)}km'
                          : '-',
                    ),
                    _buildVehicleStatDivider(context),
                    _buildVehicleStat(
                      context,
                      '油耗',
                      overview.recentFuelConsumption != null
                          ? '${overview.recentFuelConsumption!.toStringAsFixed(1)}L/100km'
                          : '-',
                    ),
                  ],
                ),
              ),

              // 本月花费提示
              if (overview.monthlyCost > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '本月 ¥${overview.monthlyCost.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${overview.totalRecords}条记录',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleStat(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStatDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
    );
  }

  // 快速添加弹窗
  void _showQuickAddDialog(BuildContext context, List<VehicleOverview> overviews) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖拽条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '选择车辆',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...overviews.map((overview) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text('${overview.vehicle.brand} ${overview.vehicle.model}'),
                subtitle: overview.vehicle.licensePlate != null
                    ? Text(overview.vehicle.licensePlate!)
                    : null,
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/records/${overview.vehicle.id}');
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
