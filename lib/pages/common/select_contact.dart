import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/http/res/burn_model.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/create_group_next.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_avatar.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:cobiz_client/http/contact.dart' as contactApi;

/*
  联系人选择页面
  联系人选择页面
  联系人选择页面
  joinFromWhere:
    1: 点击主页发起群聊进入
    2：单聊界面发起群聊
    3：群聊添加成员
    4: 转发 ——> 选择联系人
    5: 单聊选择联系人名片
    6: 群聊发送名片
    7: 群聊点头像进入单聊页面发起群聊
    8: 联系人列表进入发起群聊
*/

class SelctContatPage extends StatefulWidget {
  final int joinFromWhere;
  final List<int> listGroupM; //群聊添加成员，单聊界面发起群聊
  final dynamic data;
  SelctContatPage(
      {Key key, @required this.joinFromWhere, this.listGroupM, this.data})
      : super(key: key);

  @override
  _SelctContatPageState createState() => _SelctContatPageState();
}

class _SelctContatPageState extends State<SelctContatPage> {
  double _suspensionHeight = 30;
  String _suspensionTag = '';
  double _itemHeight = 56.5;
  bool _isLoading = true;
  bool _isCanNext = false; //发起群聊 能否下一步
  List<ContactExtendIsSelected> _contacts = List();

  int _selectedNum = 0;
  List<ContactExtendIsSelected> _selectedList = [];

  int _minGroupNum = 2;

  ChannelManager _channelManager = ChannelManager.getInstance();

  @override
  void initState() {
    super.initState();
    _getContactData();
  }

  Future _getContactData() async {
    _parseStores(await localStorage.getLocalContacts());
    _loadData();
  }

  Future _loadData() async {
    try {
      final List<ContactStore> contacts = await contactApi.getContacts();
      if (contacts != null) {
        _parseStores(await localStorage.updateLocalContacts(contacts));
      }
    } catch (e) {
      debugPrint('Load contacts error: $e');
    }
  }

  void _parseStores(List<ContactStore> stores) {
    _contacts.clear();
    if ((stores?.length ?? 0) > 0) {
      stores.forEach((store) {
        switch (widget.joinFromWhere) {

          ///加载的是自己所有联系人列表
          case 1: //点击主页发起群聊进入
          case 4: //转发 ——> 选择联系人
          case 6: //群聊发送名片
            _contacts.add(ContactExtendIsSelected(
                userId: store.uid,
                name: store.name,
                avatarUrl: store.avatar,
                status: store.status,
                isSelected: false));
            break;

          ///给群里添加成员 或者 单聊好友发起群聊 控制当前（已有）成员选中，不可取消
          case 2: //单聊主页进入发起群聊
          case 3: //给群里添加成员
          case 7: //群聊点头像进入单聊页面发起群聊
          case 8:
            if (widget.listGroupM != null) {
              if (widget.listGroupM.contains(store.uid)) {
                _contacts.add(ContactExtendIsSelected(
                    userId: store.uid,
                    name: store.name,
                    avatarUrl: store.avatar,
                    status: store.status,
                    isSelected: true,
                    isCanChange: false));
              } else {
                _contacts.add(ContactExtendIsSelected(
                  userId: store.uid,
                  name: store.name,
                  avatarUrl: store.avatar,
                  status: store.status,
                  isSelected: false,
                ));
              }
            }
            break;
          case 5: //单聊页面发送名片 排除当前用户的联系人列表
            if (widget.data['id'] != store.uid) {
              _contacts.add(ContactExtendIsSelected(
                  userId: store.uid,
                  name: store.name,
                  avatarUrl: store.avatar,
                  status: store.status,
                  isSelected: false));
            }
            break;
        }
      });
      _handleList();
      if (_isLoading) {
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      }
    }
  }

  ///发送名片弹窗
  _showSendCardDialog(ContactExtendIsSelected contactExtendIsSelected) {
    showConfirm(context,
        title: S.of(context).sendTo,
        cancelBtn: S.of(context).cancelText,
        sureBtn: S.of(context).send, sureCallBack: () {
      Navigator.pop(context, contactExtendIsSelected);
    },
        contentWidget: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListItemView(
              iconWidget: widget.joinFromWhere == 5
                  ? ImageView(
                      img: cuttingAvatar(widget.data['avatar']),
                      width: 42.0,
                      height: 42.0,
                      needLoad: true,
                      isRadius: 21.0,
                      fit: BoxFit.cover,
                    )
                  : GroupAvatar(widget.data['avatar'], widget.data['name'],
                      widget.data['avatar']?.length ?? 0, widget.data['gtype']),
              title: widget.data['name'],
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
              child: Text(
                '[${S.of(context).personalCard}] ${contactExtendIsSelected.name}',
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ));
  }

  ///转发消息弹窗
  _forwardMsgDialog(ContactExtendIsSelected contactExtendIsSelected) {
    showConfirm(context,
        title: S.of(context).forwardTo,
        cancelBtn: S.of(context).cancelText,
        sureBtn: S.of(context).send, sureCallBack: () async {
      String id = getOnlyId();

      //查询给接收者设置的焚烧设置
      BurnModel _burnModel =
          await chatApi.queryUserSetting(contactExtendIsSelected.userId);

      ChatStore chat = ChatStore(id, 1, API.userInfo.id,
          contactExtendIsSelected.userId, widget.data.mtype, widget.data.msg,
          time: DateTime.now().millisecondsSinceEpoch,
          name: API.userInfo.nickname,
          state: 1,
          avatar: API.userInfo.avatar,
          burn: _burnModel?.burn ?? 0);

      String msg = '';
      if (strIsJson(chat.msg)) {
        msg = jsonDecode(chat.msg)['text'];
      } else {
        msg = chat.msg;
      }

      // 文本消息格式化
      if (chat.mtype == 1) {
        chat.msg = jsonEncode({'text': msg});
      }

      Map result = await chatApi.sendMsg(WsRequest.upMsg(chat));
      if (result == null)
        return showToast(context, S.of(context).tryAgainLater);
      _channelManager.addSingleChat(
          contactExtendIsSelected.userId,
          contactExtendIsSelected.name,
          contactExtendIsSelected.avatarUrl,
          false,
          chat);
      Navigator.pop(context);
      Navigator.pop(context, contactExtendIsSelected);
    },
        contentWidget: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListItemView(
              iconWidget: ClipOval(
                child: ImageView(
                  img: cuttingAvatar(contactExtendIsSelected.avatarUrl),
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),
              title: contactExtendIsSelected.name,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
              child: ChatMsgShow.buildMsg(context, widget.data),
            )
          ],
        ));
  }

  ///选好两人以上下一步
  _next() {
    List<ContactExtendIsSelected> selectList = [];
    for (var i = 0; i < _contacts.length; i++) {
      if (_contacts[i].isSelected == true) {
        selectList.add(_contacts[i]);
      }
    }
    if (selectList.length < 2) {
      showToast(context, S.of(context).groupMin3);
      return;
    }
    if (selectList.length > 49) {
      showToast(context, S.of(context).groupMax50);
      return;
    }
    if (widget.joinFromWhere == 1) {
      routePush(CreateGroupNext(selectList)); //home创建群聊
    } else if (widget.joinFromWhere == 2) {
      //用户主页发起群聊
      routePush(CreateGroupNext(
        selectList,
        whereCreate: 1,
      ));
    } else if (widget.joinFromWhere == 7) {
      //群聊主页进入用户主页发起群聊
      routePush(CreateGroupNext(
        selectList,
        whereCreate: 2,
      ));
    } else if (widget.joinFromWhere == 8) {
      routePush(CreateGroupNext(
        selectList,
        whereCreate: 3,
      ));
    }
  }

  ///群聊添加成员
  _addGroup() {
    Navigator.pop(context, _selectedList);
  }

  Widget _rightW() {
    switch (widget.joinFromWhere) {
      case 1: //发起创建群聊
      case 2:
      case 7:
      case 8:
        return buildSureBtn(
          text: S.of(context).next,
          textStyle: TextStyles.textF14T2,
          color: AppColors.mainColor,
          onPressed: _isCanNext
              ? () {
                  _next();
                }
              : null,
        );
        break;
      case 3: //添加群聊成员
        return buildSureBtn(
          text: S.of(context).selectedNum(_selectedNum),
          textStyle: TextStyles.textF14T2,
          color: AppColors.mainColor,
          onPressed: _isCanNext
              ? () {
                  _addGroup();
                }
              : null,
        );
        break;
      default:
        return Container();
    }
  }

  Widget _buildHeader() {
    return Container(
      width: ScreenData.width,
      padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
      child: FlatButton(
        shape: StadiumBorder(),
        child: Row(
          children: <Widget>[
            ImageView(
              img: searchImage,
            ),
            Expanded(
              child: Text(
                S.of(context).search,
                style: TextStyles.textF14T1,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
          ],
        ),
        color: greyF6Color,
        onPressed: () {
          switch (widget.joinFromWhere) {
            case 1:
            case 2:
            case 7:
              routeMaterialPush(SearchCommonPage(
                pageType: 2,
                data: _contacts,
              )).then((value) {
                if (value != null && _contacts[value].isCanChange == true) {
                  _contacts[value].isSelected = !_contacts[value].isSelected;
                  List<ContactExtendIsSelected> selectList = [];
                  for (var i = 0; i < _contacts.length; i++) {
                    if (_contacts[i].isSelected == true) {
                      selectList.add(_contacts[i]);
                    }
                  }
                  if (selectList.length >= _minGroupNum &&
                      _isCanNext == false) {
                    _isCanNext = true;
                  }
                  if (selectList.length < _minGroupNum && _isCanNext == true) {
                    _isCanNext = false;
                  }
                  if (mounted) {
                    setState(() {});
                  }
                }
              });
              break;
            case 3:
              routeMaterialPush(SearchCommonPage(
                pageType: 2,
                data: _contacts,
              )).then((value) {
                if (value != null && _contacts[value].isCanChange == true) {
                  _contacts[value].isSelected = !_contacts[value].isSelected;
                  List<ContactExtendIsSelected> selectList = [];
                  for (var i = 0; i < _contacts.length; i++) {
                    if (_contacts[i].isSelected == true &&
                        _contacts[i].isCanChange == true) {
                      selectList.add(_contacts[i]);
                    }
                  }
                  if (selectList.length >= 1 && _isCanNext == false) {
                    _isCanNext = true;
                  }
                  if (selectList.length < 1 && _isCanNext == true) {
                    _isCanNext = false;
                  }
                  _selectedNum = selectList.length;
                  _selectedList = selectList;
                  if (mounted) {
                    setState(() {});
                  }
                }
              });
              break;
            case 4:
            case 5:
            case 6:
              routeMaterialPush(SearchCommonPage(
                pageType: 15,
                data: _contacts,
              )).then((value) {
                if (value is ContactExtendIsSelected) {
                  if (widget.joinFromWhere == 4) {
                    _forwardMsgDialog(value);
                  } else if (widget.joinFromWhere == 5 ||
                      widget.joinFromWhere == 6) {
                    _showSendCardDialog(value);
                  }
                }
              });
              break;
          }
        },
      ),
    );
  }

  Widget _buildListItem(ContactExtendIsSelected model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag, true),
        ),
        /* 
          是否是勾选框
          是否是勾选框
        */
        widget.joinFromWhere == 1 ||
                widget.joinFromWhere == 2 ||
                widget.joinFromWhere == 3 ||
                widget.joinFromWhere == 7 ||
                widget.joinFromWhere == 8
            ? RadioLineView(
                paddingLeft: 20,
                color: model.isCanChange == true
                    ? Colors.white
                    : greyEAColor.withOpacity(0.3),
                radioIsCanChange: model.isCanChange,
                checkCallback: () {
                  switch (widget.joinFromWhere) {
                    case 1:
                    case 2:
                    case 7:
                    case 8:
                      if (mounted && model.isCanChange == true) {
                        model.isSelected = !model.isSelected;
                        List<ContactExtendIsSelected> selectList = [];
                        for (var i = 0; i < _contacts.length; i++) {
                          if (_contacts[i].isSelected == true) {
                            selectList.add(_contacts[i]);
                          }
                        }
                        if (selectList.length >= _minGroupNum &&
                            _isCanNext == false) {
                          _isCanNext = true;
                        }
                        if (selectList.length < _minGroupNum &&
                            _isCanNext == true) {
                          _isCanNext = false;
                        }
                        setState(() {});
                      }
                      break;
                    case 3:
                      if (mounted && model.isCanChange == true) {
                        model.isSelected = !model.isSelected;
                        List<ContactExtendIsSelected> selectList = [];
                        for (var i = 0; i < _contacts.length; i++) {
                          if (_contacts[i].isSelected == true &&
                              _contacts[i].isCanChange == true) {
                            selectList.add(_contacts[i]);
                          }
                        }
                        if (selectList.length >= 1 && _isCanNext == false) {
                          _isCanNext = true;
                        }
                        if (selectList.length < 1 && _isCanNext == true) {
                          _isCanNext = false;
                        }
                        _selectedNum = selectList.length;
                        _selectedList = selectList;
                        setState(() {});
                      }
                      break;
                    default:
                  }
                },
                checked: model.isSelected,
                iconRt: 0,
                content: IgnorePointer(
                    child: ListItemView(
                        color: model.isCanChange == true
                            ? Colors.white
                            : greyEAColor.withOpacity(0.3),
                        paddingLeft: 0,
                        title: model.name,
                        iconWidget: ImageView(
                          img: cuttingAvatar(model.avatarUrl),
                          width: 42.0,
                          height: 42.0,
                          needLoad: true,
                          isRadius: 21.0,
                          fit: BoxFit.cover,
                        ))))
            : ListItemView(
                onPressed: () {
                  switch (widget.joinFromWhere) {
                    case 4:
                      _forwardMsgDialog(model); //消息转发弹窗
                      break;
                    case 5:
                    case 6:
                      _showSendCardDialog(model); //发送名片
                      break;
                    default:
                  }
                },
                color: model.isCanChange == true
                    ? Colors.white
                    : greyEAColor.withOpacity(0.3),
                paddingLeft: 20,
                title: model.name,
                iconWidget: ImageView(
                  img: cuttingAvatar(model.avatarUrl),
                  width: 42.0,
                  height: 42.0,
                  needLoad: true,
                  isRadius: 21.0,
                  fit: BoxFit.cover,
                )),
      ],
    );
  }

  void _handleList() {
    if (_contacts == null || _contacts.isEmpty) return;
    for (int i = 0, length = _contacts.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_contacts[i].name ?? '');
      String tag =
          strNoEmpty(pinyin) ? pinyin.substring(0, 1).toUpperCase() : '';
      _contacts[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        _contacts[i].tagIndex = tag;
      } else {
        _contacts[i].tagIndex = "#";
      }
    }
    SuspensionUtil.sortListBySuspensionTag(_contacts);
    _suspensionTag = _contacts[0].tagIndex;
  }

  List<Widget> _buildContent() {
    List<Widget> items = [_buildHeader()];
    items.add(Expanded(
      child: AzListView(
        data: _contacts,
        physics: BouncingScrollPhysics(),
        header: AzListViewHeader(
            tag: '+',
            height: 0,
            builder: (context) {
              return Container();
            }),
        itemBuilder: (context, model) => _buildListItem(model),
        suspensionWidget: _buildSusWidget(_suspensionTag, false),
        showStat: false,
        isUseRealIndex: true,
        curTag: _suspensionTag,
        itemHeight: _itemHeight,
        suspensionHeight: _suspensionHeight,
        onSusTagChanged: _onSusTagChanged,
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            decoration:
                BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: Text(hint,
                style: TextStyle(color: Colors.white, fontSize: 30.0)),
          );
        },
      ),
    ));
    return items;
  }

  void _onSusTagChanged(String tag) {
    if (mounted) {
      setState(() {
        _suspensionTag = tag;
      });
    }
  }

  Widget _buildSusWidget(String susTag, bool normal) {
    return Container(
      height: _suspensionHeight.toDouble(),
      margin: normal
          ? EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            )
          : null,
      padding: EdgeInsets.only(
        left: normal ? 15.0 : 30.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: greyBCColor),
        ),
        color: normal ? Colors.white : greyF6Color,
      ),
      child: Text(
        '$susTag',
        softWrap: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).chooseFriend,
        rightDMActions: <Widget>[_rightW()],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: _buildContent(),
        ),
      ),
    );
  }
}
