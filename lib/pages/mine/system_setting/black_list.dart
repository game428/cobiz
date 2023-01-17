import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/contact.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as storageApi;
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_item_view.dart';

class BlackListPage extends StatefulWidget {
  BlackListPage({Key key}) : super(key: key);

  @override
  _BlackListPageState createState() => _BlackListPageState();
}

class _BlackListPageState extends State<BlackListPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isOk = false;
  List<BlockedStore> _list = [];
  final SlidableController slidableController = SlidableController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future _getData() async {
    _list = await storageApi.getLocalBlocks();
    if (mounted) {
      setState(() {
        _isOk = true;
      });
    }
  }

  _remove(int userId, int index) async {
    Loading.before(context: context);
    await dealBlacklist(2, userId);
    if (mounted) {
      setState(() {
        _list.removeAt(index);
      });
    }
    Loading.complete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).blacklist,
      ),
      body: _isOk
          ? SmartRefresher(
              controller: _refreshController,
              enablePullDown: false,
              enablePullUp: false,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _list.length > 0 ? _list.length : 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index == 0 && _list.length == 0) {
                    return buildDefaultNoContent(context);
                  } else {
                    return Slidable(
                      controller: slidableController,
                      closeOnScroll: true,
                      child: ListItemView(
                        onPressed: () {
                          if (slidableController.activeState != null) {
                            slidableController.activeState.close();
                          }
                          // routePush(SingleInfoPage(
                          //   userId: _list[index].userId,
                          //   type: 2,
                          //   whereToInfo: 2,
                          // )).then((v) {
                          //   print(v);
                          //   if (v == true) {
                          //     _remove(_list[index].userId, index);
                          //   }
                          // });
                        },
                        title: _list[index].name,
                        iconWidget: ClipOval(
                          child: ImageView(
                            img: cuttingAvatar(_list[index].avatar),
                            width: 42.0,
                            height: 42.0,
                            needLoad: true,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      actionPane: SlidableScrollActionPane(),
                      secondaryActions: <Widget>[
                        SlideAction(
                          child: Text(
                            S.of(context).remove,
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.red,
                          closeOnTap: true,
                          onTap: () {
                            _remove(_list[index].userId, index);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            )
          : Center(
              child: CupertinoActivityIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
