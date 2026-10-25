// 智记能耗 - 保养 / 费用录入弹窗
//
// 两者共用同一个弹窗，按 kind 决定字段：
//   保养（maintenance）：项目多选 + 当时里程
//   费用（other）      ：类型单选

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../providers/expenses_provider.dart';
import '../providers/maintenance_items_provider.dart';
import '../../../shared/widgets/labeled_field.dart';

String _fmtDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class ExpenseDialog extends ConsumerStatefulWidget {
  final int vehicleId;

  /// maintenance 或 other
  final String kind;

  /// 编辑时传入
  final Expense? expense;

  const ExpenseDialog({
    super.key,
    required this.vehicleId,
    required this.kind,
    this.expense,
  });

  @override
  ConsumerState<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends ConsumerState<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  /// 保养：已选项目
  final Set<String> _selectedItems = {};

  /// 费用：选中的类型
  String? _selectedCategory;

  bool get _isMaintenance => widget.kind == ExpenseKinds.maintenance;

  @override
  void initState() {
    super.initState();
    _dateController.text = _fmtDate(_selectedDate);

    if (widget.expense != null) {
      final e = widget.expense!;
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(e.date);
      _dateController.text = _fmtDate(_selectedDate);
      _amountController.text = e.amount.toString();
      _mileageController.text = e.mileage?.toString() ?? '';
      _notesController.text = e.notes ?? '';

      if (_isMaintenance) {
        final items = (e.items ?? '').split(',').where((s) => s.trim().isNotEmpty);
        _selectedItems.addAll(items.map((s) => s.trim()));
        _selectedCategory = e.category;
      } else {
        _selectedCategory = e.category;
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _fmtDate(picked);
      });
    }
  }


  /// 保养项目 chip
  ///
  /// 预设项用 FilterChip；自定义项用 InputChip —— 后者自带 onDeleted 删除按钮，
  /// 能真正接收点击（FilterChip 的 label 里塞按钮会被 chip 自身的手势吞掉）。
  Widget _buildItemChip(String item, {required bool isCustom}) {
    final selected = _selectedItems.contains(item);

    void toggle(bool v) {
      setState(() {
        if (v) {
          _selectedItems.add(item);
        } else {
          _selectedItems.remove(item);
        }
        _selectedCategory =
            _selectedItems.isEmpty ? null : _selectedItems.first;
      });
    }

    if (!isCustom) {
      return FilterChip(
        label: Text(item),
        selected: selected,
        onSelected: toggle,
      );
    }

    return InputChip(
      label: Text(item),
      selected: selected,
      onSelected: toggle,
      onDeleted: () => _removeCustomItem(item),
      deleteIcon: const Icon(Icons.close, size: 16),
      deleteButtonTooltipMessage: '删除这个自定义项目',
    );
  }

  /// 弹输入框新增自定义保养项目
  Future<void> _addCustomItem() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新增保养项目'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '项目名称',
            hintText: '例如：正时皮带',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    final trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return;

    await ref.read(customMaintenanceItemsProvider.notifier).add(trimmed);
    if (!mounted) return;
    setState(() {
      _selectedItems.add(trimmed);
      _selectedCategory = trimmed;
    });
  }

  /// 删除一个自定义项目（同时从已选中移除）
  Future<void> _removeCustomItem(String item) async {
    await ref.read(customMaintenanceItemsProvider.notifier).remove(item);
    if (!mounted) return;
    setState(() {
      _selectedItems.remove(item);
      if (_selectedCategory == item) {
        _selectedCategory =
            _selectedItems.isEmpty ? null : _selectedItems.first;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isMaintenance && _selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选一个保养项目')),
      );
      return;
    }
    if (!_isMaintenance && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择费用类型')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final mileage = _isMaintenance
        ? double.tryParse(_mileageController.text)
        : null;
    final items =
        _isMaintenance ? _selectedItems.join(',') : null;
    final category = _isMaintenance
        ? (_selectedCategory ?? '保养')
        : _selectedCategory!;

    try {
      final notifier = ref.read(expensesNotifierProvider.notifier);

      if (widget.expense == null) {
        await notifier.addExpense(
          vehicleId: widget.vehicleId,
          date: _selectedDate,
          kind: widget.kind,
          category: category,
          items: items,
          mileage: mileage,
          amount: amount,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await notifier.updateExpense(
          id: widget.expense!.id,
          vehicleId: widget.vehicleId,
          date: _selectedDate,
          kind: widget.kind,
          category: category,
          items: items,
          mileage: mileage,
          amount: amount,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final label = _isMaintenance ? '保养' : '费用';
    final customItems =
        ref.watch(customMaintenanceItemsProvider).valueOrNull ?? const <String>[];

    return AlertDialog(
      title: Text(isEditing ? '编辑$label记录' : '添加$label记录'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期
              LabeledField(
                label: '日期',
                isRequired: true,
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: fieldDecoration(
                    suffixIcon: Icons.calendar_today,
                    hint: '点击选择',
                  ),
                  onTap: _pickDate,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '请选择日期' : null,
                ),
              ),
              const SizedBox(height: 16),

              // 保养：项目多选
              if (_isMaintenance) ...[
                Text('保养项目 *（可多选）',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        )),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // 预设项目
                    for (final item in ExpenseCatalog.maintenanceCategories)
                      _buildItemChip(item, isCustom: false),
                    // 用户自定义项目（持久保存）
                    for (final item in customItems)
                      _buildItemChip(item, isCustom: true),
                    // 新增自定义项目
                    ActionChip(
                      avatar: Icon(Icons.add,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary),
                      label: Text('自定义',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.45),
                      ),
                      onPressed: _addCustomItem,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: '当时里程(公里)',
                  helper: '可留空',
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: fieldDecoration(
                      icon: Icons.speed,
                      hint: '例如:23500',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 费用：类型单选
              if (!_isMaintenance) ...[
                LabeledField(
                  label: '费用类型',
                  isRequired: true,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: fieldDecoration(
                      icon: Icons.category,
                      hint: '选择类型',
                    ),
                    items: ExpenseCatalog.otherCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedCategory = v;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 金额
              LabeledField(
                label: '金额(元)',
                isRequired: true,
                child: TextFormField(
                  controller: _amountController,
                  decoration: fieldDecoration(
                    icon: Icons.payments,
                    hint: '例如:380',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请输入金额';
                    if (double.tryParse(v) == null) return '请输入有效数字';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 备注
              LabeledField(
                label: '备注',
                child: TextFormField(
                  controller: _notesController,
                  decoration: fieldDecoration(
                    icon: Icons.note,
                    hint: '其他信息（可选）',
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
}
