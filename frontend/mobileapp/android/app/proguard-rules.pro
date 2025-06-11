# Prevent R8 from removing Google Credentials classes used by smart_auth
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keepclassmembers class com.google.android.gms.auth.api.credentials.** { *; }
-dontwarn com.google.android.gms.auth.api.credentials.**
