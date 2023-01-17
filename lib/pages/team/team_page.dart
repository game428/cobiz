import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/http/res/team_model/team_group.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/top_depts.dart';
import 'package:cobiz_client/http/team.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/pages/team/friend/add_friend.dart';
import 'package:cobiz_client/pages/team/team_page/team_info_page.dart';
import 'package:cobiz_client/pages/work/work_page.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/menu/popup_menu.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:cobiz_client/ui/view/operate_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart' hide NestedScrollView;
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;

import 'join_choose.dart';
import 'friend/my_contacts.dart';
import 'group/group_page.dart';
import 'team_page/create_team.dart';
import 'department/org_page.dart';
import 'team_page/search_team.dart';
import 'team_page/switch_team.dart';
import 'member/team_member.dart';
import 'team_page/team_settings.dart';

class TeamPage extends StatefulWidget {
  TeamPage({Key key}) : super(key: key);

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage>
    with AutomaticKeepAliveClientMixin {
  bool _isDeptLoading = true;
  bool _isGroupLoading = true;
  List<TopDept> _topDepts = []; //第一级组织架构
  List<TeamGroup> _groups = []; //小组
  TeamInfo _team; //当前团队信息

  bool _haveNewTeamMember = false; //是否有新的成员申请

  bool _haveNewWork = false; //是否有新工作通知

  bool hasTeam = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _removeStream();
    super.dispose();
  }

  _init({int teamID}) async {
    var res = await getSomeoneTeam(teamId: teamID);
    if (mounted) {
      if (res == null) {
        hasTeam = false;
      } else {
        hasTeam = true;
        _team = res;
      }
      _isLoading = true;
      setState(() {});
    }
    _removeStream();
    _eventSteram();
    if (hasTeam) {
      _localTeamData();
    }
  }

  _removeStream() {
    // eventBus.off(EVENT_NEW_CONTACT_APPLY);
    eventBus.off(EVENT_UPDATE_TEAM_GROUP);
    eventBus.off(EVENT_UPDATE_TEAM_JOIN);
    eventBus.off(EVENT_UPDATE_TEAM);
    eventBus.off(EVENT_UPDATE_WORK);
  }

  _eventSteram() {
    // 新的团员申请
    eventBus.on(EVENT_UPDATE_TEAM_JOIN, (arg) {
      if (arg != null && _team != null && hasTeam) {
        if (arg == _team.id && !_haveNewTeamMember) {
          if (mounted) {
            setState(() {
              _haveNewTeamMember = true;
            });
          }
        }
        if (arg == false && _haveNewTeamMember) {
          if (mounted) {
            setState(() {
              _haveNewTeamMember = false;
            });
          }
        }
      }
    });
    // 工作通知
    eventBus.on(EVENT_UPDATE_WORK, (arg) {
      if (arg != null && _team != null && hasTeam) {
        if (arg == _team.id && !_haveNewWork) {
          if (mounted) {
            setState(() {
              _haveNewWork = true;
            });
          }
        }
        if (arg == false && _haveNewWork) {
          if (mounted) {
            setState(() {
              _haveNewWork = false;
            });
          }
        }
      }
    });
    // 团队刷新
    eventBus.on(EVENT_UPDATE_TEAM, (arg) {
      if (arg == true && _team == null && hasTeam == false) {
        _isLoading = false;
        _isDeptLoading = true;
        _isGroupLoading = true;
        _init();
      }
    });

    // 团队小组更新
    eventBus.on(EVENT_UPDATE_TEAM_GROUP, (arg) {
      if (arg == true) {
        _isGroupLoading = true;
        _localGroupData();
      }
    });
  }

  //获取本地团队数据
  Future _localTeamData() async {
    // int teamId = _team.id;
    // _team = await localStorage.getLocalTeam(teamId);
    if (_team != null) {
      _localGroupData();
      _localDeptData();
    } else {
      if (mounted)
        setState(() {
          _isDeptLoading = false;
          _isGroupLoading = false;
        });
    }
  }

  //本地 部门 组织架构
  Future _localDeptData() async {
    int teamId = _team.id;
    _loadDepts(teamId);
  }

  //本地 我的小组
  Future _localGroupData() async {
    int teamId = _team.id;
    _parseGroupStores(teamId, await localStorage.getLocalGroups(teamId));
    _loadGroups(teamId);
  }

  void _parseGroupStores(int teamId, List<TeamGroup> stores) {
    _groups.clear();
    if ((stores?.length ?? 0) > 0) {
      for (var i = 0; i < stores.length; i++) {
        _groups.add(stores[i]);
        if (_groups.length == 4) {
          break;
        }
      }
    }
    if (mounted) {
      setState(() {
        _isGroupLoading = false;
      });
    }
  }

  Future _loadDepts(int teamId) async {
    _topDepts = await getTopDepts(teamId: teamId);
    if (mounted) {
      setState(() {
        _isDeptLoading = false;
      });
    }
  }

  //获取线上
  Future _loadGroups(int teamId) async {
    List<TeamGroup> res = await getTeamGroups(teamId: teamId);
    if (res != null) {
      _isGroupLoading = true;
      _parseGroupStores(
          teamId, await localStorage.updateLocalGroups(teamId, res));
      localStorage.updateLocalGroups(teamId, res);
    }
  }

  void _teamActionHandle(TeamMenuValue teamMenuValue) async {
    switch (teamMenuValue) {
      case TeamMenuValue.teamMembers: //团队成员
        routePush(TeamMembersPage(
          teamInfo: _team,
          newApply: _haveNewTeamMember,
        ));
        break;
      case TeamMenuValue.createTeam: //创建团队
        _createTeam();
        break;
      case TeamMenuValue.joinTeam: //加入团队
        // showJoinTeamOperate(context, call: (v) {
        //   if (v != null) {}
        // });
        routePush(SearchTeamPage());
        break;
      case TeamMenuValue.switchTeam: //切换团队
        _switchTeam();
        break;
      case TeamMenuValue.teamSetting: //团队设置
        _teamSetting();
        break;
      case TeamMenuValue.collaborativeWork: //协同工作
        routePush(WorkPage(teamInfo: _team));
        break;
      case TeamMenuValue.groups: //我的小组
        bool isUpdate = await routePush(MyGroupPage(
          teamId: _team?.id,
        ));
        if (isUpdate == true) {
          _isGroupLoading = true;
          _localGroupData();
        }
        break;
      case TeamMenuValue.organization: //组织架构
        _goToOrg();
        break;
      default:
    }
  }

  //前往组织架构
  _goToOrg({TopDept curentDept}) async {
    bool isUpdate = await routePush(OrganizationPage(
      teamInfo: _team,
      topDepts: _topDepts,
      touchDept: curentDept,
    ));
    if (isUpdate == true) {
      _isDeptLoading = true;
      _localDeptData();
    }
  }

  // 团队设置
  void _teamSetting() async {
    bool changeState = await routePush(TeamSettingsPage(
      teamId: _team?.id,
    ));
    if (changeState == true) {
      _isLoading = false;
      _init();
    }
  }

  //创建团队
  void _createTeam({dynamic data}) async {
    TeamInfo team;
    if (data != null) {
      team = data;
    } else {
      team = await routePush(CreateTeamPage());
    }

    TeamInfo store = await localStorage.updateLocalTeam(team);
    if (store != null && team != null) {
      _isLoading = false;
      _isDeptLoading = true;
      _isGroupLoading = true;
      _team = null;
      _init(teamID: store.id);
    }
  }

  //切换团队
  void _switchTeam() async {
    var res = await routePush(SwitchTeamPage(
      teamId: _team?.id,
    ));
    if (res != null) {
      _isLoading = false;
      _isDeptLoading = true;
      _isGroupLoading = true;
      _team = null;
      _haveNewWork = false;
      _haveNewTeamMember = false;
      if (mounted) {
        setState(() {});
      }
      _init(teamID: res);
    }
  }

  //小组 组织架构
  Widget _buildStructure(String icon, String title, GlobalModel model,
      TeamMenuValue value, List subs, bool isLoading) {
    List<Widget> items = [
      OperateLineView(
        icon: icon,
        title: title,
        dense: true,
        haveBorder: false,
        onPressed: () => _teamActionHandle(value),
      )
    ];
    if (isLoading) {
      items.add(buildProgressIndicator());
    } else {
      String branchIcon = 'assets/images/team/branch2.png';
      for (var i = 0; i < subs.length; i++) {
        String text = '';
        Widget rightW;
        if (subs[i] is TopDept) {
          text = subs[i].name;
        } else if (subs[i] is TeamGroup) {
          text = subs[i].name;
        }
        if (i == 3 && subs[i] is TeamGroup) {
          text = '...';
        }
        if (subs[i] is TeamGroup && i != 3) {
          rightW = InkWell(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: ImageView(
                img: 'assets/images/ic_chat.png',
              ),
            ),
            onTap: () {
              if (subs[i] is TeamGroup) {
                routePush(GroupChatPage(
                  groupId: subs[i].chatId,
                  groupName: subs[i].name,
                  groupAvatar: [],
                  groupNum: subs[i].number,
                  gType: 2,
                  teamId: subs[i].teamId,
                  backCall: (v) {
                    if (v == true) {
                      _isGroupLoading = true;
                      _localGroupData();
                    }
                  },
                ));
              }
            },
          );
        }
        if (subs[i] is TopDept && subs[i].chatId > 0) {
          rightW = InkWell(
            child: ImageView(
              img: 'assets/images/ic_chat.png',
            ),
            onTap: () {
              if (subs[i] is TopDept) {
                routePush(GroupChatPage(
                  groupId: subs[i].chatId,
                  groupName: subs[i].name,
                  groupAvatar: [],
                  groupNum: subs[i].num,
                  gType: 3,
                  teamId: subs[i].teamId,
                  backCall: (v) {
                    if (v == true) {
                      _isDeptLoading = true;
                      _localDeptData();
                    }
                  },
                ));
              }
            },
          );
        }
        items.add(ListRowView(
          onPressed: () {
            if (subs[i] is TopDept) {
              _goToOrg(curentDept: subs[i]);
            }
          },
          paddingTop: 0.0,
          paddingBottom: 0.0,
          iconRt: 32,
          iconWidget: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              SizedBox(
                height: 38.0,
                width: 25.0,
              ),
              Positioned(
                child: ImageView(
                  img: i == 0 ? 'assets/images/team/branch3.png' : branchIcon,
                  width: 34.0,
                ),
                top: i == 0 ? -20.0 : -35.0,
                left: 1.5,
              ),
            ],
          ),
          titleWidget: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textF15,
          ),
          widgetRt1: rightW,
        ));
        if (i == 3 && subs[i] is TeamGroup) {
          break;
        }
      }
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: greyBCColor),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        children: items,
      ),
    );
  }

  // 有团队的时候顶部展示
  Widget _buildSomeTeamHeader(GlobalModel model) {
    List<PMenuItem> menus = [
      PMenuItem(TeamMenuValue.teamMembers, S.of(context).teamMembers,
          'assets/images/team/team.png'),
    ];
    return Stack(
      overflow: Overflow.visible,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
        ),
        ShadowCardView(
          margin: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
          ),
          padding: EdgeInsets.symmetric(vertical: 6.0),
          radius: 5.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menus.map((menu) {
              return OperateLineView(
                icon: menu.icon,
                title: menu.title,
                dense: true,
                rightWidget: (menu.value == TeamMenuValue.teamMembers &&
                        _haveNewTeamMember)
                    ? buildMessaged()
                    : null,
                haveBorder: false,
                onPressed: () => _teamActionHandle(menu.value),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  // 没团队时 顶部展示
  Widget _buildNoTeamHeader(GlobalModel model) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/images/noteam_bg.png'))),
      child: ShadowCardView(
        margin: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            bottom: 10,
            top: ScreenData.navigationBarHeight),
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
        radius: 5.0,
        child: Stack(
          children: <Widget>[
            ImageView(
              img: 'assets/images/team/team_bg.png',
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  S.of(context).teamNoneTitle,
                  textAlign: TextAlign.right,
                  style: TextStyles.textF16Bold,
                ),
                buildLabel(
                    S.of(context).teamNoneLabel1, 'assets/images/team/app.png'),
                buildLabel(S.of(context).teamNoneLabel2,
                    'assets/images/ic_server.png'),
                buildLabel(
                    S.of(context).teamNoneLabel3, 'assets/images/team/org.png'),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: CupertinoButton(
                    child: Text(
                      S.of(context).teamCreateOrJoin,
                      style: TextStyles.textCreate,
                    ),
                    color: radiusBgColor,
                    pressedOpacity: 0.8,
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    borderRadius: BorderRadius.circular(20.0),
                    onPressed: () => showJoinTeamOperate(context, call: (v) {
                      if (v != null) {
                        _createTeam(data: v);
                      }
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 有团队时 顶部 菜单
  Widget _buildPopMenu() {
    List<PMenuItem> list = [
      PMenuItem(TeamMenuValue.switchTeam, S.of(context).teamSwitch,
          'assets/images/change2.png'),
      PMenuItem(TeamMenuValue.createTeam, S.of(context).teamCreateTitle,
          'assets/images/team/team.png'),
      PMenuItem(TeamMenuValue.joinTeam, S.of(context).joinTeam,
          'assets/images/add_group.png'),
    ];
    if (_team?.creator == API.userInfo.id) {
      list.add(PMenuItem(TeamMenuValue.teamSetting, S.of(context).teamSettings,
          'assets/images/team/setting.png'));
    }
    return PopupMenu(
      icon: Icon(
        Icons.more_horiz,
        color: AppColors.white,
      ),
      list: list,
      onSelected: (PMenuItem pMenuItem) {
        _teamActionHandle(pMenuItem.value);
      },
    );
  }

  // 有团队时
  Widget _buildContent(GlobalModel model) {
    return ShadowCardView(
        margin: EdgeInsets.only(left: 15.0, right: 15.0, top: 10),
        padding: EdgeInsets.only(bottom: 6.0),
        radius: 5.0,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              _buildStructure(
                  'assets/images/team/org.png',
                  S.of(context).myDiscussGroup,
                  model,
                  TeamMenuValue.groups,
                  _groups,
                  _isGroupLoading),
              _buildStructure(
                  'assets/images/team/ic_structure.png',
                  S.of(context).teamMyOrganization,
                  model,
                  TeamMenuValue.organization,
                  _topDepts,
                  _isDeptLoading),
              OperateLineView(
                icon: 'assets/images/team/app.png',
                title: S.of(context).collaborativeWork,
                dense: true,
                rightWidget: _haveNewWork ? buildMessaged() : null,
                haveBorder: false,
                onPressed: () =>
                    _teamActionHandle(TeamMenuValue.collaborativeWork),
              ),
            ],
          ),
        ));
  }

  // 有团队的时候 整体页面
  Widget _buildHasTeam(GlobalModel model) {
    return Column(
      children: [
        _buildSomeTeamHeader(model),
        Flexible(child: _buildContent(model)),
        // _buildDataSecurity(model),
      ],
    );
  }

  // 没有团队时 整体页面
  Widget _buildNoTeam(GlobalModel model) {
    return NestedScrollView(
        pinnedHeaderSliverHeightBuilder: () {
          return ScreenData.navigationBarHeight;
        },
        headerSliverBuilder: (BuildContext context, bool i) {
          return [
            SliverAppBar(
              elevation: 0.5,
              title: Text(
                'Cobiz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              expandedHeight: 280,
              actions: [
                InkWell(
                  child: Container(
                    child: ImageView(
                      img: 'assets/images/ic_add_white.png',
                    ),
                  ),
                  onTap: () {
                    routePush(AddFriendPage());
                  },
                )
              ],
              pinned: true,
              floating: false,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildNoTeamHeader(model),
              ),
            )
          ];
        },
        body: MyContactPage(false));
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final model = Provider.of<GlobalModel>(context, listen: false);
    return Scaffold(
      appBar: hasTeam
          ? ComMomBar(
              automaticallyImplyLeading: false,
              titleW: InkWell(
                onTap: () async {
                  routePush(TeamInfoPage(
                    teamId: _team.id,
                    outName: _team?.name,
                  )).then((value) {
                    if (value == true) {
                      _isLoading = false;
                      _isDeptLoading = true;
                      _isGroupLoading = true;
                      _team = null;
                      if (mounted) {
                        setState(() {});
                      }
                      _init();
                    } else {
                      if (value is List && value[0] == 'upTeamName') {
                        if (value[1] != null && value[1] != '') {
                          if (mounted) {
                            setState(() {
                              _team?.name = value[1];
                            });
                          }
                        }
                      }
                    }
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Text(
                      _team?.name ?? '...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    Icon(Icons.navigate_next, color: Colors.white)
                  ],
                ),
              ),
              elevation: 0,
              centerTitle: false,
              mainColor: AppColors.white,
              backgroundColor: AppColors.mainColor,
              rightDMActions: [_buildPopMenu()],
            )
          : null,
      body: _isLoading
          ? (hasTeam ? _buildHasTeam(model) : _buildNoTeam(model))
          : buildProgressIndicator(),
    );
  }
}
