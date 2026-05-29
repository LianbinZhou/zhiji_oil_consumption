// 智记油耗 - 路由配置文件
// 使用go_router + ShellRoute实现底部导航栏

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 导入页面
import '../../features/vehicles/presentation/vehicles_screen.dart';
import '../../features/records/presentation/records_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// 创建并配置应用的路由器
GoRouter createRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      // 带底部导航栏的Shell路由
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) {
          return _MainScaffold(child: child);
        },
        routes: [
          // 首页（仪表盘）
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          // 车辆管理
          GoRoute(
            path: '/vehicles',
            name: 'vehicles',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VehiclesScreen(),
            ),
          ),
          // 设置
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // 不带底部导航栏的独立页面
      GoRoute(
        path: '/records/:vehicleId',
        name: 'records',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final vehicleId = int.parse(state.pathParameters['vehicleId']!);
          return RecordsScreen(vehicleId: vehicleId);
        },
      ),
      GoRoute(
        path: '/statistics/:vehicleId',
        name: 'statistics',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final vehicleId = int.parse(state.pathParameters['vehicleId']!);
          return StatisticsScreen(vehicleId: vehicleId);
        },
      ),
    ],

    // 错误页面
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('页面未找到')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('抱歉,您访问的页面不存在'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('返回首页'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 主框架 - 包含底部导航栏
class _MainScaffold extends StatelessWidget {
  final Widget child;

  const _MainScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    // 根据当前路由决定选中的tab
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.startsWith('/vehicles')) {
      currentIndex = 1;
    } else if (location.startsWith('/settings')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/vehicles');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_car_outlined),
              selectedIcon: Icon(Icons.directions_car),
              label: '车辆',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
