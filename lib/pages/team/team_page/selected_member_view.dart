import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class SelectedMemberView extends StatefulWidget {
  final List<Map> selectUser;
  final Set<int> memberIds;

  const SelectedMemberView({Key key, this.selectUser, @required this.memberIds})
      : super(key: key);

  @override
  _SelectedMemberViewState createState() => _SelectedMemberViewState();
}

class _SelectedMemberViewState extends State<SelectedMemberView> {
  List<Map> _selectUser = List();
  Set<int> _memberIds = Set();

  @override
  void initState() {
    super.initState();
    // _selectUser = widget.selectUser;
    // _memberIds = widget.memberIds;
    _selectUser.addAll(widget.selectUser);
    _memberIds.addAll(widget.memberIds);
  }

  void _delete(Map user) {
    _selectUser.remove(user);
    _memberIds.remove(user['userId']);
    if (mounted) setState(() {});
  }

  void _submit() {
    Navigator.pop(context, _memberIds);
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
            buildSureBtn(
              text: S.of(context).ok,
              textStyle: TextStyles.textF14T2,
              color: AppColors.mainColor,
              onPressed: _submit,
            ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: _selectUser.map((user) {
              return ListItemView(
                iconWidget: ImageView(
                  img: cuttingAvatar(user['avatar']),
                  width: 42.0,
                  height: 42.0,
                  needLoad: true,
                  isRadius: 21.0,
                  fit: BoxFit.cover,
                ),
                title: user['name'],
                widgetRt1: InkWell(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.0,
                      vertical: 5.0,
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Color(0xFFBCBCBC),
                    ),
                  ),
                  onTap: () => _delete(user),
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
