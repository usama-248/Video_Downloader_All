# Flutter embedding & plugins (required for release / R8)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# Pigeon (Firebase Core & other generated host APIs)
-keep class dev.flutter.pigeon.** { *; }
-keep class * extends dev.flutter.pigeon.** { *; }

# Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class io.flutter.plugins.googlemobileads.** { *; }

# AdMob mediation adapters
-keep class com.google.ads.mediation.** { *; }
-keep class com.google.android.gms.ads.mediation.** { *; }

# Meta Audience Network
-keep class com.facebook.ads.** { *; }
-keep class com.google.ads.mediation.facebook.** { *; }
-dontwarn com.facebook.ads.**

# Liftoff Monetize (Vungle)
-keep class com.vungle.** { *; }
-keep class com.google.ads.mediation.vungle.** { *; }
-dontwarn com.vungle.**

# Mintegral
-keep class com.mbridge.** { *; }
-keep class com.google.ads.mediation.mintegral.** { *; }
-dontwarn com.mbridge.**

# Gson (used by Firebase / Play Services)
-keepattributes Signature
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Flutter deferred components (Play Core — optional, not bundled in app)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# FFmpeg Kit (required for release when using ffmpeg_kit_flutter_new)
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-dontwarn com.antonkarpenko.ffmpegkit.**
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class com.antonkarpenko.ffmpegkit.FFmpegKitConfig { *; }
-keep class com.antonkarpenko.ffmpegkit.AbiDetect { *; }
-keep class com.antonkarpenko.ffmpegkit.*Session { *; }
-keep class com.antonkarpenko.ffmpegkit.*Callback { *; }
-keep public class com.antonkarpenko.ffmpegkit.** { public *; }

# SQLite / WebView plugins
-keep class com.tekartik.sqflite.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }
