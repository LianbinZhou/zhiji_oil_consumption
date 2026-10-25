// 智记能耗 - 数据导出 / 导入（v1.0.0 可靠性重做）
//
// 2026-10-25 重写要点：
//   1. 导出格式升到 V2：记录从"嵌在车辆下"改为顶层 energy_records，
//      并补齐 is_default 与 settings，实现真正可还原
//   2. 导入同时支持 V1（历史备份）与 V2，V1 走显式键名映射
//   3. 导入整体包事务：一条失败全部回滚，不留半份脏数据
//   4. 导入前自动写一份"导前备份"，出问题还能回去
//   5. 导出改用系统文件保存对话框（SAF），用户能在文件管理器里找到文件
//      —— 原来写到 getDownloadsDirectory()，在 Android 上是应用私有目录，用户根本看不到
//   6. Excel 拆成两个 sheet：能源记录 / 其他支出

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/tables.dart';
import '../../vehicles/providers/vehicles_provider.dart';

/// 导出 / 导入结果
class ExportResult {
  final bool success;
  final String message;
  final String? filePath;

  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
  });
}

class ExportNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {}

  // ==================== 导出 JSON（V2） ====================

  Future<ExportResult> exportToJson(WidgetRef ref) async {
    final db = ref.read(databaseProvider);

    final vehicles = await db.getAllVehicles();
    if (vehicles.isEmpty) {
      return ExportResult(success: false, message: '没有数据可导出');
    }

    // 车辆
    final vehicleJson = <Map<String, dynamic>>[];
    // 记录（提到顶层）
    final recordJson = <Map<String, dynamic>>[];
    final expenseJson = <Map<String, dynamic>>[];

    for (final v in vehicles) {
      vehicleJson.add({
        'id': v.id,
        'brand': v.brand,
        'model': v.model,
        'license_plate': v.licensePlate,
        'color': v.color,
        'notes': v.notes,
        'vehicle_type': v.vehicleType,
        'is_default': v.isDefault,
        'energy_type': v.energyType,
        'created_at': DateTime.fromMillisecondsSinceEpoch(v.createdAt)
            .toIso8601String(),
        'updated_at': DateTime.fromMillisecondsSinceEpoch(v.updatedAt)
            .toIso8601String(),
      });

      for (final r in await db.getEnergyRecordsForVehicle(v.id)) {
        recordJson.add({
          'id': r.id,
          'vehicle_id': r.vehicleId,
          'energy_type': r.energyType,
          'date': DateTime.fromMillisecondsSinceEpoch(r.date).toIso8601String(),
          'quantity': r.quantity,
          'amount': r.amount,
          'discount': r.discount,
          'unit_price': r.unitPrice,
          'odometer': r.odometer,
          'is_full': r.isFull,
          'is_light_on': r.isLightOn,
          'fuel_type': r.fuelType,
          'charge_method': r.chargeMethod,
          'station_name': r.stationName,
          'notes': r.notes,
          'created_at': DateTime.fromMillisecondsSinceEpoch(r.createdAt)
              .toIso8601String(),
        });
      }

      for (final e in await db.getExpensesForVehicle(v.id)) {
        expenseJson.add({
          'id': e.id,
          'vehicle_id': e.vehicleId,
          'date': DateTime.fromMillisecondsSinceEpoch(e.date).toIso8601String(),
          'kind': e.kind,
          'category': e.category,
          'items': e.items,
          'mileage': e.mileage,
          'amount': e.amount,
          'notes': e.notes,
          'created_at': DateTime.fromMillisecondsSinceEpoch(e.createdAt)
              .toIso8601String(),
        });
      }
    }

    final data = <String, dynamic>{
      'version': '2.0',
      'schema_version': 5,
      'export_time': DateTime.now().toIso8601String(),
      'vehicles': vehicleJson,
      'energy_records': recordJson,
      'expenses': expenseJson,
      'settings': await _readSettings(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    final fileName =
        'zhiji_oil_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    return _saveBytes(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(jsonString)),
      allowedExtensions: const ['json'],
      dialogTitle: '保存 JSON 备份',
      successPrefix: '备份已保存',
    );
  }

  /// 读设置（导出用）
  Future<Map<String, dynamic>> _readSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'distance_unit': prefs.getInt('distance_unit') ?? 0,
      'fuel_unit': prefs.getInt('fuel_unit') ?? 0,
      'currency': prefs.getInt('currency') ?? 0,
      'theme_mode': prefs.getInt('theme_mode') ?? 2,
    };
  }

  // ==================== 导出 Excel（两个 sheet） ====================

  Future<ExportResult> exportToExcel(WidgetRef ref, int vehicleId) async {
    final db = ref.read(databaseProvider);

    final vehicle = await db.getVehicleById(vehicleId);
    if (vehicle == null) {
      return ExportResult(success: false, message: '车辆不存在');
    }

    final records = await db.getEnergyRecordsForVehicle(vehicleId);
    final expenseList = await db.getExpensesForVehicle(vehicleId);

    if (records.isEmpty && expenseList.isEmpty) {
      return ExportResult(success: false, message: '没有记录可导出');
    }

    final excel = Excel.createExcel();

    // ① 能源记录
    if (records.isNotEmpty) {
      final sheet = excel['能源记录'];
      final headers = [
        '日期', '能源类型', '数量', '单位', '实付金额(元)', '优惠(元)',
        '机显金额(元)', '单价', '里程(公里)', '是否加满', '是否亮灯', '油品',
        '充电方式', '站点', '备注',
      ];
      for (var c = 0; c < headers.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
            .value = TextCellValue(headers[c]);
      }

      var row = 1;
      for (final r in records) {
        final isElectric = r.energyType == EnergyTypes.electric;
        final d = DateTime.fromMillisecondsSinceEpoch(r.date);
        final values = <CellValue>[
          TextCellValue(_fmtDate(d)),
          TextCellValue(isElectric ? '充电' : '加油'),
          DoubleCellValue(r.quantity),
          TextCellValue(isElectric ? 'kWh' : 'L'),
          DoubleCellValue(r.amount),
          DoubleCellValue(r.discount),
          DoubleCellValue(r.amount + r.discount),
          DoubleCellValue(r.unitPrice),
          DoubleCellValue(r.odometer),
          TextCellValue(r.isFull ? '是' : '否'),
          TextCellValue(r.isLightOn ? '是' : '否'),
          TextCellValue(r.fuelType ?? ''),
          TextCellValue(_chargeMethodLabel(r.chargeMethod)),
          TextCellValue(r.stationName ?? ''),
          TextCellValue(r.notes ?? ''),
        ];
        for (var c = 0; c < values.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
              .value = values[c];
        }
        row++;
      }
    }

    // ② 其他支出
    if (expenseList.isNotEmpty) {
      final sheet = excel['其他支出'];
      final headers = ['日期', '类别', '类型', '保养项目', '里程(公里)', '金额(元)', '备注'];
      for (var c = 0; c < headers.length; c++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
            .value = TextCellValue(headers[c]);
      }

      var row = 1;
      for (final e in expenseList) {
        final isMaint = e.kind == ExpenseKinds.maintenance;
        final values = <CellValue>[
          TextCellValue(_fmtDate(DateTime.fromMillisecondsSinceEpoch(e.date))),
          TextCellValue(isMaint ? '保养' : '费用'),
          TextCellValue(e.category),
          TextCellValue(e.items ?? ''),
          if (e.mileage != null) DoubleCellValue(e.mileage!) else TextCellValue(''),
          DoubleCellValue(e.amount),
          TextCellValue(e.notes ?? ''),
        ];
        for (var c = 0; c < values.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: row))
              .value = values[c];
        }
        row++;
      }
    }

    // 删掉 Excel 包自带的默认空 sheet，避免导出文件里多一张空表
    for (final name in ['Sheet1', 'Sheet 1', 'sheet1']) {
      if (excel.sheets.containsKey(name)) {
        excel.delete(name);
        break;
      }
    }

    final bytes = excel.encode();
    if (bytes == null) {
      return ExportResult(success: false, message: 'Excel 生成失败');
    }

    final vehicleName = '${vehicle.brand}_${vehicle.model}';
    final fileName =
        'zhiji_oil_${vehicleName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    return _saveBytes(
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
      allowedExtensions: const ['xlsx'],
      dialogTitle: '保存 Excel 报表',
      successPrefix: 'Excel 已保存',
    );
  }

  // ==================== 统一的"另存为" ====================

  /// 用系统文件保存对话框（SAF）让用户自选位置，零权限
  Future<ExportResult> _saveBytes({
    required String fileName,
    required Uint8List bytes,
    required List<String> allowedExtensions,
    required String dialogTitle,
    required String successPrefix,
  }) async {
    try {
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        bytes: bytes,
      );

      if (savedPath == null) {
        return ExportResult(success: false, message: '已取消保存');
      }

      return ExportResult(
        success: true,
        message: '$successPrefix：${p.basename(savedPath)}',
        filePath: savedPath,
      );
    } catch (e) {
      return ExportResult(success: false, message: '保存失败：$e');
    }
  }

  // ==================== 导入 ====================

  Future<ExportResult> importFromJson(WidgetRef ref) async {
    // ① 选文件
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) {
      return ExportResult(success: false, message: '未选择文件');
    }
    final filePath = picked.files.single.path;
    if (filePath == null) {
      return ExportResult(success: false, message: '无法读取文件路径');
    }

    // ② 解析并校验格式（不合法直接返回，不碰数据库）
    Map<String, dynamic> data;
    try {
      final content = await File(filePath).readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        return ExportResult(success: false, message: '无效的备份文件格式');
      }
      data = decoded;
    } catch (e) {
      return ExportResult(success: false, message: '文件读取或解析失败：$e');
    }

    if (!data.containsKey('vehicles') || data['vehicles'] is! List) {
      return ExportResult(
        success: false,
        message: '无效的备份文件：缺少 vehicles 列表',
      );
    }

    final version = data['version']?.toString() ?? '';
    final isV2 = version.startsWith('2');

    // ③ 导前备份（失败也继续，但要告诉用户）
    String? preBackupPath;
    try {
      preBackupPath = await _writePreImportBackup(ref);
    } catch (_) {
      preBackupPath = null;
    }

    // ④ 事务导入
    final db = ref.read(databaseProvider);
    try {
      final counts = await db.transaction(() async {
        // 导入前先清空默认车标记，避免导入后出现多个「默认车」
        await db.clearAllDefaultVehicles();
        return isV2
            ? await _importV2(db, data)
            : await _importV1(db, data);
      });

      final backupNote = preBackupPath == null
          ? ''
          : '\n导入前的数据已备份到：\n$preBackupPath';

      return ExportResult(
        success: true,
        message: '导入完成\n车辆 ${counts.$1} 辆 · 能源记录 ${counts.$2} 条 · '
            '支出 ${counts.$3} 条$backupNote',
        filePath: preBackupPath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: '导入失败，数据已回滚到导入前状态。\n原因：$e',
      );
    }
  }

  /// 写一份"导前备份"到应用文档目录（自动，不让用户选位置）
  Future<String> _writePreImportBackup(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final vehicles = await db.getAllVehicles();

    final data = <String, dynamic>{
      'version': '2.0',
      'schema_version': 4,
      'export_time': DateTime.now().toIso8601String(),
      'note': '导入前自动备份',
      'vehicles': [
        for (final v in vehicles)
          {
            'id': v.id,
            'brand': v.brand,
            'model': v.model,
            'license_plate': v.licensePlate,
            'color': v.color,
            'notes': v.notes,
            'vehicle_type': v.vehicleType,
            'is_default': v.isDefault,
            'energy_type': v.energyType,
            'created_at': DateTime.fromMillisecondsSinceEpoch(v.createdAt)
                .toIso8601String(),
            'updated_at': DateTime.fromMillisecondsSinceEpoch(v.updatedAt)
                .toIso8601String(),
          }
      ],
      'energy_records': [
        for (final v in vehicles)
          for (final r in await db.getEnergyRecordsForVehicle(v.id))
            {
              'id': r.id,
              'vehicle_id': r.vehicleId,
              'energy_type': r.energyType,
              'date':
                  DateTime.fromMillisecondsSinceEpoch(r.date).toIso8601String(),
              'quantity': r.quantity,
              'amount': r.amount,
              'discount': r.discount,
              'unit_price': r.unitPrice,
              'odometer': r.odometer,
              'is_full': r.isFull,
              'is_light_on': r.isLightOn,
              'fuel_type': r.fuelType,
              'charge_method': r.chargeMethod,
              'station_name': r.stationName,
              'notes': r.notes,
              'created_at': DateTime.fromMillisecondsSinceEpoch(r.createdAt)
                  .toIso8601String(),
            }
      ],
      'expenses': [
        for (final v in vehicles)
          for (final e in await db.getExpensesForVehicle(v.id))
            {
              'id': e.id,
              'vehicle_id': e.vehicleId,
              'date':
                  DateTime.fromMillisecondsSinceEpoch(e.date).toIso8601String(),
              'kind': e.kind,
              'category': e.category,
              'items': e.items,
              'mileage': e.mileage,
              'amount': e.amount,
              'notes': e.notes,
              'created_at': DateTime.fromMillisecondsSinceEpoch(e.createdAt)
                  .toIso8601String(),
            }
      ],
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path,
        'zhiji_oil_before_import_${DateTime.now().millisecondsSinceEpoch}.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }

  /// V2 导入：顶层 energy_records / expenses，键名 snake_case
  Future<(int, int, int)> _importV2(
      AppDatabase db, Map<String, dynamic> data) async {
    final idMap = <int, int>{};
    var vehicleCount = 0;
    var recordCount = 0;
    var expenseCount = 0;

    for (final raw in data['vehicles'] as List) {
      final v = raw as Map<String, dynamic>;
      final oldId = (v['id'] as num?)?.toInt();
      final newId = await db.insertVehicle(VehiclesCompanion(
        brand: Value(v['brand'] as String? ?? ''),
        model: Value(v['model'] as String? ?? ''),
        licensePlate: Value(v['license_plate'] as String?),
        color: Value(v['color'] as String?),
        notes: Value(v['notes'] as String?),
        vehicleType: Value(v['vehicle_type'] as String?),
        isDefault: Value(v['is_default'] as bool? ?? false),
        energyType: Value(v['energy_type'] as String? ?? EnergyTypes.gasoline),
        createdAt: Value(_parseMs(v['created_at'])),
        updatedAt: Value(_parseMs(v['updated_at'])),
      ));
      if (oldId != null) idMap[oldId] = newId;
      vehicleCount++;
    }

    for (final raw in (data['energy_records'] as List? ?? const [])) {
      final r = raw as Map<String, dynamic>;
      final oldVid = (r['vehicle_id'] as num?)?.toInt();
      final newVid = oldVid == null ? null : idMap[oldVid];
      if (newVid == null) continue; // 找不到归属车辆就跳过，不写脏数据

      await db.insertEnergyRecord(EnergyRecordsCompanion(
        vehicleId: Value(newVid),
        // 白名单：只接受 gasoline / electric，其余一律按 gasoline（防手改备份导致记录消失）
        energyType: Value(_normalizeEnergyType(r['energy_type'])),
        date: Value(_parseMs(r['date'])),
        quantity: Value(_toDouble(r['quantity'])),
        amount: Value(_toDouble(r['amount'])),
        discount: Value(_toDouble(r['discount'])),  // 老备份没有这列 -> 0
        unitPrice: Value(_toDouble(r['unit_price'])),
        odometer: Value(_toDouble(r['odometer'])),
        isFull: Value(r['is_full'] as bool? ?? false),
        isLightOn: Value(r['is_light_on'] as bool? ?? false),
        fuelType: Value(r['fuel_type'] as String?),
        chargeMethod: Value(r['charge_method'] as String?),
        stationName: Value(r['station_name'] as String?),
        notes: Value(r['notes'] as String?),
        createdAt: Value(_parseMs(r['created_at'])),
      ));
      recordCount++;
    }

    for (final raw in (data['expenses'] as List? ?? const [])) {
      final e = raw as Map<String, dynamic>;
      final oldVid = (e['vehicle_id'] as num?)?.toInt();
      final newVid = oldVid == null ? null : idMap[oldVid];
      if (newVid == null) continue;

      await db.insertExpense(ExpensesCompanion(
        vehicleId: Value(newVid),
        date: Value(_parseMs(e['date'])),
        kind: Value(e['kind'] as String? ?? ExpenseKinds.other),
        category: Value(e['category'] as String? ?? '其他'),
        items: Value(e['items'] as String?),
        mileage: Value((e['mileage'] as num?)?.toDouble()),
        amount: Value(_toDouble(e['amount'])),
        notes: Value(e['notes'] as String?),
        createdAt: Value(_parseMs(e['created_at'])),
      ));
      expenseCount++;
    }

    // V2 也带 settings，顺手还原（失败不影响数据导入）
    if (data['settings'] is Map) {
      await _restoreSettings(data['settings'] as Map<String, dynamic>);
    }

    return (vehicleCount, recordCount, expenseCount);
  }

  /// V1 导入：记录嵌在 vehicles[].records[]，键名是老的驼峰
  Future<(int, int, int)> _importV1(
      AppDatabase db, Map<String, dynamic> data) async {
    var vehicleCount = 0;
    var recordCount = 0;
    var first = true;

    for (final raw in data['vehicles'] as List) {
      final v = raw as Map<String, dynamic>;

      // V1 没有 energy_type，按油车处理（当时只有加油记录（v4 前））
      final newId = await db.insertVehicle(VehiclesCompanion(
        brand: Value(v['brand'] as String? ?? ''),
        model: Value(v['model'] as String? ?? ''),
        licensePlate: Value(v['licensePlate'] as String?),
        color: Value(v['color'] as String?),
        notes: Value(v['notes'] as String?),
        vehicleType: Value(v['vehicleType'] as String?),
        // V1 不存默认车标记：把第一辆设为默认，避免全部都不是默认
        isDefault: Value(first),
        energyType: const Value(EnergyTypes.gasoline),
        createdAt: Value(_parseMs(v['createdAt'])),
        updatedAt: Value(_parseMs(v['updatedAt'])),
      ));
      first = false;
      vehicleCount++;

      final records = v['records'];
      if (records is! List) continue;

      for (final rr in records) {
        final r = rr as Map<String, dynamic>;
        await db.insertEnergyRecord(EnergyRecordsCompanion(
          vehicleId: Value(newId),
          energyType: const Value(EnergyTypes.gasoline),
          date: Value(_parseMs(r['date'])),
          // 键名映射：fuelAmount → quantity，其余同理
          quantity: Value(_toDouble(r['fuelAmount'])),
          amount: Value(_toDouble(r['totalPrice'])),
          unitPrice: Value(_toDouble(r['pricePerLiter'])),
          odometer: Value(_toDouble(r['odometer'])),
          isFull: Value(r['isFullTank'] as bool? ?? false),
          isLightOn: Value(r['isLightOn'] as bool? ?? false),
          fuelType: Value(r['fuelType'] as String?),
          stationName: Value(r['stationName'] as String?),
          notes: Value(r['notes'] as String?),
          createdAt: Value(_parseMs(r['createdAt'])),
        ));
        recordCount++;
      }
    }

    return (vehicleCount, recordCount, 0);
  }

  // ==================== 小工具 ====================

  Future<void> _restoreSettings(Map<String, dynamic> s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int read(String k, int fallback) {
        final v = s[k];
        if (v is num) return v.toInt();
        return fallback;
      }

      await prefs.setInt('distance_unit', read('distance_unit', 0));
      await prefs.setInt('fuel_unit', read('fuel_unit', 0));
      await prefs.setInt('currency', read('currency', 0));
      await prefs.setInt('theme_mode', read('theme_mode', 2));
    } catch (_) {
      // 设置还原失败不影响数据，静默跳过
    }
  }

  /// 能源类型白名单：非 gasoline/electric 一律归 gasoline
  String _normalizeEnergyType(dynamic v) {
    final t = v?.toString();
    return (t == EnergyTypes.electric) ? EnergyTypes.electric : EnergyTypes.gasoline;
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  int _parseMs(dynamic v) {
    if (v is num) return v.toInt();
    if (v is String) {
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt.millisecondsSinceEpoch;
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _chargeMethodLabel(String? method) {
    switch (method) {
      case ChargeMethods.fast:
        return '快充';
      case ChargeMethods.slow:
        return '慢充';
      case ChargeMethods.home:
        return '家充';
      default:
        return '';
    }
  }
}

/// 导出 Notifier 的 provider
final exportProvider =
    NotifierProvider.autoDispose<ExportNotifier, void>(ExportNotifier.new);
