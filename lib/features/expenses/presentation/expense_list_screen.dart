// 智记能耗 - 保养 / 费用列表页（两者共用，按 kind 区分）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../providers/expenses_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/utils/unit_converter.dart';
import 'expense_dialog.dart';

class ExpenseListScreen extends ConsumerWidget {
  final int vehicleId;

  /// maintenance / other
  final String kind;

  /// 车辆名（显示在标题里）
  final String vehicleName;

  const ExpenseListScreen({
    super.key,
    required this.vehicleId,
    required this.kind,
    required this.vehicleName,
  });

  bool get _isMaintenance => kind == ExpenseKinds.maintenance;
  String get _label => _isMaintenance ? '保养记录' : '费用账本';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider(vehicleId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_label),
            Text(vehicleName,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (all) {
          final list = all.where((e) => e.kind == kind).toList();
          if (list.isEmpty) {
            return _buildEmpty(context);
          }

          final total = list.fold<double>(0, (s, e) => s + e.amount);

          return Column(
            children: [
              // 汇总条
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                child: Row(
                  children: [
                    Text('共 ${list.length} 笔',
                        style: theme.textTheme.bodySmall),
                    const Spacer(),
                    Text('合计 ¥${total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                  itemCount: list.length,
                  itemBuilder: (context, index) =>
                      _buildCard(context, ref, list[index]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.add),
        label: Text(_isMaintenance ? '记一次保养' : '记一笔费用'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isMaintenance ? Icons.build_circle_outlined : Icons.receipt_long,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(_isMaintenance ? '还没有保养记录' : '还没有费用记录',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            _isMaintenance
                ? '换机油、刹车片这类计划性支出记在这里'
                : '保险、停车、洗车、罚款这类支出记在这里',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, Expense e) {
    final theme = Theme.of(context);
    final date = DateTime.fromMillisecondsSinceEpoch(e.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _openDialog(context, expense: e),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            '${date.month}月',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        title: Text(
          _isMaintenance
              ? (e.items?.isNotEmpty == true ? e.items! : e.category)
              : e.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            if (_isMaintenance && e.mileage != null)
              '${UnitConverter.distance(e.mileage!, ref.watch(settingsProvider).settings.distanceUnit).toStringAsFixed(0)} ${UnitConverter.distanceSymbol(ref.watch(settingsProvider).settings.distanceUnit)}',
            if (e.notes?.isNotEmpty == true) e.notes!,
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¥${e.amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _confirmDelete(context, ref, e),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context, {Expense? expense}) async {
    await showDialog<bool>(
      context: context,
      builder: (ctx) => ExpenseDialog(
        vehicleId: vehicleId,
        kind: kind,
        expense: expense,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条记录？'),
        content: Text(
            '${e.category}  ¥${e.amount.toStringAsFixed(2)}，删除后无法恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除')),
        ],
      ),
    );

    if (ok != true) return;
    try {
      await ref.read(expensesNotifierProvider.notifier).deleteExpense(e.id);
    } catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('删除失败：$err')));
    }
  }
}
