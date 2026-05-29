// 智记油耗 - 设置Provider
// 这个文件管理用户的所有偏好设置

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 距离单位枚举
enum DistanceUnit {
  kilometers('公里', 'km'),
  miles('英里', 'mi');

  final String label;
  final String symbol;
  const DistanceUnit(this.label, this.symbol);
}

/// 油量单位枚举
enum FuelUnit {
  liters('升', 'L'),
  gallons('加仑', 'gal');

  final String label;
  final String symbol;
  const FuelUnit(this.label, this.symbol);
}

/// 货币类型枚举
enum AppCurrency {
  cny('人民币', '¥'),
  usd('美元', '\$'),
  eur('欧元', '€'),
  gbp('英镑', '£');

  final String label;
  final String symbol;
  const AppCurrency(this.label, this.symbol);
}

/// 应用主题模式枚举（避免与Flutter的ThemeMode冲突）
enum AppThemeMode {
  light('浅色'),
  dark('深色'),
  system('跟随系统');

  final String label;
  const AppThemeMode(this.label);
}

/// 应用设置数据类
/// 
/// 存储用户的所有偏好设置
class AppSettings {
  /// 距离单位（公里/英里）
  final DistanceUnit distanceUnit;
  
  /// 油量单位（升/加仑）
  final FuelUnit fuelUnit;
  
  /// 货币类型
  final AppCurrency currency;
  
  /// 主题模式
  final AppThemeMode themeMode;

  AppSettings({
    this.distanceUnit = DistanceUnit.kilometers,
    this.fuelUnit = FuelUnit.liters,
    this.currency = AppCurrency.cny,
    this.themeMode = AppThemeMode.system,
  });

  /// 创建一个副本，可以修改部分字段
  AppSettings copyWith({
    DistanceUnit? distanceUnit,
    FuelUnit? fuelUnit,
    AppCurrency? currency,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      distanceUnit: distanceUnit ?? this.distanceUnit,
      fuelUnit: fuelUnit ?? this.fuelUnit,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// 转换为Flutter的ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// 设置状态类
/// 
/// 封装设置的当前状态
class SettingsState {
  final AppSettings settings;

  SettingsState({required this.settings});
}

/// 设置Notifier类
/// 
/// 管理设置的读取和保存
class SettingsNotifier extends AutoDisposeNotifier<SettingsState> {
  /// SharedPreferences的键名
  static const String _distanceUnitKey = 'distance_unit';
  static const String _fuelUnitKey = 'fuel_unit';
  static const String _currencyKey = 'currency';
  static const String _themeModeKey = 'theme_mode';

  bool _initialized = false;

  @override
  SettingsState build() {
    // 自动触发异步加载已保存的设置
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() async {
        final settings = await _loadSettings();
        state = SettingsState(settings: settings);
      });
    }
    return SettingsState(settings: AppSettings());
  }

  /// 从本地存储加载设置
  Future<AppSettings> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 读取距离单位
    final distanceUnitIndex = prefs.getInt(_distanceUnitKey) ?? 0;
    final distanceUnit = DistanceUnit.values[distanceUnitIndex];
    
    // 读取油量单位
    final fuelUnitIndex = prefs.getInt(_fuelUnitKey) ?? 0;
    final fuelUnit = FuelUnit.values[fuelUnitIndex];
    
    // 读取货币类型
    final currencyIndex = prefs.getInt(_currencyKey) ?? 0;
    final currency = AppCurrency.values[currencyIndex];
    
    // 读取主题模式
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 2; // 默认跟随系统
    final themeMode = AppThemeMode.values[themeModeIndex];
    
    return AppSettings(
      distanceUnit: distanceUnit,
      fuelUnit: fuelUnit,
      currency: currency,
      themeMode: themeMode,
    );
  }

  /// 保存设置到本地存储
  Future<void> _saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_distanceUnitKey, settings.distanceUnit.index);
    await prefs.setInt(_fuelUnitKey, settings.fuelUnit.index);
    await prefs.setInt(_currencyKey, settings.currency.index);
    await prefs.setInt(_themeModeKey, settings.themeMode.index);
  }

  /// 更新距离单位
  Future<void> setDistanceUnit(DistanceUnit unit) async {
    final newSettings = state.settings.copyWith(distanceUnit: unit);
    state = SettingsState(settings: newSettings);
    await _saveSettings(newSettings);
  }

  /// 更新油量单位
  Future<void> setFuelUnit(FuelUnit unit) async {
    final newSettings = state.settings.copyWith(fuelUnit: unit);
    state = SettingsState(settings: newSettings);
    await _saveSettings(newSettings);
  }

  /// 更新货币类型
  Future<void> setCurrency(AppCurrency currency) async {
    final newSettings = state.settings.copyWith(currency: currency);
    state = SettingsState(settings: newSettings);
    await _saveSettings(newSettings);
  }

  /// 更新主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    final newSettings = state.settings.copyWith(themeMode: mode);
    state = SettingsState(settings: newSettings);
    await _saveSettings(newSettings);
  }

  /// 重置所有设置为默认值
  Future<void> resetToDefaults() async {
    final defaultSettings = AppSettings();
    state = SettingsState(settings: defaultSettings);
    await _saveSettings(defaultSettings);
  }
}

/// 设置Provider
final settingsProvider = AutoDisposeNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

/// 获取当前Flutter ThemeMode的辅助Provider
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final settingsState = ref.watch(settingsProvider);
  return settingsState.settings.flutterThemeMode;
});
