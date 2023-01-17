import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/jpush_manager.dart';
import 'package:cobiz_client/socket/ws_response.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobpush_plugin/mobpush_local_notification.dart';
import 'package:mobpush_plugin/mobpush_notify_message.dart';
import 'package:mobpush_plugin/mobpush_plugin.dart';

class PushManager {
  static final MobpushPlugin mobPush = new MobpushPlugin();
  static bool isBackstage = false; // 是否后台
  static BuildContext _context;

  static void setIsBackstage(bool v) {
    isBackstage = v;
  }

  static void setContext(BuildContext context) {
    if (context != null) {
      _context = context;
    }
  }

  static Future<void> initPlatformState() async {
    try {
      MobpushPlugin.addPushReceiver((Object event) {
        Map<String, dynamic> eventMap = json.decode(event);
        Map<String, dynamic> result = eventMap['result'];
        int action = eventMap['action'];
        switch (action) {
          case 0:
            // 接收自定义消息
            break;
          case 1:
            //接收通知消息
            // ignore: unused_local_variable
            MobPushNotifyMessage message =
                new MobPushNotifyMessage.fromJson(result);
            break;
        }
      }, (Object event) {
        print('>>>>>>>>>>>>onError:' + event.toString());
      });
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (Platform.isIOS) {
      MobpushPlugin.setCustomNotification();
      MobpushPlugin.setAPNsForProduction(false);
    }
    //上传隐私协议许可
    MobpushPlugin.updatePrivacyPermissionStatus(true);
    try {
      MobpushPlugin.getRegistrationId().then((Map<String, dynamic> ridMap) {
        MobpushPlugin.setAlias("uid_${API.userInfo.id}")
            .then((Map<String, dynamic> aliasMap) {
          String res = aliasMap['res'];
          String error = aliasMap['error'];
          String errorCode = aliasMap['errorCode'];
          print(
              ">>>>>>>>>>> setAlias -> res: $res error: $error errorCode：$errorCode");
        });
        String rid = ridMap['res'].toString();
        print("flutter get registration id : $rid");
      });
    } on PlatformException {
      print('Failed to get registrationId.');
    }
  }

  // type: 1:正常发送群聊私聊推送，2:发送自定义消息，3：工作通知 4：申请加入团队
  static void sendJpush({dynamic data, int type}) async {
    if (isBackstage && API.userInfo.newNotice) {
      if (data is WsResChat && (data.mtype ?? 0) == 104) return;
      Map<String, String> send;
      if (API.userInfo.noticeDetail) {
        switch (type) {
          case 1:
            send = formatChat(_context, data, API.userInfo.id);
            break;
          case 2:
            send = data;
            break;
          case 3:
            send = formatWork(_context, data);
            break;
          case 4:
            send = {
              "title": data['title'],
              "content": S.of(_context).applyJoin + '：' + data['content'],
            };
            break;
        }
      } else {
        send = {
          "title": 'Cobiz',
          "content": S.of(_context).newMsg,
        };
      }
      if (isIOS()) {
        JPushManager.sendJpush(data: send);
      } else {
        MobPushLocalNotification localNotification =
            new MobPushLocalNotification(
          notificationId: API.userInfo.id, //notificationId
          title: send["title"], //本地通知标题
          content: send["content"], //本地通知内容
          messageId: null, //消息id
          inboxStyleContent: null, //收件箱样式的内容
          timestamp: DateTime.now().millisecondsSinceEpoch, //本地通知时间戳, 1秒后出发本地推送
          style: 0, //通知样式
          channel: 0, //消息通道
          extrasMap: null, //附加数据
          voice: true, //声音
          shake: true, //真的
          styleContent: null, //大段文本和大图模式的样式内容
          light: true, //呼吸灯
        );
        await MobpushPlugin.addLocalNotification(localNotification)
            .then((value) {
          print('消息已经推送');
        });
      }
    }
  }
}
