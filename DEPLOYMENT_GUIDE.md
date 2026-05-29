# 📱 Android & HarmonyOS 部署指南

## 🤖 Android 部署

### ✅ 已完成配置

- ✅ 修改包名：`com.zhiji.oilconsumption`
- ✅ 设置应用名：智记油耗
- ✅ 设置SDK版本：minSdk 21, targetSdk 34
- ✅ 版本号：1.0.0

### 🚀 运行步骤

#### 1. 连接Android设备
```bash
# 开启开发者模式和USB调试
# 检查设备连接
flutter devices
```

#### 2. 运行应用
```bash
# 调试模式
flutter run -d android

# 指定设备
flutter run -d <device_id>
```

#### 3. 构建APK
```bash
# 调试APK
flutter build apk --debug

# 发布APK
flutter build apk --release
```

#### 4. 构建AppBundle（用于上架Google Play）
```bash
flutter build appbundle --release
```

### 📦 输出位置

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AppBundle: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔧 Android 发布前准备

### 1. 生成签名密钥
```bash
keytool -genkey -v -keystore zhiji-oil.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias zhiji-oil
```

### 2. 创建签名配置文件
在 `android/key.properties`:
```properties
storePassword=你的密码
keyPassword=你的密码
keyAlias=zhiji-oil
storeFile=../zhiji-oil.jks
```

### 3. 添加权限（如需要）
在 `android/app/src/main/AndroidManifest.xml` 添加：
```xml
<!-- 读取外部存储 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<!-- 写入外部存储 -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

---

## 🦋 HarmonyOS 部署

### ⚠️ 当前状态
❌ 未配置HarmonyOS支持

### 📋 部署方案

#### 方案一：Flutter HarmonyOS（推荐）

**优势**：代码完全复用，一套代码多端运行

**步骤**：

1. **安装HarmonyOS SDK**
   - 下载 [DevEco Studio](https://developer.harmonyos.com/cn/develop/deveco-studio)
   - 安装HarmonyOS SDK (API 9+)

2. **安装Flutter HarmonyOS插件**
   ```bash
   flutter config --enable-harmonyos
   ```

3. **创建HarmonyOS配置**
   ```bash
   flutter create --platforms ohos .
   ```

4. **运行HarmonyOS版本**
   ```bash
   flutter run -d ohos
   ```

#### 方案二：使用方舟开发框架（ArkTS）

**优势**：原生性能，华为生态深度集成

**劣势**：需要重写UI层（约70%工作量）

**步骤**：

1. 使用DevEco Studio创建HarmonyOS项目
2. 移植业务逻辑（Dart → ArkTS）
3. 重新实现UI界面
4. 数据库改用Preferences/DataStore

---

## 🎯 推荐路径

### 短期方案（1-2天）
✅ 先完成Android版本发布
- 测试所有功能
- 优化性能
- 上架应用市场

### 中期方案（3-5天）
✅ 添加HarmonyOS支持
- 使用Flutter HarmonyOS插件
- 测试HarmonyOS兼容性
- 发布HarmonyOS版本

---

## 📊 平台兼容性检查

| 功能 | Android | HarmonyOS | iOS |
|------|---------|-----------|-----|
| 数据库(Drift) | ✅ | ✅ | ✅ |
| 文件选择 | ✅ | ⚠️ 需测试 | ✅ |
| Excel导出 | ✅ | ✅ | ✅ |
| 图表绘制 | ✅ | ✅ | ✅ |
| 深色模式 | ✅ | ✅ | ✅ |

---

## 🚀 快速开始

### 立即运行Android版本：
```bash
cd C:\Users\zhou0\Lingma\zhiji_oil_consumption
flutter devices
flutter run -d android
```

### 检查环境：
```bash
flutter doctor -v
```

---

## 📝 待办事项

### Android发布清单
- [ ] 测试所有功能
- [ ] 添加应用图标（多尺寸）
- [ ] 配置签名密钥
- [ ] 生成发布APK
- [ ] 上架应用市场（华为/小米/OPPO等）

### HarmonyOS准备
- [ ] 安装DevEco Studio
- [ ] 配置HarmonyOS SDK
- [ ] 启用Flutter HarmonyOS支持
- [ ] 创建ohos配置
- [ ] 测试兼容性
- [ ] 发布HarmonyOS应用市场

---

## 💡 提示

1. **Android优先**：先完成Android版本，积累用户
2. **HarmonyOS延后**：等Flutter HarmonyOS插件更稳定
3. **保持统一**：用Flutter保证多端一致性
4. **性能测试**：在低端Android设备测试性能