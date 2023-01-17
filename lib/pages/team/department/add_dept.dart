import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/pages/team/team_page/select_dept.dart';
import 'package:cobiz_client/pages/team/team_page/select_manager.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

class AddDepartmentPage extends StatefulWidget {
  final int teamId;
  final String teamName;
  final Depts dept;
  final int superiorId;
  final String superiorName;
  final int masterId;
  final String masterName;
  final bool isEdit;

  const AddDepartmentPage(
      {Key key,
      this.teamId,
      this.teamName,
      this.dept,
      this.superiorId,
      this.superiorName,
      this.masterId,
      this.masterName,
      this.isEdit})
      : super(key: key);

  @override
  _AddDepartmentPageState createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  FocusNode _focusName = FocusNode();
  TextEditingController _nameController = TextEditingController();

  bool _isShowNameClear = false;
  bool _isInputFinish = false;

  int _managerId; //主管id
  int _superiorId; //上级部门id

  String _managerName = '';
  String _superiorName = '';

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.dept?.name ?? '';
    _superiorId = widget.superiorId;
    _superiorName = widget.superiorName;
    _managerId = widget.masterId;
    _managerName = widget.masterName;
    if (_nameController.text.length > 0) {
      _isShowNameClear = true;
    }
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = _nameController.text.length > 0;
          _isInputFinish = _nameController.text.length > 0;
          if ((widget.dept?.name ?? '') == _nameController.text) {
            _isInputFinish = false;
          }
        });
      }
    });
  }

  void _unfocusField() {
    _focusName.unfocus();
  }

  //选择管理员
  void _selectManager() async {
    _unfocusField();
    final Map result = await routePush(SelectManagerPage(
      teamId: widget.teamId,
      teamName: widget.teamName,
      selectedMemberId: _managerId,
      selectedMemberName: _managerName,
    ));
    if (result == null) return;

    _managerId = result['id'];
    _managerName = result['name'];
    if (mounted) {
      setState(() {
        _isInputFinish = true;
      });
    }
  }

  //选择上级部门
  void _selectDept() async {
    _unfocusField();
    if (widget.dept == null) return;
    final Map result = await routePush(SelectDepartmentPage(
      teamId: widget.teamId,
      teamName: widget.teamName,
      deptId: widget.dept.id,
      selectedDeptId: _superiorId,
      selectedDeptName: _superiorName,
    ));
    if (result == null) return;
    _superiorId = result['id'];
    _superiorName = _superiorId == null || _superiorId == 0
        ? widget.teamName
        : result['name'];
    if (mounted) {
      setState(() {
        _isInputFinish = true;
      });
    }
  }

  Future _dealSubmit() async {
    if (!_isInputFinish) {
      return;
    }
    Loading.before(context: context);
    var res = await teamApi.deptDeal(
      teamId: widget.teamId,
      deptId: widget.dept?.id ?? 0,
      parentId: _superiorId ?? 0,
      name: _nameController.text,
      leaderId: _managerId,
    );
    Loading.complete();
    if (res != null) {
      if ((widget.dept?.id ?? 0) == 0) {
        if (_managerId == API.userInfo.id) {
          ChannelManager.getInstance().addGroupChat(
              res['chatId'],
              _nameController.text,
              [],
              1,
              3,
              widget.teamId,
              false,
              ChatStore(getOnlyId(), ChatType.GROUP.index + 1, API.userInfo.id,
                  res['chatId'], 100, '',
                  state: 2, time: DateTime.now().millisecondsSinceEpoch));
        }
      }
      Navigator.pop(context, {
        'type': (_superiorId != widget.superiorId)
            ? 3
            : (widget.dept != null ? 2 : 1),
        'name': _nameController.text,
        'masterId': _managerId
      });
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  void _deleteDept() {
    showSureModal(context, S.of(context).deptDelete, () async {
      Loading.before(context: context);
      bool res = await teamApi.deleteDept(
          teamId: widget.teamId, deptId: widget.dept.id);
      Loading.complete();
      if (res) {
        Navigator.pop(context, {'type': 1});
      } else {
        showToast(context, S.of(context).tryAgainLater);
      }
    }, promptText: S.of(context).deptDeleteConfirmContent);
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EditLineView(
          title: S.of(context).name,
          hintText: S.of(context).departmentName,
          maxLen: 30,
          textController: _nameController,
          focusNode: _focusName,
          isShowClear: _isShowNameClear,
        ),
        EditLineView(
          title: S.of(context).departmentHead,
          text: _managerName ?? '',
          haveArrow: true,
          onPressed: _selectManager,
        ),
        EditLineView(
          title: S.of(context).departmentHigher,
          text: _superiorName,
          haveArrow: true,
          onPressed: _selectDept,
        ),
        widget.dept == null
            ? Container()
            : buildCommonButton(S.of(context).delete,
                margin: EdgeInsets.only(top: 40, left: 15, right: 15),
                backgroundColor: red68Color,
                onPressed: _deleteDept)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _unfocusField(),
      child: Scaffold(
          appBar: ComMomBar(
            title: widget.dept != null
                ? S.of(context).setSubDept
                : S.of(context).addSubDept,
            elevation: 0.5,
            rightDMActions: <Widget>[
              buildSureBtn(
                text: S.of(context).finish,
                textStyle: _isInputFinish
                    ? TextStyles.textF14T2
                    : TextStyles.textF14T1,
                color: _isInputFinish ? AppColors.mainColor : greyECColor,
                onPressed: _dealSubmit,
              ),
            ],
          ),
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              children: <Widget>[_buildColumn()],
            ),
          ),
          backgroundColor: Colors.white),
    );
  }

  @override
  void dispose() {
    _focusName.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
