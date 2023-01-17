import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///审批意见展示
class AgreeRefuesShow extends StatelessWidget {
  final String content;
  final int time;
  const AgreeRefuesShow({Key key, @required this.content, @required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateUtil.formatSeconds(time),
                    style: TextStyle(fontSize: 14, color: grey81Color),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(content))
                ],
              ),
            ),
          ),
          appBar: ComMomBar(
            title: S.of(context).approveMessage,
            elevation: 0.5,
          )),
    );
  }
}
