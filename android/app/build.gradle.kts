import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase / FCM：注入 google-services.json 配置（项目级 plugin 在 settings.gradle.kts 声明）
    id("com.google.gms.google-services")
}

// Google Play release signing：从 android/key.properties 读密码 + alias 等。
// 文件 gitignored，密码备份在 CREDENTIALS.local.md。
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "app.falconflix"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // 调试包 = app.falconflix（你自己手机一直装的就是这个，不变）
        applicationId = "app.falconflix"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystoreProperties.containsKey("storeFile")) {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // 有 key.properties → 用 release 签名；没有 → 退回 debug（保 `flutter run --release` 可用）。
            signingConfig = if (keystoreProperties.containsKey("storeFile"))
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            // ⚠️ Google Play 上 Personal 账号（fubill409）发的是「测试版」。
            // 之前用 .beta 后缀 → 实际包名 app.falconflix.beta，但 Play Console 创建 App 时
            // 报「此软件包名称已被使用」（Google 全局命名空间 .beta 后缀冲突）。
            // 改 .tester（罕见后缀，不撞名）→ 实际包名 app.falconflix.tester。
            // 跟正式版 app.falconflix 仍完全独立（公司账号将来上正式版时把这两行注释掉即可）。
            applicationIdSuffix = ".tester"
            versionNameSuffix = "-tester"
            // flutter_stripe 在 release(R8 收缩)下要忽略用不到的 push-provisioning/tapandpay 引用。
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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
