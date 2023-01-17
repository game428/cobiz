import 'package:cobiz_client/tools/cobiz.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

//拒绝同意页面
class AgreeRefues extends StatefulWidget {
  final int type; //1:同意 2: 拒绝 4: 完成
  final int id;
  final int teamId;
  AgreeRefues(this.type, this.id, this.teamId, {Key key}) : super(key: key);

  @override
  _AgreeRefuesState createState() => _AgreeRefuesState();
}

class _AgreeRefuesState extends State<AgreeRefues> {
  TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textController?.dispose();
  }

  void _dealSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Loading.before(context: context);
    bool modifyRes = await workApi.modifyApprovalState(
        id: widget.id,
        teamId: widget.teamId,
        type: widget.type,
        msg: _textController.text ?? '');
    Loading.complete();
    if (modifyRes == true) {
      // if (widget.type == 4) {
      //   WorkMsgStore workMsg = WorkMsgStore(widget.id, 1, logoId: 'mode_1_logoid_${widget.id}', sendTime: DateTime.now().millisecondsSinceEpoch, state: 1);
      //   await localStorage.updateLocalWorkMsg(workMsg, widget.teamId);
      // }
      Navigator.pop(context, true);
    } else {
      showToast(context, S.of(context).tryAgainLater);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: widget.type == 1
            ? S.of(context).confirmAgree
            : widget.type == 2
                ? S.of(context).confirmRefuse
                : S.of(context).confirmCompletion,
        elevation: 0.5,
        rightDMActions: <Widget>[
          buildSureBtn(
            text: S.of(context).finish,
            textStyle: TextStyles.textF14T2,
            color: AppColors.mainColor,
            onPressed: _dealSubmit,
          ),
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
            hintText: S.of(context).enterReason,
            isDense: true,
            contentPadding: EdgeInsets.all(5.0),
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          scrollPhysics: BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
