import 'dart:convert';

import 'package:cobiz_client/pages/common/select_contact.dart';
import 'package:cobiz_client/pages/dialogue/channel/complaint/complaints_type.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat_page.dart';
import 'package:cobiz_client/pages/team/friend/friend_verify_msg.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/user.dart';

import 'package:cobiz_client/http/contact.dart' as contactApi;
import 'package:cobiz_client/http/user.dart' as userApi;
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as storageApi;
import 'package:cobiz_client/ui/view/operate_line_view.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:provider/provider.dart';
import 'package:cobiz_client/provider/global_model.dart';

class SingleInfoPage extends StatefulWidget {
  final int userId;
  final int type; // 1: 好友申请，2：黑名单
  final int
      whereToInfo; //1: 主页->chat 2:联系人好友,搜索好友，二维码扫描添加 3: 聊天页面点名片 4:群聊主页点头像 10:黑名单
  const SingleInfoPage(
      {Key key, @required this.userId, @required this.whereToInfo, this.type})
      : super(key: key);

  @override
  _SingleInfoPageState createState() => _SingleInfoPageState();
}

class _SingleInfoPageState extends State<SingleInfoPage> {
  GlobalModel model;
  ChannelManager channelManager = ChannelManager.getInstance();
  UserInfo _user;
  String _place;

  FocusNode _nameFocus = FocusNode();
  TextEditingController _nameController = TextEditingController();
  bool _isShowNameClear = false;

  bool _topChat = false;
  bool _noDisturb = false;

  List _burnSettings = List();
  int _burnSettingId;
  String _burnSettingStr;

  bool _blacklist = false;
  bool _addFriend = false;
  bool _isClearChat = false;

  @override
  void initState() {
    super.initState();
    model = Provider.of<GlobalModel>(context, listen: false);
    _init();
    _loadData();
  }

  void _init() {
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = _nameController.text.length > 0;
        });
      }
    });
  }

  void _loadData() async {
    _getLocalData(await storageApi.getLocalContactInfo(widget.userId));
    _getOnlineData();
  }

  _getLocalData(UserInfo userInfo) async {
    if (userInfo != null) {
      _user = userInfo;
      for (var item in _burnSettings) {
        if (item['value'] == _user.burn) {
          _burnSettingId = _user.burn;
          _burnSettingStr = item['text'];
          break;
        }
      }
      if (mounted) {
        setState(() {
          _nameController.text = _user.name;
          _blacklist = _user.blacklist;
          _topChat = _user.topChat;
          _noDisturb = _user.dnd;
        });
        if ((_user?.area1 ?? 0) > 0) _getPlace();
      }
    }
  }

  _getOnlineData() async {
    UserInfo userOnline = await userApi.getUserInfo(userId: widget.userId);
    await storageApi.savaLocalContactInfo(userOnline);
    if (userOnline == null) {
      showToast(context, S.of(context).tryAgainLater);
      Navigator.pop(context);
    } else {
      _getLocalData(userOnline);
    }
  }

  void _getPlace() async {
    await getRegion(context).then((value) {
      String place = getPlace(value,
          area1: _user.area1, area2: _user.area2, area3: _user.area3);
      if (mounted) {
        setState(() {
          _place = place;
        });
      }
    });
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() {
    if (Navigator.canPop(context)) {
      FocusScope.of(context).requestFocus(FocusNode());
      Navigator.pop(
          context,
          widget.type == 1
              ? _addFriend
              : widget.type == 2
                  ? !_blacklist
                  : jsonEncode({
                      "_isClearChat": _isClearChat,
                      "name": strNoEmpty(_nameController.text)
                          ? _nameController.text
                          : _user?.nickname ?? '',
                      "burn": _burnSettingId
                    }));
    }
    _dealUpdate();
    return Future.value(false);
  }

  Future<void> _dealUpdate() async {
    if (_user == null) return;
    if (_user.friend == false && _blacklist != _user.blacklist) {
      contactApi.dealBlacklist(_blacklist == false ? 2 : 1, _user.id,
          name: _user.name,
          avatar: _user.avatar ?? '',
          nickname: _user?.nickname);
    } else {
      if (_nameController.text == _user.name &&
          _topChat == _user.topChat &&
          _noDisturb == _user.dnd &&
          (_burnSettingId ?? 0) == _user.burn &&
          _blacklist == _user.blacklist) return;
      bool state = await contactApi.modifyContact(widget.userId,
          name: _nameController.text,
          avatar: _user.avatar ?? '',
          top: _topChat,
          dnd: _noDisturb,
          burn: _burnSettingId ?? 0,
          blacklist: _blacklist,
          nickname: _user?.nickname);
      if (state) {
        _user?.burn = _burnSettingId ?? 0;
        ChannelStore channel =
            await storageApi.getLocalChannel(1, widget.userId);
        if (channel != null) {
          channel.top = _topChat ? 1 : 0;
          if (strNoEmpty(_nameController.text)) {
            channel.name = _nameController.text;
          } else {
            channel.name = _user.nickname;
          }
          await storageApi.updateLocalChannel(channel);
          ChannelManager.getInstance().refresh();
        }
      }
    }
  }

  Widget sexItem() {
    //  || (_user?.birthday ?? 0) > 0
    int sex = _user?.gender ?? 0;
    return sex != 0
        ? ImageView(
            img: 'assets/images/mine/${sex == 1 ? 'boy' : 'girl2'}.png',
            width: 20.0,
            // height: 20.0,
          )
        : Container();
  }

  Widget _buildHead() {
    return Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            child: Stack(
              children: [
                InkWell(
                  onTap: () {
                    if (_user != null && _user.avatar.isNotEmpty) {
                      Widget image;
                      if (isNetWorkImg(_user.avatar)) {
                        image = ExtendedImage.network(
                          _user.avatar,
                          width: ScreenData.width,
                          mode: ExtendedImageMode.gesture,
                          initGestureConfigHandler: (state) {
                            return GestureConfig(
                              minScale: 0.9,
                              animationMinScale: 0.7,
                              maxScale: 10.0,
                              animationMaxScale: 10.5,
                              speed: 1.0,
                              inertialSpeed: 100.0,
                              initialScale: 1.0,
                              inPageView: true,
                              initialAlignment: InitialAlignment.center,
                            );
                          },
                        );
                      } else {
                        File fileItem = File(_user.avatar);
                        image = ExtendedImage.file(
                          fileItem,
                          width: ScreenData.width,
                          mode: ExtendedImageMode.gesture,
                          initGestureConfigHandler: (state) {
                            return GestureConfig(
                              minScale: 0.9,
                              animationMinScale: 0.7,
                              maxScale: 10.0,
                              animationMaxScale: 10.5,
                              speed: 1.0,
                              inertialSpeed: 100.0,
                              initialScale: 1.0,
                              inPageView: true,
                              initialAlignment: InitialAlignment.center,
                            );
                          },
                        );
                      }
                      routeMaterialPush(
                        Material(
                          child: InkWell(
                            child: Container(
                              color: Colors.black87,
                              width: ScreenData.width,
                              height: ScreenData.height,
                              child: image,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: ImageView(
                    img: cuttingAvatar(_user?.avatar ?? ''),
                    width: 60.0,
                    height: 60.0,
                    needLoad: true,
                    isRadius: 35.0,
                    fit: BoxFit.cover,
                  ),
                ),
                // ((_user != null && _user.broker == true)
                //     ? Positioned(
                //         child: ImageView(
                //           img: 'assets/images/mine/certified.png',
                //           width: 25.0,
                //           height: 25.0,
                //           fit: BoxFit.cover,
                //         ),
                //         right: 0.0,
                //         bottom: 0.0,
                //       )
                //     : Container()),
              ],
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                      child: Container(
                    child: Text(
                      _user?.nickname ?? '',
                      style: TextStyles.textF18,
                    ),
                  ))
                  // sexItem(),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              strNoEmpty(_place)
                  ? Container(
                      constraints: BoxConstraints(
                        maxWidth: winWidth(context) - 140,
                      ),
                      child: Text(
                        _place,
                        style: TextStyles.textF12T1,
                      ),
                    )
                  : Container(),
            ],
          )),
        ],
      ),
    );
  }

  void _selectBurnSetting() {
    showDataPicker(
        context,
        DataPicker(
          jsonData: _burnSettings,
          isArray: false,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selecteds) {
            if (mounted) {
              setState(() {
                _burnSettingId = values[0].value;
                _burnSettingStr = values[0].text;
              });
            }
          },
        ));
  }

  void _clearSingleChat(bool isAll) async {
    await storageApi.deleteLocalChannel(1, widget.userId, isAll: isAll);
    if (mounted) {
      setState(() {
        _isClearChat = true;
      });
    }
    channelManager.refresh();
  }

  Widget buttonItem(bool isFriend) {
    if (_blacklist) {
      return Container();
    }
    // List<Widget> row = [
    //   Container(
    //     margin: EdgeInsets.only(top: 20, bottom: 20),
    //     width: (ScreenData.width - 50) / 2,
    //     height: 50,
    //     child: FlatButton(
    //       color: greyEFColor,
    //       colorBrightness: Brightness.dark,
    //       splashColor: Colors.grey,
    //       child: Text(S.of(context).chatWithTa, style: TextStyle(color: grey28Color),),
    //       shape:
    //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    //       onPressed: () async {
    //         String event =
    //             'chat1_${widget.userId > API.userInfo.id ? API.userInfo.id : widget.userId}_${widget.userId > API.userInfo.id ? widget.userId : API.userInfo.id}';
    //         bool exists = WsConnector.existsEvent(event);
    //         if (exists) {
    //           Navigator.pop(context);
    //         } else {
    //           routePush(SingleChatPage(
    //             userId: widget.userId,
    //             name: strNoEmpty(_user.name) ? _user.name : _user.nickname,
    //             avatar: _user.avatar,
    //           ));
    //         }
    //       },
    //     ),
    //   )
    // ];
    if (isFriend) {
      return Row(
        children: [
          Expanded(
            child: buildCommonButton(
              S.of(context).chat,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              paddingV: 8,
              onPressed: () {
                switch (widget.whereToInfo) {
                  case 1:
                    if (Navigator.canPop(context)) {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.pop(
                          context,
                          widget.type == 1
                              ? _addFriend
                              : widget.type == 2
                                  ? !_blacklist
                                  : jsonEncode({
                                      "_isClearChat": _isClearChat,
                                      "name": strNoEmpty(_nameController.text)
                                          ? _nameController.text
                                          : _user?.nickname ?? ''
                                    }));
                    }
                    _dealUpdate();
                    break;
                  case 2:
                    String name = _user.nickname ?? _user.name;
                    int tempBurn;
                    if (_nameController.text.isNotEmpty) {
                      name = _nameController.text;
                    }
                    // 从信息界面聊天 自己用临时burn 并同时调接口通知对方
                    if (_burnSettingId != _user.burn) {
                      tempBurn = _burnSettingId;
                      _dealUpdate();
                    }
                    routePush(SingleChatPage(
                      userId: _user.id,
                      name: name,
                      avatar: _user.avatar,
                      whereToChat: 2,
                      tempBurn: tempBurn,
                    ));
                    break;
                  case 3:
                  case 4:
                    String name = _user.nickname ?? _user.name;
                    if (_nameController.text.isNotEmpty) {
                      name = _nameController.text;
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (widget.whereToInfo == 4) {
                      Navigator.pop(context);
                    }
                    routePush(SingleChatPage(
                      userId: _user.id,
                      name: name,
                      avatar: _user.avatar,
                      whereToChat: 1,
                    ));
                    break;
                  default:
                }
              },
            ),
          ),
          Expanded(
            child: buildCommonButton(
              S.of(context).deleteFriend,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              backgroundColor: red68Color,
              onPressed: () {
                showSureModal(
                  context,
                  S.of(context).ok,
                  () async {
                    var res = await contactApi.deleteContact(_user.id);
                    if (res) {
                      await storageApi.deleteLocalChannel(1, widget.userId);
                      channelManager.refresh();
                      eventBus.emit(EVENT_UPDATE_CONTACT_LIST, true);
                      Navigator.pop(context, jsonEncode({"delFriend": true}));
                    }
                  },
                  promptText: S.of(context).deleteFriendHint,
                  textAlign: TextAlign.center,
                );
              },
            ),
          )
        ],
      );
    } else {
      return buildCommonButton(
        S.of(context).addFriends,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        onPressed: () {
          routePush(FriendVerifyMsg(userInfo: _user));
        },
      );
    }
  }

  List<Widget> listBuild() {
    List<Widget> list = [
      _buildHead(),
    ];
    bool isFriend = _user?.friend ?? false;
    if (isFriend && !_blacklist) {
      // list.add(OperateLineView(
      //   title: S.of(context).phone,
      //   rightWidget: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Container(
      //         width: 150,
      //         alignment: Alignment.centerRight,
      //         child: Text('13123456447',
      //             maxLines: 1, overflow: TextOverflow.ellipsis),
      //       ),
      //       InkWell(
      //         child: ImageView(
      //           width: IconTheme.of(context).size,
      //           height: IconTheme.of(context).size,
      //           img: 'assets/images/work/ic_call.png',
      //           fit: BoxFit.cover,
      //         ),
      //         onTap: () {
      //           showSureModal(
      //               context, S.of(context).confirmCallPhone('13123456447'),
      //               () async {
      //             String url = "tel:13123456447";
      //             if (await canLaunch(url)) {
      //               await launch(url);
      //             } else {
      //               throw 'Could not launch $url';
      //             }
      //           });
      //         },
      //       )
      //     ],
      //   ),
      //   isArrow: false,
      // ));
      // list.add(OperateLineView(
      //   title: S.of(context).team,
      //   rightWidget: Flexible(
      //       child: Padding(
      //     padding: EdgeInsets.only(left: 30),
      //     child: Text(
      //       '北京哇零哇零有限公司',
      //       maxLines: 1,
      //       overflow: TextOverflow.ellipsis,
      //     ),
      //   )),
      //   isArrow: false,
      //   haveBorder: false,
      // ));

      list.add(buildDivider(height: 8.0, color: greyEAColor));
      list.add(EditLineView(
        title: S.of(context).setNotes,
        hintText: S.of(context).plzFillRemarkName,
        textController: _nameController,
        focusNode: _nameFocus,
        isShowClear: _isShowNameClear,
        maxLen: 30,
      ));
      // list.add(OperateLineView(
      //   title: S.of(context).signature,
      //   onPressed: () {
      //     // routeMaterialPush(ModifySignature(signature: _user.mark, readOnly: true));
      //   },
      //   rightWidget: Container(
      //     width: 150,
      //     alignment: Alignment.centerRight,
      //     child: Text(
      //       _user?.mark ?? '',
      //       maxLines: 1,
      //       overflow: TextOverflow.ellipsis,
      //       style: TextStyles.textF16T4,
      //     ),
      //   ),
      // ));
      list.add(buildSwitch(S.of(context).pinedToTop, _topChat, (v) {
        if (mounted) {
          setState(() {
            _topChat = v;
          });
        }
      }));
      list.add(buildSwitch(S.of(context).doNotDisturb, _noDisturb, (v) {
        if (mounted) {
          setState(() {
            _noDisturb = v;
          });
        }
      }, isLine: false));
      list.add(buildDivider(height: 8.0, color: greyEAColor));
      list.add(EditLineView(
        title: S.of(context).burnAfterReading,
        text: _burnSettingStr ?? S.of(context).close,
        haveArrow: true,
        onPressed: _selectBurnSetting,
      ));
      list.add(OperateLineView(
        title: S.of(context).addGroupChat,
        onPressed: () {
          routePush(SelctContatPage(
              joinFromWhere: widget.whereToInfo == 4
                  ? 7
                  : (widget.whereToInfo == 2 ? 8 : 2),
              listGroupM: [_user.id]));
        },
      ));
    }
    if (!_blacklist) {
      list.add(OperateLineView(
        title: S.of(context).clearHistory,
        haveBorder: false,
        onPressed: () {
          showSureModal(
              context,
              S.of(context).clearHistory,
              () {
                _clearSingleChat(false);
              },
              text2: S.of(context).deleteOther(_user?.nickname),
              onPressed2: () {
                _clearSingleChat(true);
              });
        },
      ));
      list.add(buildDivider(height: 8.0, color: greyEAColor));
    }
    list.add(
      buildSwitch(S.of(context).addToBlacklist, _blacklist, (v) {
        if (v == true) {
          showSureModal(context, S.of(context).ok, () {
            if (mounted) {
              setState(() {
                _blacklist = v;
              });
            }
          },
              promptText: S.of(context).putBlockUwill,
              textAlign: TextAlign.center);
        } else if (mounted) {
          setState(() {
            _blacklist = v;
          });
        }
      }),
    );
    list.add(OperateLineView(
      title: S.of(context).complaints,
      haveBorder: _blacklist,
      onPressed: () {
        routeMaterialPush(ComplaintsTypePage(
          from: 1,
          targetId: widget.userId,
        ));
      },
    ));
    if (!_blacklist) {
      list.add(buildDivider(height: 8.0, color: greyEAColor));
      list.add(buttonItem(isFriend));
    }
    return list;
  }

  Widget _buildOperate() {
    return Expanded(
      child: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 20.0),
          children: listBuild()),
    );
  }

  @override
  Widget build(BuildContext context) {
    _burnSettings.clear();
    _burnSettings.addAll(burnSettingList(context));
    return WillPopScope(
        onWillPop: _onWillPop,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: ComMomBar(
              elevation: 0.5,
              backData: widget.type == 1
                  ? _addFriend
                  : widget.type == 2
                      ? !_blacklist
                      : jsonEncode({
                          "_isClearChat": _isClearChat,
                          "name": strNoEmpty(_nameController.text)
                              ? _nameController.text
                              : _user?.nickname ?? '',
                          "burn": _burnSettingId
                        }),
              backCall: _dealUpdate,
            ),
            body: Column(
              children: <Widget>[
                _user != null
                    ? _buildOperate()
                    : Expanded(
                        child: Center(
                          child: CupertinoActivityIndicator(),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _nameFocus.dispose();
    _nameController.dispose();
  }
}
