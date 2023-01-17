import 'package:cobiz_client/http/res/team_model/team_group.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/pages/team/group/create_group.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;

class MyGroupPage extends StatefulWidget {
  final int teamId;

  const MyGroupPage({
    Key key,
    this.teamId,
  }) : super(key: key);

  @override
  _MyGroupPageState createState() => _MyGroupPageState();
}

class _MyGroupPageState extends State<MyGroupPage> {
  bool _isLoading = true;
  List<TeamGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _getGroups();
    eventBus.on(EVENT_UPDATE_TEAM_GROUP, _upTG);
  }

  @override
  void dispose() {
    eventBus.off(EVENT_UPDATE_TEAM_GROUP, _upTG);
    super.dispose();
  }

  _upTG(arg) {
    if (arg == true) {
      _getGroups();
    }
  }

  Future _getGroups() async {
    _getLocalGroup();
    final List<TeamGroup> groups =
        await teamApi.getTeamGroups(teamId: widget.teamId);
    if (groups != null) {
      _isLoading = true;
      _parseStores(groups);
      localStorage.updateLocalGroups(widget.teamId, groups);
    }
  }

  Future _getLocalGroup() async {
    _parseStores(await localStorage.getLocalGroups(widget.teamId));
  }

  void _parseStores(List<TeamGroup> stores) {
    _groups.clear();
    if ((stores?.length ?? 0) > 0) {
      stores.forEach((store) {
        _groups.add(store);
      });
    }
    if (mounted && _isLoading == true)
      setState(() {
        _isLoading = false;
      });
  }

  Widget _buildContent() {
    List<Widget> items = [];
    if (_groups.isEmpty) {
      items.add(buildDefaultNoContent(context));
    } else {
      items.addAll(_groups.map((group) {
        String hint = group.manager == true
            ? S.of(context).myCreated
            : S.of(context).myJoined;
        return ShadowCardView(
          margin: EdgeInsets.only(bottom: 15.0, left: 15, right: 15),
          padding: EdgeInsets.all(0.0),
          radius: 8.0,
          blurRadius: 3.0,
          child: ListRowView(
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
                    group.name,
                    maxLines: 1,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                  padding: EdgeInsets.only(right: 8.0),
                ),
                Expanded(
                  child: Text(
                    '${group.number} ${S.of(context).personUnit}',
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
            // widgetRt1: ImageView(img: chatImage),
            onPressed: () async {
              routePush(GroupChatPage(
                groupId: group.chatId,
                groupName: group.name,
                groupAvatar: [],
                groupNum: group.number,
                gType: 2,
                teamId: group.teamId,
                backCall: (v) {
                  if (v == true) {
                    _getGroups();
                  }
                },
              ));
            },
          ),
        );
      }));
    }
    // items.add(_buildOperate());
    return Column(
      children: items,
    );
  }

  void _searchGroup() {
    routeMaterialPush(SearchCommonPage(
      pageType: 11,
      data: _groups,
    ));
  }

  Future _createGroup() async {
    bool isC = await routePush(CreateGroupPage(
      teamId: widget.teamId,
    ));
    if (isC == true) {
      _isLoading = true;
      _getGroups();
    }
  }

  /// 顶部 + 号菜单 method
  // void _actionsHandle(PMenuItem item) async {
  //   switch (item.value) {
  //     case GroupActiveType.createGroup:
  //       _createGroup();
  //       break;
  //     case GroupActiveType.addGroup:
  //       _searchGroup();
  //       break;
  //   }
  // }

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
              title: S.of(context).myDiscussGroup,
              elevation: 0.5,
              rightDMActions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createGroup,
                )
              ],
              backData: true,
            ),
            body: ScrollConfiguration(
              behavior: MyBehavior(),
              child: ListView(
                children: <Widget>[
                  buildSearch(context,
                      onPressed: _isLoading ? () {} : _searchGroup, pb: 15.0),
                  _isLoading ? buildProgressIndicator() : _buildContent()
                ],
                padding: EdgeInsets.symmetric(
                  horizontal: 0.0,
                  vertical: 10.0,
                ),
              ),
            ),
            backgroundColor: Colors.white),
        onWillPop: _onWillPop);
  }
}

enum GroupActiveType {
  createGroup, // 创建小组
  addGroup, // 加入小组
}
