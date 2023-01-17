import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

// 该页面已废弃
class ComputerLoginPage extends StatefulWidget {
  ComputerLoginPage({Key key}) : super(key: key);

  @override
  _ComputerLoginPageState createState() => _ComputerLoginPageState();
}
class _ComputerLoginPageState extends State<ComputerLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          backgroundColor: AppColors.white,
          automaticallyImplyLeading: false,
          rightDMActions: [
            IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: ImageView(
                  img: 'assets/images/chat/pc.png',
                  width: 120,
                  height: 120,
                ),
              ),
              Text(
                '电脑端 CoBiz 已登录',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('上次登录 IP: 成都 162.180.2.11'),
              ),
              buildCommonButton('电脑文件传输',
                  radius: 15, margin: EdgeInsets.fromLTRB(100, 40, 100, 10)),
              buildCommonButton('退出电脑 CoBiz',
                  radius: 15, margin: EdgeInsets.fromLTRB(100, 10, 100, 10)),
            ],
          ),
        ));
  }
}
