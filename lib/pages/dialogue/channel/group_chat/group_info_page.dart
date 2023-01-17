import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/pages/dialogue/channel/group_chat/channel_member_ber.dart';
import 'package:cobiz_client/pages/dialogue/channel/complaint/complaints_type.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/modify_group_name.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/modify_group_notice.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/group.dart' as groupApi;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;

class GroupInfoPage extends StatefulWidget {
  final int groupId;
  GroupInfoPage(this.groupId);

  @override
  _GroupInfoPageState createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  int _groupType = 0; //  0.普通 1.团队 2.小组 3.部门

  bool isTop = false;
  bool _isDoNotDisturb = true;
  bool _isClearChat = false;
  bool _isLoading = true;

  TextEditingController _nameController = TextEditingController();
  FocusNode _nameFocus = FocusNode();
  bool _isShowNameClear = false;

  GroupInfo _groupInfo;
  List<GroupMember> _members = List();
  bool _isSave = false; //群聊是否保存
  List _burnSettings = List();
  int _burnSettingId;
  String _burnSettingStr;

  var backData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    _loadLocalData(await localStorage.getLocalGroupInfo(widget.groupId));
    _getGroupData();
  }

  _loadLocalData(GroupInfo groupInfo) async {
    if (groupInfo != null) {
      _groupInfo = groupInfo;
      for (var item in _burnSettings) {
        if (item['value'] == groupInfo.burn) {
          _burnSettingId = groupInfo.burn;
          _burnSettingStr = item['text'];
          break;
        }
      }
      if (mounted) {
        setState(() {
          _groupType = _groupInfo.type;
          _isSave = _groupInfo.saved;
          _isDoNotDisturb = _groupInfo.dnd;
          _members = _groupInfo.members;
          _nameController.text = _groupInfo.nickname;
          _isLoading = false;
        });
        _nameController.addListener(() {
          if (mounted) {
            setState(() {
              _isShowNameClear = _nameController.text.length > 0;
            });
          }
        });
      }
    }
  }

  void _getGroupData({bool updata = false}) async {
    var groupInfo = await groupApi.getGroup(widget.groupId);
    if (groupInfo == 4 || groupInfo == 5 || groupInfo == 6) {
      // onClearHistoryClick();
      showToast(context, S.of(context).currentNoExistent);
      Navigator.pop(context);
    } else if (groupInfo == 2 || groupInfo == 3) {
      // onClearHistoryClick();
      showToast(context, S.of(context).noGroupMembers);
      Navigator.pop(context);
    } else if (groupInfo is GroupInfo) {
      _isLoading = true;
      localStorage.savaLocalGroupInfo(groupInfo);
      _loadLocalData(groupInfo);
      if (updata) {
        ChannelStore groupStore =
            await localStorage.getLocalChannel(2, widget.groupId);
        if (groupStore != null) {
          groupStore.num = _members.length;
          localStorage.updateLocalChannel(groupStore);
        }
      }
    } else {
      showToast(context, S.of(context).tryAgainLater);
      Navigator.pop(context);
    }
  }

  //修改群名称 普通群聊和小组
  void onChannelDisplayNameClick() async {
    if (!_isAdmin()) return;
    String name = await routeMaterialPush(
        ModifyGroupName(groupId: widget.groupId, groupName: _groupInfo.name));
    if (name != null && mounted) {
      setState(() {
        _groupInfo.name = name;
      });
    }
  }

  //修改群公告
  void onChannelAnnouncementClick() async {
    if (_isAdmin() || (_groupInfo?.role ?? 0) > 0) {
      String notice = await routeMaterialPush(ModifyGroupNotice(
          groupId: widget.groupId, groupNotice: _groupInfo.notice));
      if (notice != null && mounted) {
        setState(() {
          _groupInfo.notice = notice;
        });
      }
    }
  }

  //清空聊天记录
  void onClearHistoryClick() async {
    await localStorage.deleteLocalChannel(2, widget.groupId);
    if (mounted) {
      setState(() {
        _isClearChat = true;
      });
    }
    ChannelManager.getInstance().refresh();
  }

  //退出群聊
  void onLeaveChannelClick() {
    showSureModal(context, S.of(context).areYouSureExitThisChannel, () async {
      Loading.before(context: context);
      bool state = await groupApi.leave(widget.groupId);
      Loading.complete();
      if (state == true) {
        await localStorage.deleteLocalChannel(2, widget.groupId);
        ChannelManager.getInstance().refresh();
        Navigator.pop(context);
        Navigator.pop(context, true);
        Future.delayed(Duration(seconds: 1), () {
          eventBus.emit(EVENT_UPDATE_TEAM_GROUP, 'cancel_save');
        });
      } else {
        showToast(context, S.of(context).tryAgainLater);
      }
    }, promptText: S.of(context).deleteAndExitHint);
  }

  //解散小组
  void disbandTeamGroup() {
    showSureModal(context, S.of(context).disbandTheGroup, () async {
      Loading.before(context: context);
      bool state =
          await teamApi.deleteTeamGroup(_groupInfo.teamId, _groupInfo.thirdId);
      Loading.complete();
      if (state == true) {
        eventBus.emit(EVENT_UPDATE_TEAM_GROUP, true);
        Navigator.pop(context);
      } else {
        showToast(context, S.of(context).tryAgainLater);
      }
    }, promptText: S.of(context).disbandTheGroupTip);
  }

  // 阅后即焚
  void _selectBurnSetting() {
    showDataPicker(
        context,
        DataPicker(
          jsonData: _burnSettings,
          isArray: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selecteds) {
            if (mounted) {
              setState(() {
                _burnSettingId = values[0].value;
                _burnSettingStr = values[0].text;
              });
            }
          },
        ));
  }

  Widget buildExtendItem(String title, String icon, VoidCallback callback) {
    return Column(children: [
      Container(
          width: 60,
          height: 60,
          margin: EdgeInsets.only(bottom: 5),
          child: FlatButton(
            padding: EdgeInsets.all(0),
            color: Colors.grey[200],
            highlightColor: Colors.grey[300],
            colorBrightness: Brightness.dark,
            child: ImageView(img: icon, width: 40, height: 40),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            onPressed: callback,
          )),
      Text(title),
    ]);
  }

  Widget buildExtend() {
    return Container(
      color: Colors.white,
      width: winWidth(context),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      // margin: EdgeInsets.only(bottom: 10),
      child: new Wrap(
        spacing: (winWidth(context) - 315) / 5,
        runSpacing: 10.0,
        children: [
          buildExtendItem(S.of(context).folder,
              "assets/images/chat/extend/folder.png", () => {}
              // () => routePush(ChannelFilesPage(widget.channel))
              ),
          buildExtendItem(S.of(context).approve,
              "assets/images/chat/extend/approve.png", () => null),
        ],
      ),
    );
  }

  bool _isAdmin() {
    if (_groupType == 0) {
      return _groupInfo?.creator == API.userInfo.id;
    } else if (_groupType == 2) {
      if (_groupInfo.role == 1 || _groupInfo.role == 2) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  List<Widget> body() {
    List<Widget> _list = [
      ChannelMemberBer(
        model: _members,
        isAdmin: _isAdmin(),
        groupId: widget.groupId,
        groupType: _groupType,
        groupInfo: _groupInfo,
        addCallback: (v) async {
          if (_groupType == 0) {
            bool state = await groupApi.inviteToGroup(widget.groupId, v);
            if (mounted && state == true) {
              _getGroupData(updata: true);
            }
          } else if (_groupType == 2) {
            if (mounted && v == true) {
              _getGroupData(updata: true);
            } else {
              showToast(context, S.of(context).tryAgainLater);
            }
          }
        },
        removeCallback: (v) {
          if (mounted && v != null) {
            _getGroupData(updata: true);
          }
        },
      ),

      /// 群名称 修改  小组和普通群聊
      buildDivider(height: 8.0, color: greyEAColor),
      OperateLineView(
        isArrow: _isAdmin() && (_groupType == 0 || _groupType == 2),
        title: S.of(context).groupChatName,
        rightWidget: Container(
          alignment: Alignment.centerRight,
          constraints: BoxConstraints(maxWidth: winWidth(context) - 180),
          child: Text(
            _groupInfo?.name ?? '',
            style: TextStyles.textF16,
          ),
        ),
        onPressed: _groupType == 0 || _groupType == 2
            ? onChannelDisplayNameClick
            : null,
      )
    ];

    /// 普通群聊 我的群昵称
    if (_groupType == 0) {
      _list.add(EditLineView(
        title: S.of(context).myGroupNickname,
        hintText: S.of(context).enterNickname,
        textController: _nameController,
        focusNode: _nameFocus,
        isShowClear: _isShowNameClear,
        maxLen: 30,
      ));
    }

    /// 群公告 都有
    _list.add(InkWell(
      child: Column(
        children: <Widget>[
          ListItemView(
              title: S.of(context).groupAnnouncement,
              haveBorder: false,
              widgetRt1: Container(
                child: Icon(Icons.arrow_forward_ios,
                    size: 12.0,
                    color: (_isAdmin() || (_groupInfo?.role ?? 0) > 0)
                        ? null
                        : Colors.white),
                margin: EdgeInsets.only(
                  right: 5.0,
                ),
              )),
          (_groupInfo?.notice != null && _groupInfo?.notice != '')
              ? Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(_groupInfo?.notice ?? ''),
                      )
                    ],
                  ),
                )
              : Container(),
        ],
      ),
      onTap: onChannelAnnouncementClick,
    ));

    /// 保存群聊
    _list.add(buildDivider(height: 8.0, color: greyEAColor));

    /// 阅后即焚
    _list.add(EditLineView(
      title: S.of(context).burnAfterReading,
      text: _burnSettingStr ?? S.of(context).close,
      haveArrow:
          (_groupInfo.creator == API.userInfo.id || (_groupInfo?.role ?? 0) > 0)
              ? true
              : false,
      onPressed:
          (_groupInfo.creator == API.userInfo.id || (_groupInfo?.role ?? 0) > 0)
              ? _selectBurnSetting
              : null,
    ));
    _list.add(buildSwitch(S.of(context).saveGroupChat, _isSave, (v) {
      if (mounted) {
        setState(() {
          _isSave = v;
        });
      }
    }));

    /// 免打扰 清空聊天记录 投诉 都有
    _list.addAll([
      buildSwitch(S.of(context).disableNotification, _isDoNotDisturb, (v) {
        if (mounted) {
          setState(() {
            _isDoNotDisturb = v;
          });
        }
      }),
      OperateLineView(
        title: S.of(context).clearHistory,
        haveBorder: false,
        onPressed: () {
          showSureModal(
              context, S.of(context).clearHistory, onClearHistoryClick);
        },
      ),
      buildDivider(height: 8.0, color: greyEAColor),
      OperateLineView(
        title: S.of(context).complaints,
        haveBorder: false,
        onPressed: () {
          routeMaterialPush(ComplaintsTypePage(
            from: 2,
            targetId: widget.groupId,
          ));
        },
      ),
      buildDivider(height: 8.0, color: greyEAColor)
    ]);

    /// 普通群聊 删除并退出按钮
    if (_groupType == 0) {
      _list.add(buildCommonButton(
        S.of(context).deleteAndExit,
        onPressed: onLeaveChannelClick,
        backgroundColor: red68Color,
        margin: EdgeInsets.fromLTRB(20, 20, 20, 40),
      ));
    }

    /// 小组 解散小组
    if (_groupType == 2 && _groupInfo?.creator == API.userInfo.id) {
      _list.add(buildCommonButton(
        S.of(context).disbandTheTeam,
        onPressed: disbandTeamGroup,
        backgroundColor: red68Color,
        margin: EdgeInsets.fromLTRB(20, 20, 20, 40),
      ));
    }
    return _list;
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(context, {
        "name": _groupInfo?.name,
        "num": _members.length,
        "isClearChat": _isClearChat,
        "burn": _burnSettingId,
      });
    }
    _dealUpdate();
    return Future.value(false);
  }

  void _dealUpdate() async {
    if (_groupInfo?.saved != _isSave ||
        _groupInfo?.dnd != _isDoNotDisturb ||
        _nameController.text != _groupInfo?.nickname ||
        (_burnSettingId ?? 0) != _groupInfo.burn) {
      Future.delayed(Duration(seconds: 1), () {
        eventBus.emit(EVENT_UPDATE_TEAM_GROUP, 'cancel_save');
      });
      await groupApi.modifySettings(widget.groupId, _nameController.text,
          _isSave, _isDoNotDisturb, _burnSettingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    _burnSettings.clear();
    _burnSettings.addAll(burnSettingList(context));
    final model = Provider.of<GlobalModel>(context);
    final theme = model.currentTheme;

    return WillPopScope(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _nameFocus.unfocus();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: new ComMomBar(
              title: S.of(context).groupDetail,
              mainColor: theme.textColorDark,
              backgroundColor: theme.primaryTheme.backgroundColor,
              backData: {
                "name": _groupInfo?.name,
                "num": _members.length,
                "isClearChat": _isClearChat,
                "burn": _burnSettingId,
              },
              backCall: _dealUpdate,
            ),
            body: new SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: _isLoading
                  ? Center(
                      child: buildProgressIndicator(),
                    )
                  : Column(children: body()),
            ),
          ),
        ),
        onWillPop: _onWillPop);
  }

  @override
  void dispose() {
    _nameFocus?.dispose();
    _nameController?.dispose();
    super.dispose();
  }
}
