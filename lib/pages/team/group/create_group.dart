import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import './select_group_members.dart';

//创建新的小组
class CreateGroupPage extends StatefulWidget {
  final int teamId;

  const CreateGroupPage({Key key, this.teamId}) : super(key: key);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  TextEditingController _nameController = TextEditingController();

  bool _isShowNameClear = false;
  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          if (_nameController.text.length > 0) {
            _isShowNameClear = true;
          } else {
            _isShowNameClear = false;
          }
        });
      }
    });
  }

  List<Widget> _buildColumn() {
    return <Widget>[
      buildTextTitle(
        S.of(context).groupName,
        top: 0.0,
      ),
      EditLineView(
        minHeight: 40.0,
        hintText: S.of(context).groupNameHint,
        top: 5.0,
        textAlign: TextAlign.left,
        maxLen: 30,
        textController: _nameController,
        autofocus: true,
        isShowClear: _isShowNameClear,
        margin: EdgeInsets.all(0),
      )
    ];
  }

  void _dealSubmit() async {
    if (!_isShowNameClear) {
      return;
    }
    Loading.before(context: context);
    var group = await teamApi.createTeamGroup(
        teamId: widget.teamId, name: _nameController.text);
    Loading.complete();
    if (group != null) {
      ChannelManager.getInstance().addGroupChat(
          group['chatId'],
          _nameController.text,
          [],
          1,
          2,
          widget.teamId,
          false,
          ChatStore(getOnlyId(), ChatType.GROUP.index + 1, API.userInfo.id,
              group['chatId'], 100, '',
              state: 2, time: DateTime.now().millisecondsSinceEpoch));
      var res = await routePush(SelectGroupMembersPage(
        groupId: group['id'],
        teamId: widget.teamId,
        memberList: [],
        showType: 1,
      ));
      Loading.before(context: context);
      bool addState = true;
      if (res != null && res['ids'].length > 0) {
        addState = await teamApi.tGroupMemDeal(
            teamId: widget.teamId,
            groupId: group['id'],
            add: true,
            memberIds: res['ids']);
      }
      Loading.complete();
      Navigator.pop(context, true);
      if (addState == false) {
        showToast(context, S.of(context).tryAgainLater);
      }
    } else {
      showToast(context, S.of(context).createTeamFailure);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: ComMomBar(
            title: S.of(context).createGroup,
            elevation: 0.5,
            rightDMActions: [
              buildSureBtn(
                text: S.of(context).save,
                textStyle: _isShowNameClear
                    ? TextStyles.textF14T2
                    : TextStyles.textF14T1,
                color: _isShowNameClear ? AppColors.mainColor : greyECColor,
                onPressed: _dealSubmit,
              )
            ],
          ),
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              children: <Widget>[
                ShadowCardView(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildColumn(),
                  ),
                )
              ],
            ),
          ),
          backgroundColor: Colors.white),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
