import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

import 'issue_report.dart';

class SelectReportPage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const SelectReportPage({Key key, this.teamId, this.teamName})
      : super(key: key);

  @override
  _SelectReportPageState createState() => _SelectReportPageState();
}

class _SelectReportPageState extends State<SelectReportPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildItem(String image, String text, VoidCallback callback) {
    return InkWell(
      child: Column(
        children: <Widget>[
          ImageView(
            img: image,
          ),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textF12,
          ),
        ],
      ),
      onTap: callback,
    );
  }

  void _actionHandle(int type) {
    routePush(IssueReportPage(
      type: type,
      teamId: widget.teamId,
      teamName: widget.teamName,
    ));
  }

  // Widget _buildLately() {
  //   return Wrap(
  //     spacing: 30.0,
  //     runSpacing: 15.0,
  //     children: <Widget>[
  //       _buildItem('assets/images/work/report_daily.png', S.of(context).daily,
  //           () => _actionHandle(1)),
  //     ],
  //   );
  // }

  Widget _buildFinance() {
    return Wrap(
      spacing: 30.0,
      runSpacing: 15.0,
      children: <Widget>[
        _buildItem('assets/images/work/log_icon.png', S.of(context).daily,
            () => _actionHandle(1)),
        _buildItem('assets/images/work/log_icon.png', S.of(context).weekly,
            () => _actionHandle(2)),
        _buildItem('assets/images/work/log_icon.png',
            S.of(context).monthlyReport, () => _actionHandle(3)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).workReport,
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: <Widget>[
              Text(
                S.of(context).writeLog,
                style: TextStyles.textContactTitle,
              ),
              SizedBox(
                height: 15.0,
              ),
              _buildFinance(),
            ],
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
