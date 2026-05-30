// 智记油耗 - 添加/编辑车辆对话框
// 这个文件创建一个弹窗表单,让用户输入或修改车辆信息

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../providers/vehicles_provider.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/vehicle.dart' as model;

/// 车辆信息表单对话框
/// 
/// 这个对话框既可以用来添加新车,也可以用来编辑已有车辆
/// 通过传入[vehicle]参数来区分:
/// - 如果vehicle为null,则是添加模式
/// - 如果vehicle有值,则是编辑模式
class VehicleDialog extends ConsumerStatefulWidget {
  /// 要编辑的车辆(如果是添加模式,则为null)
  final model.Vehicle? vehicle;

  const VehicleDialog({super.key, this.vehicle});

  @override
  ConsumerState<VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends ConsumerState<VehicleDialog> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _selectedVehicleType;
  bool _isLoading = false;

  static const List<String> vehicleTypes = [
    '轿车',
    'SUV',
    'MPV',
    '面包车',
    '皮卡',
    '跑车',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _brandController.text = widget.vehicle!.brand;
      _modelController.text = widget.vehicle!.model;
      _licensePlateController.text = widget.vehicle!.licensePlate ?? '';
      _colorController.text = widget.vehicle!.color ?? '';
      _notesController.text = widget.vehicle!.notes ?? '';
      _selectedVehicleType = widget.vehicle!.vehicleType;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_isLoading) return;
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final database = ref.read(databaseProvider);

      if (widget.vehicle == null) {
        final count = await database.getVehicleCount();
        final shouldBeDefault = count == 0;
        final now = DateTime.now();

        await database.insertVehicle(
          VehiclesCompanion(
            brand: drift.Value(_brandController.text.trim()),
            model: drift.Value(_modelController.text.trim()),
            licensePlate: drift.Value(_licensePlateController.text.trim().isEmpty
                ? null
                : _licensePlateController.text.trim()),
            color: drift.Value(_colorController.text.trim().isEmpty
                ? null
                : _colorController.text.trim()),
            notes: drift.Value(_notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim()),
            vehicleType: drift.Value(_selectedVehicleType),
            isDefault: drift.Value(shouldBeDefault),
            createdAt: drift.Value(now.millisecondsSinceEpoch),
            updatedAt: drift.Value(now.millisecondsSinceEpoch),
          ),
        );
      } else {
        final existingVehicle = await database.getVehicleByIdNative(widget.vehicle!.id);
        if (existingVehicle == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('车辆不存在，请刷新后重试')),
            );
          }
          return;
        }
        final now = DateTime.now();

        await database.updateVehicle(
          VehiclesCompanion(
            id: drift.Value(widget.vehicle!.id),
            brand: drift.Value(_brandController.text.trim()),
            model: drift.Value(_modelController.text.trim()),
            licensePlate: drift.Value(_licensePlateController.text.trim().isEmpty
                ? null
                : _licensePlateController.text.trim()),
            color: drift.Value(_colorController.text.trim().isEmpty
                ? null
                : _colorController.text.trim()),
            notes: drift.Value(_notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim()),
            vehicleType: drift.Value(_selectedVehicleType),
            isDefault: drift.Value(existingVehicle.isDefault),
            createdAt: drift.Value(existingVehicle.createdAt),
            updatedAt: drift.Value(now.millisecondsSinceEpoch),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.vehicle == null ? '车辆添加成功' : '车辆信息已更新')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑车辆' : '添加车辆'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: '品牌 *',
                  hintText: '例如:丰田、本田、大众',
                  prefixIcon: Icon(Icons.branding_watermark),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入车辆品牌';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: '型号 *',
                  hintText: '例如:卡罗拉、雅阁、帕萨特',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入车辆型号';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: '车牌号码',
                  hintText: '例如:京A88888(可选)',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: '颜色',
                  hintText: '例如:白色、黑色、红色(可选)',
                  prefixIcon: Icon(Icons.color_lens),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: '车辆类型',
                  hintText: '选择车辆类型(可选)',
                  prefixIcon: Icon(Icons.category),
                ),
                items: vehicleTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVehicleType = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '备注',
                  hintText: '其他需要记录的信息(可选)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveVehicle,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }
}

/// 显示删除确认对话框
Future<bool> showDeleteConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('确认删除'),
      content: const Text('确定要删除这辆车吗?此操作不可恢复。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('删除'),
        ),
      ],
    ),
  );

  return result ?? false;
}