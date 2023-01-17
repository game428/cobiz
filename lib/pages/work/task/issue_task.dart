import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/pages/work/ui/approval_ui_view.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/picker/date_time_picker.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';

import '../../../domain/work_domain.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

class IssueTaskPage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const IssueTaskPage({Key key, this.teamId, this.teamName}) : super(key: key);

  @override
  _IssueTaskPageState createState() => _IssueTaskPageState();
}

class _IssueTaskPageState extends State<IssueTaskPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _detailController = TextEditingController();

  bool _isShowNameClear = false;
  bool _isShowDetailClear = false;

  DateTime _finishDate;
  String _finishDateStr = '';
  int _reminderTime;
  String _reminderTimeStr = '';

  List<TempMember> _copies = List();
  List<TempMember> _executor = List();

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
  }

  void _selectFinishTime() {
    showDateTimePicker(
        context,
        DateTimePicker(
          loopings: [false, true, true, true, true],
          isNumberMonth: true,
          dateType: DateTimePickerType.kYMDHM,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          yearSuffix: S.of(context).yearSuffix,
          monthSuffix: S.of(context).monthSuffix,
          daySuffix: S.of(context).daySuffix,
          onConfirm: (time, selecteds) {
            if (mounted) {
              setState(() {
                _finishDate = DateTime(
                    time.year, time.month, time.day, time.hour, time.minute, 0);
                _finishDateStr =
                    '${time.year}-${DateTimePicker.intToStr(time.month)}-'
                    '${DateTimePicker.intToStr(time.day)} '
                    '${DateTimePicker.intToStr(time.hour)}:'
                    '${DateTimePicker.intToStr(time.minute)}';
              });
            }
          },
        ));
  }

  List _loadReminderTimeData() {
    var reminderTimeData = [];
    reminderTimeData.add({'text': S.of(context).halfHourAgo, 'value': 30});
    for (int i = 1; i <= 24; i++) {
      reminderTimeData.add({
        'text':
            (i == 1 ? S.of(context).oneHourAgo : '$i${S.of(context).hoursAgo}'),
        'value': (i * 60)
      });
    }
    return reminderTimeData;
  }

  void _selectReminderTime() {
    var reminderTimeData = _loadReminderTimeData();
    showDataPicker(
        context,
        DataPicker(
          jsonData: reminderTimeData,
          isArray: true,
          looping: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selecteds) {
            if (mounted) {
              setState(() {
                _reminderTime = values[0].value;
                _reminderTimeStr = values[0].text;
              });
            }
          },
        ));
  }

  Future _dealSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_nameController.text.isEmpty) {
      return showToast(context, S.of(context).enterTaskName);
    } else if (_detailController.text.isEmpty) {
      return showToast(context, S.of(context).enterTaskDetail);
    } else if (_finishDate == null) {
      return showToast(context, S.of(context).selectCompletionTime);
    } else if (_executor.length < 1) {
      return showToast(context, S.of(context).selectExecutor);
    }
    Loading.before(context: context);
    List<int> executors = [];
    List<int> copyTo = [];
    //执行人
    if (_executor.isNotEmpty) {
      _executor.forEach((element) {
        executors.add(element.userId);
      });
    }
    //抄送人
    if (_copies.isNotEmpty) {
      _copies.forEach((element) {
        copyTo.add(element.userId);
      });
    }
    bool res = await workApi.taskAdd(
        teamId: widget.teamId,
        title: _nameController.text,
        content: _detailController.text,
        endAt: _finishDateStr,
        remind: _reminderTime,
        executors: executors,
        copyTo: copyTo);
    Loading.complete();
    if (res == true) {
      Navigator.pop(context, executors[0] == API.userInfo.id);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EditLineView(
          title: S.of(context).taskName,
          hintText: S.of(context).enterTaskName,
          textController: _nameController,
          isShowClear: _isShowNameClear,
          maxLen: 50,
        ),
        ListItemView(
          title: S.of(context).taskDetail,
          haveBorder: false,
        ),
        EditLineView(
          minHeight: 40.0,
          hintText: S.of(context).enterTaskDetail,
          top: 5.0,
          textAlign: TextAlign.left,
          textFieldLines: 3,
          textController: _detailController,
          isShowClear: _isShowDetailClear,
          maxLen: 200,
        ),
        EditLineView(
          title: S.of(context).finishTime,
          text: _finishDateStr,
          haveArrow: true,
          onPressed: _selectFinishTime,
          titleMaxOdds: 0.4,
        ),
        EditLineView(
          title: S.of(context).reminderTime,
          text: _reminderTimeStr,
          haveArrow: true,
          onPressed: _selectReminderTime,
          titleMaxOdds: 0.4,
        ),
        Container(
          padding:
              EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 10),
          child: ApprovalItemView(
            type: 3,
            members: _executor,
            teamId: widget.teamId,
            teamName: widget.teamName,
          ),
        ),
        Container(height: 8.0, color: AppColors.specialBgGray),
        Container(
          padding:
              EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 10),
          child: ApprovalItemView(
            type: 2,
            members: _copies,
            teamId: widget.teamId,
            teamName: widget.teamName,
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
            title: S.of(context).issueTask,
            elevation: 0.5,
            rightDMActions: <Widget>[
              buildSureBtn(
                text: S.of(context).publish,
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
    super.dispose();
  }
}
