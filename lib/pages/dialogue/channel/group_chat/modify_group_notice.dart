import 'package:cobiz_client/http/group.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';

class ModifyGroupNotice extends StatefulWidget {
  final int groupId;
  final String groupNotice;
  ModifyGroupNotice({Key key, this.groupId, this.groupNotice})
      : super(key: key);

  @override
  _ModifyGroupNoticeState createState() => _ModifyGroupNoticeState();
}

class _ModifyGroupNoticeState extends State<ModifyGroupNotice> {
  TextEditingController _textController;
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.groupNotice);
    _textController.addListener(() {
      if (_textController.text.length > 0 &&
          _textController.text != widget.groupNotice) {
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
    super.dispose();
    _textController.dispose();
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
          title: S.of(context).groupAnnouncement,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).save,
              textStyle: isChange ? TextStyles.textF14T2 : TextStyles.textF14T1,
              color: isChange ? AppColors.mainColor : greyECColor,
              onPressed: () async {
                if (!isChange) return;
                String notice = _textController.text;
                Loading.before(context: context);
                bool state = await modifyNotice(widget.groupId, notice);
                Loading.complete();
                if (state == true) {
                  Navigator.pop(context, notice);
                }
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: ExtendedTextField(
            autofocus: true,
            controller: _textController,
            style: TextStyles.textF16,
            keyboardType: TextInputType.multiline,
            maxLength: 100,
            minLines: 3,
            maxLines: null,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 16.0),
              hintText: S.of(context).editAnnouncement,
              isDense: true,
              contentPadding: EdgeInsets.all(5.0),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            scrollPhysics: BouncingScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
