import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// ===== 读取 release 签名配置 =====
// key.properties 与 zhiji-release.jks 都被 .gitignore 挡住，不会进仓库。
// 别人克隆后没有这个文件，会自动退回 debug 签名，仍能构建。
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.zhiji.oilconsumption"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.zhiji.oilconsumption"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        // 版本号统一由 pubspec.yaml 的 version 决定（形如 1.0.0+2）
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 注意：不要在这里手写 ndk.abiFilters 或 splits。
    // Flutter 的 gradle 插件会按 -Ptarget-platform 强制设置 abiFilters（默认三个架构全要），
    // 手写会被覆盖；手写 splits 则直接报 "Conflicting configuration"。
    // 要单架构包，用命令行参数：
    //     flutter build apk --release --split-per-abi
    // 它会产出 app-arm64-v8a-release.apk / app-armeabi-v7a-release.apk / app-x86_64-release.apk

    signingConfigs {
        create("release") {
            if (hasReleaseKey) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
