import 'package:cobiz_client/http/res/team_model/work_common_list.dart';
import 'package:cobiz_client/pages/work/ui/appr_item_view.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

//pageType 1.待处理 2.已处理 3.已发起 4.抄送我(必传)
class AppreStatePage extends StatefulWidget {
  final int teamId;
  final int pageType;
  final String title;
  final Function(dynamic) backData;
  AppreStatePage(
      {Key key,
      @required this.teamId,
      @required this.pageType,
      @required this.title,
      this.backData})
      : super(key: key);

  @override
  _AppreState createState() => _AppreState();
}

class _AppreState extends State<AppreStatePage> {
  RefreshController _refreshController = RefreshController();
  bool _isLoadOk = false;
  int _page = 1;
  int _pageSize = 20;
  List<WorkCommonListItem> _appreList = [];
  bool _isChange = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future _getData({bool isLoadMore = false}) async {
    if (isLoadMore) {
      _page++;
    } else {
      _appreList.clear();
      _page = 1;
      if (mounted && _isLoadOk != false) {
        setState(() {
          _isLoadOk = false;
        });
      }
    }
    List<WorkCommonListItem> res = await workApi.getApprovalList(
        teamId: widget.teamId,
        type: widget.pageType,
        page: _page,
        size: _pageSize);
    if (res != null && res.isNotEmpty) {
      _appreList.addAll(res);
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

  // 已处理，移除待处理列表
  void _remove(WorkCommonListItem workCommonListItem) {
    if (mounted) {
      setState(() {
        _isChange = true;
        _appreList.remove(workCommonListItem);
      });
    }
  }

  // 修改状态
  void _setChange() {
    _isChange = true;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    if (widget.backData != null) {
      widget.backData(_isChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(title: widget.title, elevation: 0.5),
        body: _isLoadOk
            ? (_appreList.isEmpty
                ? buildDefaultNoContent(context)
                : SmartRefresher(
                    physics: BouncingScrollPhysics(),
                    controller: _refreshController,
                    enablePullDown: false,
                    enablePullUp: true,
                    onLoading: _onLoading,
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 20),
                        itemCount: _appreList.length,
                        itemBuilder: (context, index) {
                          return ApprItemView(
                              teamId: widget.teamId,
                              workCommonListItem: _appreList[index],
                              pageType: widget.pageType,
                              remove: () {
                                _remove(_appreList[index]);
                              },
                              setChange: _setChange);
                        }),
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
                    )))
            : buildProgressIndicator());
  }
}
