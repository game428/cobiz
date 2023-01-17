import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_item_view.dart';

class InviteHistoryPage extends StatefulWidget {
  InviteHistoryPage({Key key}) : super(key: key);

  @override
  _InviteHistoryPageState createState() => _InviteHistoryPageState();
}

class _InviteHistoryPageState extends State<InviteHistoryPage> {
  Widget buildUser(item) {
    return ListItemView(
      title: item['name'],
      label: item['phone'],
      msgRt2: item['time'],
      iconWidget: ImageView(
        img: cuttingAvatar(item['avatar']),
        width: 42.0,
        height: 42.0,
        needLoad: true,
        isRadius: 21.0,
        fit: BoxFit.cover,
      ),
      msgUp: false,
    );
  }

  List<Widget> body() {
    List<Widget> list = [];
    List switchItems = [];
    if (switchItems.length > 0) {
      switchItems.forEach((element) {
        list.add(buildUser(element));
      });
    } else {
      list.add(buildDefaultNoContent(context));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).inviteHistory,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(children: body()),
      ),
    );
  }
}
