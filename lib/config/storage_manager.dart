import 'dart:convert';

import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;

class StorageManager {
  static SharedPreferences sp;

  /// 网络连接
  var connect;

  static init() async {
    // async 异步操作
    // sync 同步操作
    sp = await SharedPreferences.getInstance();

    StorageManager().monitorNetwork();
  }

  // 监测网络变化
  monitorNetwork() async {
    try {
      connect = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) async {
        if (result != ConnectivityResult.mobile &&
            result != ConnectivityResult.wifi) {
          await SharedUtil.instance.saveBoolean(Keys.brokenNetwork, true);
          eventBus.emit(EVENT_SOCKET_IS_RECONNECTION, 'no_wifi_and_mobile');
        } else {
          await SharedUtil.instance.saveBoolean(Keys.brokenNetwork, false);
          eventBus.emit(EVENT_SOCKET_IS_RECONNECTION, 'wifi_or_mobile');
          //连接网络时检测一下有没有没有删掉的线上记录
          List<String> his =
              await SharedUtil.instance.getStringList(Keys.deleteHistoryFail);
          if (his != null) {
            List<dynamic> list = [];
            his.forEach((element) {
              list.add(jsonDecode(element));
            });
            bool res = await chatApi.deleteOnlineChat(list);
            if (res == true) {
              SharedUtil.instance.remove(Keys.deleteHistoryFail);
            }
          }
        }
      });
    } on PlatformException {
      debugPrint('error');
    }
  }
}
