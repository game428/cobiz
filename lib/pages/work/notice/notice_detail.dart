import 'package:cobiz_client/http/res/team_model/work_notice.dart';
import 'package:cobiz_client/http/work.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:flutter/material.dart';

class NoticeDetailPage extends StatefulWidget {
  final int id;
  final int teamId;

  const NoticeDetailPage({Key key, this.id, this.teamId}) : super(key: key);

  @override
  _NoticeDetailPageState createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  bool _isLoading = false;
  Notice notice;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    Notice res = await getNotice(teamId: widget.teamId, id: widget.id);
    if (mounted) {
      setState(() {
        if (res == null) {
          showToast(context, S.of(context).networkAnomaly);
        } else {
          notice = res;
        }
        _isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          notice?.title ?? '',
          style: TextStyles.textF16Bold,
        ),
        SizedBox(
          height: 5.0,
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          notice?.name ?? '',
          style: TextStyles.textF12C4,
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          DateUtil.formatSeconds(notice?.time ?? 0, format: 'yyyy-MM-dd'),
          style: TextStyles.textF12C4,
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(notice?.content ?? ''),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).announcementDetails,
        elevation: 0.5,
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 15.0,
          ),
          children: <Widget>[
            _isLoading ? buildProgressIndicator() : _buildContent()
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
