import 'package:cobiz_client/pages/work/ui/approval_ui_view.dart';
import 'package:cobiz_client/pages/work/ui/select_images_view.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';

import '../../../domain/work_domain.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/work.dart' as workApi;

class IssueReportPage extends StatefulWidget {
  final int type; // 1.日报 2.周报 3.月报
  final int teamId;
  final String teamName;

  const IssueReportPage({Key key, this.type, this.teamId, this.teamName})
      : super(key: key);

  @override
  _IssueReportPageState createState() => _IssueReportPageState();
}

class _IssueReportPageState extends State<IssueReportPage> {
  TextEditingController _finishController = TextEditingController();
  TextEditingController _undoneController = TextEditingController();
  TextEditingController _needsController = TextEditingController();
  TextEditingController _msgController = TextEditingController();
  bool _isShowFinishClear = false;
  bool _isShowUndoneClear = false;
  bool _isShowNeedsClear = false;
  // ignore: unused_field
  bool _isShowMsgClear = false;

  List<File> _images = List();
  List<TempMember> _copies = List();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _finishController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowFinishClear = _finishController.text.length > 0;
        });
      }
    });
    _undoneController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowUndoneClear = _undoneController.text.length > 0;
        });
      }
    });
    _needsController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNeedsClear = _needsController.text.length > 0;
        });
      }
    });
    _msgController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowMsgClear = _msgController.text.length > 0;
        });
      }
    });
  }

  Future _dealSubmit() async {
    if (_finishController.text.isEmpty &&
        _undoneController.text.isEmpty &&
        _needsController.text.isEmpty) {
      return showToast(context, S.of(context).fillWorkReport);
    }
    if (_copies.isEmpty) {
      return showToast(context, S.of(context).seletctCopyTo);
    }
    Loading.before(context: context);
    List<String> img = [];
    List<int> copyTo = [];
    //图片
    if (_images.isNotEmpty) {
      Set<String> paths = Set();
      _images.forEach((element) {
        paths.add(element.path);
      });
      Map<String, String> result =
          await commonApi.uploadFilesCompressMap(paths, bucket: 5);
      if (result == null || result.length < 1)
        return showToast(context, S.of(context).imageUploadFailed);
      result.forEach((key, value) {
        img.add(value);
      });
    }
    //抄送人
    if (_copies.isNotEmpty) {
      _copies.forEach((element) {
        copyTo.add(element.userId);
      });
    }
    bool res = await workApi.worklogAdd(
        teamId: widget.teamId,
        type: widget.type,
        finished: _finishController.text,
        pending: _undoneController.text,
        needed: _needsController.text,
        images: img,
        copyTo: copyTo,
        msg: _msgController.text);
    Loading.complete();
    if (res == true) {
      eventBus.emit('update_work_log', true);
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 5.0, color: greyECColor),
            ),
          ),
          child: Column(
            children: <Widget>[
              ListItemView(
                title: S.of(context).workDone,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pEnterCompletedWork,
                top: 5.0,
                textAlign: TextAlign.left,
                textFieldLines: 3,
                textController: _finishController,
                isShowClear: _isShowFinishClear,
                maxLen: 200,
              ),
              ListItemView(
                title: S.of(context).unfinishedWork,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pEnterUnfinished,
                top: 5.0,
                textAlign: TextAlign.left,
                textFieldLines: 3,
                textController: _undoneController,
                isShowClear: _isShowUndoneClear,
                maxLen: 200,
              ),
              ListItemView(
                title: S.of(context).coordinate,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pEnterCoordinated,
                top: 5.0,
                textAlign: TextAlign.left,
                textFieldLines: 3,
                textController: _needsController,
                isShowClear: _isShowNeedsClear,
                maxLen: 200,
                haveBorder: false,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 5.0, color: greyECColor),
            ),
          ),
          child: Column(
            children: <Widget>[
              SelectImagesView(
                images: _images,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              // EditLineView(
              //   title: S.of(context).sendToGroupChat,
              //   text: _groupChat,
              //   haveArrow: true,
              //   haveBorder: false,
              //   onPressed: () {},
              // ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 15.0, top: 10),
                child: ApprovalItemView(
                  type: 2,
                  members: _copies,
                  teamId: widget.teamId,
                  teamName: widget.teamName,
                ),
              ),
              // ListItemView(
              //   title: S.of(context).leaveAMessage,
              //   haveBorder: false,
              // ),
              // EditLineView(
              //   minHeight: 40.0,
              //   hintText: S.of(context).pEnterMessage,
              //   top: 5.0,
              //   textAlign: TextAlign.left,
              //   textFieldLines: 2,
              //   textController: _msgController,
              //   isShowClear: _isShowMsgClear,
              //   maxLen: 50,
              // ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: ComMomBar(
          title: (widget.type == 2
              ? S.of(context).weekly
              : (widget.type == 3
                  ? S.of(context).monthlyReport
                  : S.of(context).daily)),
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
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            children: <Widget>[
              _buildColumn(),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _finishController.dispose();
    _undoneController.dispose();
    _needsController.dispose();
    _msgController.dispose();
    super.dispose();
  }
}
