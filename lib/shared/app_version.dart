// 智记能耗 - 版本号（单一显示源）

/// 界面展示用的版本号。
///
/// 真源始终是 `pubspec.yaml` 的 `version:`。
/// Dart 无法在编译期读取 pubspec，所以这里保留一份人工同步的副本，
/// **发版检查清单的第 1 条就是把它和 pubspec 对齐**。
///
/// 为什么带 build 号：用户报问题时，"1.0.0" 无法区分到底装的是 +2 还是 +3。
const String kAppVersionLabel = 'v1.0.7 (build 10)';