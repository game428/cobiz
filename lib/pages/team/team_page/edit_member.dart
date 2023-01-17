import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/http/res/team_model/member_detail_info.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/picker/date_time_picker.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';

import 'select_dept.dart';

class EditMemberPage extends StatefulWidget {
  final int teamId;
  final String teamName;
  final int userId;
  final String userName;
  final int deptId; // 上级部门Id
  final bool canBack;
  final Depts depts; //组织架构是否选中部门
  final bool isSupervisor; //是否是选中部门主管 depts不为null 该字段自然为true
  final int creatorId; //创建者id
  final Map<String, dynamic> manIds; //管理员
  final bool isFromTeamMember;

  const EditMemberPage(
      {Key key,
      this.teamId,
      this.teamName,
      this.userName,
      this.userId,
      this.deptId,
      this.canBack = true,
      this.depts,
      this.isSupervisor,
      this.creatorId,
      this.manIds,
      this.isFromTeamMember = false})
      : super(key: key);

  @override
  _EditMemberPageState createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  TextEditingController _nameController = TextEditingController(); //姓名
  TextEditingController _phoneController = TextEditingController(); //电话
  TextEditingController _titleController = TextEditingController(); //职位
  TextEditingController _noteController = TextEditingController(); //备注
  TextEditingController _numberController = TextEditingController(); //工号
  bool _isShowNameClear = false;
  bool _isShowPhoneClear = false;
  bool _isShowTitleClear = false;
  bool _isShowNoteClear = false;
  bool _isShowNumberClear = false;

  String _entryDateStr = '';
  DateTime _entryDate;

  bool _isInputFinish = false;

  bool _isLoadingOK = true;

  String _oldName = '';

  List<int> _deptIdList = List();
  List<String> _deptNameList = List();

  MemberDetailInfo memberDetailInfo;
  @override
  void initState() {
    super.initState();
    _initController();
    _loadInfo();
  }

  Future _loadInfo() async {
    memberDetailInfo = await teamApi.querySomebodyInfo(
        userId: widget.userId, teamId: widget.teamId);
    if (memberDetailInfo != null) {
      _oldName = widget.userName;
      _nameController.text = memberDetailInfo.name;
      if (widget.canBack == false) {
        _nameController.text = widget.userName;
      }
      _phoneController.text = memberDetailInfo.phone;
      _titleController.text = memberDetailInfo.position;
      _noteController.text = memberDetailInfo.remark;
      _numberController.text = memberDetailInfo.workNo;
      _entryDateStr = memberDetailInfo.entry;
      _deptIdList = memberDetailInfo.deptIds;
      _deptNameList = memberDetailInfo.deptNames;
    }
    _isLoadingOK = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _initController() {
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = _nameController.text.length > 0;
          _checkCanSub();
        });
      }
    });
    _phoneController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowPhoneClear = _phoneController.text.length > 0;
          _checkCanSub();
        });
      }
    });
    _titleController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowTitleClear = _titleController.text.length > 0;
          _checkCanSub();
        });
      }
    });
    _noteController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNoteClear = _noteController.text.length > 0;
          _checkCanSub();
        });
      }
    });
    _numberController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNumberClear = _numberController.text.length > 0;
          _checkCanSub();
        });
      }
    });
  }

  _checkCanSub() {
    if (_isShowNumberClear ||
        _isShowNameClear ||
        _isShowPhoneClear ||
        _isShowTitleClear ||
        _isShowNoteClear ||
        _entryDate != null) {
      _isInputFinish = true;
    } else {
      _isInputFinish = false;
    }
  }

  Future _dealSubmit() async {
    if (!_isInputFinish) {
      return;
    }
    if (_nameController.text.isEmpty) {
      return showToast(context, S.of(context).hintFullName);
    }
    Loading.before(context: context);
    var res = await teamApi.modifyTeamMember(
        teamId: widget.teamId,
        userId: widget.userId,
        name: _nameController.text,
        phone: _phoneController.text,
        position: _titleController.text,
        entry: _entryDateStr,
        remark: _noteController.text,
        workNo: _numberController.text,
        deptIds: _deptIdList,
        curDeptId: widget.depts == null ? 0 : widget.depts.id);
    Loading.complete();
    if (res == 0) {
      showToast(context, S.of(context).editOk);
      if (_oldName != _nameController.text ||
          _compareDeptId(memberDetailInfo.deptIds, _deptIdList)) {
        Navigator.pop(context, true);
      } else if (widget.isFromTeamMember == true) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
      }
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  //判断部门是否发生改变
  bool _compareDeptId(List<int> afterList, List<int> beforeList) {
    if (afterList.length != beforeList.length) {
      return true;
    } else {
      afterList.sort();
      beforeList.sort();
      bool isC = false;
      for (var i = 0; i < afterList.length; i++) {
        if (afterList[i] != beforeList[i]) {
          isC = true;
          break;
        }
      }
      return isC;
    }
  }

  void _unfocusField() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _selectDate() {
    _unfocusField();
    showDateTimePicker(
        context,
        DateTimePicker(
          loopings: [false, true, true],
          isNumberMonth: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          yearSuffix: S.of(context).yearSuffix,
          monthSuffix: S.of(context).monthSuffix,
          daySuffix: S.of(context).daySuffix,
          onConfirm: (time, selecteds) {
            if (mounted) {
              setState(() {
                _isInputFinish = true;
                _entryDate = time;
                _entryDateStr =
                    '${time.year}-${DateTimePicker.intToStr(time.month)}-'
                    '${DateTimePicker.intToStr(time.day)}';
              });
            }
          },
        ));
  }

  void _selectDept() async {
    Map<int, String> selectDepts = Map();
    for (var i = 0; i < _deptIdList.length; i++) {
      selectDepts[_deptIdList[i]] = _deptNameList[i];
    }
    final Map result = await routePush(SelectDepartmentPage(
      teamId: widget.teamId,
      teamName: widget.teamName,
      isMult: true,
      deptId: widget.deptId,
      selectDepts: selectDepts,
    ));
    if (result == null) return;
    if (mounted) {
      setState(() {
        _deptIdList = result['id'];
        _deptNameList = result['name'];
      });
    }
  }

  void _deleteMember() {
    showSureModal(
        context,
        S.of(context).deleteStaff,
        () async {
          if (widget.creatorId == widget.userId) {
            return showToast(context, S.of(context).deleteManage);
          } else {
            if (widget.manIds.containsKey(widget.userId.toString()) &&
                widget.creatorId != API.userInfo.id) {
              return showToast(context, S.of(context).deleteManage);
            }
          }
          Loading.before(context: context);
          var res = await teamApi.deleteTeamMember(
              teamId: widget.teamId, userId: widget.userId, deptId: 0);
          Loading.complete();
          if (res == 0) {
            if (widget.isFromTeamMember) {
              Navigator.pop(context, 'deleteMember');
            } else {
              Navigator.pop(context, true);
            }
          } else if (res == 3) {
            showToast(context, S.of(context).deleteManage);
          } else {
            showToast(context, S.of(context).tryAgainLater);
          }
        },
        promptText: S.of(context).memberDeleteConfirmContent,
        text2: widget.depts == null
            ? null
            : S.of(context).deleteFromDept(widget.depts.name),
        onPressed2: () async {
          if (widget.depts != null) {
            Loading.before(context: context);
            var res = await teamApi.deleteTeamMember(
                teamId: widget.teamId,
                userId: widget.userId,
                deptId: widget.depts.id);
            Loading.complete();
            if (res == 0) {
              Navigator.pop(context, true);
            } else {
              showToast(context, S.of(context).tryAgainLater);
            }
          }
        });
  }

  //底部按钮
  Widget _btn() {
    if (widget.canBack == false || widget.userId == API.userInfo.id) {
      return Container();
    } else {
      return buildCommonButton(S.of(context).delete,
          margin: EdgeInsets.only(top: 40, left: 15, right: 15),
          backgroundColor: red68Color,
          onPressed: _deleteMember);
    }
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EditLineView(
          title: S.of(context).fullName,
          hintText: S.of(context).hintFullName,
          isShowClear: _isShowNameClear,
          textController: _nameController,
          maxLen: 29,
        ),
        EditLineView(
          title: S.of(context).phone,
          keyboardType: TextInputType.phone,
          hintText: S.of(context).hintPhone,
          isShowClear: _isShowPhoneClear,
          textController: _phoneController,
          maxLen: 20,
        ),
        EditLineView(
          title: S.of(context).position,
          hintText: S.of(context).hintPosition,
          isShowClear: _isShowTitleClear,
          textController: _titleController,
          maxLen: 20,
        ),
        EditLineView(
          title: S.of(context).department,
          titleMaxOdds: 0.4,
          text: _deptNameList.join("，"),
          haveArrow: true,
          onPressed: _selectDept,
        ),
        EditLineView(
          title: S.of(context).dateOfEntry,
          titleMaxOdds: 0.4,
          text: _entryDateStr,
          haveArrow: true,
          onPressed: _selectDate,
        ),
        EditLineView(
          title: S.of(context).jobNumber,
          titleMaxOdds: 0.4,
          hintText: S.of(context).optional,
          isShowClear: _isShowNumberClear,
          textController: _numberController,
          maxLen: 20,
        ),
        EditLineView(
          title: S.of(context).remark,
          hintText: S.of(context).optional,
          isShowClear: _isShowNoteClear,
          textController: _noteController,
          maxLen: 50,
        ),
        _btn()
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
            title: S.of(context).teamEditMember,
            elevation: 0.5,
            rightDMActions: _isLoadingOK
                ? null
                : <Widget>[
                    buildSureBtn(
                      text: S.of(context).finish,
                      textStyle: TextStyles.textF14T2,
                      color: AppColors.mainColor,
                      onPressed: _dealSubmit,
                    ),
                  ],
          ),
          body: _isLoadingOK
              ? buildProgressIndicator()
              : ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView(
                    children: <Widget>[_buildColumn()],
                  ),
                ),
          backgroundColor: Colors.white),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _numberController.dispose();
    super.dispose();
  }
}
