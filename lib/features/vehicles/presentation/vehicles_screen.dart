// 智记油耗 - 车辆管理页面
// 这个页面显示所有车辆列表,并提供添加、编辑、删除功能

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 导入Provider
import '../providers/vehicles_provider.dart';
// 导入对话框
import 'vehicle_dialog.dart';
// 导入车辆模型(使用别名避免与Drift生成的Vehicle冲突)
import '../../../data/models/vehicle.dart' as model;

/// 车辆管理页面
/// 
/// 这是车辆管理功能的主页面
/// 显示所有已添加的车辆,支持:
/// - 查看车辆列表
/// - 添加新车
/// - 编辑车辆信息
/// - 删除车辆
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听车辆列表数据
    // vehiclesStreamProvider会自动在数据变化时更新UI
    final vehiclesAsync = ref.watch(vehiclesStreamProvider);

    return Scaffold(
      // 应用栏
      appBar: AppBar(
        title: const Text('车辆管理'),
      ),
      
      // 主体内容
      body: vehiclesAsync.when(
        // 数据加载中显示进度条
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        
        // 出错时显示错误信息
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
            ],
          ),
        ),
        
        // 数据加载成功,显示车辆列表
        data: (vehicles) {
          // 如果没有车辆,显示空状态提示
          if (vehicles.isEmpty) {
            return _buildEmptyState(context);
          }
          
          // 有车辆,显示列表
          return _buildVehicleList(context, ref, vehicles);
        },
      ),
      
      // 右下角浮动添加按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const VehicleDialog(),
          );
        },
        tooltip: '添加车辆',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建空状态提示
  /// 
  /// 当用户还没有添加任何车辆时显示这个界面
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 空状态图标
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          
          // 提示文字
          Text(
            '暂无车辆',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            '点击右上角"+"添加您的第一辆车',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          // 快速添加按钮
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VehicleDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('添加车辆'),
          ),
        ],
      ),
    );
  }

  /// 构建车辆列表
  /// 
  /// 使用ListView显示所有车辆
  Widget _buildVehicleList(
    BuildContext context,
    WidgetRef ref,
    List<model.Vehicle> vehicles,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return _buildVehicleCard(context, ref, vehicle, vehicles.length);
      },
    );
  }

  /// 构建单个车辆卡片
  /// 
  /// 每个车辆用一个卡片显示
  /// [totalVehicles] 车辆总数,用于决定是否显示"设为默认"按钮
  Widget _buildVehicleCard(
    BuildContext context,
    WidgetRef ref,
    model.Vehicle vehicle,
    int totalVehicles,
  ) {
    final theme = Theme.of(context);
    final isDefault = vehicle.isDefault;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDefault ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDefault
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行: 默认标记 + 车辆名称
            Row(
              children: [
                // 默认标记(仅默认车辆显示)
                if (isDefault) ...[  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '默认',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // 车辆名称
                Expanded(
                  child: Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 车牌号码
            if (vehicle.licensePlate != null && vehicle.licensePlate!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '车牌: ${vehicle.licensePlate}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            
            // 车辆类型 - 修复Bug1: 直接显示字符串,而不是对象
            if (vehicle.vehicleType != null && vehicle.vehicleType!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '类型: ${vehicle.vehicleType}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            
            // 颜色
            if (vehicle.color != null && vehicle.color!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '颜色: ${vehicle.color}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            
            // 底部操作按钮行
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 编辑按钮
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => VehicleDialog(vehicle: vehicle),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('编辑'),
                ),
                
                const SizedBox(width: 8),
                
                // 设为默认按钮
                // 修复Bug2: 只有一辆车时不显示此按钮,已经是默认车辆也不显示
                if (totalVehicles > 1 && !isDefault)
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await ref
                            .read(vehiclesNotifierProvider.notifier)
                            .setDefaultVehicle(vehicle.id);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${vehicle.brand} ${vehicle.model} 已设为默认车辆',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('设置失败: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('设为默认'),
                  ),
                
                const SizedBox(width: 8),
                
                // 删除按钮
                TextButton.icon(
                  onPressed: () => _deleteVehicle(context, ref, vehicle),
                  icon: Icon(
                    Icons.delete,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    '删除',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 删除车辆
  /// 
  /// 先显示确认对话框,用户确认后才执行删除
  Future<void> _deleteVehicle(
    BuildContext context,
    WidgetRef ref,
    model.Vehicle vehicle,
  ) async {
    // 显示确认对话框
    final confirmed = await showDeleteConfirmDialog(context);
    
    if (!confirmed) {
      return; // 用户取消删除
    }

    try {
      // 执行删除
      await ref.read(vehiclesNotifierProvider.notifier).deleteVehicle(vehicle.id);
      
      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('车辆已删除')),
        );
      }
    } catch (e) {
      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
