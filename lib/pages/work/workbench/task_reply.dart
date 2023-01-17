import 'dart:convert';

import 'package:cobiz_client/http/res/team_model/common_model.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_widget.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

class TaskReply extends StatefulWidget {
  final int teamId;
  final int id;
  final Comments curComment;
  final Map curMsg;
  TaskReply({Key key, this.teamId, this.id, this.curComment, this.curMsg})
      : super(key: key);

  @override
  _TaskReplyState createState() => _TaskReplyState();
}

class _TaskReplyState extends State<TaskReply> {
  TextEditingController _controller = TextEditingController();
  Comments _curComment;
  Map _curMsg = Map();
  bool isChange = false;
  bool _isReply = false;

  @override
  void initState() {
    super.initState();
    if (widget.curComment != null && widget.curMsg != null) {
      _curComment = widget.curComment;
      _curMsg = widget.curMsg;
      _isReply = true;
    } else {
      _isReply = false;
    }
    _controller.addListener(() {
      if (_controller.text.length > 0) {
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

  void _hideQuote() {
    if (mounted) {
      setState(() {
        _curComment = null;
        _curMsg = Map();
        _isReply = false;
      });
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
          title: S.of(context).comment,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).publish,
              textStyle: isChange ? TextStyles.textF14T2 : TextStyles.textF14T1,
              color: isChange ? AppColors.mainColor : greyECColor,
              onPressed: isChange
                  ? () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Loading.before(context: context);
                      String content;
                      if (_isReply) {
                        content = json.encode({
                          "msg": _controller.text,
                          "commentName": _curComment.name,
                          "commentMsg": _curMsg['msg'],
                          "commentUserId": _curComment.userId,
                        });
                      } else {
                        content = json.encode({"msg": _controller.text});
                      }
                      bool res = await workApi.replyTask(
                        teamId: widget.teamId,
                        id: widget.id,
                        content: content,
                      );
                      Loading.complete();
                      if (res == true) {
                        Navigator.pop(context, true);
                      } else {
                        showToast(context, S.of(context).replyFail);
                      }
                    }
                  : null,
            )
          ],
        ),
        body: Column(
          children: [
            ChatCommonWidget.quoteShow(
              _isReply,
              '${_curComment?.name ?? ""}：${_curMsg['msg'] ?? ""}',
              _hideQuote,
              bgColor: greyF6Color,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              child: ExtendedTextField(
                autofocus: true,
                controller: _controller,
                style: TextStyles.textF16,
                keyboardType: TextInputType.multiline,
                maxLength: 300,
                minLines: 5,
                maxLines: null,
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: 16.0),
                  hintText: S.of(context).entReply,
                  isDense: true,
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                scrollPhysics: BouncingScrollPhysics(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
