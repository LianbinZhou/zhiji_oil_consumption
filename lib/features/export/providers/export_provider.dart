// 智记油耗 - 数据导出Provider
// 这个文件提供数据导出和导入功能

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// 导入数据模型
import '../../../data/models/vehicle.dart' as model;
import '../../../data/models/fuel_record.dart' as model_record;
// 导入数据库表定义（用于Companion类）
import '../../../data/database/app_database.dart';
// 导入Provider
import '../../vehicles/providers/vehicles_provider.dart';
import '../../records/providers/records_provider.dart';

/// 导出结果类
/// 
/// 用于返回导出操作的结果
class ExportResult {
  /// 是否成功
  final bool success;
  
  /// 消息提示
  final String message;
  
  /// 导出的文件路径（如果成功）
  final String? filePath;

  ExportResult({
    required this.success,
    required this.message,
    this.filePath,
  });
}

/// 数据导出Notifier
/// 
/// 管理数据导出和导入操作
class ExportNotifier extends AutoDisposeNotifier<void> {
  @override
  void build() {
    // 这个Provider不需要状态，只执行操作
  }

  /// 导出所有数据为JSON备份文件
  Future<ExportResult> exportToJson(WidgetRef ref) async {
    try {
      // 获取数据库实例
      final database = ref.read(databaseProvider);
      
      // 获取所有车辆
      final vehicles = await database.getAllVehiclesNative();
      
      if (vehicles.isEmpty) {
        return ExportResult(
          success: false,
          message: '没有数据可导出',
        );
      }
      
      // 构建导出数据结构
      final exportData = <String, dynamic>{
        'version': '1.0', // 备份文件格式版本
        'exportTime': DateTime.now().toIso8601String(),
        'vehicles': <dynamic>[],
      };
      
      // 遍历所有车辆，收集数据
      for (final vehicle in vehicles) {
        final vehicleData = <String, dynamic>{
          'id': vehicle.id,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'licensePlate': vehicle.licensePlate,
          'color': vehicle.color,
          'vehicleType': vehicle.vehicleType,
          'notes': vehicle.notes,
          'createdAt': DateTime.fromMillisecondsSinceEpoch(vehicle.createdAt).toIso8601String(),
          'updatedAt': DateTime.fromMillisecondsSinceEpoch(vehicle.updatedAt).toIso8601String(),
          'records': <dynamic>[],
        };
        
        // 获取该车辆的所有加油记录
        final records = await database.getFuelRecordsForVehicleNative(vehicle.id);
        
        // 添加记录数据
        for (final record in records) {
          vehicleData['records'].add({
            'id': record.id,
            'date': DateTime.fromMillisecondsSinceEpoch(record.date).toIso8601String(),
            'fuelAmount': record.fuelAmount,
            'totalPrice': record.totalPrice,
            'pricePerLiter': record.pricePerLiter,
            'odometer': record.odometer,
            'isFullTank': record.isFullTank,
            'isLightOn': record.isLightOn,
            'fuelType': record.fuelType,
            'stationName': record.stationName,
            'notes': record.notes,
            'createdAt': DateTime.fromMillisecondsSinceEpoch(record.createdAt).toIso8601String(),
          });
        }
        
        exportData['vehicles'].add(vehicleData);
      }
      
      // 转换为JSON字符串
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // 生成文件名（包含时间戳）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'zhiji_oil_backup_$timestamp.json';
      
      // 获取导出目录（优先下载目录，移动端回退到应用文档目录）
      var directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();

      // 保存文件
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsString(jsonString);
      
      return ExportResult(
        success: true,
        message: '备份已保存到: $fileName',
        filePath: filePath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: '导出失败: $e',
      );
    }
  }

  /// 导出加油记录为Excel文件
  Future<ExportResult> exportToExcel(WidgetRef ref, int vehicleId) async {
    try {
      // 获取数据库实例
      final database = ref.read(databaseProvider);
      
      // 获取车辆信息
      final vehicleNative = await database.getVehicleByIdNative(vehicleId);
      
      if (vehicleNative == null) {
        return ExportResult(
          success: false,
          message: '车辆不存在',
        );
      }
      
      // 获取该车辆的所有加油记录
      final recordsNative = await database.getFuelRecordsForVehicleNative(vehicleId);
      
      if (recordsNative.isEmpty) {
        return ExportResult(
          success: false,
          message: '没有记录可导出',
        );
      }
      
      // 转换为自定义模型并按日期排序（从旧到新）
      final records = recordsNative.map((r) => model_record.FuelRecordModel(
        id: r.id,
        vehicleId: r.vehicleId,
        date: DateTime.fromMillisecondsSinceEpoch(r.date),
        fuelAmount: r.fuelAmount,
        totalPrice: r.totalPrice,
        pricePerLiter: r.pricePerLiter,
        odometer: r.odometer,
        isFullTank: r.isFullTank,
        isLightOn: r.isLightOn,
        fuelType: r.fuelType,
        stationName: r.stationName,
        notes: r.notes,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
      )).toList()..sort((a, b) => a.date.compareTo(b.date));
      
      // 创建Excel工作簿
      final excel = Excel.createExcel();
      final sheet = excel['加油记录'];
      
      // 设置表头
      final headers = [
        '日期',
        '加油量(升)',
        '总金额(元)',
        '单价(元/升)',
        '里程(公里)',
        '是否加满',
        '灯亮',
        '油品',
        '加油站',
        '油耗(升/100公里)',
        '备注',
      ];
      
      for (int col = 0; col < headers.length; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).value = TextCellValue(headers[col]);
      }
      
      // 添加数据行
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final row = i + 1; // 第0行是表头
        
        // 计算油耗（需要上一条记录的里程）
        String fuelConsumption = '-';
        if (i > 0) {
          final previousRecord = records[i - 1];
          final consumption = record.calculateFuelConsumption(previousRecord.odometer);
          if (consumption != null) {
            fuelConsumption = consumption.toStringAsFixed(2);
          }
        }
        
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(record.date.toString().substring(0, 10));
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = DoubleCellValue(record.fuelAmount);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue(record.totalPrice);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = DoubleCellValue(record.pricePerLiter);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = DoubleCellValue(record.odometer);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(record.isFullTank ? '是' : '否');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row)).value = TextCellValue(record.isLightOn ? '是' : '否');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row)).value = TextCellValue(record.fuelType ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row)).value = TextCellValue(record.stationName ?? '');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row)).value = TextCellValue(fuelConsumption);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row)).value = TextCellValue(record.notes ?? '');
      }
      
      // 生成文件名
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final vehicleName = '${vehicleNative.brand}_${vehicleNative.model}';
      final fileName = 'zhiji_oil_${vehicleName}_$timestamp.xlsx';
      
      // 获取导出目录（优先下载目录，移动端回退到应用文档目录）
      var directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();

      // 保存文件
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      final bytes = excel.encode();
      if (bytes == null) {
        return ExportResult(
          success: false,
          message: 'Excel文件生成失败',
        );
      }
      await file.writeAsBytes(bytes);
      
      return ExportResult(
        success: true,
        message: 'Excel已保存到: $fileName',
        filePath: filePath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: '导出失败: $e',
      );
    }
  }

  /// 从JSON文件导入数据
  Future<ExportResult> importFromJson(WidgetRef ref) async {
    try {
      // 打开文件选择对话框
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.isEmpty) {
        return ExportResult(
          success: false,
          message: '未选择文件',
        );
      }
      
      final filePath = result.files.single.path;
      if (filePath == null) {
        return ExportResult(
          success: false,
          message: '无法获取文件路径',
        );
      }
      
      // 读取文件内容
      final file = File(filePath);
      final jsonString = await file.readAsString();
      
      // 解析JSON
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 验证文件格式
      if (!jsonData.containsKey('version') || !jsonData.containsKey('vehicles')) {
        return ExportResult(
          success: false,
          message: '无效的备份文件格式',
        );
      }
      
      final database = ref.read(databaseProvider);
      
      // 开始导入数据
      int vehicleCount = 0;
      int recordCount = 0;
      
      final vehiclesData = jsonData['vehicles'] as List<dynamic>;
      
      for (final vehicleData in vehiclesData) {
        final vData = vehicleData as Map<String, dynamic>;
        
        // 插入车辆（不指定ID，让数据库自动生成）
        final newVehicleId = await database.insertVehicle(
          VehiclesCompanion(
            brand: Value(vData['brand'] as String),
            model: Value(vData['model'] as String),
            licensePlate: Value(vData['licensePlate'] as String?),
            color: Value(vData['color'] as String?),
            vehicleType: Value(vData['vehicleType'] as String?),
            notes: Value(vData['notes'] as String?),
            createdAt: Value(DateTime.parse(vData['createdAt'] as String).millisecondsSinceEpoch),
            updatedAt: Value(DateTime.parse(vData['updatedAt'] as String).millisecondsSinceEpoch),
          ),
        );
        
        vehicleCount++;
        
        // 插入该车辆的加油记录
        final recordsData = vData['records'] as List<dynamic>;
        for (final recordData in recordsData) {
          final rData = recordData as Map<String, dynamic>;
          
          await database.insertFuelRecord(
            FuelRecordsCompanion(
              vehicleId: Value(newVehicleId),
              date: Value(DateTime.parse(rData['date'] as String).millisecondsSinceEpoch),
              fuelAmount: Value((rData['fuelAmount'] as num).toDouble()),
              totalPrice: Value((rData['totalPrice'] as num).toDouble()),
              pricePerLiter: Value((rData['pricePerLiter'] as num).toDouble()),
              odometer: Value((rData['odometer'] as num).toDouble()),
              isFullTank: Value(rData['isFullTank'] as bool),
              isLightOn: Value(rData['isLightOn'] as bool? ?? false),
              fuelType: Value(rData['fuelType'] as String?),
              stationName: Value(rData['stationName'] as String?),
              notes: Value(rData['notes'] as String?),
              createdAt: Value(DateTime.parse(rData['createdAt'] as String).millisecondsSinceEpoch),
            ),
          );
          
          recordCount++;
        }
      }
      
      return ExportResult(
        success: true,
        message: '导入成功！\n车辆: $vehicleCount 辆\n记录: $recordCount 条',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: '导入失败: $e',
      );
    }
  }
}

/// 数据导出Provider
final exportProvider = AutoDisposeNotifierProvider<ExportNotifier, void>(
  ExportNotifier.new,
);
