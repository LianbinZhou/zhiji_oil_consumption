// 智记油耗 - 保养自定义项目（持久化）
//
// 预设清单写死在 ExpenseCatalog.maintenanceCategories 里；
// 用户自己加的项目存在 SharedPreferences，跨记录、跨重启都保留。
//
// 一致性规则：
//   - 去重（同名不重复加）
//   - 不覆盖预设（预设里已有的名字，不再加进自定义列表）

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'expenses_provider.dart';

const String _kCustomItemsKey = 'custom_maintenance_items';

class CustomMaintenanceItemsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kCustomItemsKey) ?? const <String>[];
  }

  Future<void> add(String item) async {
    final name = item.trim();
    if (name.isEmpty) return;

    // 与预设重名不重复添加
    if (ExpenseCatalog.maintenanceCategories.contains(name)) return;

    final current = state.valueOrNull ?? const <String>[];
    if (current.contains(name)) return;

    final next = [...current, name];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kCustomItemsKey, next);
    state = AsyncData(next);
  }

  Future<void> remove(String item) async {
    final current = state.valueOrNull ?? const <String>[];
    final next = current.where((e) => e != item).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kCustomItemsKey, next);
    state = AsyncData(next);
  }
}

final customMaintenanceItemsProvider =
    AsyncNotifierProvider<CustomMaintenanceItemsNotifier, List<String>>(
  CustomMaintenanceItemsNotifier.new,
);
