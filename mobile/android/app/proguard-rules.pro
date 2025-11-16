# Homia App ProGuard Rules
# Keep Flutter components

## Flutter Framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

## Google Play Core (CRITICAL - Fixes R8 errors)
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

## Firebase Auth
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

## Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.maps.android.** { *; }

## Dio & OkHttp (HTTP client)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

## Gson (if used by Firebase or other libraries)
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep data classes (models)
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

## WebView
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, jav.lang.String);
}

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

## Keep Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

## Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

## Crashlytics (if using Firebase Crashlytics)
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

## Remove logging (optional - uncomment for production)
# -assumenosideeffects class android.util.Log {
#     public static *** d(...);
#     public static *** v(...);
#     public static *** i(...);
# }


