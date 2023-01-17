import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

class NearbyTeamPage extends StatefulWidget {
  @override
  _NearbyTeamPageState createState() => _NearbyTeamPageState();
}

class _NearbyTeamPageState extends State<NearbyTeamPage> {
  bool _isLoading = true;

  RefreshController _refreshController = RefreshController();
  List<ListItemInfo> teamItems = [];

  int _page = 1;

  @override
  void initState() {
    super.initState();
    _getMoreTeams();
  }

  void _getMoreTeams({bool isLoading = false}) async {
    if (isLoading) _page++;
    List tmpList = await _fakeNearbyRequest(_page, 10);
    if (mounted) {
      setState(() {
        if ((tmpList?.length ?? 0) > 0) {
          teamItems.addAll(tmpList.map((tmp) {
            return ListItemInfo(
                icon: tmp['imgUrl'],
                name: tmp['title'],
                label: tmp['label'],
                msg1: tmp['distance']);
          }));
        } else {
          _refreshController.loadNoData();
        }
        if (isLoading) _refreshController.loadComplete();
        _isLoading = false;
      });
    }
  }

  Future _onLoading() async {
    _getMoreTeams(isLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).teamNearbyTitle,
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: _isLoading
                ? buildProgressIndicator()
                : SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: false,
                    enablePullUp: true,
                    onLoading: _onLoading,
                    child: ListView.builder(
                      itemCount: teamItems.length,
                      itemBuilder: (context, index) {
                        // if (index == 0) {
                        //   return buildSearch(context, onPressed: () {});
                        // }
                        return ListItemView(
                          title: '${teamItems[index].name}',
                          label: '${teamItems[index].label}',
                          icon: '${teamItems[index].icon}',
                          msgRt1: '${teamItems[index].msg1}',
                          msgUp: false,
                          onPressed: () {
                            // routePush(ApplyJoinTeamPage(
                            //   type: 1,
                            //   team: null,
                            // ));
                          },
                        );
                      },
                    ),
                    footer: CustomFooter(
                      loadStyle: LoadStyle.ShowAlways,
                      builder: (context, mode) {
                        if (mode == LoadStatus.loading) {
                          return Container(
                            height: 60.0,
                            child: Container(
                              height: 20.0,
                              width: 20.0,
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        } else
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            alignment: Alignment.center,
                            child: Text(S.of(context).noMoreMsg),
                          );
                      },
                    ),
                  )),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

Future<List> _fakeNearbyRequest(int page, int size) async {
  if (page > 5) {
    return null;
  }
  return Future.delayed(Duration(seconds: 1), () {
    // 获取团队数据
    List list = [];
    for (int i = 0; i < size; i++) {
      list.add({
        "title": "计算机架构宗师",
        "imgUrl": "https://avatar.csdnimg.cn/2/9/2/3_jking54.jpg",
        "label": "互联网",
        "distance": "<${i + 1 + (page - 1) * size} km"
      });
    }
    return list;
  });
}
