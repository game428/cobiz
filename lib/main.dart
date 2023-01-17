import 'package:cobiz_client/cobiz_app.dart';
import 'package:cobiz_client/config/provider_config.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

void main() async {
  /// 确保初始化
  WidgetsFlutterBinding.ensureInitialized();

  /// 强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  /// 配置初始化
  await StorageManager.init();

  /// APP入口并配置Provider
  runApp(ProviderConfig.getInstance().createGlobal(CobizApp()));

  /// 自定义报错页面
  // ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
  //   return Center(child: Text("App错误，快去反馈给作者!"));
  // };

  /// Android状态栏透明
  if (isAndroid()) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}
