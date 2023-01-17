import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class SelectedListView extends StatefulWidget {
  final List<TeamMemberSelected> members;

  const SelectedListView({Key key, @required this.members}) : super(key: key);

  @override
  _SelectedListViewState createState() => _SelectedListViewState();
}

class _SelectedListViewState extends State<SelectedListView> {
  List<TeamMemberSelected> _members = List();

  @override
  void initState() {
    super.initState();
    _members = widget.members;
  }

  void _delete(TeamMemberSelected members) {
    members.isSelected = false;
    _members.remove(members);
    if (mounted) setState(() {});
  }

  void _submit() {
    Navigator.pop(
        context,
        _members.map((member) {
          return member.userId;
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).select,
          elevation: 0.5,
          leadingW: SizedBox(
            width: 0.0,
          ),
          backgroundColor: Colors.white,
          rightDMActions: <Widget>[
            InkWell(
              child: Container(
                alignment: Alignment.center,
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onTap: _submit,
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: _members.map((member) {
              return ListItemView(
                icon: member.avatarUrl,
                title: member.name,
                widgetRt1: InkWell(
                  child: Icon(
                    Icons.cancel,
                    color: Color(0xFFBCBCBC),
                  ),
                  onTap: () => _delete(member),
                ),
              );
            }).toList(),
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
            ),
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
