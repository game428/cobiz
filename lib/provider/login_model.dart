import 'package:cobiz_client/config/location.dart';
import 'package:cobiz_client/provider/loginc/login_loginc.dart';
import 'package:flutter/material.dart';

class LoginModel extends ChangeNotifier {
  BuildContext context;

  LoginLogic logic;

  Area _area;
  String mobile = '';

  LoginModel() {
    logic = LoginLogic(this);
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      Future.wait<Area>([
        Location.loadArea(context: context),
      ]).then((value) {
        this._area = value[0];
        refresh();
      });
    }
  }

  Area get area => _area;

  @override
  void dispose() {
    super.dispose();
  }

  void refresh() {
    notifyListeners();
  }
}
