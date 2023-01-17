import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import 'realname_page.dart';

class RealnameStatePage extends StatefulWidget {
  RealnameStatePage();

  @override
  _RealnameStatePageState createState() => _RealnameStatePageState();
}

class _RealnameStatePageState extends State<RealnameStatePage> {
  int state = 2;
  String icUrl = '';
  String text1 = '';
  String text2 = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    switch (state) {
      case 1:
        icUrl = 'assets/images/mine/ic_wait.png';
        text1 = '审核已提交，等待处理';
        text2 = '';
        break;
      case 2:
        icUrl = 'assets/images/mine/ic_error.png';
        text1 = '审核未通过';
        text2 = '详细请客服咨询';
        break;
      case 3:
        icUrl = 'assets/images/mine/ic_success.png';
        text1 = '您已实名认证';
        text2 = '绑定时间：2020-10-13';
        break;
    }
  }

  void _doSubmit() {
    routePushReplace(RealnamePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).realNameVerify,
        elevation: 0.5,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 160, bottom: 35),
                child: ImageView(
                  img: icUrl ?? 'assets/images/mine/ic_wait.png',
                  height: 65,
                  width: 65,
                  isRadius: 0,
                ),
              ),
            ],
          ),
          Text(text1, style: TextStyles.textF17T3),
          SizedBox(
            height: 20,
          ),
          text2.isNotEmpty
              ? Text(text2, style: TextStyles.textF14T1)
              : Container(),
          Spacer(),
          state == 2
              ? buildCommonButton('重新申请', onPressed: _doSubmit)
              : Container(),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
