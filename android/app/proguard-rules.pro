#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

#厂商的混淆规则
-keep class android.os.SystemProperties
-dontwarn android.os.SystemProperties
-keep class com.huawei.**{*;}
-keep class com.meizu.**{*;}
-keep class com.xiaomi.**{*;}

-dontwarn com.huawei.**
-dontwarn com.meizu.**
-dontwarn com.xiaomi.**

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

-keep class com.huawei.hms.**{*;}
-keep class com.meizu.cloud.**{*;}
-keep class com.xiaomi.mipush.sdk.**{*;}
-keep class org.apache.thrift.**{*;}
-keep class com.google.** {*;}
-keep class com.coloros.** {*;}
-keep class com.mob.tools.* {*;}
-keep class com.mob.wrappers.* {*;}

-dontwarn com.mob.commons.**
-dontwarn com.mob.wrappers.**
-dontwarn com.huawei.hms.**
-dontwarn com.meizu.cloud.**
-dontwarn com.xiaomi.mipush.sdk.**
-dontwarn org.apache.thrift.**
-dontwarn com.google.**
-dontwarn com.coloros.**

-dontwarn com.vivo.push.**
-keep class com.vivo.push.**{*; }
-keep class com.vivo.vms.**{*; }
-keep class com.mob.pushsdk.plugins.vivo.PushVivoReceiver{*;}

-keep class com.meizu.cloud.pushsdk.MzPushMessageReceiver{
public *;
}

-keep class com.mob.pushsdk.plugins.xiaomi.PushXiaoMiRevicer {*;}
-dontwarn com.xiaomi.push.**

#这是oppo的混淆规则
-keep public class * extends android.app.Service
-keep class com.heytap.msp.** { *;}
-keep class com.mob.pushsdk.plugins.oppo.** { *;}