import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/records_provider.dart';
import '../../vehicles/providers/vehicles_provider.dart';
import '../../../data/models/fuel_record.dart' as model;

String _formatDate(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class RecordDialog extends ConsumerStatefulWidget {
  final int vehicleId;
  final model.FuelRecordModel? record;

  const RecordDialog({
    super.key, 
    required this.vehicleId,
    this.record,
  });

  @override
  ConsumerState<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends ConsumerState<RecordDialog> {
  final _dateController = TextEditingController();
  final _fuelAmountController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _odometerController = TextEditingController();
  final _stationNameController = TextEditingController();
  final _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isFullTank = true;
  bool _isLightOn = false;
  String? _selectedFuelType;
  DateTime _selectedDate = DateTime.now();

  static const List<String> _fuelTypes = ['92#', '95#', '98#', '0#柴油', '其他'];

  @override
  void initState() {
    super.initState();

    _dateController.text = _formatDate(_selectedDate);

    if (widget.record != null) {
      _selectedDate = widget.record!.date;
      _dateController.text = _formatDate(_selectedDate);
      _fuelAmountController.text = widget.record!.fuelAmount.toString();
      _totalPriceController.text = widget.record!.totalPrice.toString();
      _pricePerLiterController.text = widget.record!.pricePerLiter.toString();
      _odometerController.text = widget.record!.odometer.toString();
      _isFullTank = widget.record!.isFullTank;
      _isLightOn = widget.record!.isLightOn;
      _selectedFuelType = widget.record!.fuelType;
      _stationNameController.text = widget.record!.stationName ?? '';
      _notesController.text = widget.record!.notes ?? '';
    } else {
      _loadLatestData();
    }
  }

  Future<void> _loadLatestData() async {
    final latestRecord = await ref.read(latestRecordProvider(widget.vehicleId).future);

    if (latestRecord != null && mounted) {
      _pricePerLiterController.text = latestRecord.pricePerLiter.toString();
      _selectedFuelType = latestRecord.fuelType;
      setState(() {
        _odometerController.text = '';
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fuelAmountController.dispose();
    _totalPriceController.dispose();
    _pricePerLiterController.dispose();
    _odometerController.dispose();
    _stationNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _calculatePrice() {
    final fuelAmount = double.tryParse(_fuelAmountController.text);
    final pricePerLiter = double.tryParse(_pricePerLiterController.text);

    if (fuelAmount != null && pricePerLiter != null) {
      final totalPrice = fuelAmount * pricePerLiter;
      _totalPriceController.text = totalPrice.toStringAsFixed(2);
    }
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final notifier = ref.read(recordsNotifierProvider.notifier);

      final fuelAmount = double.parse(_fuelAmountController.text);
      final totalPrice = double.parse(_totalPriceController.text);
      final pricePerLiter = double.parse(_pricePerLiterController.text);
      final odometer = double.parse(_odometerController.text);
      final stationName = _stationNameController.text.trim();
      final notes = _notesController.text.trim();

      if (widget.record == null) {
        await notifier.addRecord(
          vehicleId: widget.vehicleId,
          date: _selectedDate,
          fuelAmount: fuelAmount,
          totalPrice: totalPrice,
          pricePerLiter: pricePerLiter,
          odometer: odometer,
          isFullTank: _isFullTank,
          isLightOn: _isLightOn,
          fuelType: _selectedFuelType,
          stationName: stationName.isEmpty ? null : stationName,
          notes: notes.isEmpty ? null : notes,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('记录添加成功')),
          );
        }
      } else {
        await notifier.updateRecord(
          id: widget.record!.id,
          vehicleId: widget.vehicleId,
          date: _selectedDate,
          fuelAmount: fuelAmount,
          totalPrice: totalPrice,
          pricePerLiter: pricePerLiter,
          odometer: odometer,
          isFullTank: _isFullTank,
          isLightOn: _isLightOn,
          fuelType: _selectedFuelType,
          stationName: stationName.isEmpty ? null : stationName,
          notes: notes.isEmpty ? null : notes,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('记录已更新')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑记录' : '添加加油记录'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: _inputDecoration('日期 *', Icons.calendar_today),
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择日期';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _fuelAmountController,
                decoration: _inputDecoration('加油量(升) *', Icons.local_gas_station, hint: '例如:50.5'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calculatePrice(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入加油量';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效数字';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pricePerLiterController,
                decoration: _inputDecoration('单价(元/升) *', Icons.attach_money, hint: '例如:7.50'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _calculatePrice(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入单价';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效数字';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _totalPriceController,
                decoration: _inputDecoration('总金额(元) *', Icons.payments, hint: '自动计算或手动输入'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入总金额';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效数字';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _odometerController,
                decoration: _inputDecoration('当前里程(公里) *', Icons.speed, hint: '例如:15000'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入里程数';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效数字';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration: _inputDecoration('油品类型', Icons.oil_barrel),
                items: _fuelTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _stationNameController,
                decoration: _inputDecoration('加油站名称', Icons.store, hint: '例如:中石化XX站'),
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text('是否加满'),
                subtitle: const Text('加满有助于准确计算油耗'),
                value: _isFullTank,
                onChanged: (value) {
                  setState(() {
                    _isFullTank = value;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('油灯亮了'),
                subtitle: const Text('亮灯法计算油耗更精准'),
                value: _isLightOn,
                onChanged: (value) {
                  setState(() {
                    _isLightOn = value;
                  });
                },
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('备注', Icons.note, hint: '其他信息(可选)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveRecord,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
}