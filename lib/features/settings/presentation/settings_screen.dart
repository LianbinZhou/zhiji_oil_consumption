// 智记能耗 - 设置页面
// 这个页面允许用户自定义应用的各项设置

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 导入设置Provider
import '../providers/settings_provider.dart';
// 导入数据库Provider
import '../../../shared/app_version.dart';
import '../../vehicles/providers/vehicles_provider.dart';
// 导入导出Provider
import '../../export/providers/export_provider.dart';

/// 设置页面
/// 
/// 提供单位、货币、主题等设置选项
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // 监听设置状态
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        // 返回按钮
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '返回',
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          const SizedBox(height: 24),
          
          // 外观设置分组
          _buildSectionTitle(context, '外观设置'),
          Card(
            child: _buildSettingTile(
              context,
              icon: Icons.palette,
              title: '主题模式',
              subtitle: settings.themeMode.label,
              trailing: Icon(
                settings.themeMode == AppThemeMode.light
                    ? Icons.light_mode
                    : settings.themeMode == AppThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.brightness_auto,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                _showThemeModeDialog(context, settings);
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 数据管理分组
          _buildSectionTitle(context, '数据管理'),
          Card(
            child: Column(
              children: [
                // 导出JSON备份
                _buildSettingTile(
                  context,
                  icon: Icons.backup,
                  title: '备份数据',
                  subtitle: '导出为JSON文件',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _exportJson(context, ref);
                  },
                ),
                const Divider(height: 1),
                
                // 导入JSON备份
                _buildSettingTile(
                  context,
                  icon: Icons.restore,
                  title: '恢复数据',
                  subtitle: '从JSON文件导入',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _importJson(context, ref);
                  },
                ),
                const Divider(height: 1),
                
                // 导出Excel报表
                _buildSettingTile(
                  context,
                  icon: Icons.table_chart,
                  title: '导出Excel',
                  subtitle: '导出能耗记录表格',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showExportExcelDialog(context, ref);
                  },
                ),
                const Divider(height: 1),
                
                // 清理数据
                _buildSettingTile(
                  context,
                  icon: Icons.delete_outline,
                  title: '清理所有数据',
                  subtitle: '删除所有车辆和记录',
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textColor: Theme.of(context).colorScheme.error,
                  onTap: () {
                    _showClearDataDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 关于应用分组
          _buildSectionTitle(context, '关于'),
          Card(
            child: Column(
              children: [
                // 版本号
                _buildAboutTile(
                  context,
                  icon: Icons.info_outline,
                  title: '应用版本',
                  subtitle: kAppVersionLabel,
                ),
                const Divider(height: 1),
                
                // 开发者信息
                _buildAboutTile(
                  context,
                  icon: Icons.person_outline,
                  title: '开发者',
                  subtitle: '智记能耗 by 细胞',
                ),
                const Divider(height: 1),
                
                // 技术栈
                _buildAboutTile(
                  context,
                  icon: Icons.code,
                  title: '技术栈',
                  subtitle: 'Flutter + Riverpod + Drift',
                ),
              ],
            ),
          ),
          
          // 底部间距
          const SizedBox(height: 32),
          
          // 版权信息
          Center(
            child: Text(
              '© 2026 智记能耗',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 构建关于信息项
  Widget _buildAboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  /// 显示主题模式选择对话框
  void _showThemeModeDialog(BuildContext context, AppSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题模式'),
        content: RadioGroup<AppThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(settingsProvider.notifier).setThemeMode(value);
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(mode.label),
                subtitle: mode == AppThemeMode.light
                    ? const Text('始终使用浅色主题')
                    : mode == AppThemeMode.dark
                        ? const Text('始终使用深色主题')
                        : const Text('跟随系统设置'),
                value: mode,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 显示清理数据确认对话框
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('警告'),
          ],
        ),
        content: const Text(
          '此操作将删除所有车辆和能耗记录，且无法恢复！\n\n确定要继续吗？',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearAllData(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
  }

  /// 清理所有数据
  Future<void> _clearAllData(BuildContext context) async {
    try {
      // 获取数据库实例
      final database = ref.read(databaseProvider);
      
      // 删除所有能耗记录
      // 三张表在同一个事务里清空，顺序：支出 → 能耗记录 → 车辆
      await database.transaction(() async {
        await database.deleteAllExpenses();
        await database.deleteAllEnergyRecords();
        await database.deleteAllVehicles();
      });
      
      if (context.mounted) {
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有数据已清理')),
        );
        
        // 返回首页
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清理失败: $e')),
        );
      }
    }
  }

  /// 导出JSON备份
  Future<void> _exportJson(BuildContext context, WidgetRef ref) async {
    // 显示加载提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出数据...')),
    );
    
    // 执行导出
    final result = await ref.read(exportProvider.notifier).exportToJson(ref);
    
    if (context.mounted) {
      // 显示结果
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// 导入JSON备份
  Future<void> _importJson(BuildContext context, WidgetRef ref) async {
    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text(
          '导入的数据将会添加到现有数据中，不会删除已有数据。\n\n确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    if (!context.mounted) return;

    // 显示加载提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导入数据...')),
    );
    
    // 执行导入
    final result = await ref.read(exportProvider.notifier).importFromJson(ref);
    
    if (context.mounted) {
      // 显示结果
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // 如果导入成功，返回首页刷新数据
      if (result.success) {
        context.go('/');
      }
    }
  }

  /// 显示导出Excel对话框
  Future<void> _showExportExcelDialog(BuildContext context, WidgetRef ref) async {
    // 获取所有车辆
    final database = ref.read(databaseProvider);
    final vehicles = await database.getAllVehicles();
    
    if (vehicles.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有车辆可导出')),
        );
      }
      return;
    }
    
    if (!context.mounted) return;

    // 显示车辆选择对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择车辆'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text('${vehicle.brand} ${vehicle.model}'),
                subtitle: vehicle.licensePlate != null && vehicle.licensePlate!.isNotEmpty
                    ? Text(vehicle.licensePlate!)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  _exportExcel(context, ref, vehicle.id);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 导出Excel
  Future<void> _exportExcel(BuildContext context, WidgetRef ref, int vehicleId) async {
    // 显示加载提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出Excel...')),
    );
    
    // 执行导出
    final result = await ref.read(exportProvider.notifier).exportToExcel(ref, vehicleId);
    
    if (context.mounted) {
      // 显示结果
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
