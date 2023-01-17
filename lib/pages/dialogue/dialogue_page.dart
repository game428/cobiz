import 'dart:convert';

import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/pages/common/scan_deal.dart';
import 'package:cobiz_client/pages/common/select_contact.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/work_notice_msg.dart';
import 'package:cobiz_client/pages/dialogue/no_internet_hint.dart';
import 'package:cobiz_client/pages/team/friend/add_friend.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/team/team_page/search_team.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/channel/channel_list_cell.dart';
import 'package:cobiz_client/ui/menu/popup_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:flutter_slidable/flutter_slidable.dart';

class DialoguePage extends StatefulWidget {
  DialoguePage({Key key}) : super(key: key);

  @override
  _DialoguePageState createState() => _DialoguePageState();
}

class _DialoguePageState extends State<DialoguePage>
    with AutomaticKeepAliveClientMixin {
  ChannelManager _channelManager = ChannelManager.getInstance();
  final SlidableController _slidableController = SlidableController();

  //是否连接
  bool _isConnecting = false;
  //是否断网 只关于开启wifi或数据 不代表网络实际可用
  bool _brokenNetwork = false;

  @override
  void initState() {
    super.initState();
    _initListener();
  }

  @override
  void dispose() {
    _cancelListener();
    eventBus.off(EVENT_SOCKET_IS_RECONNECTION);
    super.dispose();
  }

  Future<void> _initListener() async {
    if (!mounted) return;
    _brokenNetwork = await SharedUtil.instance.getBoolean(Keys.brokenNetwork);
    eventBus.on(EVENT_SOCKET_IS_RECONNECTION, (arg) async {
      if (arg == WsStatus.connecting && _isConnecting == true) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
      } else if (arg == WsStatus.connected && _isConnecting == false) {
        if (mounted) {
          setState(() {
            _isConnecting = true;
          });
        }
      }

      // 单独处理网络连接情况
      if (arg == 'no_wifi_and_mobile' && _brokenNetwork == false) {
        _brokenNetwork =
            await SharedUtil.instance.getBoolean(Keys.brokenNetwork);
        if (_brokenNetwork) {
          showToast(context, S.of(context).noNetwork, duration: 3);
        }
        if (mounted) {
          setState(() {});
        }
      }
      if (arg == 'wifi_or_mobile' && _brokenNetwork == true) {
        _brokenNetwork =
            await SharedUtil.instance.getBoolean(Keys.brokenNetwork);
        if (mounted) {
          setState(() {});
        }
      }
    });
    _channelManager.addListener(_channelListener);
  }

  //断网红色提示按钮
  Widget _noNetworkBtn() {
    return InkWell(
      onTap: () {
        routePush(NoInternetHint());
      },
      child: Container(
        color: Colors.red[100],
        padding: EdgeInsets.fromLTRB(26, 10, 15, 10),
        child: Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 20,
            ),
            SizedBox(width: 26),
            Expanded(
                child: Text(S.of(context).checkInternet,
                    style: TextStyle(fontSize: 14, color: grey81Color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            Icon(
              Icons.keyboard_arrow_right,
              size: 20,
              color: grey81Color,
            ),
          ],
        ),
      ),
    );
  }

  void _channelListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _cancelListener() {
    _channelManager.removeListener(_channelListener);
  }

  /// 顶部 + 号菜单 method
  void _actionsHandle(PMenuItem item) async {
    switch (item.value) {
      case MsgMenuValue.groupChat:
        routePush(SelctContatPage(
          joinFromWhere: 1,
        ));
        break;
      case MsgMenuValue.addFriend:
        routePush(AddFriendPage());
        break;
      case MsgMenuValue.scan:
        if (await PermissionManger.cameraPermission()) {
          await Scanner.scanDeal(context);
        } else {
          showConfirm(context, title: S.of(context).cameraPermission,
              sureCallBack: () async {
            await openAppSettings();
          });
        }
        break;
      case MsgMenuValue.joinTeam:
        routePush(SearchTeamPage());
        break;
    }
  }

  _clearSingleChat(int type, int id, {bool isAll = false}) async {
    await localStorage.deleteLocalChannel(type, id, isAll: isAll);
    _channelManager.refresh();
  }

  /// 顶部 + 号菜单
  Widget buildPopMenu() {
    return PopupMenu(
      icon: Icon(
        Icons.more_horiz,
        color: AppColors.white,
      ),
      list: [
        PMenuItem(MsgMenuValue.groupChat, S.of(context).addGroupChat,
            'assets/images/ic_chat.png'),
        PMenuItem(MsgMenuValue.addFriend, S.of(context).addFriends,
            'assets/images/ic_add.png'),
        PMenuItem(MsgMenuValue.joinTeam, S.of(context).joinTeam,
            'assets/images/add_group.png'),
        PMenuItem(
            MsgMenuValue.scan, S.of(context).qrc, 'assets/images/ic_scan.png'),
      ],
      onSelected: _actionsHandle,
    );
  }

  Widget _buildMsgList() {
    return _channelManager.channels.length > 0
        ? ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    buildSearch(context, onPressed: () {
                      routeMaterialPush(SearchCommonPage(
                        pageType: 3,
                        data: _channelManager.channels,
                      ));
                    }),
                    !_brokenNetwork ? Container() : _noNetworkBtn()
                  ],
                );
              }
              return Slidable(
                controller: _slidableController,
                closeOnScroll: true,
                child: InkWell(
                  onTap: () {
                    if (_slidableController.activeState != null) {
                      _slidableController.activeState.close();
                    }
                    switch (_channelManager.channels[index - 1].type) {
                      case 1: //私聊
                        routePush(SingleChatPage(
                            userId: _channelManager.channels[index - 1].id,
                            name:
                                _channelManager.channels[index - 1].name ?? '',
                            avatar:
                                _channelManager.channels[index - 1].avatar ??
                                    '',
                            whereToChat: 1));
                        break;
                      case 2: //群聊 //团队
                        routePush(GroupChatPage(
                          groupId: _channelManager.channels[index - 1].id,
                          groupName:
                              _channelManager.channels[index - 1].name ?? '',
                          groupAvatar: jsonDecode(
                              _channelManager.channels[index - 1].avatar),
                          groupNum:
                              _channelManager.channels[index - 1].num ?? 0,
                          gType: _channelManager.channels[index - 1].gType ?? 0,
                          teamId:
                              _channelManager.channels[index - 1].teamId ?? 0,
                        ));
                        break;
                      case 3: //工作通知
                        routePush(WorkNoticeMsgPage(
                            _channelManager.channels[index - 1].id,
                            _channelManager.channels[index - 1].name ?? ''));
                        break;
                      default:
                    }
                  },
                  child: ChannelListCell(
                    channelStore: _channelManager.channels[index - 1],
                  ),
                ),
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
                      showSureModal(context, S.of(context).sureDeleteTheChat,
                          () {
                        _clearSingleChat(
                            _channelManager.channels[index - 1].type,
                            _channelManager.channels[index - 1].id);
                      },
                          text2: _channelManager.channels[index - 1].type == 1
                              ? S.of(context).deleteOther(
                                  _channelManager.channels[index - 1].name)
                              : null,
                          onPressed2: _channelManager
                                      .channels[index - 1].type ==
                                  1
                              ? () {
                                  _clearSingleChat(
                                      _channelManager.channels[index - 1].type,
                                      _channelManager.channels[index - 1].id,
                                      isAll: true);
                                }
                              : null);
                    },
                  ),
                ],
              );
            },
            itemCount: _channelManager.channels.length + 1,
          )
        : Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 50.0),
                child: Center(
                  child: Column(
                    children: [
                      ImageView(img: noMsg),
                      Text(S.of(context).startChat, style: TextStyles.textF17T2)
                    ],
                  ),
                ),
              ),
              Positioned(child: !_brokenNetwork ? Container() : _noNetworkBtn())
            ],
          );
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        if (_slidableController.activeState != null) {
          _slidableController.activeState.close();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: _buildMsgList(),
        appBar: ComMomBar(
          automaticallyImplyLeading: false,
          elevation: 0.5,
          backgroundColor: AppColors.mainColor,
          mainColor: AppColors.white,
          titleW: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _isConnecting
                  ? Text(
                      'Cobiz',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Container(),
              buildProgressIndicator(isLoading: !_isConnecting),
              !_isConnecting
                  ? Text(
                      S.of(context).connecting,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Container(),
            ],
          ),
          centerTitle: false,
          rightDMActions: [buildPopMenu()],
        ),
      ),
    );
  }
}
