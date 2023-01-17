import 'package:cobiz_client/http/group.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModifyGroupName extends StatefulWidget {
  final int groupId;
  final String groupName;
  ModifyGroupName({Key key, this.groupId, this.groupName}) : super(key: key);

  @override
  _ModifyGroupNameState createState() => _ModifyGroupNameState();
}

class _ModifyGroupNameState extends State<ModifyGroupName> {
  TextEditingController _controller;
  bool isChange = false;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.groupName);
    _controller.addListener(() {
      if (_controller.text.length > 0 && _controller.text != widget.groupName) {
        if (mounted) {
          setState(() {
            isChange = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isChange = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
          title: S.of(context).groupChatName,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).save,
              textStyle: isChange ? TextStyles.textF14T2 : TextStyles.textF14T1,
              color: isChange ? AppColors.mainColor : greyECColor,
              onPressed: () async {
                if (!isChange) return;
                String name = _controller.text;
                Loading.before(context: context);
                bool state = await modifyName(widget.groupId, name);
                Loading.complete();
                if (state == true) {
                  Navigator.pop(context, name);
                } else {
                  showToast(context, S.of(context).tryAgainLater);
                }
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            EditLineView(
              title: '${S.of(context).groupChatName}:',
              hintText: S.of(context).plzFillGroupName,
              textController: _controller,
              maxLen: 30,
              titleMaxOdds: 0.4,
              autofocus: true,
            ),
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
