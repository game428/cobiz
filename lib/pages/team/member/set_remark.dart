import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetRemark extends StatefulWidget {
  final String remarkName;
  final String desContent;
  SetRemark({Key key, this.remarkName, this.desContent}) : super(key: key);

  @override
  _SetRemarkState createState() => _SetRemarkState();
}

class _SetRemarkState extends State<SetRemark> {
  TextEditingController _nameController;
  TextEditingController _desController;
  bool isChange = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.remarkName);
    _desController = TextEditingController(text: widget.desContent);
    _nameController.addListener(() {
      if (_nameController.text.length > 0 &&
              _nameController.text != widget.remarkName ||
          (_desController.text.length > 0 &&
              _desController.text != widget.desContent)) {
        isChange = true;
      } else {
        isChange = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
    _desController.addListener(() {
      if (_desController.text.length > 0 &&
              _desController.text != widget.desContent ||
          (_nameController.text.length > 0 &&
              _nameController.text != widget.remarkName)) {
        isChange = true;
      } else {
        isChange = false;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
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
          title: S.of(context).remark,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).finish,
              textStyle: isChange ? TextStyles.textF14T2 : TextStyles.textF14T1,
              color: isChange ? AppColors.mainColor : greyECColor,
              onPressed: () async {
                // if (!isChange) return;
                // String name = _controller.text;
                // Loading.before(context: context);
                // bool state = await modifyName(widget.groupId, name);
                // Loading.complete();
                // if (state == true) {
                //   Navigator.pop(context, name);
                // }
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            EditLineView(
              title: '${S.of(context).remark}:',
              hintText: S.of(context).remarkHintText,
              textController: _nameController,
              maxLen: 15,
              autofocus: true,
            ),
            EditLineView(
              title: '${S.of(context).description}:',
              hintText: S.of(context).plzEnterDes,
              textController: _desController,
              maxLen: 30,
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
