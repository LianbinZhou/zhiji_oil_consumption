// 智记油耗 - 油耗记录列表页面
// 美化版：更好的卡片设计和视觉层次

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/records_provider.dart';
import '../../vehicles/providers/vehicles_provider.dart';
import 'record_dialog.dart';
import '../../../data/models/fuel_record.dart' as model;

/// 油耗记录列表页面
class RecordsScreen extends ConsumerWidget {
  final int vehicleId;

  const RecordsScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsStreamProvider(vehicleId));
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);
    final vehicleName = vehiclesAsync.when(
      data: (vehicles) {
        final v = vehicles.where((v) => v.id == vehicleId).firstOrNull;
        return v != null ? '${v.brand} ${v.model}' : '加油记录';
      },
      loading: () => '加油记录',
      error: (_, __) => '加油记录',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicleName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: '查看统计',
            onPressed: () => context.go('/statistics/$vehicleId'),
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('加载失败: $error'),
        ),
        data: (records) {
          if (records.isEmpty) {
            return _buildEmptyState(context);
          }
          return Column(
            children: [
              // 顶部统计摘要
              _buildQuickStats(context, records),
              // 记录列表
              Expanded(child: _buildRecordsList(context, ref, records)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => RecordDialog(vehicleId: vehicleId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 顶部快速统计
  Widget _buildQuickStats(BuildContext context, List<model.FuelRecordModel> records) {
    // 计算统计数据
    double totalCost = 0;
    double totalFuel = 0;
    for (final r in records) {
      totalCost += r.totalPrice;
      totalFuel += r.fuelAmount;
    }
    final avgPrice = totalFuel > 0 ? totalCost / totalFuel : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildMiniStat(context, '${records.length}', '记录数'),
          _buildMiniStatDivider(context),
          _buildMiniStat(context, '¥${totalCost.toStringAsFixed(0)}', '总花费'),
          _buildMiniStatDivider(context),
          _buildMiniStat(context, '${totalFuel.toStringAsFixed(0)}L', '总加油'),
          _buildMiniStatDivider(context),
          _buildMiniStat(context, '¥${avgPrice.toStringAsFixed(2)}', '均价/L'),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
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

  Widget _buildMiniStatDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
    );
  }

  // 空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_gas_station_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '暂无加油记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方"+"按钮添加第一条记录',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // 记录列表
  Widget _buildRecordsList(
    BuildContext context,
    WidgetRef ref,
    List<model.FuelRecordModel> records,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final previousOdometer = index < records.length - 1
            ? records[index + 1].odometer
            : null;
        return _buildRecordCard(context, ref, record, previousOdometer);
      },
    );
  }

  // 单个记录卡片 - 全新设计
  Widget _buildRecordCard(
    BuildContext context,
    WidgetRef ref,
    model.FuelRecordModel record,
    double? previousOdometer,
  ) {
    final fuelConsumption = record.calculateFuelConsumption(previousOdometer);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => RecordDialog(vehicleId: vehicleId, record: record),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // 第一行：日期 + 金额
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期图标
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: record.isFullTank
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${record.date.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: record.isFullTank
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          '${record.date.month}月',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 中间信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 加油量和单价
                        Row(
                          children: [
                            Text(
                              '${record.fuelAmount.toStringAsFixed(1)}L',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '×¥${record.pricePerLiter.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 标签
                            if (record.isFullTank)
                              _buildTag(context, '满', Theme.of(context).colorScheme.primary),
                            if (record.isLightOn)
                              _buildTag(context, '灯', Colors.orange),
                            if (record.fuelType != null)
                              _buildTag(context, record.fuelType!, Theme.of(context).colorScheme.secondary),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 加油站 + 里程
                        Row(
                          children: [
                            Icon(
                              Icons.speed,
                              size: 13,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${record.odometer.toStringAsFixed(0)}km',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (record.stationName != null && record.stationName!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  record.stationName!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 右侧金额
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '¥${record.totalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (fuelConsumption != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getFuelConsumptionColor(fuelConsumption).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${fuelConsumption.toStringAsFixed(1)}L/100km',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getFuelConsumptionColor(fuelConsumption),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // 操作按钮行
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 56),
                    Icon(Icons.note_outlined, size: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  // 小标签
  Widget _buildTag(BuildContext context, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  // 根据油耗值返回颜色
  Color _getFuelConsumptionColor(double consumption) {
    if (consumption < 7) return Colors.green;
    if (consumption < 9) return Colors.orange;
    return Colors.red;
  }
}
