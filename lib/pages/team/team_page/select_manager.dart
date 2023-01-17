import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:cobiz_client/ui/view/submit_btn_view.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

// 只支持单选
class SelectManagerPage extends StatefulWidget {
  final String title; // 标题
  final int teamId; // 团队ID
  final String teamName; // 团队名字
  final int selectedMemberId; // 已选中的成员ID
  final String selectedMemberName; // 已选中的成员名称

  const SelectManagerPage({
    Key key,
    this.title,
    this.teamId,
    this.teamName,
    this.selectedMemberId,
    this.selectedMemberName,
  }) : super(key: key);

  @override
  _SelectManagerPageState createState() => _SelectManagerPageState();
}

class _SelectManagerPageState extends State<SelectManagerPage> {
  bool _isLoading = true;
  bool _hasBread = false;

  Depts _curDept; //当前选中部门
  List<Depts> _oldDepts = List();

  List<Depts> _depts = List(); //公司部门组织架构
  List<Members> _members = List(); //公司成员

  int _selectedMemberId;
  String _selectedMemberName;
  String _selectedMemberAvatar;

  @override
  void initState() {
    super.initState();
    _selectedMemberId = widget.selectedMemberId;
    _selectedMemberName = widget.selectedMemberName;
    _getData();
  }

  Future _getData() async {
    DeptAndMember res =
        await teamApi.getTeamMembers(teamId: widget.teamId, type: 2);
    if (res != null) {
      if (res.depts.isNotEmpty) {
        _depts = res.depts;
      }
      if (res.members.isNotEmpty) {
        _members = res.members;
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clickDept(Depts dept, bool isBack) {
    if (isBack) {
      _oldDepts.removeLast();
    } else {
      _oldDepts.add(_curDept);
    }
    _curDept = dept;
    _hasBread = dept != null;

    if (mounted) setState(() {});
  }

  Widget _buildBread() {
    if (!_hasBread)
      return SizedBox(
        height: 0,
      );

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

  void _selectMember(int memberId, String memberName, String avatarUrl) {
    if (mounted) {
      setState(() {
        if (_selectedMemberId == memberId) {
          _selectedMemberId = null;
          _selectedMemberName = '';
          _selectedMemberAvatar = '';
        } else {
          _selectedMemberId = memberId;
          _selectedMemberName = memberName;
          _selectedMemberAvatar = avatarUrl;
        }
      });
    }
  }

  Widget _buildMember(int userId, String profileImage, String nickname,
      int manager, int leader, String job, bool haveBorder) {
    List<Widget> roleWidget = identity(context, manager, leader);
    return RadioLineView(
      checked: (_selectedMemberId == userId),
      haveBorder: haveBorder,
      iconRt: 2.0,
      paddingLeft: 6.0,
      content: ListItemView(
        paddingRight: 0.0,
        paddingLeft: 0.0,
        iconWidget: ImageView(
          img: cuttingAvatar(profileImage),
          width: 42.0,
          height: 42.0,
          needLoad: true,
          isRadius: 21.0,
          fit: BoxFit.cover,
        ),
        title: nickname,
        labelWidget: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: roleWidget,
          ),
        ),
        dense: true,
        haveBorder: false,
        onPressed: () => _selectMember(userId, nickname, profileImage),
      ),
      checkCallback: () => _selectMember(userId, nickname, profileImage),
    );
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

  Widget _buildStructure() {
    List<Widget> items = [
      ShadowCardView(
        margin: EdgeInsets.only(top: 5.0),
        padding: EdgeInsets.only(
          left: 12.0,
          right: 5.0,
          top: 12.0,
          bottom: 12.0,
        ),
        radius: 8.0,
        blurRadius: 3.0,
        child: Column(
          children: <Widget>[
            RadioLineView(
              content: Text(
                _curDept?.name ?? widget.teamName,
                style: TextStyles.textF16Bold,
              ),
            ),
          ],
        ),
      )
    ];

    if (!_isLoading) {
      items.addAll(_dealDepts().map((sub) {
        return ShadowCardView(
          margin: EdgeInsets.only(top: 15.0),
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            top: 12.0,
            bottom: 12.0,
          ),
          radius: 8.0,
          blurRadius: 3.0,
          child: Column(
            children: <Widget>[
              RadioLineView(
                text: sub.name,
                arrowRt: true,
                onPressed: () => _clickDept(sub, false),
              ),
            ],
          ),
        );
      }));
    }
    List<Members> members = [];
    if (_curDept == null) {
      _members.forEach((element) {
        if (element.remark == null || element.remark == '') {
          members.add(element);
        }
      });
    } else {
      _curDept.memberIds.forEach((element) {
        for (var item in _members) {
          if (element == item.id) {
            members.add(item);
            break;
          }
        }
      });
    }

    if (members.length > 0) {
      items.add(ShadowCardView(
        margin: EdgeInsets.only(top: 15.0),
        radius: 8.0,
        blurRadius: 3.0,
        child: Column(
          children: members.map((member) {
            return _buildMember(
                member.id,
                member.avatar,
                member.name,
                member.manager,
                member.leader,
                member.remark,
                member.id != members.last.id);
          }).toList(),
        ),
      ));
    }

    return Column(
      children: items,
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey, width: 0.3),
        ),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 0.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${S.of(context).selected}：',
            style: TextStyles.textF16,
          ),
          Expanded(
            child: Text(
              _selectedMemberName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.textF16C1,
            ),
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
    Navigator.pop(context, {
      'id': _selectedMemberId,
      'name': _selectedMemberName,
      'avatar': _selectedMemberAvatar
    });
  }

  void _openSearch() async {
    final result = await routeMaterialPush(SearchCommonPage(
      pageType: 13,
      data: {'members': _members, 'seId': _selectedMemberId},
    ));
    if (result == null) return;
    if (mounted) {
      setState(() {
        _selectedMemberId = result['touchId'];
        _selectedMemberName = result['name'];
        _selectedMemberAvatar = result['avatarUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget rWidget = InkWell(
      child: Container(
        child: ImageView(
          img: searchImage,
        ),
        color: Colors.white,
      ),
      onTap: _openSearch,
    );

    return Scaffold(
      appBar: ComMomBar(
        title: widget.title ?? S.of(context).setDepartmentHead,
        elevation: 0.5,
        rightDMActions: <Widget>[rWidget],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Stack(
          children: <Widget>[
            Column(
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
              ],
            ),
            (_isLoading
                ? buildProgressIndicator()
                : SizedBox(
                    height: 0.0,
                  )),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      bottomSheet: _buildFooter(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
