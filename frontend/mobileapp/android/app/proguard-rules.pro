# Prevent R8 from removing Google Credentials classes used by smart_auth
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keepclassmembers class com.google.android.gms.auth.api.credentials.** { *; }
-dontwarn com.google.android.gms.auth.api.credentials.**

# Prevent R8 from removing TensorFlow Lite GPU delegate classes
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-dontwarn org.tensorflow.lite.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# FCM
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.installations.** { *; }

# Firestore
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class ** {
    @com.google.firebase.firestore.PropertyName <methods>;
    @com.google.firebase.firestore.PropertyName <fields>;
}

# Additional Firebase rules for better compatibility
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.database.** { *; }
-keep class com.google.firebase.functions.** { *; }

# Keep notification service classes
-keep class * extends com.google.firebase.messaging.FirebaseMessagingService { *; }

# Flutter Firebase plugin classes
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.firebasemessaging.** { *; }

# Keep SharedPreferences related classes (for your user data storage)
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# Gson (if you're using it for JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }

# Keep generic signature of classes (important for Firestore)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep model classes (replace com.example.mobileapp with your actual package)
-keep class com.example.mobileapp.models.** { *; }
-keep class com.example.mobileapp.data.** { *; }

# OkHttp (used by Firebase)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Retrofit (if using)
-keep class retrofit2.** { *; }
-keepclasseswithmembers class * {
    @retrofit2.http.* <methods>;
}

# Additional safety rules
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}