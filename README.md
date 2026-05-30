# 智记油耗 (Zhiji Oil Consumption)

> 一款基于 Flutter 的本地化车辆油耗记录应用，支持 Android 与 HarmonyOS Next，帮助您轻松管理每一笔燃油消费。

[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue)](LICENSE)

---

## 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [环境配置](#环境配置)
- [快速开始](#快速开始)
- [构建与分发](#构建与分发)
- [参与贡献](#参与贡献)
- [许可证](#许可证)

---

## 功能特性

- **车辆管理** — 添加、编辑、删除车辆信息，支持品牌、型号、车牌、颜色和类型
- **加油记录** — 记录每次加油的油量、金额、单价、里程等详细信息
- **油耗统计** — 按月/年聚合统计油耗趋势，支持亮灯法油耗计算
- **数据看板** — 可视化展示累计花费、最低/最高油价、总油耗等关键指标
- **数据导出** — 支持 JSON 备份导出/导入，一键生成 Excel 报表
- **个性设置** — 支持浅色/深色/跟随系统三种主题，可自定义单位（公里/英里、升/加仑）
- **跨平台** — 同一套代码在 Android 和 HarmonyOS Next 上原生运行

---

## 技术栈

| 类别 | 技术 | 说明 |
|------|------|------|
| 框架 | Flutter 3.44 / Dart 3.12 | 跨平台 UI 框架 |
| 状态管理 | Riverpod 2.6 | 声明式、编译安全的响应式状态管理 |
| 本地数据库 | Drift 2.21 (SQLite) | 类型安全的 SQLite ORM |
| 路由 | go_router 14.8 | 声明式路由管理 |
| 图表 | fl_chart 0.68 | 高性能 Flutter 图表库 |
| 本地存储 | shared_preferences | 轻量级 KV 持久化 |
| 文件操作 | file_picker / excel / path_provider | 导出与文件选择 |
| 鸿蒙适配 | Flutter-OH 3.27.4 (Dart 3.6.2) | 基于 OpenHarmony SIG 维护的 Flutter 分支 |

---

## 项目结构

```
zhiji_oil_consumption/
├── lib/
│   ├── main.dart                         # 应用入口
│   ├── data/
│   │   ├── database/                     # Drift 数据库定义与操作
│   │   │   ├── app_database.dart         # 数据库主类
│   │   │   ├── app_database.g.dart       # Drift 生成代码
│   │   │   └── tables.dart               # 表结构定义 (Vehicles, FuelRecords)
│   │   └── models/                       # 数据模型
│   │       ├── vehicle.dart
│   │       └── fuel_record.dart
│   ├── features/                         # 功能模块 (Feature-first 架构)
│   │   ├── dashboard/                    # 数据看板
│   │   ├── vehicles/                     # 车辆管理
│   │   ├── records/                      # 加油记录
│   │   ├── statistics/                   # 统计报表
│   │   ├── settings/                     # 应用设置
│   │   └── export/                       # 数据导入导出
│   └── shared/                           # 跨模块共享
│       ├── routes/app_router.dart        # 路由配置
│       └── themes/app_theme.dart         # Material 3 主题 (Light/Dark)
├── android/                              # Android 平台
├── ohos/                                 # HarmonyOS 平台
├── pubspec.yaml                          # 项目依赖声明
├── analysis_options.yaml                 # Dart 静态分析规则
└── build.yaml                            # Drift 代码生成配置
```

---

## 环境配置

### 前置要求

| 工具 | 版本要求 | 用途 |
|------|---------|------|
| Flutter SDK | ≥ 3.44.0 | Android 构建 |
| Android Studio | 2024+ | Android 模拟器/构建 |
| JDK | 17+ | Android Gradle 编译 |
| Flutter-OH SDK | 3.27.4-ohos | HarmonyOS 构建 |
| DevEco Studio | 5.0+ | HarmonyOS 签名/IDE |
| Node.js | 18.x LTS | Hvigor 构建引擎 |
| Git | 2.x | 版本控制 |

### 安装 Flutter (Android)

1. 下载并安装 [Flutter SDK](https://docs.flutter.dev/get-started/install/windows)
2. 运行 `flutter doctor` 确认环境就绪
3. 确保 Android SDK、Android Studio 已正确配置

### 安装 Flutter-OH (HarmonyOS)

1. 安装 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) 5.0+
2. 克隆 Flutter-OH SDK：
   ```bash
   git clone -b br_3.27.4-ohos-1.0.4 https://atomgit.com/openharmony-sig/flutter_flutter.git C:/src/flutter-ohos-3.27
   ```
3. 首次运行完成 Dart SDK 下载：
   ```bash
   C:/src/flutter-ohos-3.27/bin/flutter --version
   ```
4. 配置 HarmonyOS SDK 路径：
   ```bash
   C:/src/flutter-ohos-3.27/bin/flutter config --ohos-sdk="C:/Program Files/Huawei/DevEco Studio/sdk"
   ```
   ## 📦 下载安装包

[![Download from GitHub Releases](https://img.shields.io/badge/下载-APK%20%26%20HAP-blue?logo=github)](https://github.com/LianbinZhou/zhiji_oil_consumption/releases)

点击上方徽章或 [此链接](https://github.com/LianbinZhou/zhiji_oil_consumption/releases) 进入 Releases 页面，即可下载以下文件：

| 平台 | 文件 |
|------|------|
| Android | `app-release.apk` |
| HarmonyOS | `entry-default-unsigned.hap` |
> ⚠️ 鸿蒙 HAP 为未签名调试版，安装时需使用 `hdc install -d` 命令。

---

## 快速开始

### 克隆仓库

```bash
git clone <your-repo-url> zhiji_oil_consumption
cd zhiji_oil_consumption
```

### 安装依赖

```bash
flutter pub get
```

### 代码生成（首次或数据库表变更后）

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 运行应用

```bash
# Android 设备/模拟器
flutter run -d android

# Chrome 浏览器 (Web 模式)
flutter run -d chrome

# Windows 桌面应用
flutter run -d windows

# HarmonyOS 设备 (需要 Flutter-OH SDK)
C:/src/flutter-ohos-3.27/bin/flutter run -d ohos
```

---

## 构建与分发

### Android APK

```bash
# Release APK
flutter build apk --release

# AppBundle (Google Play)
flutter build appbundle --release
```

产物位于 `build/app/outputs/flutter-apk/app-release.apk`。

### HarmonyOS HAP

在配置好 Flutter-OH 环境后：

```powershell
cd C:\path\to\zhiji_oil_consumption
$env:DEVECO_SDK_HOME = "C:\Program Files\Huawei\DevEco Studio"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin;C:\Program Files\Huawei\DevEco Studio\tools\node;C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin;C:\Program Files\Android\Android Studio\jbr\bin;" + $env:PATH
C:\src\flutter-ohos-3.27\bin\flutter.bat build hap --release
```

> **说明**：发布版本需要先在 DevEco Studio 中配置签名：`File → Project Structure → Signing Configs`，登录华为开发者账号并勾选 "Automatically generate signature"。

产物位于 `ohos/entry/build/default/outputs/default/entry-default-signed.hap`。

---

## 测试状态

| 平台 | 构建 | 功能测试 |
|------|------|----------|
| Windows | ✅ 通过 | ✅ 已测试（核心流程） |
| Android | ✅ 通过 | ⚠️ 仅构建，未运行测试 |
| HarmonyOS | ✅ 通过 | ⚠️ 仅构建，未运行测试 |

> 欢迎社区帮助在各平台进行功能验证，并通过 [Issue](https://github.com/LianbinZhou/zhiji_oil_consumption/issues) 反馈问题。

---

## 参与贡献

我们欢迎任何形式的贡献！无论是报告 Bug、提出新功能建议、改进文档还是提交代码。

### 贡献流程

1. **Fork** 本仓库
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交你的更改：`git commit -m 'feat: add amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 提交 **Pull Request**

### 提交规范

本项目遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `refactor:` 代码重构
- `chore:` 构建/工具链变更

### 代码风格

- 所有 Dart 代码使用中文注释
- 遵循 `flutter_lints` 规定的代码规范
- 运行 `flutter analyze` 确保无新增警告
- 遵循 Feature-first 目录结构，将新功能放在 `lib/features/<feature_name>/` 下

---

## 许可证

本项目基于 **Apache License 2.0** 开源，与 OpenHarmony 社区许可保持一致。

```
Copyright 2026 Zhiji Oil Consumption Contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

## 致谢

- [Flutter](https://flutter.dev) — Google 的跨平台 UI 框架
- [OpenHarmony SIG](https://atomgit.com/openharmony-sig/flutter_flutter) — 鸿蒙 Flutter 适配维护团队
- [OpenHarmony TPC](https://atomgit.com/openharmony-tpc/flutter_packages) — 鸿蒙三方 Flutter 插件适配仓库
