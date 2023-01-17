import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/team/ui/commonsWidget.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:cobiz_client/http/team.dart' as teamApi;

class SwitchTeamPage extends StatefulWidget {
  final int teamId;

  const SwitchTeamPage({Key key, this.teamId}) : super(key: key);

  @override
  _SwitchTeamPageState createState() => _SwitchTeamPageState();
}

class _SwitchTeamPageState extends State<SwitchTeamPage> {
  bool _isLoading = true;

  List<TeamStore> _teams = [];

  @override
  void initState() {
    super.initState();
    _localTeamData();
  }

  Future _localTeamData() async {
    _teams = await localStorage.getLocalTeams();
    if ((_teams?.length ?? 0) > 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _loadTeamData();
  }

  Future _loadTeamData() async {
    _teams = await teamApi.getAllTeams();
    if (_teams != null) {
      if (_teams.isEmpty) {
        showToast(context, S.of(context).noTeam);
        Navigator.pop(context, 0);
        return;
      }
      await localStorage.updateLocalTeams(_teams);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Widget> _buildContent() {
    List<Widget> list = [buildSearch(context, onPressed: _toSearch)];

    list.addAll(_teams.map((team) {
      return buildChangeTeamItem(context, team.name, team.manager,
          isSel: (team.id == widget.teamId), switchCallback: () {
        if (team.id == widget.teamId) return;
        _switchTeam(team);
      }, pressedCallback: () {
        if (team.id == widget.teamId) return;
        _switchTeam(team);
      });
    }).toList());
    return list;
  }

  void _toSearch() async {
    routeMaterialPush(SearchCommonPage(
      pageType: 10,
      data: _teams,
      teamId: widget.teamId,
    )).then((value) {
      if (value != null) {
        if (value is TeamStore) {
          if (value.id == widget.teamId) return;
          _switchTeam(value);
        }
      }
    });
  }

  void _switchTeam(TeamStore team) async {
    showSureModal(context, S.of(context).teamSwitch, () async {
      Loading.before(context: context);
      bool res = await teamApi.switchTeam(team.id);
      Loading.complete();
      if (res == true) {
        Navigator.pop(context, team.id);
      } else {
        showToast(context, S.of(context).switchFailed);
      }
    }, promptText: S.of(context).teamSwitchTip(team.name));
    // _selectedTeam = team;
    // API.userInfo.setLastTeam(team.id);
    // SharedUtil.instance.remove(Keys.teamMembers);
    // Navigator.pop(context, _selectedTeam);
  }

  @override
  Widget build(BuildContext context) {
    // Widget rWidget = InkWell(
    //   child: Container(
    //     child: ImageView(
    //       img: 'assets/images/add_group.png',
    //     ),
    //     color: Colors.white,
    //   ),
    //   onTap: () => showJoinTeamOperate(context),
    // );

    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).team,
          elevation: 0.5,
          // rightDMActions: <Widget>[rWidget],
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            padding: EdgeInsets.only(bottom: 10.0),
            children: _isLoading
                ? <Widget>[buildProgressIndicator()]
                : _buildContent(),
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

Widget buildChangeTeamItem(
  BuildContext context,
  String teamName,
  int manger, {
  bool isSel = false,
  VoidCallback switchCallback,
  VoidCallback pressedCallback,
}) {
  return ListItemView(
    title: teamName,
    dense: true,
    labelWidget: Container(
        padding: EdgeInsets.only(top: 5.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: identity(context, manger, null),
          ),
        )),
    widgetRt1: CupertinoButton(
      child: ImageView(
        img: 'assets/images/tick_${isSel ? "yes" : "no"}.png',
      ),
      minSize: 40.0,
      padding: EdgeInsets.symmetric(
        horizontal: 0.0,
      ),
      onPressed: () {
        if (switchCallback != null) switchCallback();
      },
    ),
    onPressed: () {
      if (pressedCallback != null) pressedCallback();
    },
  );
}
