import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class JPushManager {
  static final JPush jpush = new JPush();

  static Future<void> initPlatformState() async {
    try {
      jpush.addEventHandler(
        // 接收通知回调方法。
        onReceiveNotification: (Map<String, dynamic> message) async {
          print("flutter onReceiveNotification: $message");
        },
        // 点击通知回调方法。
        onOpenNotification: (Map<String, dynamic> message) async {
          print("flutter onOpenNotification: $message");
        },
        // 接收自定义消息回调方法。
        onReceiveMessage: (Map<String, dynamic> message) async {
          print("flutter onReceiveMessage: $message");
        },
        onReceiveNotificationAuthorization:
            (Map<String, dynamic> message) async {
          print("flutter onReceiveNotificationAuthorization: $message");
        },
      );
    } on PlatformException {
      print('Failed to get platform version.');
    }
    // only ios
    jpush.setup(
      appKey: 'c12d80b17aa2e8ed6d90b50f',
      channel: "Cobiz",
      production: true,
      debug: false,
    );
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jpush.getRegistrationID().then((rid) {
        jpush.setAlias('uid_${API.userInfo.id}');
        print("flutter get registration id : $rid");
      });
    } catch (e) {
      //skip
    }
  }

  static void sendJpush({dynamic data}) async {
    // 1秒后出发本地推送
    var fireDate = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    var localNotification = LocalNotification(
      id: API.userInfo.id,
      title: data["title"], // title:
      buildId: 1,
      content: data["content"], // alert,  cn.jpush.android.ALERT
      fireTime: fireDate,
      // subtitle: 'fasf',
      badge: 1,
      // extra: {"fa": "0"},
    );
    jpush.sendLocalNotification(localNotification).then((res) {
      print('已推送消息');
    });
  }
}
