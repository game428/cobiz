import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/pages/work/ui/approval_process_view.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';

import '../ui/select_images_view.dart';
import '../../../domain/work_domain.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/work.dart' as workApi;

class ApplyGeneralPage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const ApplyGeneralPage({Key key, this.teamId, this.teamName})
      : super(key: key);

  @override
  _ApplyGeneralPageState createState() => _ApplyGeneralPageState();
}

class _ApplyGeneralPageState extends State<ApplyGeneralPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _detailController = TextEditingController();
  TextEditingController _msgController = TextEditingController();
  bool _isShowNameClear = false;
  bool _isShowDetailClear = false;
  // ignore: unused_field
  bool _isShowMsgClear = false;

  List<File> _images = List();

  List<TempMember> _approvers = List();
  List<TempMember> _copies = List();

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = _nameController.text.length > 0;
        });
      }
    });
    _detailController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowDetailClear = _detailController.text.length > 0;
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

  void _unfocusField() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future _dealSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_nameController.text.isEmpty) {
      return showToast(context, S.of(context).pApplicationContent);
    } else if (_approvers.length < 1) {
      return showToast(context, S.of(context).selectApprover);
    }
    Loading.before(context: context);
    List<String> img = [];
    List<int> approvers = [];
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
    //审批人
    if (_approvers.isNotEmpty) {
      _approvers.forEach((element) {
        approvers.add(element.userId);
      });
    }
    //抄送人
    if (_copies.isNotEmpty) {
      _copies.forEach((element) {
        copyTo.add(element.userId);
      });
    }
    bool res = await workApi.generalAdd(
        teamId: widget.teamId,
        title: _nameController.text,
        content: _detailController.text,
        images: img,
        approvers: approvers,
        copyTo: copyTo,
        msg: _msgController.text);
    Loading.complete();
    if (res == true) {
      Navigator.pop(context, approvers[0] == API.userInfo.id);
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
              EditLineView(
                title: S.of(context).applyContent,
                hintText: S.of(context).pApplicationContent,
                textController: _nameController,
                isShowClear: _isShowNameClear,
                titleMaxOdds: 0.4,
                maxLen: 50,
              ),
              ListItemView(
                title: S.of(context).applyDetail,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pApplyDetail,
                top: 5.0,
                textAlign: TextAlign.left,
                textFieldLines: 3,
                textController: _detailController,
                isShowClear: _isShowDetailClear,
                maxLen: 200,
              ),
              SelectImagesView(
                images: _images,
                onPressed: _unfocusField,
                haveBorder: true,
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              ApprovalProcessView(
                approvers: _approvers,
                copies: _copies,
                teamId: widget.teamId,
                teamName: widget.teamName,
                margin: EdgeInsets.only(bottom: 10.0, left: 15.0, right: 15.0),
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
              //   textFieldLines: 3,
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
            title: S.of(context).generalApproval,
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
        ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _msgController.dispose();
    super.dispose();
  }
}
