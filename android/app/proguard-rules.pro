# Stack traces stay readable in Play Console / Crashlytics after you upload mapping.txt
-keepattributes SourceFile, LineNumberTable
-renamesourcefileattribute SourceFile

# Annotations and generics that some plugins read by reflection
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

# Only if the release build fails with "Missing class com.google.android.play.core..."
# (older Flutter setups that reference deferred components)
-dontwarn com.google.android.play.core.**

# Strip native Android debug logs from release builds (needs the -optimize file below)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}