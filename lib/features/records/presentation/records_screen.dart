// 智记能耗 - 油耗记录列表页面
// 美化版：更好的卡片设计和视觉层次

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/records_provider.dart';
import '../../../shared/utils/fuel_type_label.dart';
import '../../../data/database/tables.dart';
import '../../expenses/presentation/expense_list_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/utils/unit_converter.dart';
import '../../vehicles/providers/vehicles_provider.dart';
import 'record_dialog.dart';
import '../../../data/models/fuel_record.dart' as model;
import '../../../data/models/vehicle.dart' as model_vehicle;

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
    final vehicle = vehiclesAsync.valueOrNull
        ?.where((v) => v.id == vehicleId)
        .firstOrNull;
    final vehicleName = vehiclesAsync.when(
      data: (vehicles) {
        final v = vehicles.where((v) => v.id == vehicleId).firstOrNull;
        return v != null ? '${v.brand} ${v.model}' : '能耗记录';
      },
      loading: () => '能耗记录',
      error: (_, __) => '能耗记录',
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
            icon: const Icon(Icons.build_outlined),
            tooltip: '保养记录',
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ExpenseListScreen(
                  vehicleId: vehicleId,
                  kind: ExpenseKinds.maintenance,
                  vehicleName: vehicleName,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: '费用账本',
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ExpenseListScreen(
                  vehicleId: vehicleId,
                  kind: ExpenseKinds.other,
                  vehicleName: vehicleName,
                ),
              ),
            ),
          ),
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
              _buildQuickStats(context, ref, records, vehicle),
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
  Widget _buildQuickStats(BuildContext context, WidgetRef ref,
      List<model.FuelRecordModel> records, model_vehicle.Vehicle? vehicle) {
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildMiniStat(context, '${records.length}', '记录数'),
          _buildMiniStatDivider(context),
          _buildMiniStat(context, '¥${totalCost.toStringAsFixed(0)}', '总花费'),
          _buildMiniStatDivider(context),
          // 混动车同时有油和电，升与 kWh 相加没有意义（会得到一个既不是油耗也不是电耗的数），
          // 所以混动只给「每公里成本」这一条有意义的汇总。
          if (vehicle?.energyType == 'hybrid') ...[
            _buildMiniStat(
                context, _costPerKmLabel(records, totalCost), '每公里成本'),
          ] else ...[
            _buildMiniStat(
                context,
                '${totalFuel.toStringAsFixed(0)}${_quantityUnit(vehicle)}',
                _quantityLabel(vehicle)),
            _buildMiniStatDivider(context),
            _buildMiniStat(
                context, '¥${avgPrice.toStringAsFixed(2)}', _avgPriceLabel(vehicle)),
          ],
        ],
      ),
    );
  }

  /// 混动专用：每公里成本（用首末里程差算，少于 2 条则显示 —）
  String _costPerKmLabel(List<model.FuelRecordModel> records, double totalCost) {
    if (records.length < 2) return '—';
    final odos = records.map((r) => r.odometer).toList()..sort();
    final distance = odos.last - odos.first;
    if (distance <= 0) return '—';
    return '¥${(totalCost / distance).toStringAsFixed(2)}';
  }

  /// 数量单位（按车辆能源类型）
  String _quantityUnit(model_vehicle.Vehicle? v) {
    switch (v?.energyType) {
      case 'electric':
        return ' kWh';
      case 'hybrid':
        return '';
      default:
        return ' L';
    }
  }

  /// 数量标签
  String _quantityLabel(model_vehicle.Vehicle? v) {
    switch (v?.energyType) {
      case 'electric':
        return '总加电';
      case 'hybrid':
        return '总能耗';
      default:
        return '总加油';
    }
  }

  /// 均价标签
  String _avgPriceLabel(model_vehicle.Vehicle? v) {
    switch (v?.energyType) {
      case 'electric':
        return '均价/kWh';
      case 'hybrid':
        return '均价';
      default:
        return '均价/L';
    }
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
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
            '暂无能耗记录',
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
    // 先按锚点区间算好每条记录的油耗（与统计页同一口径）
    final consumptionById = _computeIntervalConsumption(records);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _buildRecordCard(
            context, ref, record, consumptionById[record.id]);
      },
    );
  }

  /// 按「锚点区间」算每条记录的油耗，口径与统计页完全一致
  ///
  /// 规则：从上一个"加满/充满"的锚点，到这条锚点之间，所有油量求和 ÷ 里程差。
  /// 这样中途没加满的那次也会被计入，不会像"单条油量÷里程差"那样漏算。
  /// 逐段油耗（列表页专用：每行显示自己那一段）
  ///
  /// 口径与 statistics_provider 的 weightedConsumption 同源：
  /// 都是「isFull 作锚点 + 区间内同能源类型求和」，区别只是这里按段返回、那里算整体。
  Map<int, double?> _computeIntervalConsumption(
      List<model.FuelRecordModel> records) {
    // 传进来的是倒序（新→旧），先转成时间正序
    final asc = records.reversed.toList();
    final result = <int, double?>{};

    // 关键：油和电各自维护锚点与累加，绝不跨类型相加
    // （混动车同时有加油和充电记录，混在一起会把 kWh 当升算）
    final Map<String, int> anchorIdx = {};
    final Map<String, double> quantitySum = {};

    for (var i = 0; i < asc.length; i++) {
      final r = asc[i];
      final type = r.energyType;
      final anchor = anchorIdx[type];

      if (anchor == null) {
        result[r.id] = null;
        if (r.isFullTank) anchorIdx[type] = i;
        continue;
      }

      quantitySum[type] = (quantitySum[type] ?? 0) + r.fuelAmount;

      if (r.isFullTank) {
        final dist = r.odometer - asc[anchor].odometer;
        result[r.id] =
            dist > 0 ? (quantitySum[type]! / dist) * 100 : null;
        anchorIdx[type] = i;
        quantitySum[type] = 0;
      } else {
        result[r.id] = null;
      }
    }

    return result;
  }

  // 单个记录卡片 - 全新设计
  Widget _buildRecordCard(
    BuildContext context,
    WidgetRef ref,
    model.FuelRecordModel record,
    double? fuelConsumption,
  ) {
    final settings = ref.watch(settingsProvider).settings;

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
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
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
                              '${record.fuelAmount.toStringAsFixed(1)}${record.energyType == 'electric' ? 'kWh' : 'L'}',
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
                            // "0#" 这类原始标号统一显示成 "0#柴油"
                            if (fuelTypeLabel(record.fuelType) != null)
                              _buildTag(context, fuelTypeLabel(record.fuelType)!, Theme.of(context).colorScheme.secondary),
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
                              '${UnitConverter.distance(record.odometer, settings.distanceUnit).toStringAsFixed(0)}${UnitConverter.distanceSymbol(settings.distanceUnit)}',
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
                            color: _getFuelConsumptionColor(fuelConsumption).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${fuelConsumption.toStringAsFixed(1)}${record.energyType == 'electric' ? 'kWh/100km' : 'L/100km'}',
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
        color: color.withValues(alpha: 0.1),
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
