import 'dart:convert';

import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/provider/global_model.dart';
import 'package:cobiz_client/tools/shared_util.dart';

class GlobalLogic {
  final GlobalModel _globalModel;

  GlobalLogic(this._globalModel);

  ///获取app的名字
  Future getAppName() async {
    final appName = await SharedUtil.instance.getString(Keys.appName);
    if (appName == null) return;
    if (appName == _globalModel.appName) return;
    _globalModel.appName = appName;
  }

  ///获取当前的语言code
  Future getCurrentLanguageCode() async {
    final list =
        await SharedUtil.instance.getStringList(Keys.currentLanguageCode);
    if (list == null) return;
    if (list == _globalModel.currentLanguageCode) return;
    _globalModel.currentLanguageCode = list;
  }

  ///获取当前登录的token
  Future loadLoginUser() async {
    try {
      final token = await SharedUtil.instance.getString(Keys.token);
      if (token != null) {
        _globalModel.token = token;
        _globalModel.goToLogin = false;
      }

      final userData = await SharedUtil.instance.getString(Keys.userInfo);
      if (userData != null) {
        var obj = json.decode(userData);
        _globalModel.userInfo = User.fromJsonMap(obj);
      }
    } catch (e) {
      print(e);
    }
  }
}
