import 'package:cobiz_client/http/contact.dart';
import 'package:cobiz_client/http/res/contact.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FriendVerifyPage extends StatefulWidget {
  @override
  _FriendVerifyPageState createState() => _FriendVerifyPageState();
}

class _FriendVerifyPageState extends State<FriendVerifyPage> {
  final SlidableController _slidableController = SlidableController();

  bool _isLoading = true;
  List<ContactApply> _resps = [];
  List<String> _dealingIds = List();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future _loadData() async {
    _resps = await getApplies();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDefault() {
    return buildDefaultNoContent(context);
  }

  //同意
  Future _agreeApply(ContactApply apply, int index) async {
    var res = await dealApply(1, apply.userId,
        name: apply.name, avatar: apply.avatar);
    if (res == true) {
      eventBus.emit(EVENT_UPDATE_CONTACT_LIST, true);
      _resps[index].state = 1;
      if (mounted) {
        setState(() {});
      }
    }
  }

  ///删除
  _delete(int uId, int index) async {
    var res = await dealApply(2, uId);
    if (res && mounted) {
      setState(() {
        _resps.removeAt(index);
      });
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  Widget _buildContent() {
    return !_isLoading
        ? _resps.length == 0
            ? _buildDefault()
            : (ListView.builder(
                itemCount: _resps.length,
                itemBuilder: (context, index) {
                  Widget right;
                  if (_resps[index].state == 2) {
                    right = Container(
                      alignment: Alignment.center,
                      width: 70.0,
                      height: 20.0,
                      child: Text(
                        S.of(context).rejected,
                        style: TextStyles.textF14C2,
                      ),
                    );
                  } else if (_resps[index].state == 1) {
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
                    right = _dealingIds.contains(_resps[index].id)
                        ? buildProgressIndicator()
                        : CupertinoButton(
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
                            onPressed: () {
                              if (_slidableController.activeState != null) {
                                _slidableController.activeState.close();
                              }
                              _agreeApply(_resps[index], index);
                            },
                          );
                  }

                  return Slidable(
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
                          _delete(_resps[index].userId, index);
                        },
                      ),
                    ],
                    closeOnScroll: true,
                    controller: _slidableController,
                    child: ListItemView(
                      title: '${(_resps[index].name)}',
                      label: '${_resps[index].msg}',
                      iconWidget: ImageView(
                        img: cuttingAvatar(_resps[index].avatar),
                        width: 42.0,
                        height: 42.0,
                        needLoad: true,
                        isRadius: 21.0,
                        fit: BoxFit.cover,
                      ),
                      widgetRt1: right,
                    ),
                  );
                },
              ))
        : buildProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_slidableController.activeState != null) {
          _slidableController.activeState.close();
        }
      },
      child: Scaffold(
        appBar: ComMomBar(
          title: S.of(context).friendVerify,
          // titleW: Row(
          //   children: <Widget>[
          //     Text(
          //       S.of(context).friendVerify,
          //       style: TextStyles.textNavTitle,
          //     ),
          //     SizedBox(
          //       width: 5.0,
          //     ),
          //     _haveNewContactApply
          //         ? buildMessaged()
          //         : SizedBox(
          //             width: 0.0,
          //           ),
          //   ],
          // ),
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: _buildContent(),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
