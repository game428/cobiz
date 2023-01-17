import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/group.dart' as groupApi;
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AtGroupUser extends StatefulWidget {
  final int groupId;
  AtGroupUser(this.groupId, {Key key}) : super(key: key);

  @override
  _AtGroupUserState createState() => _AtGroupUserState();
}

class _AtGroupUserState extends State<AtGroupUser> {
  GroupInfo _groupInfo;
  List<GroupMember> listGroupUser = [];
  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    _groupInfo = await groupApi.getGroup(widget.groupId);
    if (_groupInfo != null) {
      _groupInfo.members.forEach((element) {
        if (element.userId != API.userInfo.id) {
          listGroupUser.add(element);
        }
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).atTa,
      ),
      body: _groupInfo != null
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: listGroupUser.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                return ListItemView(
                  onPressed: () {
                    Navigator.pop(context, {
                      'nickname': listGroupUser[index].nickname,
                      'id': listGroupUser[index].userId
                    });
                  },
                  title: listGroupUser[index].nickname,
                  iconWidget: ImageView(
                    img: cuttingAvatar(listGroupUser[index].avatar),
                    width: 42.0,
                    height: 42.0,
                    needLoad: true,
                    isRadius: 21.0,
                    fit: BoxFit.cover,
                  ),
                );
              })
          : Center(
              child: CupertinoActivityIndicator(),
            ),
    );
  }
}
