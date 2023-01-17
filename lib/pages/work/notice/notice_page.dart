import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/work_notice.dart';
import 'package:cobiz_client/http/work.dart' as workApi;
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'issue_notice.dart';
import 'notice_detail.dart';

class NoticePage extends StatefulWidget {
  final TeamInfo teamInfo;
  final Function updateCall;

  const NoticePage({
    Key key,
    this.teamInfo,
    this.updateCall,
  }) : super(key: key);

  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  final SlidableController _slidableController = SlidableController();
  RefreshController _refreshController = RefreshController();
  bool _isLoadOk = false;
  List<Notice> _notices = List();
  bool _isAdmin = false;
  int _page = 1;
  int _size = 20;
  bool _isChange = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.teamInfo.creator == API.userInfo.id ||
        widget.teamInfo.managers.containsKey(API.userInfo.id.toString());
    _getData();
  }

  void _getData({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _page++;
    } else {
      _notices.clear();
      _page = 1;
      if (mounted && _isLoadOk != false) {
        setState(() {
          _isLoadOk = false;
        });
      }
    }
    List<Notice> res = await workApi.noticeList(
        teamId: widget.teamInfo.id, page: _page, size: _size);
    if (res != null && res.isNotEmpty) {
      _notices.addAll(res);
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

  Future _onLoading() async {
    _getData(isLoadMore: true);
  }

  void delNotice(int id) async {
    bool resState = await workApi.delNotice(teamId: widget.teamInfo.id, id: id);
    if (!resState) {
      showToast(context, S.of(context).operateFailure);
    } else {
      _isChange = true;
      _getData();
    }
  }

  Widget _buildItem(Notice notice) {
    return ListItemView(
      dense: false,
      title: notice.title,
      widgetRt1: SizedBox(
          width: 100,
          child: Text(
            notice.name,
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textF12C4,
          )),
      widgetRt2: Text(
        DateUtil.formatSeconds(notice.time),
        style: TextStyles.textF12C4,
      ),
      onPressed: () {
        if (_slidableController.activeState != null) {
          _slidableController.activeState.close();
        }
        routePush(NoticeDetailPage(
          teamId: widget.teamInfo.id,
          id: notice.id,
        ));
      },
    );
  }

  Widget _buildContent() {
    return _notices.length > 0
        ? ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              return _isAdmin
                  ? Slidable(
                      controller: _slidableController,
                      closeOnScroll: true,
                      child: _buildItem(_notices[index]),
                      actionPane: SlidableScrollActionPane(),
                      secondaryActions: <Widget>[
                        SlideAction(
                          child: Text(
                            S.of(context).delete,
                            style: TextStyles.textF16T1,
                          ),
                          color: Colors.red,
                          closeOnTap: true,
                          onTap: () {
                            showSureModal(
                                context, S.of(context).sureDeleteTheNotice, () {
                              delNotice(_notices[index].id);
                            });
                          },
                        ),
                      ],
                    )
                  : _buildItem(_notices[index]);
            },
            itemCount: _notices.length,
          )
        : Container(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
              child: Column(
                children: [
                  ImageView(img: noContent),
                  Text(S.of(context).noData, style: TextStyles.textF17T2)
                ],
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_slidableController.activeState != null) {
          _slidableController.activeState.close();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: ComMomBar(
          title: S.of(context).announcement,
          elevation: 0.5,
          rightDMActions: <Widget>[
            _isAdmin
                ? buildSureBtn(
                    text: S.of(context).publish,
                    textStyle: TextStyles.textF14T2,
                    color: AppColors.mainColor,
                    onPressed: () {
                      if (_slidableController.activeState != null) {
                        _slidableController.activeState.close();
                      }
                      routePush(IssueNoticePage(
                        teamId: widget.teamInfo.id,
                      )).then((v) {
                        if (v == true) {
                          _isChange = true;
                          _getData();
                        }
                      });
                    },
                  )
                : Container(),
          ],
        ),
        body: !_isLoadOk
            ? buildProgressIndicator()
            : SmartRefresher(
                controller: _refreshController,
                enablePullUp: true,
                onLoading: _onLoading,
                onRefresh: () {
                  _getData();
                },
                physics: BouncingScrollPhysics(),
                child: _buildContent(),
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
              ),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    if (_isChange == true) {
      widget.updateCall();
    }
    super.dispose();
  }
}

// Future<List> _fakeRequest() async {
//   return Future.delayed(Duration(seconds: 1), () {
//     List list = [
//       {
//         'id': '1',
//         'title': '今日下午3点公司会议室开会!',
//         'sender': '料子',
//         'readed': 0,
//         'unread': 10,
//         'createTime': '2019-12-04 12:00',
//         'content': '今日下午3点公司会议室开会! 大家都务必参与, 有重大消息要协商.',
//       },
//       {
//         'id': '2',
//         'title': '明日上午10点集体活动',
//         'sender': '料子',
//         'readed': 2,
//         'unread': 8,
//         'createTime': '2019-12-04 12:00',
//         'content': '重要的事情说三遍: 明日活动有惊喜!',
//       },
//     ];
//     return list;
//   });
// }
