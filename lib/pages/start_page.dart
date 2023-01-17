import 'dart:convert';

import 'package:cobiz_client/config/provider_config.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/http/user.dart' as userApi;
import 'package:cobiz_client/pages/login/login_page.dart';
import 'package:cobiz_client/pages/mine/improve_data.dart';
import 'package:cobiz_client/pages/root_page.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  GlobalModel model;

  @override
  void initState() {
    super.initState();
    model = Provider.of<GlobalModel>(context, listen: false);
    countDown();
  }

  void countDown() {
    var duration = Duration(seconds: 0);
    Future.delayed(duration, _gotoNext);
  }

  void _gotoNext() async {
    if (model.goToLogin) {
      routePushAndRemove(ProviderConfig.getInstance().createLogin(LoginPage()));
    } else {
      User user = await userApi.getUserInfo();
      if (user == null) {
        await userApi.logout(context);
        routePushAndRemove(
            ProviderConfig.getInstance().createLogin(LoginPage()));
      } else {
        model.userInfo = user;
        await SharedUtil.instance
            .saveString(Keys.userInfo, json.encode(user.toJson()));
        model.refresh();
        await AESUtils.getSharedSecret();
        routePushAndRemove(strNoEmpty(model.userInfo.nickname)
            ? RootPage()
            : ImproveDataPage(
                from: 1,
              ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
