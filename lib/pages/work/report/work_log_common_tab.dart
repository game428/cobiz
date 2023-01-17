import 'package:cobiz_client/http/res/team_model/log_list.dart';
import 'package:cobiz_client/pages/work/report/report_detail.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cobiz_client/http/work.dart' as workApi;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../work_common.dart';

class WorkLogTab extends StatefulWidget {
  final int teamId;
  final int tabType;
  WorkLogTab({Key key, @required this.teamId, @required this.tabType})
      : super(key: key);

  @override
  _WorkLogTabState createState() => _WorkLogTabState();
}

class _WorkLogTabState extends State<WorkLogTab> {
  RefreshController _refreshController = RefreshController();

  bool _isLoadOk = false;
  List<LogList> _dataList = List();
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _getData();
    if (widget.tabType != 2) {
      eventBus.on('update_work_log', _update);
    }
  }

  _update(dynamic arg) {
    _getData();
  }

  @override
  void dispose() {
    _refreshController?.dispose();
    eventBus.off('update_work_log', _update);
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
    List<LogList> res = await workApi.getLogList(
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

  Widget _buildContent(LogList item) {
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
          routePush(ReportDetailPage(teamId: widget.teamId, id: item.id));
        });
  }

  // Item样式
  Widget buildReportItem(BuildContext context, LogList item) {
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
                    '[${item.type == 1 ? S.of(context).daily : item.type == 2 ? S.of(context).weekly : S.of(context).monthlyReport}] ${S.of(context).logTitle(item.issuer)}',
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
                buildAnnotation(S.of(context).workDone, item.finished),
                SizedBox(
                  height: 3.0,
                ),
                buildAnnotation(S.of(context).unfinishedWork, item.pending),
                SizedBox(
                  height: 3.0,
                ),
                buildAnnotation(S.of(context).coordinate, item.needed),
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
              Container(
                constraints: BoxConstraints(
                  maxWidth: winWidth(context) / 2 - 50,
                ),
                child: Text(
                    DateUtil.formatSeconds(item.time,
                        format: 'yyyy-MM-dd HH:mm'),
                    style: TextStyles.textF12C4),
              ),
              Spacer(),
              Container(
                constraints: BoxConstraints(
                  maxWidth: winWidth(context) / 2 - 50,
                ),
                child: Text(
                  '${S.of(context).sender}:' + item.issuer,
                  style: TextStyles.textF12C5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
