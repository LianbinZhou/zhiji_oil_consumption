import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/records_provider.dart';
import '../../../shared/utils/fuel_type_label.dart';
import '../../vehicles/providers/vehicles_provider.dart';
import '../../../data/models/fuel_record.dart' as model;
import '../../../shared/widgets/labeled_field.dart';

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
  final _discountController = TextEditingController();
  /// 机显金额（油枪上显示的那笔"应付"）——加了多少油由它 ÷ 单价反推
  final _grossAmountController = TextEditingController();

  /// 用户是否手动改过「实付金额」
  /// 改过之后，数量/单价/优惠变动就不该再自动覆盖它（现实里实付经常和理论值不一致）
  bool _totalPriceManuallyEdited = false;

  /// 用户是否手动改过「升数」
  /// 手改之后就不再自动覆盖（油枪显示 96.74，公式算出来 96.7391，以油枪为准）
  bool _quantityManuallyEdited = false;
  final _pricePerLiterController = TextEditingController();
  final _odometerController = TextEditingController();
  final _stationNameController = TextEditingController();
  final _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isFullTank = true;
  bool _isLightOn = false;
  String? _selectedFuelType;

  /// 车辆能源类型：gasoline / electric / hybrid（从数据库读）
  String _vehicleEnergyType = 'gasoline';

  /// 本条记录是油还是电（纯电固定 electric；混动可在界面上切换）
  String _recordEnergyType = 'gasoline';

  /// 充电方式（仅充电记录）
  String? _selectedChargeMethod;

  /// 充电方式：存英文枚举（与 ChargeMethods 一致），界面显示中文
  static const Map<String, String> _chargeMethodOptions = {
    'fast': '快充',
    'slow': '慢充',
    'home': '家充',
  };

  bool get _isElectricMode => _recordEnergyType == 'electric';
  bool get _isHybrid => _vehicleEnergyType == 'hybrid';
  DateTime _selectedDate = DateTime.now();

  /// 油品标号（按现行国标）
  ///   汽油：92# / 95# / 98#
  ///   柴油：0# / -10# / -20# / -35#（数字是凝点，北方冬天要用低温标号）
  /// 存的是纯标号，界面上柴油会自动显示成「0#柴油」这类
  static const List<String> _fuelTypes = [
    '92#', '95#', '98#',
    '0#', '-10#', '-20#', '-35#',
    '其他',
  ];

  @override
  void initState() {
    super.initState();

    _dateController.text = _formatDate(_selectedDate);
    _loadVehicleEnergyType();

    if (widget.record != null) {
      // 编辑态：能源类型和充电方式都取自「这条记录自己」，绝不能从车辆类型推导
      _recordEnergyType = widget.record!.energyType;
      _selectedChargeMethod = widget.record!.chargeMethod;
      _selectedDate = widget.record!.date;
      _dateController.text = _formatDate(_selectedDate);
      _fuelAmountController.text = widget.record!.fuelAmount.toString();
      _totalPriceController.text = widget.record!.totalPrice.toString();
      _discountController.text =
          widget.record!.discount > 0 ? widget.record!.discount.toString() : '';
      _pricePerLiterController.text = widget.record!.pricePerLiter.toString();
      // 机显金额 = 实付 + 优惠（库里只存这两个，机显是推算出来的）
      _grossAmountController.text =
          (widget.record!.totalPrice + widget.record!.discount)
              .toStringAsFixed(2);
      _odometerController.text = widget.record!.odometer.toString();
      _isFullTank = widget.record!.isFullTank;
      _isLightOn = widget.record!.isLightOn;
      // 导入的数据里柴油是 "0#"，下拉选项是 "0#柴油"，这里归一化一下
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

  /// 读取车辆能源类型，决定界面显示加油字段还是充电字段
  Future<void> _loadVehicleEnergyType() async {
    try {
      final db = ref.read(databaseProvider);
      final v = await db.getVehicleById(widget.vehicleId);
      if (v == null || !mounted) return;
      setState(() {
        _vehicleEnergyType = v.energyType;
        // 只有「新建记录」才由车辆类型决定默认能源；
        // 编辑既有记录时必须保留它自己的 energyType（否则混动的充电记录会被改成加油）
        if (widget.record == null) {
          _recordEnergyType =
              v.energyType == 'electric' ? 'electric' : 'gasoline';
        }
      });
    } catch (_) {
      // 读不到车辆就按油车处理，不阻断录入
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fuelAmountController.dispose();
    _totalPriceController.dispose();
    _discountController.dispose();
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

  /// 机显金额 = 数量 × 单价；实付 = 机显 − 优惠
  ///
  /// 为什么这么算：油站标价和你实际付的钱经常不一样（会员价、券、活动）。
  /// 统计里的「每公里成本」「均价」都用实付，所以输入框显示的是扣完优惠的金额。
  /// 按「单价 + 机显金额」反推升数，再算实付
  ///
  /// 为什么升数必须从「机显金额」算：
  ///   机显金额 = 单价 × 升数      ← 油枪上的应付
  ///   实付金额 = 机显金额 − 优惠   ← 实际扣款
  /// 用「实付 ÷ 单价」是错的 —— 优惠不是按比例打折，会把升数算少
  /// （例：单价 8.28、机显 801、实付 780.5 → 正确 96.74 L，错算 94.26 L）。
  void _calculatePrice() {
    final unitPrice = double.tryParse(_pricePerLiterController.text);
    final gross = double.tryParse(_grossAmountController.text);
    final discount = double.tryParse(_discountController.text) ?? 0;

    // 升数 = 机显 ÷ 单价（保留 2 位，和油枪显示一致）
    if (!_quantityManuallyEdited &&
        unitPrice != null &&
        unitPrice > 0 &&
        gross != null &&
        gross > 0) {
      _fuelAmountController.text = (gross / unitPrice).toStringAsFixed(2);
    }

    // 实付 = 机显 − 优惠
    if (!_totalPriceManuallyEdited && gross != null) {
      final paid = gross - discount;
      _totalPriceController.text =
          (paid > 0 ? paid : 0).toStringAsFixed(2);
    }
  }

  // ==================== 录入校验（项 2.4）====================
  // 原则：只提示、不硬拦。用户点"确认保存"仍可写入。
  // 为什么要有：数据一旦录错，后面的区间求和与加权平均都在错误数据上算得"很精确"。

  Future<List<String>> _collectWarnings({
    required DateTime date,
    required double quantity,
    required double unitPrice,
    required double odometer,
  }) async {
    final warnings = <String>[];

    // ① 单价远大于数量：才大概率是把两者填反了。
    //    用 3 倍阈值避免误报（例：加 5 L、单价 7.5 元/L 是合法的）
    if (quantity > 0 && unitPrice > quantity * 3) {
      warnings.add(
        '单价 ${unitPrice.toStringAsFixed(2)} 比数量 ${quantity.toStringAsFixed(2)} 还大，'
        '是不是把单价和数量填反了？',
      );
    }

    // ② / ③ 与上一条对比（编辑既有记录时跳过，避免拿自己跟自己比）
    if (widget.record == null) {
      final latest =
          await ref.read(latestRecordProvider(widget.vehicleId).future);
      if (latest != null) {
        if (odometer <= latest.odometer) {
          warnings.add(
            '这条的里程 ${odometer.toStringAsFixed(0)} 比上一条 '
            '${latest.odometer.toStringAsFixed(0)} 少或相等。'
            '两次加油/充电之间里程应该增加，是不是填错了？',
          );
        }

        final latestDay = DateTime(
            latest.date.year, latest.date.month, latest.date.day);
        final thisDay = DateTime(date.year, date.month, date.day);
        if (thisDay.isBefore(latestDay)) {
          warnings.add(
            '这条的日期（${_formatDate(date)}）比上一条'
            '（${_formatDate(latest.date)}）早，确认吗？',
          );
        }
      }
    }

    return warnings;
  }

  Future<bool?> _confirmWarnings(List<String> warnings) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('数据看起来有问题'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: warnings
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(w)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('返回修改'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ===== 录入校验：先提示，用户确认后再写 =====
    final preQuantity = double.tryParse(_fuelAmountController.text) ?? 0;
    final prePrice = double.tryParse(_pricePerLiterController.text) ?? 0;
    final preOdometer = double.tryParse(_odometerController.text) ?? 0;
    final warnings = await _collectWarnings(
      date: _selectedDate,
      quantity: preQuantity,
      unitPrice: prePrice,
      odometer: preOdometer,
    );
    if (warnings.isNotEmpty) {
      if (!mounted) return;
      final confirmed = await _confirmWarnings(warnings);
      if (confirmed != true) return;
    }

    try {
      final notifier = ref.read(recordsNotifierProvider.notifier);

      final fuelAmount = double.parse(_fuelAmountController.text);
      final totalPrice = double.parse(_totalPriceController.text);
      final pricePerLiter = double.parse(_pricePerLiterController.text);
      final odometer = double.parse(_odometerController.text);
      final discount = double.tryParse(_discountController.text) ?? 0;
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
          fuelType: _isElectricMode ? null : _selectedFuelType,
          chargeMethod: _isElectricMode ? _selectedChargeMethod : null,
          energyType: _recordEnergyType,
          discount: discount,
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
          fuelType: _isElectricMode ? null : _selectedFuelType,
      chargeMethod: _isElectricMode ? _selectedChargeMethod : null,
      energyType: _recordEnergyType,
          stationName: stationName.isEmpty ? null : stationName,
          // 编辑时必须把优惠原样带回去，否则 updateRecord 的默认值 0 会把它清零
          discount: discount,
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


  @override
  Widget build(BuildContext context) {
    final isEditing = widget.record != null;

    return AlertDialog(
      title: Text(isEditing ? '编辑记录' : '添加能源记录'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 给第一个输入框的浮动标签留出空间
              const SizedBox(height: 6),
              // 混动车：先选这次是加油还是充电
              if (_isHybrid) ...[
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'gasoline',
                      label: Text('加油'),
                      icon: Icon(Icons.local_gas_station),
                    ),
                    ButtonSegment(
                      value: 'electric',
                      label: Text('充电'),
                      icon: Icon(Icons.battery_charging_full),
                    ),
                  ],
                  selected: {_recordEnergyType},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _recordEnergyType = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

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
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请选择日期';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: _isElectricMode ? '电价(元/度)' : '单价(元/升)',
                isRequired: true,
                child: TextFormField(
                  controller: _pricePerLiterController,
                  decoration: fieldDecoration(
                    icon: Icons.currency_yen,
                    hint: _isElectricMode ? '例如:1.20' : '例如:7.50',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculatePrice(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _isElectricMode ? '请输入电价' : '请输入单价';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || !parsed.isFinite) {
                      return '请输入有效数字';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 机显金额：油枪上那笔"应付"。填了它 + 单价，升数就能自动算准
              LabeledField(
                label: _isElectricMode ? '机显金额(元)' : '机显金额(元)',
                isRequired: true,
                helper: '油枪上显示的应付金额',
                child: TextFormField(
                  controller: _grossAmountController,
                  decoration: fieldDecoration(
                    icon: Icons.receipt_long,
                    hint: _isElectricMode ? '例如:60.00' : '例如:801.00',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculatePrice(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入机显金额';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || !parsed.isFinite) {
                      return '请输入有效数字';
                    }
                    if (parsed <= 0) return '机显金额要大于 0';
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: _isElectricMode ? '充电量(kWh)' : '加油量(升)',
                isRequired: true,
                helper: '机显金额 ÷ 单价，自动算出；和油枪对不上可以手改',
                child: TextFormField(
                  controller: _fuelAmountController,
                  decoration: fieldDecoration(
                    icon: _isElectricMode
                        ? Icons.battery_charging_full
                        : Icons.local_gas_station,
                    hint: _isElectricMode ? '自动计算' : '自动计算',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    // 手改过就标记，之后单价/机显再变也不覆盖它
                    _quantityManuallyEdited = true;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return _isElectricMode ? '请输入充电量' : '请输入加油量';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || !parsed.isFinite) {
                      return '请输入有效数字';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: '优惠金额(元)',
                helper: '油站优惠/券，没有就留空',
                child: TextFormField(
                  controller: _discountController,
                  decoration: fieldDecoration(
                    icon: Icons.local_offer,
                    hint: '例如:43',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _calculatePrice(),
                  validator: (v) {
                    final d = double.tryParse(v ?? '');
                    if (d == null) return null;
                    if (d < 0) return '优惠不能是负数';
                    final q = double.tryParse(_fuelAmountController.text) ?? 0;
                    final up =
                        double.tryParse(_pricePerLiterController.text) ?? 0;
                    if (q > 0 && up > 0 && d > q * up) {
                      return '优惠不能超过机显金额（${(q * up).toStringAsFixed(2)}）';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: '实付金额(元)',
                isRequired: true,
                helper: '机显金额 − 优惠，也可手改',
                child: TextFormField(
                  controller: _totalPriceController,
                  decoration: fieldDecoration(
                    icon: Icons.payments,
                    hint: '例如:450.96',
                  ),
                  onChanged: (_) => _totalPriceManuallyEdited = true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请输入总金额';
                    final parsed = double.tryParse(value);
                    if (parsed == null || !parsed.isFinite) {
                      return '请输入有效数字';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: '当前里程(公里)',
                isRequired: true,
                child: TextFormField(
                  controller: _odometerController,
                  decoration: fieldDecoration(
                    icon: Icons.speed,
                    hint: '仪表盘读数',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请输入里程数';
                    final parsed = double.tryParse(value);
                    if (parsed == null || !parsed.isFinite) {
                      return '请输入有效数字';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: _isElectricMode ? '充电方式' : '油品类型',
                child: DropdownButtonFormField<String>(
                  initialValue: _isElectricMode
                      ? _selectedChargeMethod
                      : _selectedFuelType,
                  decoration: fieldDecoration(
                    icon: _isElectricMode
                        ? Icons.ev_station
                        : Icons.oil_barrel,
                    hint: _isElectricMode ? '选择充电方式' : '选择油品标号',
                  ),
                  items: _isElectricMode
                      ? _chargeMethodOptions.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList()
                      : [
                          // 历史数据可能是 '0#柴油'、'93#'、'97#' 这些不在标准列表里的值；
                          // 不补进去的话 DropdownButton 的 initialValue 找不到匹配项（debug 会断言失败）
                          ...{
                            if (_selectedFuelType != null) _selectedFuelType!,
                            ..._fuelTypes,
                          }
                        ]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                // 0# / -10# 这类显示成「0#柴油」，方便辨认
                                child: Text(fuelTypeLabel(type) ?? type),
                              ))
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      if (_isElectricMode) {
                        _selectedChargeMethod = value;
                      } else {
                        _selectedFuelType = value;
                      }
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              LabeledField(
                label: _isElectricMode ? '充电站名称' : '加油站名称',
                child: TextFormField(
                  controller: _stationNameController,
                  maxLength: 50,
                  decoration: fieldDecoration(
                    icon: Icons.store,
                    hint: _isElectricMode ? '例如:特来电XX站' : '例如:中石化XX站',
                  ),
                ),
              ),

              const SizedBox(height: 8),

              SwitchListTile(
                title: Text(_isElectricMode ? '是否充满' : '是否加满'),
                subtitle: Text(_isElectricMode
                    ? '充满有助于准确计算电耗'
                    : '加满有助于准确计算油耗'),
                value: _isFullTank,
                onChanged: (value) {
                  setState(() {
                    _isFullTank = value;
                  });
                },
              ),

              SwitchListTile(
                title: Text(_isElectricMode ? '油灯提示（纯电车不适用）' : '油灯亮了'),
                subtitle: Text(
                    _isElectricMode ? '纯电车没有油灯' : '亮灯法计算油耗更精准'),
                value: _isLightOn,
                onChanged: (value) {
                  setState(() {
                    _isLightOn = value;
                  });
                },
              ),

              const SizedBox(height: 8),

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