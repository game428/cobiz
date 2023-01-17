import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/team.dart';
import 'package:cobiz_client/pages/team/friend/invite_qrcode.dart';
import 'package:cobiz_client/pages/team/member/team_member_info.dart';
import 'package:cobiz_client/pages/team/team_page/edit_billing_info.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

//团队信息
class TeamInfoPage extends StatefulWidget {
  final int teamId;
  final String outName;
  TeamInfoPage({Key key, @required this.teamId, this.outName})
      : super(key: key);

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  String _teamtype = '';
  TeamInfo teamInfo;

  @override
  void initState() {
    super.initState();
    this._getInfo();
  }

  // 获取团队信息
  _getInfo() async {
    var res = await getSomeoneTeam(teamId: widget.teamId);
    if (mounted) {
      setState(() {
        if (res != null) {
          teamInfo = res;
        } else {
          showToast(context, S.of(context).currentNoExistent);
          Navigator.pop(context, true);
        }
      });
    }
    _getData();
  }

  //
  _getData() async {
    if (teamInfo != null) {
      _teamtype = await queryTeamTypeName(teamInfo?.type, context);
      if (mounted) {
        setState(() {});
      }
    }
  }

  //退出团队
  _leaveTeam() async {
    Loading.before(context: context);
    var res = await teamApi.leaveTeam(teamId: teamInfo.id);
    Loading.complete();
    if (res) {
      Navigator.pop(context, true);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  //创建者解散团队
  _deleteTeam() async {
    Loading.before(context: context);
    var res = await teamApi.dismissTeam(teamInfo.id);
    Loading.complete();
    if (res) {
      Navigator.pop(context, true);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  //创建者 管理员
  Widget _buildCreators() {
    List<Widget> _ls = [
      OperateLineView(
          onPressed: () {
            routePush(TeamMemberInfo(
                teamId: teamInfo?.id, userId: teamInfo?.creator, fromWhere: 1));
          },
          title: S.of(context).creator,
          isArrow: true,
          spaceSize: 0,
          haveBorder: teamInfo.managers.isNotEmpty,
          rightWidget: Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '${teamInfo?.creatorName ?? ''}',
              textAlign: TextAlign.right,
              style: TextStyles.textF16,
            ),
          )))
    ];
    teamInfo.managers.forEach((key, value) {
      _ls.add(OperateLineView(
          onPressed: () {
            routePush(TeamMemberInfo(
                teamId: teamInfo?.id, userId: int.parse(key), fromWhere: 1));
          },
          title: S.of(context).manager,
          isArrow: true,
          spaceSize: 0,
          haveBorder: key != teamInfo.managers.keys.last,
          rightWidget: Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              '${value ?? ''}',
              textAlign: TextAlign.right,
              style: TextStyles.textF16,
            ),
          ))));
    });
    return Column(
      children: _ls,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
          title: S.of(context).teamInfo,
          elevation: 0.5,
          backData: teamInfo?.name != widget.outName
              ? ['upTeamName', teamInfo?.name]
              : null),
      body: teamInfo == null
          ? buildProgressIndicator()
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              physics: BouncingScrollPhysics(),
              children: [
                ShadowCardView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(teamInfo?.name ?? '',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              '$_teamtype   ${teamInfo?.numB ?? 0}人',
                              style:
                                  TextStyle(fontSize: 14, color: greyAAColor),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              teamInfo?.intro ?? '',
                              style:
                                  TextStyle(fontSize: 14, color: greyAAColor),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                      buildFilletImage(
                          strNoEmpty(teamInfo?.icon ?? '')
                              ? teamInfo.icon
                              : logoImageG,
                          needLoad: true,
                          radius: 20)
                    ],
                  ),
                ),
                ShadowCardView(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: OperateLineView(
                      onPressed: () {
                        routePush(InviteQrcodePage(
                          type: 2,
                          teamCode: teamInfo?.code,
                          name: teamInfo?.name,
                        ));
                      },
                      spaceSize: 0,
                      haveBorder: false,
                      title: S.of(context).teamInviteQrCode,
                      isArrow: false,
                      rightWidget: ImageView(
                        img: 'assets/images/qrcode.png',
                        width: 20.0,
                        height: 20.0,
                      )),
                ),
                ShadowCardView(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: OperateLineView(
                      onPressed: () {
                        routePush(EditBillingInfoPage(
                          teamId: teamInfo.id,
                          readOnly: true,
                        ));
                      },
                      spaceSize: 0,
                      haveBorder: false,
                      title: S.of(context).billingInformation,
                      rightWidget: Expanded(
                          child: Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          S.of(context).viewInvoice,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: greyC1Color, fontSize: 16),
                        ),
                      ))),
                ),
                ShadowCardView(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: _buildCreators(),
                ),
                teamInfo?.creator == API.userInfo.id
                    ? buildCommonButton(
                        S.of(context).dissolveOrg,
                        backgroundColor: red68Color,
                        margin: EdgeInsets.only(top: 20),
                        onPressed: () {
                          showSureModal(
                              context, S.of(context).dissolveOrg, _deleteTeam,
                              promptText:
                                  S.of(context).teamDissolveConfirmContent);
                        },
                      )
                    : buildCommonButton(
                        S.of(context).leaveTeam,
                        backgroundColor: red68Color,
                        margin: EdgeInsets.only(top: 20),
                        onPressed: () {
                          showSureModal(
                              context, S.of(context).leaveTeam, _leaveTeam,
                              promptText: S.of(context).leaveTeamHint);
                        },
                      ),
              ],
            ),
    );
  }
}
