import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import '../work_common.dart';
import './issue_meeting.dart';
import 'meeting_common_tab.dart';

// 会议纪要列表
class MeetingPage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const MeetingPage({Key key, this.teamId, this.teamName}) : super(key: key);

  @override
  _MeetingPageState createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    eventBus.off('update_work_meeting');
    super.dispose();
  }

  void _initController() {
    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    );
  }

  void _createMeeting() {
    routePush(IssueMeetingPage(
      teamId: widget.teamId,
      teamName: widget.teamName,
    ));
  }

   Widget _buildNavBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.white,
      indicatorWeight: 0.1,
      labelColor: Colors.black,
      labelStyle: TextStyles.textTabSel,
      unselectedLabelColor: grey81Color,
      unselectedLabelStyle: TextStyles.textTabUnSel,
      tabs: <Widget>[
        // Tab(
        //   child: Stack(
        //     fit: StackFit.passthrough,
        //     overflow: Overflow.visible,
        //     children: <Widget>[
        //       Text(S.of(context).toBeConsulted),
        //       Positioned(
        //         right: -8,
        //         child: buildMessaged(),
        //       ),
        //     ],
        //   ),
        // ),
        Tab(
          text: S.of(context).toBeConsulted,
        ),
        Tab(
          text: S.of(context).reviewed,
        ),
        Tab(
          text: S.of(context).initiated,
        ),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        MeetingTab(teamId: widget.teamId, tabType: 1),
        MeetingTab(teamId: widget.teamId, tabType: 2),
        MeetingTab(teamId: widget.teamId, tabType: 3),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).meeting,
        elevation: 0.5,
        rightDMActions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createMeeting,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: <Widget>[
            _buildNavBar(),
            buildLine(),
            Expanded(
              child: _buildTabBarView(),
            ),
          ],
        ),
      ),
    );
  }
}
