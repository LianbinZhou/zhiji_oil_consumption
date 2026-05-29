// 智记油耗 - 基础Widget测试
// 确保应用能正常启动

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zhiji_oil_consumption/main.dart';

void main() {
  testWidgets('应用启动测试', (WidgetTester tester) async {
    // 构建应用
    await tester.pumpWidget(
      const ProviderScope(
        child: ZhijiOilConsumptionApp(),
      ),
    );

    // 验证应用标题显示
    expect(find.text('智记油耗'), findsOneWidget);
  });
}
