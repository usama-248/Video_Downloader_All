import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.FutureLabszee.facebook.video.downloader"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.FutureLabszee.facebook.video.downloader"
        // FFmpeg Kit requires API 24+.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            keyAlias = (keystoreProperties["keyAlias"] as? String) ?: "androiddebugkey"
            keyPassword = (keystoreProperties["keyPassword"] as? String) ?: "android"
            storeFile = (keystoreProperties["storeFile"] as? String)?.let { file(it) } ?: file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = (keystoreProperties["storePassword"] as? String) ?: "android"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    dependencies {
    // Add Google Mobile Ads dependency
    implementation("com.google.android.gms:play-services-ads:23.0.0")
}

}

flutter {
    source = "../.."
}