import 'package:cobiz_client/pages/work/report/work_log_common_tab.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import '../work_common.dart';
import 'select_report.dart';

class WorkReportPage extends StatefulWidget {
  final int index;
  final int teamId;
  final String teamName;

  const WorkReportPage({Key key, this.index = 0, this.teamId, this.teamName})
      : super(key: key);

  @override
  _WorkReportPageState createState() => _WorkReportPageState();
}

class _WorkReportPageState extends State<WorkReportPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: (widget.index > 2 || widget.index < 0 ? 0 : widget.index),
    );
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
        WorkLogTab(teamId: widget.teamId, tabType: 1),
        WorkLogTab(teamId: widget.teamId, tabType: 2),
        WorkLogTab(teamId: widget.teamId, tabType: 3),
      ],
    );
  }

  void _createReport() {
    // 写日志
    routePush(SelectReportPage(
      teamId: widget.teamId,
      teamName: widget.teamName,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).dailyRecord,
        elevation: 0.5,
        rightDMActions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createReport,
          )
        ],
      ),
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
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    eventBus.off('update_work_log');
    super.dispose();
  }
}
