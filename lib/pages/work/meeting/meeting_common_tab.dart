import 'package:cobiz_client/http/res/team_model/meeting_list.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cobiz_client/http/work.dart' as workApi;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../work_common.dart';
import './meeting_detail.dart';

class MeetingTab extends StatefulWidget {
  final int teamId;
  final int tabType;
  MeetingTab({Key key, @required this.teamId, @required this.tabType})
      : super(key: key);

  @override
  _MeetingTabState createState() => _MeetingTabState();
}

class _MeetingTabState extends State<MeetingTab> {
  RefreshController _refreshController = RefreshController();

  bool _isLoadOk = false;
  List<MeetingList> _dataList = List();
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _getData();
    if (widget.tabType != 2) {
      eventBus.on('update_work_meeting', _update);
    }
  }

  _update(dynamic arg) {
    _getData();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    eventBus.off('update_work_meeting', _update);
    super.dispose();
  }

  Future _getData({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _page++;
    } else {
      _dataList.clear();
      _page = 1;
      if (mounted && _isLoadOk != false) {
        setState(() {
          _isLoadOk = false;
        });
      }
    }
    List<MeetingList> res = await workApi.getMeetingList(
        teamId: widget.teamId, type: widget.tabType, page: _page);
    if (res != null && res.isNotEmpty) {
      _dataList.addAll(res);
    } else {
      if (isLoadMore) {
        _refreshController.loadNoData();
        _page--;
      }
    }
    if (isLoadMore) {
      _refreshController.loadComplete();
    }
    if (mounted) {
      setState(() {
        _isLoadOk = true;
      });
    }
  }

  /// 上拉加载
  Future _onLoading() async {
    _getData(isLoadMore: true);
  }

  // 更新
  // Future _update() async {
  //   _dataList.clear();
  //   _page = 1;
  //   _getData();
  // }

  Widget _buildContent(MeetingList item) {
    return InkWell(
        child: Container(
          child: buildReportItem(context, item),
          margin: EdgeInsets.only(
            top: 15.0,
          ),
        ),
        onTap: () {
          if (widget.tabType == 1) {
            _dataList.remove(item);
          }
          routePush(MeetingDetailPage(teamId: widget.teamId, id: item.id));
        });
  }

  // Item样式
  Widget buildReportItem(BuildContext context, MeetingList item) {
    return ShadowCardView(
      blurRadius: 3.0,
      radius: 5.0,
      padding: EdgeInsets.symmetric(
        vertical: 3.0,
      ),
      child: Column(
        children: <Widget>[
          ListItemView(
            titleWidget: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    S.of(context).meetingMinTitle(item.issuerName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.textF16C3,
                  ),
                ),
              ],
            ),
            labelWidget: Column(
              children: <Widget>[
                SizedBox(
                  height: 3.0,
                ),
                buildAnnotation(S.of(context).meetingTitle, item.title),
                SizedBox(
                  height: 3.0,
                ),
                buildAnnotation(
                    S.of(context).beginTime,
                    DateUtil.formatSeconds(item.beginAt,
                        format: 'yyyy-MM-dd HH:mm')),
                SizedBox(
                  height: 3.0,
                ),
                buildAnnotation(
                    S.of(context).endTime,
                    DateUtil.formatSeconds(item.endAt,
                        format: 'yyyy-MM-dd HH:mm')),
                SizedBox(
                  height: 3.0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                width: 15.0,
              ),
              Flexible(
                  child: Container(
                child: Text(
                    DateUtil.formatSeconds(item.time,
                        format: 'yyyy-MM-dd HH:mm'),
                    style: TextStyles.textF12C4),
              )),
              SizedBox(
                width: 15.0,
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoadOk
        ? buildProgressIndicator()
        : (_dataList.length == 0
            ? buildDefaultNoContent(context)
            : SmartRefresher(
                physics: BouncingScrollPhysics(),
                controller: _refreshController,
                enablePullDown: false,
                enablePullUp: true,
                onLoading: _onLoading,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  itemCount: _dataList.length,
                  itemBuilder: (context, index) {
                    return _buildContent(_dataList[index]);
                  },
                ),
                footer: CustomFooter(
                  loadStyle: LoadStyle.ShowAlways,
                  builder: (context, mode) {
                    if (mode == LoadStatus.noMore) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: Text(S.of(context).noMoreData),
                      );
                    } else if (mode == LoadStatus.loading) {
                      return Container(
                        height: 60.0,
                        child: Container(
                          height: 20.0,
                          width: 20.0,
                          child: CupertinoActivityIndicator(),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ));
  }
}
