# 智记能耗

> 一个**纯本地**的车辆能耗记录 App。记录加油、充电、保养和各项用车开销，不联网、不注册、不申请任何权限。

[![Flutter](https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-7.0%2B-3DDC84?logo=android)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 为什么做这个

两个原因：

1. 同类 App 被工信部通报过**读取用户数据**
2. 打开同类 App，**到处都是广告**

所以这个 App 的原则只有三条：**免费、数据本地、不用登录开箱即用**。

它不收集任何信息，Android 上**一条权限都没有申请**——不是"承诺不上传"，而是没有权限上传。详见 [PRIVACY.md](PRIVACY.md)。

---

## 下载与安装

> ⚠️ **只发布 arm64 包。永远不要发通用包（`app-release.apk`）。**
>
> 原因：`--split-per-abi` 会把 versionCode 改写成 `基础号×1000 + ABI 偏移`
> （arm64 = **2003**，v7a = 1003，x86_64 = 4003），而通用包仍是基础号 **3**。
> 装过 split 版的用户再装通用包，系统会判定为**降级并拒绝安装**，
> 只能先卸载——**卸载会删掉本地数据库**，而这个 App 没有云端，只能事先导出 JSON。

1. 到 [Releases](https://github.com/LianbinZhou/zhiji_oil_consumption/releases) 下载 `zhiji_oil_arm64_vX.Y.Z-N.apk`
2. 手机上允许「安装未知来源应用」
3. 装完直接打开，不需要注册、不需要联网
4. 如果你从旧版本升级：先在旧版里「设置 → 导出备份」，新装后再导入

每个 Release 都附带 `.sha256` 文件，可以自行校验：

```powershell
Get-FileHash .\zhiji_oil_arm64_v1.0.0-3.apk -Algorithm SHA256
```

---

## 系统要求

### Android 版本

| 项目 | 要求 | 说明 |
|---|---|---|
| **最低系统** | **Android 7.0（API 24）** | 2016 年 8 月之后的设备 |
| **目标系统** | Android 14（API 34） | 为什么锁 34：在 Android 15/16 上走兼容模式，行为可预测；随手改成 36 会引入新的强制要求（权限、文件访问），改动面比看起来大 |
| **CPU 架构** | **arm64-v8a（64 位）** | 2020 年后的手机基本都是 64 位 |
| **存储空间** | 约 60 MB（安装后） | 应用本体 21 MB，其余是运行数据 |
| **权限** | **0 个** | 安装时不会向你要任何权限 |
| **网络** | **不需要** | 没网也能完整使用 |

### 哪些手机能用

- ✅ **2020 年以后的主流安卓手机**（基本都是 64 位 + Android 10 以上）
- ✅ **2023 年以后的所有手机**（Android 12+，完全覆盖）
- ✅ 华为 / 小米 / OPPO / vivo / 荣耀 / 三星 / 一加 等主流品牌
- ⚠️ **2019 年以前的 32 位设备装不上**（本项目只打包 arm64）
- ❌ **iOS / HarmonyOS** 暂不支持（鸿蒙版代码保留在 `ohos/` 目录但停止维护）

### 实际测试过的环境

| 项目 | 实测情况 |
|---|---|
| 机型 | 华为 NOH-AN00（Android 12） |
| 系统版本 | Android 12 |
| 功能 | ✅ 完整流程人工验收通过 |
| **未验证** | Android 7.0–11 的老设备、其他品牌机型 |

> **诚实说明**：只在一台 Android 12 的华为真机上完整测过。理论上 Android 7.0+ 都能装，但**没有在更老的系统上验证过**。如果你在别的机型上跑出了问题，欢迎开 [Issue](https://github.com/LianbinZhou/zhiji_oil_consumption/issues) 反馈。

---

## 功能

### 记录

- **车辆管理** — 一辆车一条记录，支持**油车 / 纯电 / 混动**三种能源类型
- **能源记录** — 加油记油量、充电记电量。纯电车自动切换成充电表单，混动车可在两者间切换
- **保养记录** — 项目多选（机油、刹车片、轮胎…），支持**自定义项目**并长期保存
- **油站优惠** — 机显金额和实付金额分别记录（会员价、券、活动），统计用**实付**
- **左滑删除** — 记录卡片往左拖即可删除，带二次确认
- **费用账本** — 保险、停车、洗车、罚款、维修等非加油支出

### 统计

- **单车统计** — 油耗 / 电耗、每公里成本、月度趋势、油价区间
- **统计总览（跨车辆）** — 全部花费构成、年度报告（含同比）、车辆对比排行、里程统计

### 数据

- **JSON 备份** — 导出 / 导入，兼容旧版本备份文件
- **Excel 报表** — 两个 sheet（能源记录 / 其他支出）
- 导出走系统文件选择器，文件存在哪由你决定

### 其他

- 浅色 / 深色 / 跟随系统三种主题
- 全程中文（含日期选择器等系统组件）
- **单位固定**：公里（km）、升（L）/ 度（kWh）、人民币（¥）

---

## 计算口径

油耗的计算容易出错，这里写清楚：

**锚点法**：先"加满"，再"加到加满"，两次之间烧掉的油 ÷ 里程差 × 100。

- **区间求和**：中间没加满的那次油量**也会计入**（不会漏算）
- **加权平均**：总油量 ÷ 总里程，不是每次油耗的平均值
- **亮灯法**：勾"油灯亮"时改用灯亮作为锚点
- **充电**：按充电桩计费电量算，实际电耗会略低于显示值（充电有损耗）
- **混动**：油耗和电耗各自与自己同类型的锚点配对，绝不跨类型；"每公里成本"最准

---

## 隐私

**不收集、不上传、也无法上传。**

| 检查项 | 结果 |
|---|---|
| Android 声明权限 | 0 个 |
| 网络请求代码 | 0 处 |
| 网络相关依赖 | 0 个 |
| 第三方 SDK / 广告 / 统计埋点 | 0 个 |

完整声明见 [PRIVACY.md](PRIVACY.md)，里面写了怎么自己验证。

---

## 技术栈

| 类别 | 技术 |
|---|---|
| 框架 | Flutter 3.44 / Dart 3.12 |
| 状态管理 | Riverpod 2.6 |
| 本地数据库 | Drift 2.21（SQLite） |
| 路由 | go_router 14.8 |
| 图表 | fl_chart 0.68 |
| 本地存储 | shared_preferences |
| 文件操作 | file_picker / excel / path_provider |
| 中文本地化 | flutter_localizations |

---

## 项目结构

```
zhiji_oil_consumption/
├── lib/
│   ├── main.dart                        # 入口（含中文本地化配置）
│   ├── data/
│   │   ├── database/
│   │   │   ├── tables.dart              # 表定义（vehicles / energy_records / expenses）
│   │   │   ├── app_database.dart        # 数据库操作 + v3→v4 迁移
│   │   │   └── app_database.g.dart      # Drift 生成（勿手改）
│   │   └── models/                      # 数据模型
│   ├── features/
│   │   ├── dashboard/                   # 首页看板 + 统计总览入口
│   │   ├── vehicles/                    # 车辆管理
│   │   ├── records/                     # 加油 / 充电记录
│   │   ├── expenses/                    # 保养 + 费用
│   │   ├── statistics/                  # 单车统计 + 跨车总览
│   │   ├── settings/                    # 设置
│   │   └── export/                      # 导入导出
│   └── shared/
│       ├── routes/                      # 路由
│       ├── themes/                      # Material 3 主题
│       ├── utils/                       # 工具
│       └── widgets/                     # 共享组件
├── android/                             # Android 平台
├── ohos/                                # 鸿蒙平台（暂停维护，代码保留）
├── test/                                # 单元测试
├── docs/                                # 设计、评审、拆解文档
└── tools/                               # 图标生成等脚本
```

---

## 快速开始

### 环境要求

| 工具 | 版本 |
|---|---|
| Flutter SDK | ≥ 3.44.0 |
| Dart | ≥ 3.12 |
| JDK | 17+ |
| Android SDK | compileSdk 36 / build-tools 34+ |

### 跑起来

```bash
git clone https://github.com/LianbinZhou/zhiji_oil_consumption.git
cd zhiji_oil_consumption
flutter pub get
flutter run -d android
```

### 改了数据库表之后

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 静态检查与测试

```bash
flutter analyze
flutter test
```

---

## 构建

```bash
# 只打 arm64（体积最小，约 21 MB）
flutter build apk --release --split-per-abi
```

产物：`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

也可以直接双击项目根目录的 `build_apk.cmd`（会自动拉依赖 → 检查 → 打包 → 复制到 `dist/`）。

### 升级时会发生什么

- 旧版本的数据库会先被复制成 `zhiji_oil.db.pre-v4.bak`（连同 `-wal` / `-shm`），再做结构迁移
- 备份**只做一次**：即使迁移中途失败，也不会用半成品覆盖掉最初的原始快照
- ⚠️ 该备份位于**应用私有目录**（`Android/data/com.zhiji.oilconsumption/files/`），
  普通文件管理器在 Android 11+ 上通常看不到。它主要是给开发排查用的；
  **你自己要做长期留档，请用「设置 → 导出 JSON 备份」**（走系统文件选择器，存哪由你决定）

### 关于签名

仓库**不包含**签名证书。要用自己的证书：

1. 生成 keystore 放到 `android/app/`
2. 在 `android/key.properties` 里填别名和密码
3. `gradle` 会自动读取；没有这个文件时会退回 debug 签名（别人克隆后仍能构建）

---

## 测试状态

| 项目 | 状态 |
|---|---|
| 静态检查（`flutter analyze`） | ✅ 手写代码 0 错误 0 警告 |
| 数据库迁移（v3 → v4） | ✅ 有自动化测试，含幂等性验证；迁移前自动备份为 `*.pre-v4.bak*` |
| 应用启动 | ✅ 有自动化测试 |
| 能耗计算 | ✅ `test/consumption_test.dart` **10 个用例**（区间求和、亮灯法、油电隔离、除零/倒退等边界） |
| 导入兼容性 | ⚠️ 代码支持 V1/V2 两种格式，**没有自动化测试** |
| 真机功能 | ✅ Android 12（华为 NOH-AN00）完整流程通过 |

---

## 参与贡献

欢迎提 Issue 和 PR。

- 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/)（`feat:` / `fix:` / `docs:` / `refactor:` / `chore:`）
- 代码用中文注释
- 提交前跑 `flutter analyze` 和 `flutter test`
- 新功能放 `lib/features/<功能名>/` 下

---

## 许可证

[MIT](LICENSE)

```
Copyright (c) 2026 LianbinZhou
```

---

## 致谢

- [Flutter](https://flutter.dev) — 跨平台 UI 框架
- [Drift](https://drift.simonbinder.eu/) — 类型安全的 SQLite ORM
- [Riverpod](https://riverpod.dev/) — 状态管理
- [fl_chart](https://github.com/imaNNeo/fl_chart) — 图表库
- 所有提 Issue 和 PR 的人
