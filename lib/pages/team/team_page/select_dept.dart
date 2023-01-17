import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:cobiz_client/ui/view/submit_btn_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';

import 'selected_dept_view.dart';

class SelectDepartmentPage extends StatefulWidget {
  final int teamId; // 团队ID
  final String teamName; // 团队名字
  final int deptId; // 本部门ID
  final int selectedDeptId; // 单选时，选中的部门ID
  final String selectedDeptName; // 单选时，选中的部门名字
  final Map<int, String> selectDepts; // 多选时，选择的部门
  final bool isMult; // 是否多选

  const SelectDepartmentPage({
    Key key,
    this.teamId,
    this.teamName,
    this.deptId,
    this.selectedDeptId,
    this.selectedDeptName = '',
    this.isMult = false, //是否多选
    this.selectDepts,
  }) : super(key: key);

  @override
  _SelectDepartmentPageState createState() => _SelectDepartmentPageState();
}

class _SelectDepartmentPageState extends State<SelectDepartmentPage> {
  bool _isLoading = true;
  // bool _hasBread = false;

  Depts _curDept;
  List<Depts> _oldDepts = List();
  List<Depts> _depts = List();

  Map<int, String> _multSelectedIds = Map();
  int _selectedDeptId;
  String _selectedDeptName;
  Map<int, Map> _selectedIds = Map();

  bool _isAdmin = false; //是否是主管理员和管理员
  bool isSupervisor = false; //是不是当前选中部门的主管

  @override
  void initState() {
    super.initState();
    if (widget.isMult) {
      _multSelectedIds =
          widget.selectDepts == null ? Map() : widget.selectDepts;
    } else {
      _selectedDeptId = widget.selectedDeptId;
      _selectedDeptName = widget.selectedDeptName;
    }
    _localDeptData();
  }

  void _isManage(List<Depts> depts, bool isManage) {
    for (int i = 0; i < depts.length; i++) {
      bool isCutManage = false;
      if (_multSelectedIds.containsKey(depts[i].id)) {
        if (isManage != true) {
          isCutManage = depts[i].managerId == API.userInfo.id;
        }
        _selectedIds[depts[i].id] = {
          'id': depts[i].id,
          'name': depts[i].name,
          'isManage': isManage || isCutManage,
        };
      }
      if (depts[i].childs != null && depts[i].childs.length > 0) {
        _isManage(depts[i].childs, isManage || isCutManage);
      }
    }
  }

  Future _localDeptData() async {
    DeptAndMember res =
        await teamApi.getTeamMembers(teamId: widget.teamId, type: 2);
    if (res != null) {
      if (res.depts.isNotEmpty) {
        _depts = res.depts;
      }
      if (res.members.isNotEmpty) {
        //判断自己是不是管理员或者创建者
        for (var i = 0; i < res.members.length; i++) {
          if (res.members[i].id == API.userInfo.id) {
            if (res.members[i].manager == 1 || res.members[i].manager == 2) {
              _isAdmin = true;
            } else {
              _isAdmin = false;
            }
            break;
          }
        }
      }
      if (_isAdmin) {
        _multSelectedIds.forEach((key, value) {
          _selectedIds[key] = {
            'id': key,
            'name': value,
            'isManage': _isAdmin,
          };
        });
      } else {
        _isManage(_depts, false);
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clickDept(Depts dept, bool isBack) {
    if (dept != null && dept.childs.isEmpty) {
      if (_isPermission(dept.managerId)) {
        _selectDept(dept.id, dept.name);
      }
    } else {
      if (isBack) {
        if (_oldDepts.isNotEmpty) {
          _oldDepts.removeLast();
        }
      } else {
        _oldDepts.add(_curDept);
      }
      _curDept = dept;
      // _hasBread = dept != null;
      //重置不是主管
      isSupervisor = false;
      //直接判断当前部门是主管 如果不是 则查询是否是上级某部门的主管
      if (_curDept != null) {
        if (_curDept.managerId == API.userInfo.id) isSupervisor = true;
        if (isSupervisor == false) {
          for (var i = 0; i < _oldDepts.length; i++) {
            if (_oldDepts[i] != null) {
              if (_oldDepts[i].managerId == API.userInfo.id) {
                isSupervisor = true;
                break;
              }
            }
          }
        }
      }

      if (mounted) setState(() {});
    }
  }

  void _showSelected() async {
    var res = await routeMaterialPush(SelectedDeptView(
      deptIds: _multSelectedIds,
      depts: _selectedIds,
    ));
    if (res != null && mounted) {
      setState(() {
        if (res['multDeptIds'] != null) {
          _multSelectedIds = res['multDeptIds'];
        }
        if (res['selectIds'] != null) {
          _selectedIds = res['selectIds'];
        }
      });
    }
  }

  Widget _buildBread() {
    // if (!_hasBread)
    //   return SizedBox(
    //     height: 0,
    //   );

    List<Widget> list = [
      InkWell(
        child: Text(
          widget.teamName,
          style: TextStyles.textF16Bold,
        ),
        onTap: () {
          _clickDept(null, true);
          _oldDepts.clear();
        },
      )
    ];

    if (_oldDepts != null && _oldDepts.length > 0) {
      int length = _oldDepts.length;
      for (int i = 0; i < length; i++) {
        Depts dept = _oldDepts[i];
        if (dept == null) continue;

        if (dept != null) {
          list.add(InkWell(
            child: arrowText(dept.name),
            onTap: () {
              int count = 0;
              for (int j = length - 1; j >= 0; j--) {
                if (_oldDepts[j].id == dept.id) break;
                count++;
              }
              _clickDept(dept, true);
              for (int j = 0; j < count; j++) {
                _oldDepts.removeLast();
              }
            },
          ));
        }
      }
    }

    if (_curDept != null) {
      list.add(arrowText(_curDept.name, type: true));
    }

    return Container(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Container(
              child: Row(
                children: list,
              ),
              constraints: BoxConstraints(
                minWidth: winWidth(context) - 30,
              ),
            ),
          );
        },
      ),
      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
    );
  }

  void _selectDept(int deptId, String deptName) {
    if (mounted) {
      setState(() {
        if (widget.isMult) {
          if (deptId != null) {
            if (_multSelectedIds[deptId] != null) {
              _multSelectedIds.remove(deptId);
              _selectedIds.remove(deptId);
            } else {
              _multSelectedIds[deptId] = deptName;
              _selectedIds[deptId] = {
                'id': deptId,
                'name': deptName,
                'isManage': true
              };
            }
          }
        } else {
          if (_selectedDeptId == deptId) {
            _selectedDeptId = null;
            _selectedDeptName = widget.teamName;
          } else {
            _selectedDeptId = deptId;
            _selectedDeptName = deptName;
          }
        }
      });
    }
  }

  //部门架构
  List<Depts> _dealDepts() {
    if (_curDept == null) {
      return _depts;
    } else {
      if (_curDept.childs.isNotEmpty) {
        return _curDept.childs;
      } else {
        return List<Depts>();
      }
    }
  }

  bool isChecked() {
    bool checked = _curDept == null
        ? (widget.selectedDeptId == 0 || widget.selectedDeptId == null)
        : widget.isMult
            ? _multSelectedIds[_curDept.id] != null
            : (_selectedDeptId == _curDept.id);
    return checked;
  }

  bool _isPermission(int managerId) {
    return _isAdmin || isSupervisor || managerId == API.userInfo.id;
  }

  Widget _buildStructure() {
    List<Widget> items = [];

    items.addAll(_dealDepts().map((sub) {
      if (sub.id == (widget.deptId ?? 0)) {
        return SizedBox(
          height: 0.0,
        );
      }
      return ShadowCardView(
        margin: EdgeInsets.only(top: 15.0),
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 12.0, bottom: 12.0),
        radius: 8.0,
        blurRadius: 3.0,
        child: RadioLineView(
          radioIsCanChange: _isPermission(sub.managerId),
          radioPadding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 5.0),
          iconRt: 0,
          checked: _isPermission(sub.managerId)
              ? (widget.isMult
                  ? _multSelectedIds[sub.id] != null
                  : _selectedDeptId == sub.id)
              : true,
          text: sub.name,
          arrowRt: (sub.childs.length ?? 0) > 0 &&
              (widget.isMult ? true : sub.id != widget.deptId),
          onPressed: () => _clickDept(sub, false),
          checkCallback: _isPermission(sub.managerId)
              ? () => _selectDept(sub.id, sub.name)
              : null,
        ),
      );
    }));
    //true

    return Column(
      children: items,
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.3),
        ),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: (widget.isMult
                ? InkWell(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            child: Text(
                          '${S.of(context).selected}: '
                          '${_multSelectedIds.keys.toList().length} ${S.of(context).deptUnit}',
                          style: TextStyles.textF16C1,
                        )),
                        Icon(
                          Icons.keyboard_arrow_up,
                          color: themeColor,
                        ),
                      ],
                    ),
                    onTap: _showSelected,
                  )
                : Text(
                    '${S.of(context).selected}：${_selectedDeptName ?? ''}',
                    style: TextStyles.textF16C1,
                  )),
          ),
          SubmitBtnView(
            text: S.of(context).ok,
            haveValue: true,
            onPressed: _dealSubmit,
            top: 0.0,
          ),
        ],
      ),
    );
  }

  void _dealSubmit() {
    Map<String, dynamic> data = Map();
    if (widget.isMult) {
      // if (_multSelectedIds.keys.toList().length <= 0) return;
      data = {
        'id': _multSelectedIds.keys.toList(),
        'name': _multSelectedIds.values.toList()
      };
      Navigator.pop(context, data);
    } else {
      if (_selectedDeptId == null && _selectedDeptName == null) return;
      data = {'id': _selectedDeptId, 'name': _selectedDeptName};
      Navigator.pop(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).setSuperDepartment,
        elevation: 0.5,
      ),
      body: _isLoading
          ? buildProgressIndicator()
          : ScrollConfiguration(
              behavior: MyBehavior(),
              child: Column(
                children: <Widget>[
                  _buildBread(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: 15.0,
                        right: 15.0,
                        bottom: 60.0,
                      ),
                      children: <Widget>[_buildStructure()],
                    ),
                  ),
                  _buildFooter()
                ],
              ),
            ),
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
