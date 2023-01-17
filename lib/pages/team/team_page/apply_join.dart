import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/team_model/search_team_info.dart';
import 'package:cobiz_client/http/res/team_model/team_group.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/http/team.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;

class ApplyJoinTeamPage extends StatefulWidget {
  final int type; // 1.加入团队 2.普通成员发送邀请 3.管理员直接添加团队成员
  final int teamId;
  final int deptId;
  final SearchTeamInfo team;
  final TeamGroup group;
  final UserInfo userInfo;
  ApplyJoinTeamPage({
    Key key,
    this.type,
    this.team,
    this.group,
    this.userInfo,
    this.teamId,
    this.deptId,
  })  : assert(type != null),
        super(key: key);

  @override
  _ApplyJoinTeamPageState createState() => _ApplyJoinTeamPageState();
}

class _ApplyJoinTeamPageState extends State<ApplyJoinTeamPage> {
  SearchTeamInfo _teamInfo;

  TextEditingController _validController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  bool _isShowNameClear = false;
  bool _isShowValidClear = false;
  bool _isInputFinish = false;

  @override
  void initState() {
    super.initState();
    _validController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowValidClear = (_validController.text.length > 0);
        });
      }
    });
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = (_nameController.text.length > 0);
          _isInputFinish = _isShowNameClear;
        });
      }
    });

    if (widget.type == 3 || widget.type == 2) {
      _isInputFinish = true;
    }
    if (widget.type == 1) {
      _initTeamInfo();
    }
  }

  void _initTeamInfo() async {
    if (widget.team != null) {
      if (mounted) {
        setState(() {
          _teamInfo = widget.team;
        });
      }
    }
  }

  void _unfocusField() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  List<Widget> _buildColumn() {
    String icon = '';
    String name = '';
    if (widget.type == 1) {
      name = _teamInfo?.name ?? '';
      icon = logoImageG;
      if (strNoEmpty(_teamInfo?.icon ?? '')) {
        icon = _teamInfo.icon;
      }
    } else if (widget.type == 3 || widget.type == 2) {
      name = widget.userInfo.nickname;
      icon = widget.userInfo.avatar;
    }
    return <Widget>[
      buildFilletImage(icon, imgSize: 45.0, radius: 22.5, needLoad: true),
      SizedBox(height: 5.0),
      Text(
        name,
        style: TextStyles.textF16Bold,
      ),
      SizedBox(height: 10.0),
      widget.type == 3 || widget.type == 2
          ? Container()
          : buildTextTitle(S.of(context).teamApplyLabel1),
      widget.type == 3 || widget.type == 2
          ? Container()
          : EditLineView(
              maxLen: 30,
              minHeight: 40.0,
              hintText: S.of(context).teamApplyHintText1,
              top: 5.0,
              textAlign: TextAlign.left,
              textController: _nameController,
              isShowClear: _isShowNameClear,
            ),
      widget.type == 3 || widget.type == 2
          ? Container()
          : buildTextTitle(S.of(context).teamApplyLabel2),
      widget.type == 3 || widget.type == 2
          ? Container()
          : EditLineView(
              maxLen: 50,
              minHeight: 40.0,
              hintText: S.of(context).teamApplyHintText2,
              top: 5.0,
              textAlign: TextAlign.left,
              textController: _validController,
              isShowClear: _isShowValidClear,
            ),
      buildCommonButton(
        widget.type == 3
            ? S.of(context).sureAdd
            : (widget.type == 2 ? S.of(context).teamJoinTypeInvite : S.of(context).submit),
        backgroundColor: _isInputFinish ? AppColors.mainColor : greyECColor,
        margin: EdgeInsets.only(top: 20),
        onPressed: _dealSubmit,
      )
    ];
  }

  Future _dealSubmit() async {
    if (!_isInputFinish) {
      return;
    } else if (mounted) {
      if (widget.type == 1) {
        if (_teamInfo?.joined == true) {
          return showToast(context, S.of(context).uAreTeamMember);
        }
        Loading.before(context: context);
        bool res = await applyJoinTeam(
          teamId: _teamInfo.id,
          deptId: widget.deptId,
          name: _nameController.text,
          msg: _validController.text,
        );
        Loading.complete();
        if (res) {
          // Navigator.pop(context);
          // Navigator.pop(context, true);
          showToast(context, S.of(context).sendSuccess);
        } else {
          showToast(context, S.of(context).tryAgainLater);
        }
      } else if (widget.type == 3) {
        Loading.before(context: context);
        var res = await addTeamMembers(
            teamId: widget.teamId,
            deptId: widget.deptId,
            memberIds: [widget.userInfo.id]);
        Loading.complete();

        if (res == 0) {
          showToast(context, S.of(context).addOk);
          Navigator.pop(context, true);
        } else if (res == 3) {
          showToast(context, S.of(context).memberIsMax);
        } else if (res == 2) {
          showToast(context, S.of(context).noPermisson);
        } else {
          showToast(context, S.of(context).tryAgainLater);
        }
      } else if (widget.type == 2) {
        Loading.before(context: context);
        var tInfo = await getSomeoneTeam(teamId: widget.teamId);
        var msg = {
          'tId': tInfo.id,
          'tName': tInfo.name,
          'tAvatar': tInfo.icon,
          'teamCode': tInfo.code,
          'deptId': widget.deptId
        };
        ChatStore store = ChatStore(getOnlyId(), 1, API.userInfo.id,
            widget.userInfo.id, 108, jsonEncode(msg),
            state: 1,
            time: DateTime.now().millisecondsSinceEpoch,
            burn: 0,
            name: API.userInfo.nickname);
        Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
        if (res != null) {
          ChannelManager.getInstance().addSingleChat(widget.userInfo.id,
              widget.userInfo.nickname, widget.userInfo.avatar, false, store);
          showToast(context, S.of(context).teamInviteSuccess);
        } else {
          showToast(context, S.of(context).teamInviteFail);
        }
        Loading.complete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: widget.type == 3
              ? S.of(context).teamAddMember
              : S.of(context).teamApplyTitle,
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            children: <Widget>[
              GestureDetector(
                child: ShadowCardView(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildColumn(),
                  ),
                ),
                onTap: () => _unfocusField(),
              )
            ],
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    _validController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
