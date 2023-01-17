import 'package:cobiz_client/provider/theme_model.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/provider/loginc/global_loginc.dart';

class GlobalModel extends ChangeNotifier with ThemeModel {
  BuildContext context;

  // app的名字
  String appName = 'Cobiz';

  // 用户信息
  User _userInfo;
  String _token = '';

  // 当前语言
  List<String> currentLanguageCode = ['zh', 'CN'];
  Locale currentLocale;

  ///是否进入登录页
  bool goToLogin = true;

  GlobalLogic globalLogic;

  static GlobalModel _instance;

  static GlobalModel getInstance() => _instance;

  GlobalModel() {
    globalLogic = GlobalLogic(this);
    _instance = this;
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      Future.wait([
        globalLogic.getAppName(),
        globalLogic.getCurrentLanguageCode(),
        globalLogic.loadLoginUser(),
      ]).then((value) {
        currentLocale = Locale(currentLanguageCode[0], currentLanguageCode[1]);
        refresh();
      });
    }
  }

  void changeLanguage(Locale locale) {
    currentLocale = locale;
    currentLanguageCode = [locale.languageCode, locale.countryCode];
    notifyListeners();
  }

  set token(v) {
    _token = v;
    API.userToken = v;
  }

  set userInfo(v) {
    _userInfo = v;
    API.userInfo = v;
    notifyListeners();
  }

  void notifyListeners() {
    super.notifyListeners();
  }

  String get token => _token;

  User get userInfo => _userInfo;

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  //暂时写的勾选数量
  int _total = 0;
  int get total => _total;

  setTotal(int n) {
    _total = n;
  }
}
