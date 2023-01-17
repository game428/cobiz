import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/group.dart';
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//选好联系人之后 创建群聊页面
class CreateGroupNext extends StatefulWidget {
  final List<ContactExtendIsSelected> list;
  final int whereCreate; //1:用户主页
  CreateGroupNext(this.list, {Key key, this.whereCreate}) : super(key: key);

  @override
  _CreateGroupNextState createState() => _CreateGroupNextState();
}

class _CreateGroupNextState extends State<CreateGroupNext> {
  TextEditingController _controller = TextEditingController();
  Function onPressed;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.text.length > 0) {
        if (mounted) {
          setState(() {
            onPressed = _create;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            onPressed = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _create() async {
    Loading.before(context: context);
    List<int> members = [];
    List<String> names = [];
    widget.list.forEach((element) {
      members.add(element.userId);
      names.add(element.name);
    });
    GroupBase res = await createGroup(_controller.text, members);
    Loading.complete();
    if (res != null) {
      // ChannelManager.getInstance().addGroupChat(
      //     res.id,
      //     res.name,
      //     res.avatar,
      //     res.num,
      //     false,
      //     ChatStore(getOnlyId(), ChatType.GROUP.index + 1, API.userInfo.id,
      //         res.id, 101, json.encode({'names': names, 'ids': members}),
      //         state: 2, time: DateTime.now().millisecondsSinceEpoch));
      Navigator.pop(context);
      if (widget.whereCreate == 1) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
      if (widget.whereCreate == 2) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      }
      if (widget.whereCreate == 3) {
        Navigator.pop(context);
      }
      routePushReplace(GroupChatPage(
        groupId: res.id,
        groupName: res.name,
        groupAvatar: res.avatar,
        groupNum: res.num,
        gType: 0,
        teamId: 0,
      ));
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: ComMomBar(
          elevation: 0.5,
          title: S.of(context).newGroup,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).create,
              textStyle: TextStyles.textF14T2,
              color: AppColors.mainColor,
              onPressed: onPressed,
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            EditLineView(
              title: '${S.of(context).groupChatName}:',
              hintText: S.of(context).plzFillGroupName,
              textController: _controller,
              maxLen: 20,
              titleMaxOdds: 0.35,
              autofocus: true,
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: widget.list == null ? 0 : widget.list.length,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      return ListItemView(
                        iconWidget: ImageView(
                          img: cuttingAvatar(widget.list[index].avatarUrl),
                          width: 42.0,
                          height: 42.0,
                          needLoad: true,
                          isRadius: 21.0,
                          fit: BoxFit.cover,
                        ),
                        title: widget.list[index].name,
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
