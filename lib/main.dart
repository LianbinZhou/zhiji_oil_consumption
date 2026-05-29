// 智记油耗 - 应用主入口文件
// 这是Flutter应用的起点,负责初始化应用并启动

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 导入主题配置
import 'shared/themes/app_theme.dart';
// 导入路由配置
import 'shared/routes/app_router.dart';
// 导入设置Provider
import 'features/settings/providers/settings_provider.dart';

/// 应用的主函数
/// 
/// Dart程序的入口点,类似于其他语言的main()函数
/// 当应用启动时,首先执行这个函数
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: ZhijiOilConsumptionApp(),
    ),
  );
}

/// 智记油耗应用的主组件
/// 
/// 这是一个无状态组件(StatelessWidget),因为它本身不需要管理状态
/// 所有的状态管理都交给Riverpod处理
class ZhijiOilConsumptionApp extends ConsumerWidget {
  const ZhijiOilConsumptionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 创建路由器实例
    // go_router使用这个对象来管理页面导航
    final router = createRouter();
    
    // 监听主题模式设置
    final themeMode = ref.watch(flutterThemeModeProvider);
    
    // MaterialApp 是Material Design风格应用的根组件
    return MaterialApp.router(
      // 应用标题(显示在任务栏或最近应用中)
      title: '智记油耗',
      
      // 调试横幅(显示应用信息,生产环境应设为false)
      debugShowCheckedModeBanner: false,
      
      // 浅色主题配置
      theme: AppTheme.lightTheme,
      
      // 深色主题配置
      darkTheme: AppTheme.darkTheme,
      
      // 主题模式:根据用户设置动态切换
      themeMode: themeMode,
      
      // 路由器配置
      // 使用go_router来处理所有页面导航
      routerConfig: router,
    );
  }
}
