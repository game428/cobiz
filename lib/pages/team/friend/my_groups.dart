import 'package:cobiz_client/http/group.dart' as groupApi;
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_avatar.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyGropusPage extends StatefulWidget {
  MyGropusPage({Key key}) : super(key: key);

  @override
  _MyGropusPageState createState() => _MyGropusPageState();
}

class _MyGropusPageState extends State<MyGropusPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SlidableController _slidableController = SlidableController();
  bool _isOk = false;
  List<MyGroup> _list = [];

  @override
  void initState() {
    super.initState();
    _getData();
    eventBus.on(EVENT_UPDATE_TEAM_GROUP, _eventF);
  }

  _eventF(v) {
    if (v == true || v == 'cancel_save') {
      _getData();
    }
  }

  @override
  void dispose() {
    eventBus.off(EVENT_UPDATE_TEAM_GROUP, _eventF);
    _refreshController.dispose();
    super.dispose();
  }

  Future _getData() async {
    _list = await groupApi.getMyGroups();
    if (mounted) {
      setState(() {
        _isOk = true;
      });
    }
  }

  _delete(int groupID, int index) async {
    bool res = await groupApi.deleteMyGroup(groupID);
    if (res == true) {
      _list.removeAt(index);
      if (mounted) {
        setState(() {});
      }
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  _onLoading() async {
    await Future.delayed(Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).myGroups,
      ),
      body: _isOk
          ? SmartRefresher(
              physics: BouncingScrollPhysics(),
              controller: _refreshController,
              enablePullDown: false,
              enablePullUp: false,
              // onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _list.length > 0 ? _list.length : 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index == 0 && _list.length == 0) {
                    return buildDefaultNoContent(context);
                  } else {
                    return Slidable(
                      controller: _slidableController,
                      closeOnScroll: true,
                      child: ListItemView(
                        onPressed: () {
                          if (_slidableController.activeState != null) {
                            _slidableController.activeState.close();
                          }
                          routePush(GroupChatPage(
                            groupId: _list[index].groupId,
                            groupName: _list[index].name ?? '',
                            groupAvatar: _list[index].avatars,
                            groupNum: _list[index].num ?? 0,
                            gType: _list[index].gtype ?? 0,
                            teamId: _list[index].teamId ?? 0,
                          ));
                        },
                        msgUp: true,
                        titleWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                child: Text(
                              _list[index].name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            )),
                            ChatMsgShow.groupWidget2(_list[index].gtype ?? 0)
                          ],
                        ),
                        iconWidget: ClipOval(
                          child: GroupAvatar(
                              _list[index].avatars,
                              _list[index].name,
                              _list[index].avatars.length,
                              _list[index].gtype),
                        ),
                      ),
                      actionPane: SlidableScrollActionPane(),
                      secondaryActions: <Widget>[
                        SlideAction(
                          child: Text(
                            S.of(context).delete,
                            style: TextStyles.textF16T1,
                          ),
                          color: Colors.red,
                          closeOnTap: true,
                          onTap: () {
                            _delete(_list[index].groupId, index);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            )
          : Center(
              child: CupertinoActivityIndicator(),
            ),
    );
  }
}
