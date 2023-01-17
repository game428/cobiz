import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/mobPush_manager.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/chat.dart' as syncApi;
import 'package:cobiz_client/pages/login/login_page.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/socket/ws_response.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:flutter/material.dart';
/*
  * 消息类型
  * 1: 文本，2：语音，3：图片，4：视频，5：名片, 8: 团队公告 9：工作通知 11.删除消息
  * 100: 新建群聊
  * 101：邀请进群推送，102：退群推送，103：被移除群推送
  * 104：群信息更新（如删除群成员，或群成员修改头像昵称）
  * 105：群公告，106：已被对方拉黑，201：添加好友推送
  * 108：团员邀请好友加入团队或部门
  * 121: 申请加入团队，122：已被同意加入团队
  * 301: 文本草稿缓存
  */

class ChannelManager extends ChangeNotifier {
  static ChannelManager _instance;

  List<ChannelStore> _channels;

  List<ChatStoreItem> _chatItems = List();
  bool _isChatAdding = false;

  int _lastSyncUpdata; //最后一次同步时间
  String _oldChannelStr; //最后一次channel str

  final int _syncTime = 300000; //同步间隔五分钟

  bool isRevice11 = false;

  static ChannelManager getInstance() {
    if (_instance == null) {
      _instance = ChannelManager._internal();
    }
    return _instance;
  }

  void init() {
    refresh();
  }

  List<ChannelStore> get channels {
    if (_channels == null) {
      _channels = [];
      refresh();
    }
    return _channels;
  }

  void messageHandler(WsResponse res) async {
    if (res.command > ActionValue.values.length) {
      print('未定义ActionValue${res.command}');
      return;
    }
    switch (ActionValue.values[res.command]) {
      case ActionValue.LOGIN: //登录
        var data = res.data as WsResLogin;
        if (data.data != 'success') {
          WsConnector.disconnect();
          WsConnector.connect();
        }
        break;
      case ActionValue.KICK: //被踢下线
        routePushAndRemove(LoginPage(isKick: true));
        break;
      case ActionValue.PING: //心跳
        if (_lastSyncUpdata != null &&
            DateTime.now().millisecondsSinceEpoch - _lastSyncUpdata >=
                _syncTime &&
            _oldChannelStr != jsonEncode(_channels)) {
          _lastSyncUpdata = DateTime.now().millisecondsSinceEpoch;
          _oldChannelStr = jsonEncode(_channels);
          await syncMsgChannel();
        }
        break;
      case ActionValue.READ: //已读
        upDataChannelRead(res);
        break;
      case ActionValue.AGREE: //被同意添加申请
        eventBus.emit(EVENT_UPDATE_CONTACT_LIST, true);
        break;
      case ActionValue.ADDED: //被添加好友
        eventBus.emit(EVENT_NEW_CONTACT_APPLY, true);
        break;
      case ActionValue.MSG: //聊天消息
        var data = res.data as WsResChat;
        if (!strNoEmpty(data.id) || data.mtype < 1 || !strNoEmpty(data.msg))
          return;
        _chatMsgProcessing(data);
        break;
      case ActionValue.APPLYJOINTEAM: //申请加入团队
        if (res.data['mtype'] == 121) {
          eventBus.emit(EVENT_UPDATE_TEAM_JOIN, res.data['msg']['teamId']);
          PushManager.sendJpush(data: {
            "title": res.data['msg']['applier'],
            "content": res.data['msg']['teamName'],
          }, type: 4);
        } else if (res.data['mtype'] == 122) {
          eventBus.emit(EVENT_UPDATE_TEAM, true);
        }
        break;
      case ActionValue.WORK: //工作通知
        var data = res.data as WsResChat;
        if (!strNoEmpty(data.id) || data.mtype < 1 || !strNoEmpty(data.msg)) {
          return;
        }
        _workMsgProcessing(data);
        break;
      case ActionValue.SYNCHANNEL:
        try {
          if (jsonEncode(_channels) != res.data['data']) {
            List<ChannelStore> _sync = [];
            _sync.addAll(_channels);
            List cannelOl = jsonDecode(res.data['data']);
            int dataLen = cannelOl.length;
            for (var i = 0; i < dataLen; i++) {
              ChannelStore _c = ChannelStore.fromJsonMap(cannelOl[i]);
              bool _isHavathis = false;
              for (var j = 0; j < _sync.length; j++) {
                if (_sync[j].id == _c.id) {
                  if (_c.lastAt > _sync[j].lastAt) {
                    _sync[j] = _c;
                  }
                  _isHavathis = true;
                  break;
                }
              }
              if (_isHavathis == false) {
                _sync.add(_c);
              }
            }
            await localStorage.updateLocalChannels(_sync);
            refresh();
            _oldChannelStr = jsonEncode(_sync);
            _lastSyncUpdata = DateTime.now().millisecondsSinceEpoch;
            await syncApi.syncChannel(jsonEncode(_sync));
          } else {
            _lastSyncUpdata = DateTime.now().millisecondsSinceEpoch;
            _oldChannelStr = jsonEncode(_channels);
          }
          isRevice11 = true;
        } catch (err) {
          isRevice11 = true;
        }
        break;
      default:
    }
  }

  //更新消息列表已读未读
  upDataChannelRead(WsResponse res) async {
    if (res.data == null) return;
    int _sender = res.data['sender'];
    if (_sender == null) return;
    String _id = res.data['id'];
    if (strNoEmpty(_id)) {
      localStorage.readLocalChat(1, _sender, _id);

      ///更新消息列表已读
      bool re = await localStorage.readMyMsgLocalChannel(_sender);
      if (re == true) {
        refresh();
      }
    } else {
      localStorage.readLocalChats(1, _sender, true);

      ///更新消息列表已读
      bool re = await localStorage.readMyMsgLocalChannel(_sender);
      if (re == true) {
        refresh();
      }
    }
  }

  //工作通知消息处理
  _workMsgProcessing(WsResChat workData) async {
    await addWorkMsg(
        workData.from,
        workData.name,
        workData.avatar,
        true,
        ChatStore(workData.id, workData.type, workData.from, workData.to,
            workData.mtype, workData.msg,
            state: 0,
            time: workData.time ?? DateTime.now().millisecondsSinceEpoch));
  }

  //聊天消息处理
  _chatMsgProcessing(WsResChat chatData) async {
    if (chatData.type >= ChatType.values.length) {
      print('未定义ChatType${chatData.type}');
      return;
    }
    switch (ChatType.values[chatData.type - 1]) {
      case ChatType.SINGLE: //单聊
        if (chatData.mtype == 11) {
          List<dynamic> list = jsonDecode(chatData.msg);

          if (list != null && list.isNotEmpty) {
            List<String> listStr = [];
            list.forEach((element) {
              listStr.add(element.toString());
            });
            if (listStr.length == 1 && listStr[0].startsWith('clear_')) {
              await localStorage.deleteLocalChannel(1, chatData.from,
                  isOnlyDeletetLocal: true);
              refresh();
            } else {
              List<ChatStore> chats = await localStorage.getLocalChats(
                  chatData.type, chatData.from);
              await localStorage.deleteLocalChats(
                  chatData.type, chatData.from, listStr,
                  isOnlyDeleteLocal: true);
              //以下为更新角标 channel label 操作
              bool isFin = false;
              for (var i = 0; i < listStr.length; i++) {
                for (var item in chats) {
                  //如果删除了未读的消息，让角标减1
                  if (item.id == listStr[i] && item.state == 1) {
                    //查询channel
                    ChannelStore channel =
                        await localStorage.getLocalChannel(1, chatData.from);
                    if (channel != null) {
                      await localStorage.updateLocalChannel(channel,
                          msgType: 11);
                    }
                    break;
                  }
                }
                if ((i + 1) == listStr.length) {
                  isFin = true;
                }
              }

              if (isFin) {
                // 查询一次最新的 然后更新channel
                List<ChatStore> newStores =
                    await localStorage.getLocalChats(1, chatData.from);
                //查询channel
                ChannelStore channel =
                    await localStorage.getLocalChannel(1, chatData.from);
                if (newStores.isEmpty) {
                  newStores.add(ChatStore(
                    null,
                    1,
                    API.userInfo.id,
                    chatData.from,
                    1,
                    '',
                    state: -1,
                    time: DateTime.now().millisecondsSinceEpoch,
                    readTime: DateTime.now().millisecondsSinceEpoch,
                    burn: 0,
                    name: API.userInfo.nickname,
                  ));
                }
                if (channel != null) {
                  await localStorage.updateLocalChannel(
                      ChannelStore(
                        type: 1,
                        id: channel.id,
                        name: channel.name,
                        avatar: channel.avatar,
                        label: json.encode(newStores[0]),
                        unread: channel.unread,
                        lastAt: newStores[0].time,
                        top: channel?.top,
                        // 只有自己发的，非推送消息才显示已读未读状态
                        readUnread: (newStores[0].sender == API.userInfo.id &&
                                newStores[0].mtype != 201 &&
                                newStores[0].mtype != 106 &&
                                strNoEmpty(json.encode(newStores[0])))
                            ? newStores[0].state
                            : null,
                      ),
                      msgType: 104);
                  //104不改变unread
                  refresh();
                } else {
                  refresh();
                }
              }
            }
          }
        } else {
          await addSingleChat(
              chatData.from,
              chatData.name,
              chatData.avatar,
              true,
              ChatStore(chatData.id, chatData.type, chatData.from, chatData.to,
                  chatData.mtype, chatData.msg,
                  state: 1,
                  time: chatData.time ?? DateTime.now().millisecondsSinceEpoch,
                  name: chatData.name,
                  burn: chatData.burn));
          ContactStore sender =
              await localStorage.getLocalContact(chatData.from);
          if (sender == null || sender.dnd == 0) {
            PushManager.sendJpush(data: chatData, type: 1);
            if (PushManager.isBackstage == false) {
              if (API.userInfo.vibration == true) {
                VibrationPhone.cancelVibration();
                VibrationPhone.checkVibrationPhone();
              }
              if (API.userInfo.voiceOpen == true) {
                VibrationPhone.play();
              }
            }
          }
        }

        break;
      case ChatType.GROUP: //群聊
        addGroupChat(
            chatData.to,
            chatData.gname,
            chatData.gavatar,
            chatData.gnum,
            chatData.gType,
            chatData.teamId,
            true,
            ChatStore(chatData.id, chatData.type, chatData.from, chatData.to,
                chatData.mtype, chatData.msg,
                state: 1,
                name: chatData.name,
                avatar: chatData.avatar,
                time: chatData.time ?? DateTime.now().millisecondsSinceEpoch,
                burn: chatData.burn));
        if (!(chatData?.dnd ?? true)) {
          PushManager.sendJpush(data: chatData, type: 1);
          if (PushManager.isBackstage == false) {
            if (API.userInfo.vibration == true) {
              VibrationPhone.cancelVibration();
              VibrationPhone.checkVibrationPhone();
            }
            if (API.userInfo.voiceOpen == true) {
              VibrationPhone.play();
            }
          }
        }
        break;
      default:
    }
  }

  ChannelStore getChannel(int type, int to) {
    if (_channels == null || _channels.length < 1) return null;
    try {
      return _channels
          .firstWhere((element) => element.type == type && element.id == to);
    } catch (e) {
      return null;
    }
  }

  //添加工作消息 otherId 固定是11
  Future<void> addWorkMsg(int otherId, String name, String avatar, bool out,
      ChatStore workMsg) async {
    var store = jsonDecode(workMsg.msg);
    store['sendTime'] = workMsg.time;
    store['logoId'] = workMsg.id;
    WorkMsgStore workMsgStore = WorkMsgStore.fromJsonMap(store);
    if (workMsgStore == null) {
      return;
    }

    ///推送通知
    PushManager.sendJpush(data: {
      'title': name,
      'userName': workMsgStore.name ?? "",
      'mode': (workMsgStore.mode == 1 && workMsgStore.type == 4)
          ? 10
          : workMsgStore.mode,
      'isRev': workMsgStore.reviewer
    }, type: 3);
    if (PushManager.isBackstage == false) {
      if (API.userInfo.vibration == true) {
        VibrationPhone.cancelVibration();
        VibrationPhone.checkVibrationPhone();
      }
      if (API.userInfo.voiceOpen == true) {
        VibrationPhone.play();
      }
    }
    // -----
    if (!strNoEmpty(workMsgStore.reviewer)) {
      eventBus.emit(EVENT_UPDATE_WORK, workMsgStore.teamId);
    }
    addLocalWork(otherId, name, avatar, out, workMsg, workMsgStore);
  }

  //添加单聊消息
  Future<void> addSingleChat(
      int otherId, String name, String avatar, bool out, ChatStore chat) async {
    String label = json.encode(chat);
    ContactStore contact = await localStorage.getLocalContact(otherId);
    int top = 0;
    if (contact != null) {
      name = contact.name;
      top = contact.top;
    }

    ChannelStore channelStore = ChannelStore(
      type: chat.type,
      id: otherId,
      name: name,
      avatar: avatar,
      label: label,
      unread: (chat.sender != otherId || !out) ? 0 : 1,
      lastAt: chat.time,
      top: top,
      // 只有自己发的，非推送消息才显示已读未读状态
      readUnread: (chat.sender == API.userInfo.id &&
              chat.mtype != 201 &&
              chat.mtype != 106 &&
              strNoEmpty(label))
          ? chat.state
          : null,
    );
    _addLocalChat(chat, otherId, 1,
        channelStore: channelStore, mtype: chat.mtype);
  }

  //添加群聊消息
  Future<void> addGroupChat(int groupId, String gname, List<dynamic> gavatar,
      int gnum, int gType, int teamId, bool out, ChatStore chat) async {
    String label = json.encode(chat);
    //被移除了群
    if (chat.mtype == 103) {
      await localStorage.deleteLocalChannel(2, groupId);
      refresh();
      return;
    } else if (chat.mtype == 1) {
      bool isAtMe = false;
      if (chat.msg.startsWith('{') && chat.msg.endsWith('}')) {
        try {
          Map<String, dynamic> msgMap = jsonDecode(chat.msg);
          if (msgMap['ats'] != null &&
              msgMap['ats'].contains(API.userInfo.id)) {
            isAtMe = true;
          }
        } catch (e) {
          isAtMe = false;
        }
      }
      if (isAtMe) {
        label = json.encode({'atMe': isAtMe, 'text': label});
      } else {
        label = label;
      }
    }
    if (chat.mtype == 104) {
      ChannelStore channel = await localStorage.getLocalChannel(2, groupId);
      if (channel != null) {
        channel.name = gname;
        channel.avatar = json.encode(gavatar);
        channel.num = gnum;
        channel.gType = gType;
        channel.teamId = teamId;
        bool rs =
            await localStorage.updateLocalChannel(channel, msgType: chat.mtype);
        eventBus.emit(EVENT_UPDATE_TEAM_GROUP, true);
        if (rs) {
          refresh();
        }
      }
    } else if (chat.mtype == 100) {
      int top = 0;
      bool rs = await localStorage.updateLocalChannel(
          ChannelStore(
              type: chat.type,
              id: groupId,
              name: gname,
              avatar: json.encode(gavatar),
              label: label,
              unread: (chat.sender == API.userInfo.id || !out) ? 0 : 1,
              lastAt: chat.time,
              top: top,
              num: gnum,
              gType: gType,
              teamId: teamId),
          msgType: chat.mtype);
      if (rs) {
        refresh();
      }
    } else {
      int top = 0;
      ChannelStore channelStore = ChannelStore(
          type: chat.type,
          id: groupId,
          name: gname,
          avatar: json.encode(gavatar),
          label: label,
          unread: (chat.sender == API.userInfo.id || !out) ? 0 : 1,
          lastAt: chat.time,
          top: top,
          num: gnum,
          gType: gType,
          teamId: teamId);

      _addLocalChat(chat, groupId, 2,
          channelStore: channelStore, mtype: chat.mtype);
    }
  }

  //添加工作消息 otherId 固定是11
  void addLocalWork(int otherId, String name, String avatar, bool out,
      ChatStore workMsg, WorkMsgStore workMsgStore) {
    String label = json.encode(workMsg);
    ChannelStore channelStore = ChannelStore(
      type: 3,
      id: workMsgStore.teamId,
      name: name,
      avatar: avatar,
      label: label,
      unread: !out ? 0 : 1,
      lastAt: workMsg.time,
      top: 0,
      // 只有自己发的，非推送消息才显示已读未读状态
      readUnread: null,
    );
    _addLocalChat(workMsgStore, workMsgStore.teamId, 3,
        channelStore: channelStore, mtype: workMsg.mtype);
  }

  void _addLocalChat(dynamic store, int otherId, int msgType,
      {ChannelStore channelStore, int mtype}) async {
    _chatItems.add(ChatStoreItem(store, otherId, msgType, channelStore, mtype));
    if (_isChatAdding) {
      return;
    }
    _isChatAdding = true;
    _dealLocalChat();
  }

  void _dealLocalChat() async {
    if (_chatItems.length < 1) {
      _isChatAdding = false;
      return;
    }
    ChatStoreItem item = _chatItems.removeAt(0);
    if (item.chatType == 3 && item.chat is WorkMsgStore) {
      await localStorage.addLocalWorkMsg(item.chat, item.otherId);
    } else {
      await localStorage.addLocalChat(item.chat, item.otherId);
    }
    bool rs = await localStorage.updateLocalChannel(item.channelStore,
        msgType: item.mtype);

    if (rs) {
      refresh();
    }
    _dealLocalChat();
  }

  void sort() {
    if (_channels == null && _channels.length > 1) return;
    _channels.sort((ChannelStore a, ChannelStore b) {
      if (b.top == 1 && a.top == 1) {
        return (b.lastAt ?? 0) - (a.lastAt ?? 0);
      } else if (b.top == 1) {
        return 1;
      } else if (a.top == 1) {
        return -1;
      } else {
        return (b.lastAt ?? 0) - (a.lastAt ?? 0);
      }
    });
  }

  void refresh() async {
    _channels = await localStorage.getLocalChannels();
    if (_channels.any((element) => element.unread != 0)) {
      eventBus.emit(EVENT_UPDATE_MSG_UNREAD, true);
    } else {
      eventBus.emit(EVENT_UPDATE_MSG_UNREAD, false);
    }
    sort();
    notifyListeners();
  }

  //同步一次channel
  Future<void> syncMsgChannel() async {
    if (isRevice11) {
      await syncApi.syncChannel(jsonEncode(_channels));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ChannelManager._internal();
}
