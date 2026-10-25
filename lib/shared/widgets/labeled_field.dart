// 智记能耗 - 表单字段（标签在框外）
//
// 为什么不用 Material 自带的 floatingLabel：
//   默认行为是"标签浮起后压在输入框边框上"，在浅色主题下会显得标签和边框打架。
//   这里改成「标签在框外上方 + 输入框内只显示值/占位」，视觉更整齐。
//
// 用法：
//   LabeledField(
//     label: '加油量(升)',
//     isRequired: true,
//     child: TextFormField(decoration: InputDecoration(hintText: '例如：50.5', ...)),
//   )

import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Widget child;
  final String? helper;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = false,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (helper != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    helper!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// 统一的输入框装饰（不带 label —— 标签由 LabeledField 负责）
InputDecoration fieldDecoration({
  IconData? icon,
  IconData? suffixIcon,
  String? hint,
  bool dense = false,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    suffixIcon: suffixIcon == null ? null : Icon(suffixIcon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: dense ? 12 : 16,
    ),
    isDense: dense,
  );
}
