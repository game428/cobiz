import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/pages/common/select_contact.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/del_member.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_info_page.dart';
import 'package:cobiz_client/pages/team/member/team_member_info.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/pages/team/group/select_group_members.dart';

class ChannelMemberBer extends StatefulWidget {
  final List<GroupMember> model;
  final bool isAdmin;
  final Function(dynamic) addCallback;
  final Function(dynamic) removeCallback;
  final int groupId;
  final int groupType;
  final GroupInfo groupInfo;

  ChannelMemberBer(
      {this.model,
      this.isAdmin = false,
      this.addCallback,
      this.groupId,
      this.groupType,
      this.groupInfo,
      this.removeCallback});

  @override
  _ChannelMemberBerState createState() => _ChannelMemberBerState();
}

class _ChannelMemberBerState extends State<ChannelMemberBer> {
  int _maxDisplayCount = 15;

  void onUserClick(GroupMember member) {
    if (member.userId == API.userInfo.id) {
      return;
    }
    if (widget.groupInfo.type == 0 || widget.groupInfo.teamId == 0) {
      routePush(SingleInfoPage(
        userId: member.userId,
        whereToInfo: 4,
      ));
    } else {
      routePush(TeamMemberInfo(
          teamId: widget.groupInfo.teamId,
          userId: member.userId,
          fromWhere: 4));
    }
  }

  //移除群成员
  void onRemoveUserClick() async {
    List<GroupMember> membersList = await routePush(DelMemberPage(
        widget.model, widget.groupId, widget.groupInfo, widget.groupType));
    if (membersList != null) {
      widget.removeCallback(membersList);
    }
  }

  //添加新的成员
  void onAddNewUserClick() async {
    List<int> ids = [];
    widget.model.forEach((element) {
      ids.add(element.userId);
    });
    if (widget.groupType == 0) {
      List<ContactExtendIsSelected> chooseList =
          await routePush(SelctContatPage(
        //跳转选择联系人页面
        joinFromWhere: 3,
        listGroupM: ids,
      ));
      if (chooseList != null) {
        List<int> addIds = List();
        chooseList.forEach((element) {
          addIds.add(element.userId);
        });
        widget.addCallback(addIds);
      }
    } else if (widget.groupType == 2) {
      var res = await routePush(SelectGroupMembersPage(
        groupId: widget.groupInfo.thirdId,
        teamId: widget.groupInfo.teamId,
        memberList: ids,
      ));
      if (res != null && res['ids'].length > 0) {
        bool addState = await teamApi.tGroupMemDeal(
            teamId: res['teamId'],
            groupId: res['groupId'],
            add: true,
            memberIds: res['ids']);
        widget.addCallback(addState);
      }
    }
  }

  Widget buildMemberItem(CustomThemeData theme, GroupMember member) {
    return new InkWell(
      child: new Container(
        width: 55.0,
        child: new Column(
          children: <Widget>[
            new ImageView(
              img: cuttingAvatar(member.avatar),
              width: 55.0,
              height: 55.0,
              fit: BoxFit.cover,
              isRadius: 27.5,
              needLoad: true,
            ),
            Container(
                alignment: Alignment.center,
                height: 30,
                child: Text(
                  member.nickname,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.textColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        ),
      ),
      onTap: () => onUserClick(member),
    );
  }

  List<Widget> buildMembers(CustomThemeData theme) {
    List<Widget> wrap = [];
    int i = 0;
    var model = widget.model;
    for (var member in model) {
      i++;
      if (i > _maxDisplayCount) {
        break;
      }
      // var member = 'model.getMember(id)';
      // if (member == null) {
      // }
      wrap.add(buildMemberItem(theme, member));
    }
    if (widget.isAdmin) {
      wrap.add(
        new InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: greyF6Color,
              borderRadius: BorderRadius.all(Radius.circular(55 / 2)),
            ),
            width: 55,
            height: 55,
            child: Icon(
              Icons.add,
              color: greyA0Color,
              size: 30,
            ),
          ),
          onTap: onAddNewUserClick,
        ),
      );

      wrap.add(
        new InkWell(
          child: Container(
            decoration: BoxDecoration(
              color: greyF6Color,
              borderRadius: BorderRadius.all(Radius.circular(55 / 2)),
            ),
            width: 55,
            height: 55,
            child: Icon(
              Icons.remove,
              color: greyA0Color,
              size: 30,
            ),
          ),
          onTap: onRemoveUserClick,
        ),
      );
    }
    return wrap;
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context, listen: false);

    return Container(
      color: Colors.white,
      width: winWidth(context),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: (winWidth(context) - 315) / 5,
            runSpacing: 10.0,
            children: buildMembers(model.currentTheme),
          ),
          widget.model.length <= _maxDisplayCount
              ? Container()
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(top: 10.0),
                  child: InkWell(
                    child: Text(
                      S.of(context).lookAllgGroupPeople,
                      textAlign: TextAlign.center,
                      style: TextStyles.textF16T4,
                    ),
                    onTap: () {
                      _maxDisplayCount = 10000;

                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                )
        ],
      ),
    );
  }
}
