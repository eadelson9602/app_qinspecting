# ProGuard/R8 rules to fix TypeToken/generic stripping for notifications cache
-keepattributes Signature
-keepattributes *Annotation*

# Gson
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Flutter runtime (safe)
-keep class io.flutter.** { *; }

# Services/BroadcastReceivers used by notifications
-keep class ** extends android.app.Service { *; }
-keep class ** extends android.content.BroadcastReceiver { *; }

# Play Core splitinstall (for deferred components manager)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
