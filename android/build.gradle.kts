allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // flutter_stripe 的 stripe_android 插件传递依赖
    // com.stripe:stripe-android-issuing-push-provisioning → play-services-tapandpay:17.1.2，
    // 而 tapandpay 是 Google Pay 发卡合作方专用库、公网 Maven 根本没有，导致 release 解析失败。
    // 我们只用 PaymentSheet 充值、不用发卡进钱包；插件里 tapandpay 也只走反射(Class.forName)，
    // 故排掉这个取不到的传递依赖（push-provisioning AAR 本体保留，编译/运行都不受影响）。
    configurations.configureEach {
        exclude(group = "com.google.android.gms", module = "play-services-tapandpay")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// 某些插件（如 flutter_webrtc 0.12.x）把自己的 android.compileSdk 硬编在 31，
// 而它的 androidx 传递依赖要求 ≥34，导致 release 的 checkReleaseAarMetadata 失败。
// 把每个 Android 子模块过低的 compileSdk 顶到 36（反射避开 AGP 版本间的 DSL 类型差异）。
// 上面的 evaluationDependsOn(":app") 会让部分子工程提前评估完，所以这里要分已/未评估两种情况处理。
subprojects {
    val bumpCompileSdk = {
        project.extensions.findByName("android")?.let { android ->
            val klass = android.javaClass
            runCatching {
                val current = klass.getMethod("getCompileSdk").invoke(android) as? Int
                if (current == null || current < 36) {
                    klass.getMethod("setCompileSdk", Int::class.javaObjectType).invoke(android, 36)
                }
            }
        }
    }
    if (project.state.executed) bumpCompileSdk() else afterEvaluate { bumpCompileSdk() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
