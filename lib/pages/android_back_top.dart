import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidBackTop {
  //初始化通信管道-设置退出到手机桌面
  static const platform = const MethodChannel('back/desktop');

  static Future<bool> backDesktop() async {
    try {
      if (Platform.isAndroid) {
        final bool out = await platform.invokeMethod('backToDesktop');
        debugPrint('安卓返回桌面 $out');
      }
    } on PlatformException catch (e) {
      debugPrint('通信失败 e >>> $e');
    }
    return Future.value(false);
  }
}
