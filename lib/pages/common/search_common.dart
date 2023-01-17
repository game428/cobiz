import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/http/res/team_model/team_group.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/http/user.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_info_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/work_notice_msg.dart';
import 'package:cobiz_client/pages/team/member/team_member_info.dart';
import 'package:cobiz_client/pages/team/team_page/apply_join.dart';
import 'package:cobiz_client/pages/team/team_page/switch_team.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:cobiz_client/ui/view/search_navbar_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:cobiz_client/http/user.dart' as userApi;

class SearchCommonPage extends StatefulWidget {
  final int pageType;
  final dynamic data;
  final int teamId;
  final int deptId;
  final bool isAdmin;
  SearchCommonPage(
      {Key key,
      @required this.pageType,
      this.data,
      this.teamId,
      this.deptId,
      this.isAdmin = false})
      : super(key: key);

  @override
  _SearchCommonPageState createState() => _SearchCommonPageState();
}

class _SearchCommonPageState extends State<SearchCommonPage> {
  String _hintText;
  TextInputType _textInputType;
  ValueChanged _onSubmitted;
  ValueChanged _onChanged;
  List<Widget> _body = [];
  bool _isSub = false;
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _filterType();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  _filterType() async {
    switch (widget.pageType) {
      case 1:
        _searchByPhone(); // 手机号添加好友
        break;
      case 2:
        _searchContact(); // 发起群聊搜索联系人
        break;
      case 3:
        _searchChatChannel(); // 消息列表搜索聊天
        break;
      case 4:
        _searchContact(); // 在我的好友里面搜索
        break;
      case 5:
        _searchChatChannel(); // 转发->搜索最近聊天
        break;
      case 6:
        _searchChatChannel(); // 删除成员
        break;
      case 7:
        // 搜索区号国家
        _searchTelNumber();
        break;
      case 8:
        // 添加团队成员 搜索手机号
        _searchByPhone();
        break;
      case 9:
        // 在团队成员里面搜索
        _searchTeamnumber();
        break;
      case 10:
        // 在我的团队里面搜索
        _searchTeam();
        break;
      case 11:
        // 在我的小组里面搜索
        _searchGroup();
        break;
      case 12:
        break;
      case 13:
        // 选择管理员
        _searchManager();
        break;
      case 14:
        // 在我的组织里面搜索
        _searchOrganization();
        break;
      case 15:
        // 转发 -> 选择联系人 -> 搜索
        _searchContact();
        break;
      case 16:
        // 添加小组成员
        _searchGroupMember();
        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  ///什么也没找到
  Widget _nothingToFind(String notice) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 50, left: 50, right: 50),
      child: Text(
        notice,
        textAlign: TextAlign.center,
      ),
    );
  }

  // 汉字或字母搜索
  bool _lowerCaseSearch(List<String> listString, v) {
    bool isC = false;
    for (var i = 0; i < listString.length; i++) {
      if (listString[i].toLowerCase().contains(v.toString().toLowerCase())) {
        isC = true;
        break;
      }
    }
    return isC;
  }

  ///搜索聊天
  _searchChatChannel() {
    _hintText = S.of(context).searchChat;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          widget.data is List<ChannelStore>) {
        List<ChannelStore> _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          if (_lowerCaseSearch([
            _list[i].name,
            _list[i].label,
            PinyinHelper.getPinyinE(_list[i].name ?? ''),
            PinyinHelper.getPinyinE(_list[i].label ?? '')
          ], v)) {
            _body.add(ListItemView(
              iconWidget: ChatMsgShow.channelAvatar(_list[i]),
              title: _list[i].type == 3
                  ? '${S.of(context).workNotice}:' + _list[i].name
                  : _list[i].name,
              titleWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      child: Text(
                    (_list[i].type == 3
                            ? '${S.of(context).workNotice}:' + _list[i].name
                            : _list[i].name) ??
                        '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  )),
                  ChatMsgShow.groupWidget(_list[i])
                ],
              ),
              labelWidget: ChatMsgShow.labelWidget(context, _list[i]),
              onPressed: () {
                switch (widget.pageType) {
                  case 3:
                    switch (_list[i].type) {
                      case 1: //私聊
                        routePushReplace(SingleChatPage(
                            userId: _list[i].id,
                            name: _list[i].name ?? '',
                            avatar: _list[i].avatar ?? '',
                            whereToChat: 1));
                        break;
                      case 2: //群聊
                        routePushReplace(GroupChatPage(
                          groupId: _list[i].id,
                          groupName: _list[i].name ?? '',
                          groupAvatar: jsonDecode(_list[i].avatar),
                          groupNum: _list[i].num ?? 0,
                          gType: _list[i].gType ?? 0,
                          teamId: _list[i].teamId ?? 0,
                        ));
                        break;
                      case 3: //工作通知
                        routePushReplace(WorkNoticeMsgPage(
                            _list[i].id, _list[i].name ?? ''));
                        break;
                      default:
                    }
                    break;
                  case 5:
                    Navigator.pop(context, _list[i]);
                    break;
                }
              },
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///搜索联系人
  _searchContact() {
    _hintText = S.of(context).searchContact;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data is List<ContactExtendIsSelected> ||
              widget.data is List<ContactExtend>)) {
        var _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          _list[i].namePinyin = _list[i].namePinyin.replaceAll(' ', '');
          if (_lowerCaseSearch([_list[i].name, _list[i].namePinyin], v)) {
            _body.add(widget.pageType == 2
                ? RadioLineView(
                    paddingLeft: 20,
                    color: _list[i].isCanChange == true
                        ? Colors.white
                        : greyEAColor.withOpacity(0.3),
                    radioIsCanChange: _list[i].isCanChange,
                    checkCallback: () {
                      switch (widget.pageType) {
                        case 2:
                          Navigator.pop(context, i);
                          break;
                        default:
                      }
                    },
                    checked: _list[i].isSelected,
                    iconRt: 0,
                    content: IgnorePointer(
                        child: ListItemView(
                            color: _list[i].isCanChange == true
                                ? Colors.white
                                : greyEAColor.withOpacity(0.3),
                            paddingLeft: 0,
                            title: _list[i].name,
                            iconWidget: ImageView(
                              img: cuttingAvatar(_list[i].avatarUrl),
                              width: 42.0,
                              height: 42.0,
                              needLoad: true,
                              isRadius: 21.0,
                              fit: BoxFit.cover,
                            ))))
                : ListItemView(
                    onPressed: () {
                      switch (widget.pageType) {
                        case 4:
                          routePushReplace(SingleInfoPage(
                            userId: _list[i].userId,
                            whereToInfo: 2,
                          ));
                          break;
                        case 15:
                          Navigator.pop(context, _list[i]);
                          break;
                        default:
                      }
                    },
                    color: Colors.white,
                    paddingLeft: 20,
                    title: _list[i].name,
                    iconWidget: ImageView(
                      img: cuttingAvatar(_list[i].avatarUrl),
                      width: 42.0,
                      height: 42.0,
                      needLoad: true,
                      isRadius: 21.0,
                      fit: BoxFit.cover,
                    )));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///手机号搜索提交
  _onSub(v) async {
    if (_isSub) {
      return;
    } else {
      _isSub = true;
    }
    if (v.length == 0) {
      showToast(context, S.of(context).plzEnterRight);
      _isSub = false;
      return;
    }

    var res;

    if (widget.pageType == 1 || widget.pageType == 8) {
      res = await getUserByPhone(v);
    }

    if (res == null) {
      if (mounted) {
        setState(() {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        });
      }
      _isSub = false;
      return;
    }
    if (res == API.userInfo.id) {
      showToast(context, S.of(context).cantAddMine);
      _isSub = false;
      return;
    }
    if (widget.pageType == 1) {
      routePush(SingleInfoPage(
        userId: res,
        whereToInfo: 2,
      ));
      _isSub = false;
    } else if (widget.pageType == 8) {
      Loading.before(context: context);
      UserInfo _user = await userApi.getUserInfo(userId: res);
      Loading.complete();
      var r = await routePush(ApplyJoinTeamPage(
        type: widget.isAdmin ? 3 : 2,
        userInfo: _user,
        teamId: widget.teamId,
        deptId: widget.deptId,
      ));
      if (widget.isAdmin && r == true) {
        Navigator.pop(context, true);
      }
      _isSub = false;
    }
  }

  ///手机号添加好友
  _searchByPhone() {
    _hintText = S.of(context).searchPhone;
    _textInputType = TextInputType.phone;
    _onSubmitted = _onSub;
    _onChanged = (v) {
      if (v.length > 0) {
        _body = [
          ListItemView(
            onPressed: () {
              _onSub(v);
            },
            titleWidget: Row(
              children: <Widget>[
                Text('${S.of(context).search}：',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    )),
                Expanded(
                    child: Text('$v',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        )))
              ],
            ),
            iconWidget: ClipOval(
              child: ImageView(
                img: searchImage,
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
            ),
          )
        ];
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///在团队成员里面搜索
  _searchTeamnumber() {
    _hintText = S.of(context).searchTeamMember;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data is List<TeamMemberExtend>)) {
        List<TeamMemberExtend> _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          TeamMemberExtend teamMemberExtend = _list[i];
          teamMemberExtend.namePinyin =
              teamMemberExtend.namePinyin.replaceAll(' ', '');
          if (_lowerCaseSearch([
            teamMemberExtend.member.name,
            teamMemberExtend.namePinyin,
          ], v)) {
            _body.add(ListItemView(
              title: '${teamMemberExtend.member.name}',
              iconWidget: ImageView(
                img: cuttingAvatar(teamMemberExtend.member.avatar),
                width: 42.0,
                height: 42.0,
                needLoad: true,
                isRadius: 21.0,
                fit: BoxFit.cover,
              ),
              labelWidget: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: identity(context, teamMemberExtend.member.manager,
                        teamMemberExtend.member.leader),
                  )),
              onPressed: () {
                routePush(TeamMemberInfo(
                        teamId: teamMemberExtend.teamId,
                        userId: teamMemberExtend.member.userId,
                        fromWhere: 3,
                        isCanEdit: widget.isAdmin))
                    .then((value) {
                  if (value == true) {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context);
                  }
                });
              },
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///在我的团队里面搜索
  _searchTeam() {
    _hintText = S.of(context).teamSearch;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data is List<TeamStore>)) {
        List<TeamStore> _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          if (_lowerCaseSearch(
              [_list[i].name, PinyinHelper.getPinyinE(_list[i].name ?? '')],
              v)) {
            _body.add(InkWell(
              onTap: () {
                Navigator.pop(context, _list[i]);
              },
              child: IgnorePointer(
                child: buildChangeTeamItem(
                    context, _list[i].name, _list[i].manager,
                    isSel: _list[i].id == widget.teamId),
              ),
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///添加小组成员
  _searchGroupMember() {
    _hintText = S.of(context).searchTeamMember;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data is List<TeamMemberSelected>)) {
        var _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          _list[i].namePinyin = _list[i].namePinyin.replaceAll(' ', '');
          if (_lowerCaseSearch([_list[i].name, _list[i].namePinyin], v)) {
            _body.add(
              RadioLineView(
                paddingLeft: 20,
                color: _list[i].isCanChange == true
                    ? Colors.white
                    : greyEAColor.withOpacity(0.3),
                radioIsCanChange: _list[i].isCanChange,
                checkCallback: () {
                  Navigator.pop(context, i);
                },
                checked: _list[i].isSelected,
                iconRt: 0,
                content: IgnorePointer(
                  child: ListItemView(
                    color: _list[i].isCanChange == true
                        ? Colors.white
                        : greyEAColor.withOpacity(0.3),
                    paddingLeft: 0,
                    title: '${_list[i].name}',
                    iconWidget: ImageView(
                      img: cuttingAvatar(_list[i].avatarUrl),
                      width: 42.0,
                      height: 42.0,
                      needLoad: true,
                      isRadius: 21.0,
                      fit: BoxFit.cover,
                    ),
                    // labelWidget: Text(
                    //   memberlabel(_list[i].manager),
                    //   style: TextStyles.textF12C3,
                    // ),
                  ),
                ),
              ),
            );
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///选择管理员
  _searchManager() {
    _hintText = S.of(context).searchTeamMember;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data['members'] is List<Members>)) {
        List<Members> _list = widget.data['members'];
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          Members teamMemberExtend = _list[i];
          List<Widget> roleWidget = identity(
              context, teamMemberExtend.manager, teamMemberExtend.leader);
          if (_lowerCaseSearch([
            teamMemberExtend.name,
            PinyinHelper.getPinyinE(teamMemberExtend.name ?? '')
          ], v)) {
            _body.add(RadioLineView(
              checked: (teamMemberExtend.id == widget.data['seId']),
              iconRt: 0.0,
              paddingLeft: 20.0,
              checkCallback: () {
                Navigator.pop(context, {
                  'touchId': teamMemberExtend.id == widget.data['seId']
                      ? null
                      : teamMemberExtend.id,
                  'name': teamMemberExtend.id == widget.data['seId']
                      ? ''
                      : teamMemberExtend.name,
                  'avatarUrl': teamMemberExtend.id == widget.data['seId']
                      ? ''
                      : teamMemberExtend.avatar,
                });
              },
              content: IgnorePointer(
                child: ListItemView(
                  icon: teamMemberExtend.avatar,
                  title: teamMemberExtend.name,
                  labelWidget: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: roleWidget,
                    ),
                  ),
                ),
              ),
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///在我的组织里面搜索成员
  _searchOrganization() {
    _hintText = S.of(context).searchTeamMember;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data is List<Members>)) {
        List<Members> _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          Members teamMemberExtend = _list[i];
          List<Widget> roleWidget = identity(
              context, teamMemberExtend.manager, teamMemberExtend.leader);
          if (_lowerCaseSearch([
            teamMemberExtend.name,
            PinyinHelper.getPinyinE(teamMemberExtend.name ?? '')
          ], v)) {
            _body.add(ListItemView(
              iconWidget: ImageView(
                img: cuttingAvatar(teamMemberExtend.avatar),
                width: 42.0,
                height: 42.0,
                needLoad: true,
                isRadius: 21.0,
                fit: BoxFit.cover,
              ),
              title: teamMemberExtend.name,
              labelWidget: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Row(
                  children: roleWidget,
                ),
              ),
              paddingRight: 15.0,
              paddingLeft: 15.0,
              dense: true,
              haveBorder: true,
              onPressed: () {
                routePush(TeamMemberInfo(
                  teamId: teamMemberExtend.teamId,
                  userId: teamMemberExtend.id,
                  fromWhere: 1,
                  isCanEdit: widget.isAdmin,
                )).then((value) {
                  if (value == true) {
                    Navigator.pop(context, {
                      'isEdit': true,
                      'uid': teamMemberExtend.id,
                      'uName': teamMemberExtend.name
                    });
                  } else {
                    Navigator.pop(context, {
                      'isEdit': false,
                      'uid': teamMemberExtend.id,
                      'uName': teamMemberExtend.name
                    });
                  }
                });
              },
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///在我的小组里面搜索
  _searchGroup() {
    _hintText = S.of(context).searchGroup;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0 &&
          widget.data != null &&
          (widget.data is List<TeamGroup>)) {
        List<TeamGroup> _list = widget.data;
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          if (_lowerCaseSearch(
              [_list[i].name, PinyinHelper.getPinyinE(_list[i].name ?? '')],
              v)) {
            String hint = _list[i].manager == true
                ? S.of(context).myCreated
                : S.of(context).myJoined;
            _body.add(ShadowCardView(
              margin:
                  EdgeInsets.only(top: 13.0, left: 15, right: 15, bottom: 2),
              padding: EdgeInsets.all(0.0),
              radius: 8.0,
              blurRadius: 3.0,
              child: ListRowView(
                onPressed: () {
                  routePushReplace(GroupChatPage(
                    groupId: _list[i].chatId,
                    groupName: _list[i].name,
                    groupAvatar: [],
                    groupNum: _list[i].number,
                    gType: 2,
                    teamId: _list[i].teamId ?? 0,
                  ));
                },
                haveBorder: false,
                iconRt: 10.0,
                paddingTop: 12.0,
                paddingBottom: 12.0,
                paddingLeft: 10.0,
                paddingRight: 10.0,
                icon: 'assets/images/team/org.png',
                titleWidget: Row(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: winWidth(context) * 0.4,
                      ),
                      child: Text(
                        _list[i].name ?? "",
                        maxLines: 1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                      padding: EdgeInsets.only(right: 8.0),
                    ),
                    Expanded(
                      child: Text(
                        '${_list[i].number} ${S.of(context).personUnit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.textNum,
                      ),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 60.0,
                      ),
                      child: Text(
                        hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.textNum,
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.only(left: 8.0),
                    ),
                  ],
                ),
                // widgetRt1: ImageView(
                //   img: chatImage,
                // ),
              ),
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  ///搜索区号国家
  _searchTelNumber() {
    _hintText = S.of(context).searchCode;
    _textInputType = TextInputType.text;
    _onChanged = (v) {
      if (v.length > 0) {
        var _list = widget.data['codeList'];
        _body.clear();
        for (var i = 0; i < _list.length; i++) {
          _list[i]['namePinyin'] = _list[i]['namePinyin'].replaceAll(' ', '');
          if (_lowerCaseSearch(
              [_list[i]['tel'], _list[i]['name'], _list[i]['namePinyin']], v)) {
            _body.add(ListItemView(
              titleWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text('+${_list[i]['tel']}'),
                  ),
                  Flexible(child: Text('${_list[i]['name']}'))
                ],
              ),
              trailing: _list[i]['tel'] == widget.data['telCode']
                  ? Icon(
                      Icons.check,
                      color: AppColors.mainColor,
                      size: 18.0,
                    )
                  : null,
              onPressed: () {
                Navigator.pop(context, _list[i]['tel']);
              },
            ));
          }
        }
        if (_body.isEmpty) {
          _body = [_nothingToFind(S.of(context).searchNothing(v))];
        }
      } else {
        _body = [Container()];
      }
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: SearchNavbarView(
          onChanged: _onChanged,
          onSubmitted: _onSubmitted,
          textInputType: _textInputType,
          textInputAction: TextInputAction.search,
          hintText: _hintText,
          textController: _textController,
          autoFocus: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
            // WhitelistingTextInputFormatter(
            //     RegExp("[a-zA-Z]|[\u4e00-\u9fa5]|[0-9]"))
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: _body,
          ),
        ),
      ),
    );
  }
}
