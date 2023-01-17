import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/pages/team/friend/invite_qrcode.dart';
// import 'package:cobiz_client/pages/team/friend/phone_contacts.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/team/team_page/select_members.dart';
import 'package:cobiz_client/tools/cobiz.dart';
// import 'package:easy_contact_picker/easy_contact_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// 添加团队成员
class AddTeamMemberPage extends StatefulWidget {
  final int teamId;
  final int deptId;
  final String teamName;
  final bool isNewTeam;
  final bool isManager;
  final int membersSum;
  final String teamCode;

  const AddTeamMemberPage(
      {Key key,
      this.teamId,
      this.deptId,
      this.teamName,
      this.isNewTeam = false,
      this.isManager = false,
      this.membersSum = 0,
      this.teamCode})
      : super(key: key);

  @override
  _AddTeamMemberPageState createState() => _AddTeamMemberPageState();
}

class _AddTeamMemberPageState extends State<AddTeamMemberPage> {
  bool _isLoading = false;
  int _num = 0;
  int _limit = 1000;
  bool _isAdd = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNewTeam) {
      _num = widget.membersSum;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _clickToAdd(AddMemberMenuValue value) async {
    switch (value) {
      case AddMemberMenuValue.phone:
        var res = await routePush(SearchCommonPage(
            pageType: 8,
            data: widget.teamId,
            deptId: widget.deptId,
            teamId: widget.teamId,
            isAdmin: widget.isManager));
        if (res == true) {
          _isAdd = true;
          if (mounted) {
            setState(() {});
          }
        }
        break;
      case AddMemberMenuValue.contacts:
        // _openAddressBook();
        break;
      case AddMemberMenuValue.qrcode:
        routePush(InviteQrcodePage(
          type: 2,
          teamCode: widget.teamCode,
          deptId: widget.deptId,
          name: widget.teamName,
        ));
        break;
      case AddMemberMenuValue.cobiz:
        _addFromCobiz();
        break;
    }
  }

  void _addFromCobiz() async {
    final Set<int> memberIds = await routePush(SelectMembersPage(
      type: 1,
      deptId: widget.deptId,
      teamId: widget.teamId,
      isAdmin: widget.isManager,
    ));
    if (memberIds == null) return;
    _isAdd = true;
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildContent() {
    List<PMenuItem> menus = [
      // PMenuItem(AddMemberMenuValue.contacts,
      //     S.of(context).teamOperateByContacts, 'assets/images/contacts.png'),
      PMenuItem(AddMemberMenuValue.qrcode, S.of(context).teamOperateByQrcode,
          'assets/images/qrcode.png'),
    ];
    menus.insert(
        0,
        PMenuItem(AddMemberMenuValue.cobiz, S.of(context).teamOperateByCobiz,
            'assets/images/cobiz.png'));
    menus.insert(
        0,
        PMenuItem(AddMemberMenuValue.phone, S.of(context).teamOperateByPhone,
            'assets/images/phone.png'));

    List<Widget> list = [
      buildTextTitle(
        S.of(context).teamAddMemberMark,
        fontSize: FontSizes.font_s14,
        bottom: 10.0,
        haveBorder: true,
        margin: EdgeInsets.symmetric(horizontal: 15.0),
      )
    ];
    list.addAll(menus.map((menu) {
      return OperateLineView(
        icon: menu.icon,
        iconLeft: 0.0,
        title: menu.title,
        spaceSize: 15.0,
        onPressed: () => _clickToAdd(menu.value),
      );
    }));

    if (!widget.isNewTeam) {
      if (!_isLoading) {
        double totalWidth = winWidth(context) - 30.0;
        double validWidth = (_num / _limit) * totalWidth;
        if (validWidth < 5.0) validWidth = 5.0;
        list.insert(
            0,
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    S.of(context).teamMemberLimit,
                    style: TextStyles.textF16,
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: Text(
                      '$_num/$_limit',
                      style: TextStyles.textF16C1,
                    ),
                  ),
                ],
              ),
            ));
        list.insert(
            1,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: radiusBgColor,
              ),
              margin: EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10.0,
              ),
              height: 5.0,
              width: totalWidth,
              child: Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: themeColor,
                    ),
                    height: 5.0,
                    width: (validWidth > totalWidth ? totalWidth : validWidth),
                  ),
                ],
              ),
            ));
      } else {
        list.insert(0, buildProgressIndicator());
      }
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: list,
          ),
        ),
      ],
    );
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(context, _isAdd);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: ComMomBar(
            title: S.of(context).teamAddMember,
            elevation: 0.5,
            backData: _isAdd,
          ),
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: _buildContent(),
          ),
          backgroundColor: Colors.white,
        ),
        onWillPop: _onWillPop);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
