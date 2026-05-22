plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.zero_cost_streamer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.zero_cost_streamer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = "${flutter.versionName} Build ${flutter.versionCode}"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")

            applicationVariants.all {
                val variant = this
                variant.outputs.all {
                    val output = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
                    val project = "Zero_Stream"
                    val version = variant.versionName

                    output.outputFileName = "$project v$version.apk"
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}