import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/member_detail_info.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat_page.dart';
import 'package:cobiz_client/pages/team/friend/friend_verify_msg.dart';
import 'package:cobiz_client/pages/team/team_page/edit_member.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/http/user.dart' as userApi;

//团队成员 主页信息
enum TeamMemberInfoItem { phone, team, dept, attendance }

class TeamMemberInfo extends StatefulWidget {
  final int teamId;
  final int userId;
  final bool isCanEdit;
  final int fromWhere; //2：群聊聊天界面点击头像进入 1：增加2之前不动  3:团队成员进入 4: 群聊信息界面点击头像进入
  TeamMemberInfo(
      {Key key,
      @required this.teamId,
      @required this.userId,
      @required this.fromWhere,
      this.isCanEdit = false})
      : super(key: key);

  @override
  _TeamMemberInfoState createState() => _TeamMemberInfoState();
}

class _TeamMemberInfoState extends State<TeamMemberInfo> {
  MemberDetailInfo _memberDetailInfo;
  bool _isLoadingOk = false;
  bool _isBackRefresh = false;
  TeamInfo teamInfo;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    _memberDetailInfo = await teamApi.querySomebodyInfo(
        teamId: widget.teamId, userId: widget.userId);
    teamInfo = await teamApi.getSomeoneTeam(teamId: widget.teamId);
    if (mounted && _memberDetailInfo != null && teamInfo != null) {
      setState(() {
        _isLoadingOk = true;
      });
    }
  }

  void _editMember(int userId, String userName) async {
    if (userId == null) return;

    final result = await routePush(EditMemberPage(
      teamId: widget.teamId,
      teamName: teamInfo.name,
      userId: userId,
      userName: userName,
      creatorId: teamInfo.creator,
      manIds: teamInfo.managers,
      isFromTeamMember: true,
    ));
    if (result != null) {
      _isBackRefresh = true;
      if (result == true) {
        _getData();
      }
      if (result == 'deleteMember') {
        Navigator.pop(context, true);
      }
    }
  }

  _editBtn() {
    if (widget.isCanEdit && _memberDetailInfo != null) {
      return IconButton(
          icon: ImageIcon(AssetImage('assets/images/ic_edit.png'),
              color: Colors.white),
          onPressed: () {
            if (widget.fromWhere == 3) {
              _editMember(_memberDetailInfo.id, _memberDetailInfo.name);
            } else {
              Navigator.pop(context, true);
            }
          });
    } else {
      return Container();
    }
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15))),
      padding: EdgeInsets.only(bottom: 10.0),
      child: ListRowView(
        color: AppColors.mainColor,
        haveBorder: false,
        paddingRight: 15.0,
        paddingLeft: 15.0,
        // paddingBottom: 10,
        iconRt: 15.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        iconWidget: InkWell(
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.circular(40.0),
                side: BorderSide(color: Colors.grey, width: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: ImageView(
                img: cuttingAvatar(_memberDetailInfo.avatar),
                needLoad: true,
                width: 65,
                height: 65,
              ),
            ),
          ),
          // onTap: () => onProfileImageClick(model),
        ),
        titleWidget: Text(
          _memberDetailInfo.name,
          style: TextStyles.myStyle,
        ),
        labelWidget: Container(
          padding: EdgeInsets.only(
            top: 5.0,
          ),
          child: Text(
            _memberDetailInfo.entry,
            style: TextStyles.textF14T2,
          ),
        ),
        onPressed: () async {},
      ),
    );
  }

  Widget _body(BuildContext context) {
    List<Widget> data = [
      OperateLineView(
        title: S.of(context).phone,
        isArrow: false,
        onPressed: () {
          if (_memberDetailInfo.phone != null &&
              _memberDetailInfo.phone != '') {
            showSureModal(context,
                S.of(context).confirmCallPhone(_memberDetailInfo.phone),
                () async {
              String url = "tel:${_memberDetailInfo.phone}";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            });
          }
        },
        rightWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 160,
              alignment: Alignment.centerRight,
              child: Text(_memberDetailInfo.phone),
            ),
            ImageView(
              width: IconTheme.of(context).size,
              height: IconTheme.of(context).size,
              img: 'assets/images/work/ic_call.png',
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
      OperateLineView(
          title: S.of(context).position,
          isArrow: false,
          rightWidget: Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              _memberDetailInfo.position,
              textAlign: TextAlign.right,
              style: TextStyles.textF16,
            ),
          ))),
      OperateLineView(
          title: S.of(context).dateOfEntry,
          isArrow: false,
          rightWidget: Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              _memberDetailInfo.entry,
              textAlign: TextAlign.right,
              style: TextStyles.textF16,
            ),
          ))),
      OperateLineView(
          title: S.of(context).jobNumber,
          isArrow: false,
          rightWidget: Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              _memberDetailInfo.workNo,
              textAlign: TextAlign.right,
              style: TextStyles.textF16,
            ),
          ))),
      OperateLineView(
          title: S.of(context).remark,
          isArrow: false,
          rightWidget: Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              _memberDetailInfo.remark,
              textAlign: TextAlign.right,
              style: TextStyles.textF16,
            ),
          ))),
    ];

    if (_memberDetailInfo.deptIds.isNotEmpty &&
        _memberDetailInfo.deptNames.isNotEmpty) {
      _memberDetailInfo.deptNames.forEach((element) {
        data.add(OperateLineView(
            title: S.of(context).department,
            isArrow: false,
            rightWidget: Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                '$element',
                textAlign: TextAlign.right,
                style: TextStyles.textF16,
              ),
            ))));
      });
    }
    return Expanded(
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(), child: Column(children: data)));
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(context, _isBackRefresh);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          appBar: ComMomBar(
            mainColor: AppColors.white,
            backgroundColor: AppColors.mainColor,
            rightDMActions: [_editBtn()],
            backData: _isBackRefresh,
          ),
          bottomSheet: (_isLoadingOk && widget.userId != API.userInfo.id)
              ? Container(
                  constraints: BoxConstraints(maxHeight: 90),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildCommonButton(
                          S.of(context).chat,
                          margin: EdgeInsets.symmetric(vertical: 20),
                          paddingV: 8,
                          backgroundColor: themeColor,
                          sizeColor: Colors.white,
                          onPressed: () {
                            if (widget.fromWhere == 2) {
                              Navigator.pop(context);
                              routePushReplace(SingleChatPage(
                                userId: _memberDetailInfo.id,
                                name: _memberDetailInfo.name ?? '',
                                avatar: _memberDetailInfo.avatar,
                                whereToChat: 1,
                              ));
                            } else if (widget.fromWhere == 4) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              routePushReplace(SingleChatPage(
                                userId: _memberDetailInfo.id,
                                name: _memberDetailInfo.name ?? '',
                                avatar: _memberDetailInfo.avatar,
                                whereToChat: 1,
                              ));
                            } else {
                              routePush(SingleChatPage(
                                userId: _memberDetailInfo.id,
                                name: _memberDetailInfo.name ?? '',
                                avatar: _memberDetailInfo.avatar,
                                whereToChat: 1,
                              ));
                            }
                          },
                        ),
                      ),
                      _memberDetailInfo?.friend == false
                          ? SizedBox(width: 15)
                          : Container(),
                      _memberDetailInfo?.friend == false
                          ? Expanded(
                              child: buildCommonButton(
                                S.of(context).addFriends,
                                margin: EdgeInsets.symmetric(vertical: 20),
                                paddingV: 8,
                                backgroundColor: greyE5Color,
                                sizeColor: Colors.black,
                                onPressed: () async {
                                  UserInfo _user = await userApi.getUserInfo(
                                      userId: widget.userId);
                                  if (_user != null) {
                                    if (_user.friend == true) {
                                      _getData();
                                    } else {
                                      routePush(
                                          FriendVerifyMsg(userInfo: _user));
                                    }
                                  } else {
                                    showToast(
                                        context, S.of(context).tryAgainLater);
                                  }
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                )
              : null,
          body: _isLoadingOk
              ? Column(
                  children: [
                    _header(context),
                    _body(context),
                    SizedBox(
                      height: 100,
                    )
                  ],
                )
              : buildProgressIndicator(),
        ),
        onWillPop: _onWillPop);
  }
}
