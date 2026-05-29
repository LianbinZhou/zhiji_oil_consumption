# 智记油耗

一款本地记录车辆油耗的Flutter APP,帮助用户管理燃油消耗数据。

## 技术栈

- **框架**: Flutter 3.x (Dart)
- **状态管理**: Riverpod
- **本地数据库**: Drift (SQLite)
- **路由**: go_router
- **图表**: fl_chart
- **UI规范**: Material Design 3,支持深色模式

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── data/                  # 数据层
│   ├── database/          # 数据库相关
│   └── models/            # 数据模型
├── features/              # 功能模块
│   ├── home/              # 首页
│   ├── vehicles/          # 车辆管理
│   └── records/           # 油耗记录
└── shared/                # 共享资源
    ├── widgets/           # 通用组件
    ├── themes/            # 主题配置
    └── routes/            # 路由配置
```

## 快速开始

### 前置要求

1. 安装Flutter SDK: https://docs.flutter.dev/get-started/install
2. 配置好Android Studio或Xcode(用于模拟器)

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
# 在Chrome浏览器中运行
flutter run -d chrome

# 在Android模拟器中运行
flutter run

# 在Windows桌面运行
flutter run -d windows
```

### 代码生成

如果使用Riverpod或Drift的代码生成功能:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 开发规范

- 所有代码包含详细的中文注释
- 优先保证代码可读性
- 遵循Material Design 3设计规范
