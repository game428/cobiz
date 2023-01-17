import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/pages/work/ui/select_images_view.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/picker/date_time_picker.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import '../../../domain/work_domain.dart';
import '../ui/approval_process_view.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/work.dart' as workApi;

class ApplyLeavePage extends StatefulWidget {
  final int value;
  final List types;
  final int teamId;
  final String teamName;

  const ApplyLeavePage(
      {Key key,
      this.value = 0,
      @required this.types,
      this.teamId,
      this.teamName})
      : super(key: key);

  @override
  _ApplyLeavePageState createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  // TextEditingController _durationController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _msgController = TextEditingController();
  // bool _isShowDurationClear = false;
  bool _isShowReasonClear = false;
  // ignore: unused_field
  bool _isShowMsgClear = false;

  int _leaveType = 0;
  String _leaveTypeStr = '';
  DateTime _beginTime;
  String _beginTimeStr = '';
  DateTime _endTime;
  String _endTimeStr = '';
  String _timeUnit = '';
  List<File> _images = List();

  List<TempMember> _approvers = List(); //审批人
  List<TempMember> _copies = List(); //抄送人

  @override
  void initState() {
    super.initState();
    if (widget.value > 0) {
      for (int i = 0; i < widget.types.length; i++) {
        if (widget.types[i]['value'] == widget.value) {
          _leaveType = widget.value;
          _leaveTypeStr = widget.types[i]['text'];
          break;
        }
      }
    }
    _initController();
  }

  void _initController() {
    // _durationController.addListener(() {
    //   if (mounted) {
    //     setState(() {
    //       _isShowDurationClear = _durationController.text.length > 0;
    //     });
    //   }
    // });
    _reasonController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowReasonClear = _reasonController.text.length > 0;
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

  void _switchLeaveType(int value, String text) {
    _leaveType = value;
    _leaveTypeStr = text;
    _beginTime = null;
    _beginTimeStr = '';
    _endTime = null;
    _endTimeStr = '';
    if ([1, 2, 3, 10].contains(value)) {
      _timeUnit = S.of(context).hour;
    } else {
      _timeUnit = S.of(context).day;
    }
    if (mounted) setState(() {});
  }

  void _selectLeaveType() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDataPicker(
        context,
        DataPicker(
          jsonData: widget.types,
          isArray: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selecteds) {
            _switchLeaveType(values[0].value, values[0].text);
          },
        ));
  }

  void _calDuration(bool isBeginControl) {
    if (_beginTime == null || _endTime == null) {
      return;
    } else if (_beginTime.isAfter(_endTime) ||
        _beginTime.isAtSameMomentAs(_endTime)) {
      if (mounted) {
        setState(() {
          if (isBeginControl) {
            _endTime = null;
            _endTimeStr = '';
          } else {
            _beginTime = null;
            _beginTimeStr = '';
          }
        });
      }
      return;
    }
    // TODO 计算时长算法待优化, 且还没计算节假日
    // int count = 0;
    // if ([4, 8].contains(_leaveType)) {
    // } else if ([5, 6, 7, 9].contains(_leaveType)) {
    //   int begin = _beginTime.millisecondsSinceEpoch;
    //   int end = _endTime.millisecondsSinceEpoch;
    //   DateTime tmp;
    //   while (begin <= end) {
    //     tmp = DateTime.fromMillisecondsSinceEpoch(begin);
    //     if (tmp.weekday >= 1 && tmp.weekday <= 5) {
    //       count++;
    //     }
    //     begin += 24 * 3600 * 1000;
    //   }
    //   _durationController.text = '$count';
    // } else {}
  }

  void _selectTime(bool isBeginControl) {
    FocusScope.of(context).requestFocus(FocusNode());
    showDateTimePicker(
        context,
        DateTimePicker(
          loopings: ([1, 2, 3, 10].contains(_leaveType)
              ? [false, true, true, true, true]
              : [false, true, true]),
          isNumberMonth: true,
          dateType: ([1, 2, 3, 10].contains(_leaveType)
              ? DateTimePickerType.kYMDHM
              : DateTimePickerType.kYMD),
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          yearSuffix: S.of(context).yearSuffix,
          monthSuffix: S.of(context).monthSuffix,
          daySuffix: S.of(context).daySuffix,
          strAMPM: [S.of(context).morning, S.of(context).afternoon],
          onConfirm: (time, selecteds) {
            String str;
            DateTime tmp;
            if ([1, 2, 3, 10].contains(_leaveType)) {
              str = '${time.year}-${DateTimePicker.intToStr(time.month)}-'
                  '${DateTimePicker.intToStr(time.day)} '
                  '${DateTimePicker.intToStr(time.hour)}:'
                  '${DateTimePicker.intToStr(time.minute)}';
              tmp = DateTime.parse('$str:00');
            } else {
              str = '${time.year}-${DateTimePicker.intToStr(time.month)}-'
                  '${DateTimePicker.intToStr(time.day)}';
              tmp = DateTime.parse('$str 00:00:00');
            }
            if (isBeginControl) {
              _beginTime = tmp;
              _beginTimeStr = str;
            } else {
              _endTime = tmp;
              _endTimeStr = str;
            }
            if (mounted) setState(() {});

            _calDuration(isBeginControl);
          },
        ));
  }

  Future _dealSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_beginTime == null) {
      return showToast(context, S.of(context).selectStartTime);
    } else if (_endTime == null) {
      return showToast(context, S.of(context).selectEndTime);
    } else if (_reasonController.text.isEmpty) {
      return showToast(context, S.of(context).pEnterreasonForLeave);
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
    bool res = await workApi.leaveAdd(
        teamId: widget.teamId,
        type: _leaveType,
        beginAt: _beginTimeStr,
        endAt: _endTimeStr,
        reason: _reasonController.text,
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
    if (_timeUnit.isEmpty) {
      _switchLeaveType(_leaveType, _leaveTypeStr);
    }
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
                title: S.of(context).typeOfLeave,
                text: _leaveTypeStr,
                haveArrow: true,
                onPressed: _selectLeaveType,
              ),
              EditLineView(
                title: S.of(context).beginTime,
                text: _beginTimeStr,
                haveArrow: true,
                titleMaxOdds: 0.4,
                onPressed: () => _selectTime(true),
              ),
              EditLineView(
                title: S.of(context).endTime,
                text: _endTimeStr,
                haveArrow: true,
                titleMaxOdds: 0.4,
                onPressed: () => _selectTime(false),
              ),
              // EditLineView(
              //   title: S.of(context).duration(_timeUnit),
              //   hintText: S.of(context).pEnterDuration,
              //   textController: _durationController,
              //   isShowClear: _isShowDurationClear,
              //   keyboardType: [4, 8].contains(_leaveType)
              //       ? TextInputType.numberWithOptions(decimal: true)
              //       : TextInputType.number,
              // ),
              ListItemView(
                title: S.of(context).reasonForLeave,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pEnterreasonForLeave,
                top: 5.0,
                textAlign: TextAlign.left,
                textFieldLines: 3,
                textController: _reasonController,
                isShowClear: _isShowReasonClear,
                maxLen: 100,
              ),
              SelectImagesView(
                images: _images,
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
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
        )
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
            title: S.of(context).leaveApplication,
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
    // _durationController.dispose();
    _reasonController.dispose();
    _msgController.dispose();
    super.dispose();
  }
}
