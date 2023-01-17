import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/top_depts.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/pages/team/member/team_member_info.dart';
import 'package:cobiz_client/pages/team/team_page/edit_member.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/menu/popup_menu.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_dept.dart';
import '../member/add_member.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

class OrganizationPage extends StatefulWidget {
  final TeamInfo teamInfo;
  final List<TopDept> topDepts; //第一级部门信息
  final TopDept touchDept;
  const OrganizationPage(
      {Key key, this.teamInfo, this.topDepts, this.touchDept})
      : super(key: key);

  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  bool _isLoading = true;
  bool _hasBread = false; //顶部导航

  Depts _curDept; //当前选中部门
  List<Depts> _oldDepts = List();

  List<Depts> _depts = List(); //公司部门组织架构
  List<Members> _members = List(); //公司成员
  bool _isAdmin = false; //是否是主管理员和管理员

  bool isSupervisor = false; //是不是当前选中部门的主管

  bool isUpSupervisor = false; //是不是当前选中部门的上级部门主管

  @override
  void initState() {
    super.initState();
    _getData(isFirst: true);
  }

  Future _getData({bool isFirst = false}) async {
    DeptAndMember res =
        await teamApi.getTeamMembers(teamId: widget.teamInfo.id, type: 2);
    if (res != null) {
      if (res.depts.isNotEmpty) {
        _depts = res.depts;
      }
      if (res.members.isNotEmpty) {
        _members = res.members;
      }
      //判断自己是不是管理员或者创建者
      for (var i = 0; i < _members.length; i++) {
        if (_members[i].id == API.userInfo.id) {
          if (_members[i].manager == 1 || _members[i].manager == 2) {
            _isAdmin = true;
          } else {
            _isAdmin = false;
          }
          break;
        }
      }
      //主页进入跳到指定的部门
      if (widget.touchDept != null && isFirst) {
        for (var i = 0; i < _depts?.length ?? 0; i++) {
          if (_depts[i].id == widget.touchDept.id) {
            _clickDept(_depts[i], false);
            break;
          }
        }
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showToast(context, S.of(context).tryAgainLater);
      Navigator.pop(context);
    }
  }

  //更新
  void _update() {
    //备份导航
    Depts _copyD = _curDept;
    List<Depts> _copyL = _oldDepts;

    _isLoading = true;
    _hasBread = false;
    _curDept = null;
    _oldDepts = List();
    _depts = List(); //公司部门组织架构
    _members = List(); //公司成员
    _getData().then((value) {
      //做一下导航
      if (_copyD != null) {
        for (var i = 0; i < _copyL.length; i++) {
          if (_copyL[i] != null) {
            List<Depts> _cut = [];
            if (_curDept == null) {
              _cut = _depts;
            } else {
              _cut = _curDept.childs;
            }
            for (var j = 0; j < _cut.length; j++) {
              if (_copyL[i].id == _cut[j].id) {
                _clickDept(_cut[j], false);
                break;
              }
            }
          }
        }
        if (_curDept != null) {
          for (var i = 0; i < _curDept.childs.length; i++) {
            if (_curDept.childs[i].id == _copyD.id) {
              _clickDept(_curDept.childs[i], false);
              break;
            }
          }
        } else {
          for (var i = 0; i < _depts?.length ?? 0; i++) {
            if (_depts[i].id == _copyD.id) {
              _clickDept(_depts[i], false);
              break;
            }
          }
        }

        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Widget _buildBread() {
    if (!_hasBread)
      return SizedBox(
        height: 0,
      );

    //导航最初
    List<Widget> list = [
      InkWell(
        child: Text(
          widget.teamInfo.name,
          style: TextStyles.textF16Bold,
        ),
        onTap: () {
          _clickDept(null, true);
          _oldDepts.clear();
        },
      )
    ];

    if (_oldDepts != null && _oldDepts.length > 0) {
      int length = _oldDepts.length;
      for (int i = 0; i < length; i++) {
        Depts dept = _oldDepts[i];
        if (dept == null) continue;

        list.add(InkWell(
          child: arrowText(dept.name),
          onTap: () {
            int count = 0;
            for (int j = length - 1; j >= 0; j--) {
              if (_oldDepts[j].id == dept.id) break;
              count++;
            }
            _clickDept(dept, true);
            for (int j = 0; j < count; j++) {
              _oldDepts.removeLast();
            }
          },
        ));
      }
    }

    if (_curDept != null) {
      list.add(arrowText(_curDept.name, type: true));
    }

    return Container(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Container(
              height: 30,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: list,
              ),
              constraints: BoxConstraints(minWidth: winWidth(context) - 30),
            ),
          );
        },
      ),
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
    );
  }

  List<Widget> _buildDeptTitle(bool isHead, String title, int num) {
    List<Widget> list = [
      Container(
        child: Text(
          title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.textF16,
        ),
        constraints: BoxConstraints(
          maxWidth: winWidth(context) - (isHead ? 140 : 150),
        ),
      ),
      Expanded(
        child: Padding(
          child: Text(
            '$num ${S.of(context).personUnit}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textNum,
          ),
          padding: EdgeInsets.only(
            top: 2.0,
            left: 10.0,
          ),
        ),
      ),
    ];
    if (!isHead) {
      list.add(Container(
        child: ImageView(
          img: arrowRtImage,
        ),
        margin: EdgeInsets.only(
          right: 5.0,
        ),
      ));
    }
    return list;
  }

  int _calDeptNum(Depts _dept) {
    if ((_dept?.id ?? 0) == 0) return _members?.length ?? 0;
    Set memberIds = Set();
    _calDeptAllNum(_dept, memberIds);
    return memberIds.length;
  }

  void _calDeptAllNum(Depts _dept, Set memberIds) {
    if (_dept.memberIds != null && _dept.memberIds.length > 0) {
      memberIds.addAll(_dept.memberIds);
    }
    if (_dept.childs != null && _dept.childs.length > 0) {
      for (var j = 0; j < _dept.childs.length; j++) {
        _calDeptAllNum(_dept.childs[j], memberIds);
      }
    }
  }

  //部门架构
  List<Depts> _dealDepts() {
    if (_curDept == null) {
      return _depts;
    } else {
      if (_curDept.childs.isNotEmpty) {
        return _curDept.childs;
      } else {
        return List<Depts>();
      }
    }
  }

  Widget _buildDepartment() {
    List<Widget> icons = [
      Container(
        height: 30,
        child: ImageView(
          img: 'assets/images/team/ic_structure.png',
        ),
        margin: EdgeInsets.only(
          top: 0.0,
          left: 0.0,
          right: 10.0,
        ),
      )
    ];
    List<Depts> depts = _dealDepts();

    List<Widget> deptWidgets = [
      Container(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildDeptTitle(true,
              _curDept?.name ?? widget.teamInfo.name, _calDeptNum(_curDept)),
        ),
        // padding: EdgeInsets.only(
        //   bottom: (depts?.length ?? 0) > 0 ? 9.0 : 0.0,
        // ),
      )
    ];
    if ((depts?.length ?? 0) > 0) {
      icons.clear();
      double top = 0.0;
      icons.addAll(depts.map((sub) {
        top += (sub.id == depts.first.id ? 15.0 : 38.0);
        return Container(
          child: ImageView(
            img: 'assets/images/team/branch2.png',
          ),
          margin: EdgeInsets.only(
            top: top,
            left: 9,
          ),
        );
      }).toList());
      icons.add(Container(
        height: 30,
        child: ImageView(
          img: 'assets/images/team/ic_structure.png',
        ),
        margin: EdgeInsets.only(
          top: 0.0,
          left: 0.0,
          right: 10.0,
        ),
        color: Colors.white,
      ));
      deptWidgets.addAll(depts.map((sub) {
        return InkWell(
          child: Container(
            height: 30,
            child: Row(
              children: _buildDeptTitle(false, sub.name, _calDeptNum(sub)),
            ),
            margin: EdgeInsets.only(top: 8),
          ),
          onTap: () {
            _clickDept(sub, false);
          },
        );
      }).toList());
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          overflow: Overflow.visible,
          children: icons,
        ),
        Expanded(
          child: Column(
            children: deptWidgets,
          ),
        ),
      ],
    );
  }

  //点击部门
  void _clickDept(Depts dept, bool isBack) {
    if (isBack) {
      _oldDepts.removeLast();
    } else {
      _oldDepts.add(_curDept);
    }
    _curDept = dept;
    _hasBread = dept != null;

    //重置不是主管
    isSupervisor = false;
    isUpSupervisor = false;
    //直接判断当前部门是主管 如果不是 则查询是否是上级某部门的主管
    if (_curDept != null) {
      for (var i = 0; i < _oldDepts.length; i++) {
        if (_oldDepts[i] != null) {
          if (_oldDepts[i].managerId == API.userInfo.id) {
            isUpSupervisor = true;
            isSupervisor = true;
            break;
          }
        }
      }
      if (!isSupervisor) {
        isSupervisor = _curDept.managerId == API.userInfo.id;
      }
    }

    if (mounted) setState(() {});
  }

  Widget _buildMembers() {
    List<Members> members = [];
    if (_curDept == null) {
      //没选中部门 第一级成员展示 没有部门的展示 有部门的过滤
      for (var item in _members) {
        if (item.remark == null || item.remark == '') {
          members.add(item);
        }
      }
    } else {
      _curDept.memberIds.forEach((element) {
        for (var item in _members) {
          if (element == item.id) {
            if (_curDept.managerId == item.id) {
              item.leader = 1;
            } else {
              item.leader = 0;
            }

            members.add(item);
            break;
          }
        }
      });
    }
    return Container(
      child: Column(
        children: members.map((member) {
          return _buildMember(member, member.id != _members.last.id);
        }).toList(),
      ),
      padding: EdgeInsets.only(top: 5.0),
    );
  }

  Widget _buildMember(Members teamMember, bool haveBorder) {
    List<Widget> roleWidget =
        identity(context, teamMember.manager, teamMember.leader);
    return ListItemView(
      iconWidget: ImageView(
        img: cuttingAvatar(teamMember.avatar),
        width: 42.0,
        height: 42.0,
        needLoad: true,
        isRadius: 21.0,
        fit: BoxFit.cover,
      ),
      title: teamMember.name,
      labelWidget: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: roleWidget,
        ),
      ),
      widgetRt1: _isAdmin || isSupervisor
          ? InkWell(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                  child: ImageView(
                    img: 'assets/images/ic_edit.png',
                  )),
              onTap: () => _editMember(teamMember.id, teamMember.name),
            )
          : null,
      paddingRight: 0.0,
      paddingLeft: 0.0,
      dense: true,
      haveBorder: haveBorder,
      onPressed: () {
        routePush(TeamMemberInfo(
                teamId: teamMember.teamId,
                userId: teamMember.id,
                isCanEdit: _isAdmin || isSupervisor,
                fromWhere: 1))
            .then((value) {
          if (value == true) {
            _editMember(teamMember.id, teamMember.name);
          }
        });
      },
    );
  }

  void _editMember(int userId, String userName) async {
    if (userId == null) return;

    final result = await routePush(EditMemberPage(
      teamId: widget.teamInfo.id,
      teamName: widget.teamInfo.name,
      userId: userId,
      userName: userName,
      depts: _curDept,
      isSupervisor: isSupervisor,
      creatorId: widget.teamInfo.creator,
      manIds: widget.teamInfo.managers,
    ));
    if (result != null && result == true) {
      _update();
    }
  }

  Widget _buildStructure() {
    return Column(
      children: [ShadowCardView(child: _buildDepartment()), _buildMembers()],
    );
  }

  Future _dealAddDept(bool isEdit) async {
    if (_isLoading) return;
    int superiorId;
    String superiorName;
    int masterId;
    String masterName = '';
    if (isEdit) {
      superiorId = _curDept.pid;
      superiorName = _oldDepts.length > 0
          ? (_oldDepts[_oldDepts.length - 1]?.name ?? widget.teamInfo.name)
          : widget.teamInfo.name;
      masterId = _curDept.managerId;
      if (masterId != null) {
        for (int i = 0; i < _members.length; i++) {
          if (_members[i].id == masterId) {
            masterName = _members[i].name;
            break;
          }
        }
      }
    } else {
      superiorId = _curDept?.id ?? null;
      superiorName = _curDept?.name ?? widget.teamInfo.name;
    }

    final Map result = await routePush(AddDepartmentPage(
        teamId: widget.teamInfo.id,
        teamName: widget.teamInfo.name,
        dept: isEdit ? _curDept : null,
        superiorId: superiorId,
        superiorName: superiorName,
        masterId: masterId,
        masterName: masterName,
        isEdit: isEdit));

    if (result == null) return;

    int type = result['type'];
    if (type == 3) {
      _update();
    } else if (type == 2) {
      if (mounted) {
        setState(() {
          if (_curDept != null) {
            _curDept.name = result['name'];
          }
          if (_curDept.managerId != result['masterId']) {
            _curDept.managerId = result['masterId'];
          }
          if (!_curDept.memberIds.contains(_curDept.managerId) &&
              _curDept.managerId != 0 &&
              _curDept.managerId != null) {
            _curDept.memberIds.add(_curDept.managerId);
          }
        });
      }
    } else {
      _update();
    }
  }

  void _openSearch() {
    routeMaterialPush(
            SearchCommonPage(pageType: 14, data: _members, isAdmin: _isAdmin))
        .then((value) {
      if (value != null) {
        if (value['isEdit'] == true) {
          _editMember(value['uid'], value['uName']);
        }
      }
    });
  }

  /// 顶部 + 号菜单
  Widget buildPopMenu() {
    List<PMenuItem> list = [];

    if (_isAdmin) {
      // 主管理员/管理员
      list.add(PMenuItem(DeptActiveType.addMember, S.of(context).teamAddMember,
          'assets/images/ic_add.png'));
      list.add(PMenuItem(DeptActiveType.addDept, S.of(context).addSubDept,
          'assets/images/add_group.png'));
      if (_hasBread) {
        list.add(PMenuItem(
            DeptActiveType.deptSet, S.of(context).setSubDept, settingImage));
      }
    } else if (isSupervisor) {
      // 部门主管
      list.add(PMenuItem(DeptActiveType.addMember, S.of(context).teamAddMember,
          'assets/images/ic_add.png'));
      list.add(PMenuItem(DeptActiveType.addDept, S.of(context).addSubDept,
          'assets/images/add_group.png'));
      if (_hasBread && isUpSupervisor) {
        list.add(PMenuItem(
            DeptActiveType.deptSet, S.of(context).setSubDept, settingImage));
      }
    } else if (_curDept == null ||
        (_curDept.chatId != null && _curDept.chatId != 0)) {
      // 普通成员
      list.add(PMenuItem(DeptActiveType.addMember, S.of(context).teamAddMember,
          'assets/images/ic_add.png'));
    }
    if (_curDept == null || (_curDept.chatId != null && _curDept.chatId != 0)) {
      list.insert(
          0,
          PMenuItem(
              DeptActiveType.goToChat, S.of(context).goToChat, chatImage));
    }

    if (list.length > 0) {
      return PopupMenu(
        icon: Icon(
          Icons.more_horiz,
        ),
        list: list,
        onSelected: _actionsHandle,
      );
    } else {
      return Container();
    }
  }

  /// 顶部 + 号菜单 method
  void _actionsHandle(PMenuItem item) async {
    switch (item.value) {
      case DeptActiveType.addDept:
        _dealAddDept(false);
        break;
      case DeptActiveType.addMember:
        _addMember();
        break;
      case DeptActiveType.deptSet:
        _dealAddDept(true);
        break;
      case DeptActiveType.goToChat:
        _goToChat();
        break;
      default:
    }
  }

  _addMember() async {
    routePush(AddTeamMemberPage(
      teamId: widget.teamInfo.id,
      deptId: _curDept?.id ?? null,
      teamName: widget.teamInfo.name,
      isManager: _isAdmin || isSupervisor,
      membersSum: _members.length ?? 0,
      teamCode: widget.teamInfo.code,
    )).then((value) {
      if (value != null && value == true) {
        _update();
      }
    });
    // if (_curDept == null) {
    // } else {
    //   var res = await routePush(SelectGroupMembersPage(
    //     teamId: widget.teamInfo.id,
    //     groupId: _curDept.id,
    //     memberList: _curDept.memberIds,
    //     showType: 2,
    //   ));
    //   if (res != null && res['ids'].length > 0) {
    //     Loading.before(context: context);
    //     bool isC = await teamApi.addDeptMember(
    //         _curDept.teamId, _curDept.id, res['ids']);
    //     Loading.complete();
    //     if (isC == true) {
    //       _update();
    //     } else {
    //       showToast(context, S.of(context).tryAgainLater);
    //     }
    //   }
    // }
  }

  _goToChat() {
    if (_curDept == null) {
      routePush(GroupChatPage(
          groupId: widget.teamInfo.chatId,
          groupName: widget.teamInfo.name,
          groupAvatar: [widget.teamInfo.icon],
          groupNum: _members.length,
          gType: 1,
          teamId: widget.teamInfo.id ?? 0));
    } else {
      if (_curDept.chatId != null && _curDept.chatId != 0) {
        routePush(GroupChatPage(
            groupId: _curDept.chatId,
            groupName: _curDept.name,
            groupAvatar: [],
            groupNum: _curDept.memberIds.length,
            gType: 3,
            teamId: widget.teamInfo.id ?? 0));
      } else {
        showToast(context, S.of(context).noPermisson);
      }
    }
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(context, true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: ComMomBar(
              title: S.of(context).teamMyOrganization,
              elevation: 0.5,
              rightDMActions: _isLoading ? null : [buildPopMenu()],
              backData: true,
            ),
            body: ScrollConfiguration(
              behavior: MyBehavior(),
              child: Column(
                children: <Widget>[
                  buildSearch(context,
                      onPressed: _isLoading ? () {} : _openSearch, pb: 5.0),
                  _buildBread(),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        _isLoading
                            ? buildProgressIndicator()
                            : _buildStructure(),
                      ],
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white),
        onWillPop: _onWillPop);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum DeptActiveType {
  goToChat, //前往群聊
  addDept, // 创建小组
  addMember, // 加入小组
  deptSet, // 设置小组
}
