import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/team_member.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/team/member/team_member_info.dart';
import 'package:cobiz_client/pages/team/team_page/edit_member.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'add_member.dart';
import 'member_verify.dart';

class TeamMembersPage extends StatefulWidget {
  final TeamInfo teamInfo;
  final bool newApply;
  const TeamMembersPage({Key key, @required this.teamInfo, this.newApply})
      : super(key: key);

  @override
  _TeamMembersPageState createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;

  List<TeamMemberExtend> _members = List();
  double _suspensionHeight = 30;
  double _itemHeight = 64.4; // 56.3
  String _suspensionTag = '';
  bool isAdmin = false;

  bool _haveNewTeamMember = false; //是否有新的成员申请

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getData();
    _eventListner();
  }

  _eventListner() {
    _haveNewTeamMember = widget.newApply;
    eventBus.on(EVENT_UPDATE_TEAM_JOIN, _teamJoin);
  }

  _teamJoin(arg) {
    if (arg == widget.teamInfo.id && _haveNewTeamMember == false) {
      if (mounted) {
        setState(() {
          _haveNewTeamMember = true;
        });
      }
    }
  }

  @override
  void dispose() {
    eventBus.off(EVENT_UPDATE_TEAM_JOIN, _teamJoin);
    super.dispose();
  }

  Future _getData() async {
    isAdmin = widget.teamInfo.creator == API.userInfo.id ||
        widget.teamInfo.managers.containsKey(API.userInfo.id.toString());
    _localMember();
    List<TeamMember> res =
        await teamApi.getTeamMembers(teamId: widget.teamInfo.id, type: 1);
    if (res != null) {
      _parseStores(
          await localStorage.updateLocalMembers(widget.teamInfo.id, res));
    }
  }

  //本地成员数据
  Future _localMember() async {
    _parseStores(await localStorage.getLocalMembers(widget.teamInfo.id));
  }

  void _parseStores(List<TeamMember> stores) {
    _members.clear();
    if ((stores?.length ?? 0) > 0) {
      stores.forEach((store) {
        _members.add(TeamMemberExtend(member: store, teamId: store.teamId));
      });
      _handleList();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleList() {
    if (_members == null || _members.isEmpty) return;
    for (int i = 0, length = _members.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_members[i].member.name);
      String tag =
          strNoEmpty(pinyin) ? pinyin.substring(0, 1).toUpperCase() : '';
      _members[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        _members[i].tagIndex = tag;
      } else {
        _members[i].tagIndex = "#";
      }
    }
    SuspensionUtil.sortListBySuspensionTag(_members);
    _suspensionTag = _members[0].tagIndex;
  }

  void _onSusTagChanged(String tag) {
    if (mounted) {
      setState(() {
        _suspensionTag = tag;
      });
    }
  }

  Widget _buildSusWidget(String susTag, bool normal) {
    return Container(
      height: _suspensionHeight.toDouble(),
      margin: normal
          ? EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            )
          : null,
      padding: EdgeInsets.only(
        left: normal ? 15.0 : 30.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: greyBCColor),
        ),
        color: normal ? Colors.white : greyF6Color,
      ),
      child: Text(
        '$susTag',
        softWrap: false,
      ),
    );
  }

  void _editMember(int userId, String userName) async {
    if (userId == null) return;

    final result = await routePush(EditMemberPage(
      teamId: widget.teamInfo.id,
      teamName: widget.teamInfo.name,
      userId: userId,
      userName: userName,
      creatorId: widget.teamInfo.creator,
      manIds: widget.teamInfo.managers,
    ));
    if (result != null && result == true) {
      _getData();
    }
  }

  Widget _buildListItem(TeamMemberExtend model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag, true),
        ),
        ListItemView(
          title: '${model.member.name}',
          iconWidget: ImageView(
            img: cuttingAvatar(model.member.avatar),
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
              children:
                  identity(context, model.member.manager, model.member.leader),
            ),
          ),
          widgetRt1: isAdmin
              ? InkWell(
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
                      child: ImageView(
                        img: 'assets/images/ic_edit.png',
                      )),
                  onTap: () =>
                      _editMember(model.member.userId, model.member.name),
                )
              : null,
          onPressed: () {
            routePush(TeamMemberInfo(
                    teamId: model.teamId,
                    userId: model.member.userId,
                    isCanEdit: isAdmin,
                    fromWhere: 3))
                .then((value) {
              if (value == true) {
                _getData();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    if (!isAdmin) {
      return SizedBox(
        height: 0.0,
      );
    }
    return Column(
      children: [
        OperateLineView(
          icon: 'assets/images/team/new_member.png',
          iconLeft: 0.0,
          title: S.of(context).teamMemberVerify,
          spaceSize: 15.0,
          rightWidget: _haveNewTeamMember ? buildMessaged() : null,
          onPressed: () async {
            bool change = await routePush(MemberVerifyPage(
              teamId: widget.teamInfo.id,
              teamName: widget.teamInfo.name,
              teamCode: widget.teamInfo.code,
            ));
            if (mounted && _haveNewTeamMember) {
              eventBus.emit(EVENT_UPDATE_TEAM_JOIN, false);
              setState(() {
                _haveNewTeamMember = false;
              });
            }
            if (change == true) {
              _getData();
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [
      buildSearch(context, onPressed: () {
        routeMaterialPush(
                SearchCommonPage(pageType: 9, data: _members, isAdmin: isAdmin))
            .then((value) {
          if (value == true) {
            _getData();
          }
        });
      }, pb: isAdmin ? 0 : 5)
    ];
    items.add(Expanded(
      child: AzListView(
        data: _members,
        header: AzListViewHeader(
            tag: '+',
            height: isAdmin ? 57 : 0,
            builder: (context) {
              return _buildHeader();
            }),
        itemBuilder: (context, model) => _buildListItem(model),
        suspensionWidget: _buildSusWidget(_suspensionTag, false),
        isUseRealIndex: true,
        curTag: _suspensionTag,
        itemHeight: _itemHeight,
        suspensionHeight: _suspensionHeight,
        onSusTagChanged: _onSusTagChanged,
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            decoration:
                BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: Text(hint,
                style: TextStyle(color: Colors.white, fontSize: 30.0)),
          );
        },
      ),
    ));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget rWidget = _isLoading
        ? Container()
        : InkWell(
            child: Container(
              child: ImageView(
                img: 'assets/images/ic_add.png',
              ),
            ),
            onTap: () {
              routePush(AddTeamMemberPage(
                      teamId: widget.teamInfo.id,
                      teamName: widget.teamInfo.name,
                      teamCode: widget.teamInfo.code,
                      isManager: isAdmin,
                      membersSum: _members.length ?? 0))
                  .then((value) {
                if (value != null && value == true) {
                  _getData();
                }
              });
            },
          );

    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).teamMembers,
        elevation: 0.5,
        rightDMActions: <Widget>[rWidget],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: _isLoading
            ? buildProgressIndicator()
            : Column(
                children: _buildContent(),
              ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
