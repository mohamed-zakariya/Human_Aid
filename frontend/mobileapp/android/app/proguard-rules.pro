# Prevent R8 from removing Google Credentials classes used by smart_auth
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keepclassmembers class com.google.android.gms.auth.api.credentials.** { *; }
-dontwarn com.google.android.gms.auth.api.credentials.**

# Prevent R8 from removing TensorFlow Lite GPU delegate classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-dontwarn org.tensorflow.lite.**
