import 'package:cobiz_client/pages/work/ui/approval_ui_view.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/picker/date_time_picker.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;
import '../../../domain/work_domain.dart';

class IssueMeetingPage extends StatefulWidget {
  final int teamId;
  final int type; // 1 新增， 2 编辑
  final String teamName;

  const IssueMeetingPage({Key key, this.type, this.teamId, this.teamName})
      : super(key: key);

  @override
  _IssueMeetingPageState createState() => _IssueMeetingPageState();
}

class _IssueMeetingPageState extends State<IssueMeetingPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _isShowTitleClear = false;
  bool _isShowContentClear = false;

  List<TempMember> _participants = List();

  List<TempMember> _hostList = List();

  DateTime _beginTime;
  String _beginTimeStr = '';
  DateTime _endTime;
  String _endTimeStr = '';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _titleController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowTitleClear = _titleController.text.length > 0;
        });
      }
    });
    _contentController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowContentClear = _contentController.text.length > 0;
        });
      }
    });
  }

  // 选择时间
  void _selectTime(bool isBeginControl) {
    FocusScope.of(context).requestFocus(FocusNode());
    showDateTimePicker(
        context,
        DateTimePicker(
          loopings: ([false, true, true, true, true]),
          isNumberMonth: true,
          dateType: DateTimePickerType.kYMDHM,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          yearSuffix: S.of(context).yearSuffix,
          monthSuffix: S.of(context).monthSuffix,
          daySuffix: S.of(context).daySuffix,
          strAMPM: [S.of(context).morning, S.of(context).afternoon],
          onConfirm: (time, selecteds) {
            String str = '${time.year}-${DateTimePicker.intToStr(time.month)}-'
                '${DateTimePicker.intToStr(time.day)} '
                '${DateTimePicker.intToStr(time.hour)}:'
                '${DateTimePicker.intToStr(time.minute)}';
            DateTime tmp = DateTime.parse('$str:00');
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

  // 计算时间
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
  }

  // 完成
  Future _dealSubmit() async {
    if (_titleController.text.isEmpty) {
      return showToast(context, S.of(context).pEnterMeetingTitle);
    }

    if (_contentController.text.isEmpty) {
      return showToast(context, S.of(context).pEnterMeetingContent);
    }

    if (_beginTimeStr.isEmpty) {
      return showToast(context, S.of(context).selectStartTime);
    }

    if (_endTimeStr.isEmpty) {
      return showToast(context, S.of(context).selectEndTime);
    }

    // 参与人员
    if (_participants.isEmpty) {
      return showToast(context, S.of(context).seletctParticipants);
    }

    Loading.before(context: context);

    List<int> participants = [];
    _participants.forEach((element) {
      participants.add(element.userId);
    });

    List<int> hostIds = [];
    if (_hostList.isNotEmpty) {
      _hostList.forEach((element) {
        hostIds.add(element.userId);
      });
    }
    bool res = await workApi.meetingAdd(
      teamId: widget.teamId,
      title: _titleController.text,
      content: _contentController.text,
      beginAt: _beginTimeStr,
      endAt: _endTimeStr,
      approvers: hostIds,
      copyTo: participants,
    );
    Loading.complete();
    if (res == true) {
      eventBus.emit('update_work_meeting', true);
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
                title: S.of(context).meetingTitle,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pEnterMeetingTitle,
                top: 5.0,
                textAlign: TextAlign.left,
                textFieldLines: 3,
                textController: _titleController,
                isShowClear: _isShowTitleClear,
                maxLen: 30,
              ),
              ListItemView(
                title: S.of(context).meetingDes,
                haveBorder: false,
              ),
              EditLineView(
                minHeight: 40.0,
                hintText: S.of(context).pEnterMeetingContent,
                top: 5.0,
                textAlign: TextAlign.left,
                textController: _contentController,
                isShowClear: _isShowContentClear,
                maxLen: 500,
                textFieldLines: 5,
                showMaxLen: true,
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 15.0, top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 5.0, color: greyECColor),
                  ),
                ),
                child: ApprovalItemView(
                  type: 5,
                  members: _hostList,
                  teamId: widget.teamId,
                  teamName: widget.teamName,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 15.0, top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 5.0, color: greyECColor),
                  ),
                ),
                child: ApprovalItemView(
                  type: 4,
                  members: _participants,
                  teamId: widget.teamId,
                  teamName: widget.teamName,
                ),
              ),
            ],
          ),
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
        SizedBox(
          height: 50,
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
          title: S.of(context).meeting,
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
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
