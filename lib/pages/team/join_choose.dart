import 'package:cobiz_client/pages/team/team_page/create_team.dart';
import 'package:cobiz_client/pages/team/team_page/nearby_page.dart';
import 'package:cobiz_client/pages/team/team_page/search_team.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class JoinTeamChooseSheet extends StatelessWidget {
  final double height;
  final Function(dynamic) callBack;
  const JoinTeamChooseSheet(this.height, {Key key, this.callBack})
      : super(key: key);

  FlatButton _buildFlatButton(
      String iconSrc, String text, int type, BuildContext context) {
    return new FlatButton(
        child: new Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Image.asset(iconSrc, width: 30.0, height: 30.0),
            new Text(text, style: TextStyles.textDefault)
          ],
        ),
        onPressed: () async {
          if (type == 1) {
            routePushReplaceWithMaterial(NearbyTeamPage());
          } else if (type == 2) {
            routePushReplaceWithMaterial(SearchTeamPage());
          } else if (type == 3) {
            var data = await routePushReplaceWithMaterial(CreateTeamPage());
            if (callBack != null && data != null) {
              callBack(data);
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          // Expanded(
          //     child: _buildFlatButton('assets/images/team/nearby.png',
          //         S.of(context).teamNearby, 1, context)),
          Expanded(
              child: _buildFlatButton(
                  searchImage, S.of(context).teamSearch, 2, context)),
          Expanded(
              child: _buildFlatButton('assets/images/team/team.png',
                  S.of(context).teamCreate, 3, context))
        ],
      ),
    );
  }
}

// 询问是否加入或创建团队
void confirmJoinTeam(BuildContext context) {
  showConfirm(
    context,
    iconWidget: ImageView(
      img: 'assets/images/team/team.png',
      height: 20.0,
    ),
    title: S.of(context).teamJoinConfirmTitle,
    content: S.of(context).teamJoinConfirmContent,
    sureCallBack: () {
      showJoinTeamOperate(context);
    },
  );
}

// 显示加入团队的操作选择界面
void showJoinTeamOperate(BuildContext context, {Function(dynamic) call}) {
  double radius = 15.0;
  double height = 100.0;

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius))),
    builder: (BuildContext bct) {
      return Stack(
        children: <Widget>[
          Container(
            height: height + ScreenData.bottomSafeHeight,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                )),
          ),
          Container(
            child: JoinTeamChooseSheet(
              height,
              callBack: call,
            ),
          ),
        ],
      );
    },
  );
}
