import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/domain/work_domain.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:cobiz_client/ui/view/submit_btn_view.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'selected_list_view.dart';

class SelectMultiMemberPage extends StatefulWidget {
  final String title;
  final int teamId;
  final String teamName;
  final List<TempMember> selectedIds;
  final int total;

  const SelectMultiMemberPage(
      {Key key,
      this.title,
      this.teamId,
      this.teamName,
      this.selectedIds,
      this.total = 20})
      : super(key: key);

  @override
  _SelectMultiMemberPageState createState() => _SelectMultiMemberPageState();
}

class _SelectMultiMemberPageState extends State<SelectMultiMemberPage> {
  bool _isLoading = true;
  bool _hasBread = false;

  Depts _curDept;
  List<Depts> _oldDepts = List();

  List<Depts> _depts = List();
  List<Members> _allMembers = List();
  List<TeamMemberSelected> _members = List();

  List<TeamMemberSelected> _selectedMembers = List();

  int lastUserId;

  @override
  void initState() {
    super.initState();
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
        _allMembers = res.members;
        res.members.forEach((Members member) {
          bool isSelected = _isSelect(member.id);
          String pinyin = PinyinHelper.getPinyinE(member.name);
          TeamMemberSelected currMember = TeamMemberSelected(
            userId: member.id,
            name: member.name,
            avatarUrl: member.avatar,
            namePinyin: pinyin,
            teamId: widget.teamId,
            isSelected: isSelected,
          );
          if (isSelected) {
            _selectedMembers.add(currMember);
          }
          _members.add(currMember);
        });
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isSelect(int id) {
    if ((widget.selectedIds?.length ?? 0) == 0) {
      return false;
    }
    for (var item in widget.selectedIds) {
      if (item.userId == id) {
        return true;
      }
    }
    return false;
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

  void _selectMember(TeamMemberSelected member) {
    if (_selectedMembers.length >= widget.total) return;
    member.isSelected = !member.isSelected;
    if (member.isSelected) {
      _selectedMembers.add(member);
    } else {
      _selectedMembers.remove(member);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildMember(TeamMemberSelected member, int manager, int leader,
      String job, bool haveBorder) {
    List<Widget> roleWidget = identity(context, manager, leader);
    return RadioLineView(
      checked: member.isSelected,
      haveBorder: haveBorder,
      iconRt: 2.0,
      paddingLeft: 6.0,
      content: ListItemView(
        paddingRight: 0.0,
        paddingLeft: 0.0,
        iconWidget: ImageView(
          img: cuttingAvatar(member.avatarUrl),
          width: 42.0,
          height: 42.0,
          needLoad: true,
          isRadius: 21.0,
          fit: BoxFit.cover,
        ),
        title: member.name,
        labelWidget: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: roleWidget,
          ),
        ),
        dense: true,
        haveBorder: false,
        onPressed: () => _selectMember(member),
      ),
      checkCallback: () => _selectMember(member),
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
    List<TeamMemberSelected> _deptMembers = [];
    List<Members> _deptAllMembers = [];
    List<Widget> list = List();
    if (_curDept == null) {
      for (int i = 0; i < _members.length; i++) {
        if (_allMembers[i].remark == null || _allMembers[i].remark == '') {
          _deptMembers.add(_members[i]);
          _deptAllMembers.add(_allMembers[i]);
          list.add(_buildMember(
            _members[i],
            _allMembers[i].manager,
            _allMembers[i].leader,
            _allMembers[i].remark,
            _members[i].userId != _members.last.userId,
          ));
        }
      }
      if (_members.last.userId != _deptMembers.last.userId) {
        list.removeLast();
        list.add(_buildMember(
          _deptMembers.last,
          _deptAllMembers.last.manager,
          _deptAllMembers.last.leader,
          _deptAllMembers.last.remark,
          false,
        ));
      }
    } else {
      _curDept.memberIds.forEach((element) {
        for (int i = 0; i < _members.length; i++) {
          if (element == _members[i].userId) {
            _deptMembers.add(_members[i]);
            _deptAllMembers.add(_allMembers[i]);
            list.add(_buildMember(
              _members[i],
              _allMembers[i].manager,
              _allMembers[i].leader,
              _allMembers[i].remark,
              _members[i].userId != _curDept.memberIds.last,
            ));
            break;
          }
        }
      });
    }

    if (_deptMembers.length > 0) {
      items.add(ShadowCardView(
        margin: EdgeInsets.only(top: 15.0),
        radius: 8.0,
        blurRadius: 3.0,
        child: Column(children: list),
      ));
    }

    return Column(
      children: items,
    );
  }

  void _showSelected() async {
    var res = await routeMaterialPush(SelectedListView(
      members: _selectedMembers,
    ));
    if (res != null && mounted) {
      setState(() {});
    }
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
            child: (_selectedMembers.length == 0
                ? Text(
                    '${S.of(context).maxSelect} ${widget.total} ${S.of(context).personUnit}',
                    style: TextStyles.textF16C1,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                          child: InkWell(
                        child: Text(
                          '${S.of(context).selected}: '
                          '${_selectedMembers.length}${S.of(context).personUnit}',
                          style: TextStyles.textF16C1,
                        ),
                        onTap: _showSelected,
                      )),
                      InkWell(
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: themeColor,
                        ),
                        onTap: _showSelected,
                      ),
                    ],
                  )),
          ),
          SubmitBtnView(
            text:
                '${S.of(context).ok}(${_selectedMembers.length}/${widget.total})',
            haveValue: true,
            onPressed: _dealSubmit,
            top: 0.0,
          ),
        ],
      ),
    );
  }

  void _dealSubmit() {
    List<TempMember> _selectList = List();
    _selectedMembers.forEach((element) {
      _selectList.add(TempMember(
        userId: element.userId,
        name: element.name,
        head: element.avatarUrl,
      ));
    });
    Navigator.pop(context, _selectList);
  }

  void _openSearch() {
    routeMaterialPush(SearchCommonPage(
      pageType: 16,
      data: _members,
    )).then((value) {
      if (value != null && _members[value] != null) {
        _selectMember(_members[value]);
      }
    });
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
        title: widget.title ?? '',
        elevation: 0.5,
        rightDMActions: <Widget>[rWidget],
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
