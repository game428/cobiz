import 'package:cobiz_client/http/res/team_model/team_new_member.dart';
import 'package:cobiz_client/pages/team/team_page/edit_member.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:pull_to_refresh/pull_to_refresh.dart';

//团队成员验证
class MemberVerifyPage extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String teamCode;
  const MemberVerifyPage({Key key, this.teamId, this.teamName, this.teamCode})
      : super(key: key);

  @override
  _MemberVerifyPageState createState() => _MemberVerifyPageState();
}

class _MemberVerifyPageState extends State<MemberVerifyPage> {
  final SlidableController _slidableController = SlidableController();
  RefreshController _refreshController = RefreshController();
  bool _isLoading = true;

  int _page = 1;
  int _pageSize = 20;
  List<TeamNewMember> _requests = List();
  List<int> _dealingIds = List();
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future _loadData({bool isLoadMore = false}) async {
    if (isLoadMore) _page++;
    List res = await teamApi.applyJoinTeamList(
        teamId: widget.teamId, page: _page, size: _pageSize);
    if (mounted) {
      setState(() {
        if ((res?.length ?? 0) > 0) {
          _requests = res;
        } else {
          _refreshController.loadNoData();
        }
        if (isLoadMore) _refreshController.loadComplete();
        _isLoading = false;
      });
    }
  }

  Future _onLoading() async {
    _loadData(isLoadMore: true);
  }

  Widget _buildDefault() {
    return buildDefaultNoContent(context);
  }

  ///删除
  _delete(int uId, int index) async {
    // var res = await dealApply(2, uId);
    var res = true;
    if (res && mounted) {
      setState(() {
        _requests.removeAt(index);
      });
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  Future _agreeApply(int requestId, int userId, String userName) async {
    if (_slidableController.activeState != null) {
      _slidableController.activeState.close();
    }
    if (_dealingIds.contains(requestId)) return;
    if (mounted) {
      setState(() {
        _dealingIds.add(requestId);
      });
    }
    var res = await teamApi.dealApplyJoinTeam(
        teamId: widget.teamId, applyId: userId, type: 1);
    if (mounted) {
      setState(() {
        _dealingIds.remove(requestId);
      });
    }
    if (res == true) {
      routePush(EditMemberPage(
        teamId: widget.teamId,
        teamName: widget.teamName,
        userId: userId,
        userName: userName,
        canBack: false,
      )).then((value) {
        isChange = true;
        _page = 1;
        _loadData();
      });
    } else {
      showToast(context, S.of(context).operateFailure);
      // 1.失败 2.没有权限(管理员和创建者) 3.该申请已被处理 4.团队成员数超过上限 5.操作失败
    }
  }

  Widget _buildContent() {
    return _isLoading
        ? buildProgressIndicator()
        : _requests.length == 0
            ? _buildDefault()
            : (SmartRefresher(
                controller: _refreshController,
                enablePullDown: false,
                enablePullUp: true,
                onLoading: _onLoading,
                child: ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    Widget right;
                    if (_requests[index].state == 2) {
                      right = Container(
                        alignment: Alignment.center,
                        width: 70.0,
                        height: 20.0,
                        child: Text(
                          S.of(context).rejected,
                          style: TextStyles.textF14C2,
                        ),
                      );
                    } else if (_requests[index].state == 1) {
                      right = Container(
                        alignment: Alignment.center,
                        width: 70.0,
                        height: 20.0,
                        child: Text(
                          S.of(context).agreed,
                          style: TextStyles.textF14C2,
                        ),
                      );
                    } else {
                      right = Stack(
                        alignment: Alignment.center,
                        children: [
                          CupertinoButton(
                            child: Text(
                              S.of(context).agree,
                              style: TextStyles.textF14C3,
                            ),
                            color: themeColor,
                            minSize: 36.0,
                            pressedOpacity: 0.8,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            onPressed: () =>
                                !_dealingIds.contains(_requests[index].id)
                                    ? _agreeApply(
                                        _requests[index].id,
                                        _requests[index].userId,
                                        _requests[index].name)
                                    : null,
                          ),
                          Offstage(
                            offstage:
                                !_dealingIds.contains(_requests[index].id),
                            child: SizedBox(
                              child: buildProgressIndicator(),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      );
                    }
                    return Slidable(
                        secondaryActions: <Widget>[
                          SlideAction(
                            child: Text(
                              S.of(context).delete,
                              style: TextStyles.textF16T1,
                            ),
                            color: Colors.red,
                            closeOnTap: true,
                            onTap: () {
                              _delete(_requests[index].id, index);
                            },
                          ),
                        ],
                        closeOnScroll: true,
                        controller: _slidableController,
                        child: ListItemView(
                          title: '${_requests[index].name}',
                          label: '${_requests[index].msg}',
                          iconWidget: ImageView(
                            img: cuttingAvatar(_requests[index].avatar),
                            width: 42.0,
                            height: 42.0,
                            needLoad: true,
                            isRadius: 21.0,
                            fit: BoxFit.cover,
                          ),
                          widgetRt1: right,
                        ),
                        actionPane: SlidableBehindActionPane());
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
                )));
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() async {
    if (Navigator.canPop(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(context, isChange);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_slidableController.activeState != null) {
              _slidableController.activeState.close();
            }
          },
          child: Scaffold(
            appBar: ComMomBar(
              title: S.of(context).teamMemberVerify,
              centerTitle: false,
              backData: isChange,
              elevation: 0.5,
            ),
            body: ScrollConfiguration(
              behavior: MyBehavior(),
              child: _buildContent(),
            ),
            backgroundColor: Colors.white,
          ),
        ),
        onWillPop: _onWillPop);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
