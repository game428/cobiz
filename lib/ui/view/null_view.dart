import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class HomeNullView extends StatelessWidget {
  final String str;

  HomeNullView({this.str = '暂无会话消息'});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new InkWell(
        child: new Text(
          str ?? '',
          style: TextStyle(color: ThemeModel.defaultTextColor),
        ),
//        onTap: () => routePush(new UserPage()),
      ),
    );
  }
}
