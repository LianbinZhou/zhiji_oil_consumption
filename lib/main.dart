// 智记能耗 - 应用主入口文件

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 导入主题配置
import 'shared/themes/app_theme.dart';
// 导入路由配置
import 'shared/routes/app_router.dart';
// 导入设置Provider
import 'features/settings/providers/settings_provider.dart';
// 迁移前自动备份（必须在数据库连接打开之前执行）
import 'data/database/migration_backup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 旧版本数据库先备份成 *.pre-v4.bak*，然后在打开连接时触发迁移。
  // 顺序很重要：必须在任何代码碰数据库之前完成复制。
  final backupPath = await ensurePreMigrationBackup();
  if (backupPath != null) {
    debugPrint('[迁移] 已备份旧数据库: $backupPath');
  }

  runApp(
    const ProviderScope(
      child: ZhijiOilConsumptionApp(),
    ),
  );
}

/// 智记能耗应用的主组件
class ZhijiOilConsumptionApp extends ConsumerWidget {
  const ZhijiOilConsumptionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter();
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp.router(
      title: '智记能耗',
      debugShowCheckedModeBanner: false,

      // ===== 中文本地化 =====
      // 不配这段的话，showDatePicker / 时间选择器 / 文本选择菜单全是英文
      // （会显示 "Select date" / "Cancel" / "OK" 之类）
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      routerConfig: router,
    );
  }
}
