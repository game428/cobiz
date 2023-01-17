import 'package:cobiz_client/pages/dialogue/channel/complaint/complaints_edit.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class ComplaintsTypePage extends StatefulWidget {
  final int from; //来源 1.用户 2.群聊
  final int targetId;
  const ComplaintsTypePage(
      {Key key, @required this.from, @required this.targetId})
      : super(key: key);
  @override
  _ComplaintsTypePageState createState() => _ComplaintsTypePageState();
}

class _ComplaintsTypePageState extends State<ComplaintsTypePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ComMomBar(
        title: S.of(context).complaints,
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: <Widget>[
            OperateLineView(
              title: S.of(context).harass,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 1,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
            OperateLineView(
              title: S.of(context).cheatMoney,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 2,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
            OperateLineView(
              title: S.of(context).misappropriation,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 3,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
            OperateLineView(
              title: S.of(context).infringement,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 4,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
            OperateLineView(
              title: S.of(context).counterfeit,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 5,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
            OperateLineView(
              title: S.of(context).impersonate,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 6,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
            OperateLineView(
              title: S.of(context).other,
              onPressed: () {
                routePushReplaceWithMaterial(ComplaintsEditPage(
                  type: 0,
                  from: widget.from,
                  targetId: widget.targetId,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
