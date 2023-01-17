import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/team_model/team_member.dart';
import 'package:cobiz_client/http/team.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:cobiz_client/ui/view/submit_btn_view.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/contact.dart' as contactApi;
import 'package:cobiz_client/http/chat.dart' as chatApi;

import 'selected_member_view.dart';

class SelectMembersPage extends StatefulWidget {
  /// 1.添加团队成员
  /// 2.添加小组成员
  final int type;
  final String groupId;
  final int teamId;
  final int deptId;
  final bool isAdmin;

  const SelectMembersPage({
    Key key,
    this.type = 0,
    this.groupId,
    this.teamId,
    this.deptId,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  _SelectMembersPageState createState() => _SelectMembersPageState();
}

class _SelectMembersPageState extends State<SelectMembersPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  List<TeamStore> _teams = List(); // 所有已加入或未加入团队列表
  Map<int, List<TeamMember>> _teamMembers = Map(); // 其余团队及成员列表
  Set<int> _teamMemberInfo = Set(); // 团队现有成员列表
  Set<int> _allMembers = Set(); // 其余团队成员列表去重
  List<TeamMemberSelected> _allMembersList = List(); // 其余团队成员列表去重

  List<ContactExtendIsSelected> _contacts = List(); // 好友辅助搜索对象

  bool _isContactLoaded = false;
  bool _isTeamLoading = true;
  bool _processing = false;

  int _curTeamId; // 团队Id

  Set<int> _selectedIds = Set(); // 已选中成员列表

  Map<int, bool> _teamShow = Map();

  @override
  void initState() {
    super.initState();
    _curTeamId = widget.teamId;
    _loadTeamData();

    _tabController = TabController(
      vsync: this,
      length: 2,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      if (_tabController.index == 1 && !_isContactLoaded) {
        _localContactData();
      }
    });
  }

  Future _loadTeamData() async {
    _teams = await teamApi.getAllTeams();
    if (widget.type == 1) {
      List<TeamMember> res = await teamApi.getTeamMembers(
          teamId: widget.teamId, deptId: widget.deptId, type: 1);
      if (res != null) {
        res.forEach((element) {
          _teamMemberInfo.add(element.userId);
        });
      }
    }
    _initShow();
    if ((_teams?.length ?? 0) > 0 && _isTeamLoading) {
      if (mounted)
        setState(() {
          _isTeamLoading = false;
        });
    } else {
      if (mounted)
        setState(() {
          _isTeamLoading = false;
        });
    }
  }

  Future _localContactData() async {
    _parseContactStores(await localStorage.getLocalContacts());
    _loadContactData();
  }

  Future _loadContactData() async {
    try {
      final List<ContactStore> contacts = await contactApi.getContacts();
      if (contacts != null) {
        _parseContactStores(await localStorage.updateLocalContacts(contacts));
      }
    } catch (e) {
      debugPrint('Load contacts error: $e');
    }
  }

  void _parseContactStores(List<ContactStore> stores) {
    _contacts.clear();
    if ((stores?.length ?? 0) > 0) {
      stores.forEach((store) {
        String pinyin = PinyinHelper.getPinyinE(store.name ?? '');
        if (_teamMemberInfo.contains(store.uid)) {
          _contacts.add(ContactExtendIsSelected(
              userId: store.uid,
              name: store.name,
              avatarUrl: store.avatar,
              status: store.status,
              namePinyin: pinyin,
              isSelected: true,
              isCanChange: false));
        } else {
          _contacts.add(ContactExtendIsSelected(
            userId: store.uid,
            name: store.name,
            avatarUrl: store.avatar,
            status: store.status,
            namePinyin: pinyin,
            isSelected: false,
          ));
        }
      });
    }
    if (mounted) {
      _isContactLoaded = true;
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {});
      });
    }
  }

  void _initShow() {
    if (widget.type == 1) {
      for (int i = 0; i < _teams.length; i++) {
        if (_teams[i].id == _curTeamId && widget.deptId == null) {
          _teams.removeAt(i);
          break;
        }
      }
    }

    _teams.forEach((team) {
      if (_teamShow[team.id] == null) {
        _teamShow[team.id] = false;
      }
      _loadMemberData(team.id);
    });
  }

  Future _loadMemberData(int teamId) async {
    List<TeamMember> res =
        await teamApi.getTeamMembers(teamId: teamId, type: 1);
    _teamMembers[teamId] = res;
    if (res != null) {
      res.forEach((teamMember) {
        if (!_allMembers.contains(teamMember.userId)) {
          _allMembers.add(teamMember.userId);
          String pinyin = PinyinHelper.getPinyinE(teamMember.name ?? '');
          if (_teamMemberInfo.contains(teamMember.userId)) {
            _allMembersList.add(TeamMemberSelected(
                userId: teamMember.userId,
                name: teamMember.name,
                avatarUrl: teamMember.avatar,
                namePinyin: pinyin,
                isSelected: true,
                isCanChange: false));
          } else {
            _allMembersList.add(TeamMemberSelected(
              userId: teamMember.userId,
              name: teamMember.name,
              avatarUrl: teamMember.avatar,
              namePinyin: pinyin,
              isSelected: false,
            ));
          }
        }
      });
    }
  }

  void _selectMember(int memberId) {
    if (mounted) {
      setState(() {
        if (_selectedIds.contains(memberId)) {
          _selectedIds.remove(memberId);
        } else {
          _selectedIds.add(memberId);
        }
      });
    }
  }

  Widget _buildStructure(int teamId, String name) {
    List<Widget> items = [
      ShadowCardView(
        margin: EdgeInsets.only(
          top: 5.0,
          left: 15.0,
          right: 15.0,
        ),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 5.0,
          top: 12.0,
          bottom: 12.0,
        ),
        radius: 8.0,
        blurRadius: 3.0,
        child: Column(
          children: <Widget>[
            RadioLineView(
              content: Text(
                name,
                style: TextStyles.textF16Bold,
              ),
              arrowUp: _teamShow[teamId],
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _teamShow[teamId] = !_teamShow[teamId];
                  });
                }
              },
            ),
          ],
        ),
      )
    ];

    if (_teamShow[teamId]) {
      List<TeamMember> members =
          _teamMembers[teamId] == null ? List() : _teamMembers[teamId];
      if (members.length > 0) {
        items.add(ShadowCardView(
          margin: EdgeInsets.only(
            top: 15.0,
            left: 15.0,
            right: 15.0,
          ),
          radius: 8.0,
          blurRadius: 3.0,
          child: Column(
            children: members.map((member) {
              return _buildMember(
                  member.userId,
                  member.avatar,
                  member.name,
                  member.manager,
                  member.leader,
                  member.remark,
                  member.userId != members.last.userId);
            }).toList(),
          ),
        ));
      }
    }

    return Column(
      children: items,
    );
  }

  Widget _buildMember(int userId, String profileImage, String nickname,
      int manager, int leader, String job, bool haveBorder) {
    List<Widget> roleWidget = identity(context, manager, leader);
    return RadioLineView(
        checked:
            (_teamMemberInfo.contains(userId) || _selectedIds.contains(userId)),
        color: !_teamMemberInfo.contains(userId)
            ? Colors.white
            : greyEAColor.withOpacity(0.3),
        haveBorder: haveBorder,
        iconRt: 2.0,
        paddingLeft: 6.0,
        radioIsCanChange: !_teamMemberInfo.contains(userId),
        content: ListItemView(
          paddingRight: 0.0,
          paddingLeft: 0.0,
          iconWidget: ImageView(
            img: cuttingAvatar(profileImage),
            width: 42.0,
            height: 42.0,
            needLoad: true,
            isRadius: 21.0,
            fit: BoxFit.cover,
          ),
          color: !_teamMemberInfo.contains(userId)
              ? Colors.white
              : greyEAColor.withOpacity(0.3),
          title: nickname,
          labelWidget: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: roleWidget,
            ),
          ),
          dense: true,
          haveBorder: false,
          onPressed: () {
            if (!_teamMemberInfo.contains(userId)) {
              _allMembersList.forEach((element) {
                if (element.userId == userId) {
                  element.isSelected = !element.isSelected;
                }
              });
              _selectMember(userId);
            }
          },
        ),
        checkCallback: () {
          if (!_teamMemberInfo.contains(userId)) {
            _allMembersList.forEach((element) {
              if (element.userId == userId) {
                element.isSelected = !element.isSelected;
              }
            });
            _selectMember(userId);
          }
        });
  }

  Widget _buildTeamContent() {
    List<Widget> items = [];
    for (int i = 0; i < _teams.length; i++) {
      TeamStore team = _teams[i];
      items.add(_buildStructure(team.id, team.name));
      items.add(Container(
        height: 5.0,
        color: greyF6Color,
        margin: EdgeInsets.only(
          bottom: 10.0,
          top: 15.0,
        ),
      ));
    }
    if (items.length > 1) {
      items.removeLast();
    }
    return Column(
      children: items,
    );
  }

  void _dealSubmit() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    if (widget.isAdmin == true) {
      _pullMembers();
    } else {
      _inviteMembers();
    }
  }

  // 管理员或部门主管，直接拉人进团队或部门
  void _pullMembers() async {
    Loading.before(context: context);
    var res = await teamApi.addTeamMembers(
      teamId: widget.teamId,
      deptId: widget.deptId,
      memberIds: _selectedIds.toList(),
    );
    Loading.complete();

    if (res == 0) {
      showToast(context, S.of(context).addOk);
      Navigator.pop(context, _selectedIds);
    } else if (res == 3) {
      showToast(context, S.of(context).memberIsMax);
    } else if (res == 2) {
      showToast(context, S.of(context).noPermisson);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  // 普通成员邀请人进团队或部门
  void _inviteMembers() async {
    Loading.before(context: context);
    var tInfo = await getSomeoneTeam(teamId: widget.teamId);
    var msg = {
      'tId': tInfo.id,
      'tName': tInfo.name,
      'tAvatar': tInfo.icon,
      'teamCode': tInfo.code,
      'deptId': widget.deptId
    };
    int sendNum = 0;
    _selectedIds.forEach((id) async {
      bool isFind = false;
      String nickname;
      String avatar;
      // 先在好友里面查找
      for (int c = 0; c < _contacts.length; c++) {
        if (_contacts[c].userId == id) {
          isFind = true;
          nickname = _contacts[c].name;
          avatar = _contacts[c].avatarUrl;
          break;
        }
      }
      // 没找到再在团队成员里面查找
      if (isFind == false) {
        for (int i = 0; i < _allMembersList.length; i++) {
          if (_allMembersList[i].userId == id) {
            nickname = _allMembersList[i].name;
            avatar = _allMembersList[i].avatarUrl;
            isFind = true;
            break;
          }
        }
      }
      ChatStore store = ChatStore(
          getOnlyId(), 1, API.userInfo.id, id, 108, jsonEncode(msg),
          state: 1,
          time: DateTime.now().millisecondsSinceEpoch,
          burn: 0,
          name: API.userInfo.nickname);
      Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
      if (res != null) {
        await ChannelManager.getInstance()
            .addSingleChat(id, nickname, avatar, false, store);
        sendNum += 1;
      }
      if (id == _selectedIds.last) {
        if (sendNum == _selectedIds.length) {
          showToast(context, S.of(context).teamInviteSuccess);
        } else if (sendNum == 0) {
          showToast(context, S.of(context).teamInviteFail);
        } else {
          showToast(context, S.of(context).teamInviteSuccessNum(sendNum));
        }
        Loading.complete();
        Navigator.pop(context, _selectedIds);
      }
    });
  }

  void _openSearch() async {
    if (_tabController.index == 0) {
      routeMaterialPush(SearchCommonPage(
        pageType: 16,
        data: _allMembersList,
      )).then((i) {
        if (i != null && _allMembersList[i].isCanChange == true) {
          _allMembersList[i].isSelected = !_allMembersList[i].isSelected;
          if (_selectedIds.contains(_allMembersList[i].userId)) {
            _selectedIds.remove(_allMembersList[i].userId);
          } else {
            _selectedIds.add(_allMembersList[i].userId);
          }
        }
      });
    } else if (_tabController.index == 1) {
      routeMaterialPush(SearchCommonPage(
        pageType: 2,
        data: _contacts,
      )).then((i) {
        if (i != null && _contacts[i].isCanChange == true) {
          _contacts[i].isSelected = !_contacts[i].isSelected;
          if (_selectedIds.contains(_contacts[i].userId)) {
            _selectedIds.remove(_contacts[i].userId);
          } else {
            _selectedIds.add(_contacts[i].userId);
          }
        }
      });
    }
  }

  Widget _buildNavBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: Colors.white,
      indicatorWeight: 0.1,
      labelColor: Colors.black,
      labelStyle: TextStyles.textTabSel,
      unselectedLabelColor: grey81Color,
      unselectedLabelStyle: TextStyles.textTabUnSel,
      tabs: <Widget>[
        Tab(text: parseTextFirstUpper(S.of(context).team)),
        Tab(
          text: parseTextFirstUpper(S.of(context).friend),
        ),
      ],
    );
  }

  Widget _buildTeams() {
    return _isTeamLoading
        ? buildProgressIndicator()
        : Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: 60.0,
                  ),
                  children: <Widget>[_buildTeamContent()],
                ),
              ),
            ],
          );
  }

  Widget _buildFriends() {
    return !_isContactLoaded
        ? buildProgressIndicator()
        : ListView.builder(
            padding: EdgeInsets.only(
              bottom: 60.0,
            ),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              return RadioLineView(
                checked: (_teamMemberInfo.contains(_contacts[index].userId) ||
                    _selectedIds.contains(_contacts[index].userId)),
                haveBorder: true,
                color: !_teamMemberInfo.contains(_contacts[index].userId)
                    ? Colors.white
                    : greyEAColor.withOpacity(0.3),
                radioIsCanChange: _contacts[index].isCanChange,
                paddingLeft: 15.0,
                paddingRight: 15.0,
                iconRt: 2.0,
                content: ListItemView(
                  paddingLeft: 0,
                  color: !_teamMemberInfo.contains(_contacts[index].userId)
                      ? Colors.white
                      : greyEAColor.withOpacity(0.3),
                  iconWidget: ImageView(
                    img: cuttingAvatar(_contacts[index].avatarUrl),
                    width: 42.0,
                    height: 42.0,
                    needLoad: true,
                    isRadius: 21.0,
                    fit: BoxFit.cover,
                  ),
                  title: _contacts[index].name,
                  // label: labelText,
                  haveBorder: false,
                  onPressed: () {
                    if (_contacts[index].isCanChange != false) {
                      _contacts[index].isSelected =
                          !_contacts[index].isSelected;
                      _selectMember(_contacts[index].userId);
                    }
                  },
                ),
                checkCallback: () {
                  if (_contacts[index].isCanChange != false) {
                    _contacts[index].isSelected = !_contacts[index].isSelected;
                    _selectMember(_contacts[index].userId);
                  }
                },
              );
            },
          );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _buildTeams(),
        _buildFriends(),
      ],
    );
  }

  // 查看所有已选人员
  void _showSelected() async {
    Set<int> teamMemberId = Set();
    List<Map> selectUser = [];
    if (_selectedIds.length > 0) {
      _selectedIds.forEach((id) {
        bool isFind = false;
        for (int i = 0; i < _contacts.length; i++) {
          if (id == _contacts[i].userId) {
            isFind = true;
            selectUser.add({
              "name": _contacts[i].name,
              "avatar": _contacts[i].avatarUrl,
              "userId": _contacts[i].userId,
            });
            break;
          }
        }
        if (isFind == false) {
          teamMemberId.add(id);
        }
      });
    } else {
      teamMemberId.addAll(_selectedIds);
    }

    if (teamMemberId.length > 0) {
      teamMemberId.forEach((id) {
        for (int i = 0; i < _allMembersList.length; i++) {
          if (id == _allMembersList[i].userId) {
            selectUser.add({
              "name": _allMembersList[i].name,
              "avatar": _allMembersList[i].avatarUrl,
              "userId": _allMembersList[i].userId,
            });
            break;
          }
        }
      });
    }

    Set<int> res = await routeMaterialPush(SelectedMemberView(
      selectUser: selectUser,
      memberIds: _selectedIds,
    ));
    if (res != null && mounted) {
      setState(() {
        _selectedIds = res;
      });
    }
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.3),
        ),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: InkWell(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                      child: Text(
                    '${S.of(context).selected}：'
                    '${_selectedIds.length} ${S.of(context).personUnit}',
                    style: TextStyles.textF16C1,
                  )),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: themeColor,
                  ),
                ],
              ),
              onTap: _showSelected,
            ),
          ),
          _processing
              ? buildProgressIndicator()
              : SubmitBtnView(
                  text: S.of(context).ok,
                  haveValue: _selectedIds.isNotEmpty,
                  onPressed: _dealSubmit,
                  top: 0.0,
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget rWidget = InkWell(
      child: Container(
        child: ImageView(
          img: searchImage,
        ),
        color: Colors.white,
      ),
      onTap: _openSearch,
    );

    return Scaffold(
      appBar: ComMomBar(
        titleW: _buildNavBar(),
        mainColor: Colors.black,
        backgroundColor: Colors.white,
        rightDMActions: <Widget>[rWidget],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: [Expanded(child: _buildTabBarView()), _buildFooter()],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
