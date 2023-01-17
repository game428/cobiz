import 'package:cobiz_client/provider/login_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cobiz_client/provider/global_model.dart';

/// ProviderConfig  provider配置
class ProviderConfig {
  static ProviderConfig _instance;

  static ProviderConfig getInstance() {
    if (_instance == null) {
      _instance = ProviderConfig._internal();
    }
    return _instance;
  }

  ///全局
  ChangeNotifierProvider<GlobalModel> createGlobal(Widget child) {
    return ChangeNotifierProvider<GlobalModel>(
      create: (context) => GlobalModel(),
      child: child,
    );
  }

  ///登陆
  ChangeNotifierProvider<LoginModel> createLogin(Widget child) {
    return ChangeNotifierProvider<LoginModel>(
      create: (context) => LoginModel()..setContext(context),
      child: child,
    );
  }

  ProviderConfig._internal();
}
