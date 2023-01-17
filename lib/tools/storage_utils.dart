import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/http/res/team_model/team_group.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/team_member.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 本地数据存储

//保存本地用户信息
Future savaLocalContactInfo(UserInfo userInfo) async {
  if (userInfo == null) {
    return;
  }
  String data = await SharedUtil.instance
      .getString('${Keys.contactInfo}${API.userInfo.id}');
  if (data == null) {
    Map<String, dynamic> map = {userInfo.id.toString(): userInfo};
    await SharedUtil.instance
        .saveString('${Keys.contactInfo}${API.userInfo.id}', jsonEncode(map));
  } else {
    Map map = jsonDecode(data);
    map[userInfo.id.toString()] = userInfo;
    await SharedUtil.instance
        .saveString('${Keys.contactInfo}${API.userInfo.id}', jsonEncode(map));
  }
}

//获取本地用户信息
Future<UserInfo> getLocalContactInfo(int userId) async {
  if (userId == null) {
    return null;
  }
  String data = await SharedUtil.instance
      .getString('${Keys.contactInfo}${API.userInfo.id}');
  if (data == null) {
    return null;
  } else {
    Map map = jsonDecode(data);
    if (map[userId.toString()] == null) {
      return null;
    } else {
      return UserInfo.fromJsonMap(map[userId.toString()]);
    }
  }
}

//保存本地群组信息
Future savaLocalGroupInfo(GroupInfo groupInfo) async {
  if (groupInfo == null) {
    return;
  }
  String data = await SharedUtil.instance
      .getString('${Keys.groupInfo}${API.userInfo.id}');
  if (data == null) {
    Map<String, dynamic> map = {groupInfo.id.toString(): groupInfo};
    await SharedUtil.instance
        .saveString('${Keys.groupInfo}${API.userInfo.id}', jsonEncode(map));
  } else {
    Map map = jsonDecode(data);
    map[groupInfo.id.toString()] = groupInfo;
    await SharedUtil.instance
        .saveString('${Keys.groupInfo}${API.userInfo.id}', jsonEncode(map));
  }
}

//获取本地群组信息
Future<GroupInfo> getLocalGroupInfo(int teamId) async {
  if (teamId == null) {
    return null;
  }
  String data = await SharedUtil.instance
      .getString('${Keys.groupInfo}${API.userInfo.id}');
  if (data == null) {
    return null;
  } else {
    Map map = jsonDecode(data);
    if (map[teamId.toString()] == null) {
      return null;
    } else {
      return GroupInfo.fromJsonMap(map[teamId.toString()]);
    }
  }
}

//添加本地工作通知
Future<void> addLocalWorkMsg(WorkMsgStore store, int teamId) async {
  if (store == null) return;
  List<WorkMsgStore> chats = await getLocalWorkMsgs(teamId);
  if (chats == null || chats.length < 1) {
    List<String> list = [json.encode(store)];
    await SharedUtil.instance
        .saveStringList('${Keys.workMsg}${API.userInfo.id}_$teamId', list);
  } else {
    List<String> list = List();
    bool isUpdate = false;
    if (strNoEmpty(store.reviewer)) {
      // 如果是评论，直接新增
      list = chats.map((e) => json.encode(e)).toList();
      list.add(json.encode(store));
    } else {
      for (WorkMsgStore chat in chats) {
        if (chat.logoId == store.logoId) {
          isUpdate = true;
          list.add(json.encode(store));
        } else {
          list.add(json.encode(chat));
        }
      }
      if (isUpdate == false) {
        list.add(json.encode(store));
      }
    }
    await SharedUtil.instance
        .saveStringList('${Keys.workMsg}${API.userInfo.id}_$teamId', list);
  }
}

//更新本地通知
Future<void> updateLocalWorkMsg(WorkMsgStore store, int teamId) async {
  if (store == null) return;
  List<WorkMsgStore> chats = await getLocalWorkMsgs(teamId);
  if (chats == null || chats.length < 1) return;
  List<String> list = List();
  bool isModify = false;
  for (WorkMsgStore chat in chats) {
    // 更新
    if (chat.logoId == store.logoId) {
      chat.state = store.state;
      chat.sendTime = store.sendTime;
      isModify = true;
    }
    list.add(json.encode(chat));
  }
  if (isModify) {
    await SharedUtil.instance
        .saveStringList('${Keys.workMsg}${API.userInfo.id}_$teamId', list);
  }
}

//获取本地工作通知
Future<List<WorkMsgStore>> getLocalWorkMsgs(int teamId) async {
  return SharedUtil.instance
      .getStringList('${Keys.workMsg}${API.userInfo.id}_$teamId')
      .then((data) {
    if (data != null && data.length > 0) {
      List<WorkMsgStore> chats =
          data.map((e) => WorkMsgStore.fromJsonMap(json.decode(e))).toList();
      if (chats != null && chats.length > 1) {
        chats.sort((WorkMsgStore a, WorkMsgStore b) {
          b.sendTime = b.sendTime ?? 0;
          a.sendTime = a.sendTime ?? 0;
          return b.sendTime - a.sendTime;
        });
      }
      return chats;
    }
    return List<WorkMsgStore>();
  }).catchError((e) {
    return List<WorkMsgStore>();
  });
}

//指定工作通知记录部分删除
Future<void> deleteLocalWork(int teamId, List<String> ids) async {
  List<WorkMsgStore> works = await getLocalWorkMsgs(teamId);
  if (works == null || works.length < 1) return;
  List<String> list = List();
  for (WorkMsgStore work in works) {
    if (!ids.contains(work.logoId)) {
      list.add(json.encode(work));
    }
  }
  SharedUtil.instance
      .saveStringList('${Keys.workMsg}${API.userInfo.id}_$teamId', list);
  deleteOnLineHistory(3, teamId, ids);
}

//指定团队工作通知全删除
Future<void> deleteLocalWorkMsg(int teamId) async {
  List<WorkMsgStore> works = await getLocalWorkMsgs(teamId);
  SharedUtil.instance.remove('${Keys.workMsg}${API.userInfo.id}_$teamId');
  if (works.isEmpty) {
    deleteOnLineHistory(3, teamId, ['clear_']);
  } else {
    deleteOnLineHistory(3, teamId, ['clear_${works.first.id}']);
  }
}

//获取本地聊天记录
Future<List<ChatStore>> getLocalChats(int type, int userId) async {
  return SharedUtil.instance
      .getStringList('${Keys.chatPrefix}${API.userInfo.id}_${type}_$userId')
      .then((data) {
    if (data != null && data.length > 0) {
      List<ChatStore> chats =
          data.map((e) => ChatStore.fromJsonMap(json.decode(e))).toList();
      if (chats != null && chats.length > 1) {
        chats.sort((ChatStore a, ChatStore b) {
          return b.time - a.time;
        });
      }
      return chats;
    }
    return List<ChatStore>();
  }).catchError((e) {
    debugPrint('本地获取Chats[${type}_$userId]异常: $e');
    return List<ChatStore>();
  });
}

Future<void> updateLocalChat(ChatStore store, int userId) async {
  if (store == null) return;
  List<ChatStore> chats = await getLocalChats(store.type, userId);
  if (chats == null || chats.length < 1) return;
  List<String> list = List();
  bool isModify = false;
  for (ChatStore chat in chats) {
    if (chat.id == store.id) {
      chat.state = store.state;
      chat.time = store.time;
      isModify = true;
    }
    list.add(json.encode(chat));
  }
  if (isModify) {
    SharedUtil.instance.saveStringList(
        '${Keys.chatPrefix}${API.userInfo.id}_${store.type}_$userId', list);
  }
}

//直接替换指定用户本地 otherId 根据type 传相应的 用户id/群id 等
Future<void> addLocalAllChats(
    List<ChatStore> stores, int otherId, int type) async {
  if (stores == null || stores.isEmpty) return;
  List<String> list = [];
  stores.forEach((element) {
    list.add(json.encode(element));
  });
  await SharedUtil.instance.saveStringList(
      '${Keys.chatPrefix}${API.userInfo.id}_${type}_$otherId', list);
}

//添加本地聊天记录
Future<void> addLocalChat(ChatStore store, int userId) async {
  if (store == null) return;
  List<ChatStore> chats = await getLocalChats(store.type, userId);
  if (chats == null || chats.length < 1) {
    List<String> list = [json.encode(store)];
    await SharedUtil.instance.saveStringList(
        '${Keys.chatPrefix}${API.userInfo.id}_${store.type}_$userId', list);
  } else {
    List<String> list = List();
    for (ChatStore chat in chats) {
      if (chat.id == store.id) {
        return;
      }
      list.add(json.encode(chat));
    }
    list.add(json.encode(store));
    await SharedUtil.instance.saveStringList(
        '${Keys.chatPrefix}${API.userInfo.id}_${store.type}_$userId', list);
  }
}

//更新已读
Future<void> readLocalChat(int type, int userId, String id) async {
  List<ChatStore> chats = await getLocalChats(type, userId);
  if (chats == null || chats.length < 1) return;
  List<String> list = List();
  bool isModify = false;
  for (ChatStore chat in chats) {
    if (chat.id == id) {
      //如果是焚毁的消息 加上开始时间
      if (chat.burn != null && chat.burn != 0) {
        chat.readTime = DateTime.now().millisecondsSinceEpoch;
      }
      chat.state = 2;
      isModify = true;
    }
    list.add(json.encode(chat));
  }
  if (isModify) {
    SharedUtil.instance.saveStringList(
        '${Keys.chatPrefix}${API.userInfo.id}_${type}_$userId', list);
  }
}

//单条语音更新已读
Future<void> voiceReadLocalChat(int type, int userId, String id) async {
  List<ChatStore> chats = await getLocalChats(type, userId);
  if (chats == null || chats.length < 1) return;
  List<String> list = List();
  bool isModify = false;
  for (ChatStore chat in chats) {
    if (chat.id == id && chat.mtype == 2 && chat.isReadVoice != true) {
      chat.isReadVoice = true;
      isModify = true;
    }
    list.add(json.encode(chat));
  }
  if (isModify) {
    SharedUtil.instance.saveStringList(
        '${Keys.chatPrefix}${API.userInfo.id}_${type}_$userId', list);
  }
}

///对方已读我的消息 消息列表页面
Future<bool> readMyMsgLocalChannel(int id) async {
  List<ChannelStore> channels = await getLocalChannels();
  if (channels == null || channels.length < 1) return null;
  bool isModify = false;
  for (ChannelStore channel in channels) {
    // 如果是个人聊天且是自己发送的消息，并且对方未读，就改为已读
    if (channel.type == 1 && channel.id == id && channel.readUnread == 1) {
      channel.readUnread = 2;
      isModify = true;
      break;
    }
  }
  if (isModify) {
    await SharedUtil.instance.saveString(
        '${Keys.channels}${API.userInfo.id}', json.encode(channels));
    return true;
  } else {
    return false;
  }
}

Future<void> readLocalChats(int type, int userId, bool self) async {
  List<ChatStore> chats = await getLocalChats(type, userId);
  if (chats == null || chats.length < 1) return;
  List<String> list = List();
  bool isModify = false;
  for (ChatStore chat in chats) {
    //如果是焚毁的消息 加上开始时间
    if (chat.burn != null && chat.burn != 0 && chat.state == 1) {
      chat.readTime = DateTime.now().millisecondsSinceEpoch;
    }
    if (type == 2 && chat.state == 1) {
      chat.state = 2;
      isModify = true;
    } else if (((self && chat.receiver == userId) ||
            (!self && chat.sender == userId)) &&
        chat.state == 1) {
      chat.state = 2;
      isModify = true;
    }
    list.add(json.encode(chat));
  }
  if (isModify) {
    SharedUtil.instance.saveStringList(
        '${Keys.chatPrefix}${API.userInfo.id}_${type}_$userId', list);
  }
}

Future<void> readLocalChannel(int type, int id) async {
  List<ChannelStore> channels = await getLocalChannels();
  if (channels == null || channels.length < 1) return null;
  bool isModify = false;
  for (ChannelStore channel in channels) {
    if (channel.type == type && channel.id == id && channel.unread > 0) {
      if (type == 2 &&
          strNoEmpty(channel.label) &&
          channel.label.startsWith('{') &&
          channel.label.endsWith('}')) {
        try {
          Map<String, dynamic> labelMap = jsonDecode(channel.label);
          if (labelMap['atMe'] != null) {
            channel.label = labelMap['text'];
          }
        } catch (e) {
          // skip
        }
      }
      channel.unread = 0;
      isModify = true;
      break;
    }
  }
  if (isModify) {
    await SharedUtil.instance.saveString(
        '${Keys.channels}${API.userInfo.id}', json.encode(channels));
  }
  await readLocalChats(type, id, false);
}

//指定用户/群组消息记录全删 otherId 指根据type 传相应的 用户id/群id 等
Future<void> deleteLocalChat(int type, int otherId,
    {bool isAll = false, bool isOnlyDeleteLocal = false}) async {
  List<ChatStore> chats = [];
  if (isOnlyDeleteLocal != true) {
    chats = await getLocalChats(type, otherId);
  }

  SharedUtil.instance
      .remove('${Keys.chatPrefix}${API.userInfo.id}_${type}_$otherId');

  if (isOnlyDeleteLocal != true) {
    if (chats.isEmpty) {
      deleteOnLineHistory(type, otherId, ['clear_'], isAll: isAll);
    } else {
      deleteOnLineHistory(type, otherId, ['clear_${chats.first.id}'],
          isAll: isAll);
    }
  }
}

//指定用户消息记录部分删除
Future<void> deleteLocalChats(int type, int userId, List<String> ids,
    {bool isAll = false, bool isOnlyDeleteLocal = false}) async {
  List<ChatStore> chats = await getLocalChats(type, userId);
  if (chats == null || chats.length < 1) return;
  List<String> list = List();
  for (ChatStore chat in chats) {
    if (!ids.contains(chat.id)) {
      list.add(json.encode(chat));
    }
  }
  SharedUtil.instance.saveStringList(
      '${Keys.chatPrefix}${API.userInfo.id}_${type}_$userId', list);
  if (isOnlyDeleteLocal != true) {
    await deleteOnLineHistory(type, userId, ids, isAll: isAll);
  }
}

//删除线上聊天记录
deleteOnLineHistory(int type, int otherId, List<String> ids,
    {bool isAll = false}) async {
  List<dynamic> list = [
    {'type': type, 'otherId': otherId, 'ids': ids, 'isAll': isAll}
  ];
  bool res = await chatApi.deleteOnlineChat(list);
  if (res != true) {
    List<String> his =
        await SharedUtil.instance.getStringList(Keys.deleteHistoryFail);
    if (his == null) {
      his = [];
    }
    his.add(jsonEncode(
        {'type': type, 'otherId': otherId, 'ids': ids, 'isAll': isAll}));
    await SharedUtil.instance
        .saveStringList(Keys.deleteHistoryFail, his.toSet().toList());
  } else {
    print('删除成功了');
  }
}

//获取本地消息频道列表
Future<List<ChannelStore>> getLocalChannels() async {
  return SharedUtil.instance
      .getString('${Keys.channels}${API.userInfo.id}')
      .then((data) async {
    if (strNoEmpty(data)) {
      List<BlockedStore> blockeds = await getLocalBlocks();
      List jsonList = json.decode(data);
      if (blockeds == null || blockeds.length < 1) {
        return jsonList.map((t) => ChannelStore.fromJsonMap(t)).toList();
      } else {
        List<ChannelStore> stores = [];
        for (var tmp in jsonList) {
          ChannelStore store = ChannelStore.fromJsonMap(tmp);
          if (store.type == 1) {
            bool isBlocked = false;
            for (BlockedStore blocked in blockeds) {
              if (blocked.userId == store.id) {
                isBlocked = true;
                break;
              }
            }
            if (!isBlocked) {
              stores.add(store);
            }
          } else {
            stores.add(store);
          }
        }
        return stores;
      }
    }
    return List<ChannelStore>();
  }).catchError((e) {
    debugPrint('本地获取Channels异常/未查询到指定数据: $e');
    return List<ChannelStore>();
  });
}

// 更新本地消息频道
Future<bool> updateLocalChannel(ChannelStore channel, {int msgType}) async {
  if (channel == null) return false;
  List<ChannelStore> channels = await getLocalChannels();
  if (channels == null) {
    channels = List<ChannelStore>();
  }
  bool isModify = false;
  for (ChannelStore store in channels) {
    if (store.type == channel.type && store.id == channel.id) {
      if (channel.name != null) store.name = channel.name;
      if (channel.avatar != null) store.avatar = channel.avatar;
      if (channel.gType != null) store.gType = channel.gType;
      if (channel.teamId != null) store.teamId = channel.teamId;

      store.top = channel.top;
      if (channel.lastAt != null) {
        store.lastAt = channel.lastAt;
      } else {
        store.lastAt = DateTime.now().millisecondsSinceEpoch;
      }

      if (channel.num != null) store.num = channel.num;

      // 未读消息条数+1，如果类型不是104
      if (msgType != 104) {
        if (msgType == 11) {
          if (channel.unread >= 1) {
            store.unread--;
          } else {
            store.unread = 0;
          }
        } else {
          if (channel.unread == 1) {
            store.unread++;
          } else {
            store.unread = 0;
          }
        }
      }

      bool _curAtMe = false;
      Map<String, dynamic> labelMap;
      Map<String, dynamic> labelMap2;
      int oldMtype;
      try {
        if (strNoEmpty(channel.label) &&
            channel.label.startsWith('{') &&
            channel.label.endsWith('}')) {
          labelMap = jsonDecode(channel.label);
        }
        if (strNoEmpty(store.label) &&
            store.label.startsWith('{') &&
            store.label.endsWith('}')) {
          labelMap2 = jsonDecode(store.label);
          oldMtype = labelMap2['mtype'];
          if (labelMap2['atMe'] != null) {
            Map<String, dynamic> labelMap3 = jsonDecode(labelMap2['text']);
            oldMtype = labelMap3['mtype'];
          }
        }
      } catch (e) {
        _curAtMe = false;
      }

      if (oldMtype == 301 && labelMap['sender'] != API.userInfo.id) {
        // 如果新消息有@我，且当前显示没有@我
        if (labelMap['atMe'] != null &&
            labelMap['atMe'] &&
            labelMap2['atMe'] != true) {
          store.label = jsonEncode({'atMe': true, 'text': store.label});
        }
      } else {
        // 当前收到的消息是否有@我
        if (labelMap['atMe'] != null && labelMap['atMe']) {
          _curAtMe = true;
        } else if (labelMap['text'] != null) {
          channel.label = labelMap['text'];
        }

        // 未读的消息是否有@我
        if (!_curAtMe && labelMap2['atMe'] != null && labelMap2['atMe']) {
          channel.label = jsonEncode({'atMe': true, 'text': channel.label});
        }
        if (channel.type == 1) {
          store.readUnread = channel.readUnread;
        }
        store.label = channel.label;
      }
      isModify = true;
      break;
    }
  }
  if (!isModify) {
    channels.add(channel);
  }
  await SharedUtil.instance
      .saveString('${Keys.channels}${API.userInfo.id}', json.encode(channels));
  return true;
}

Future<List<ChannelStore>> updateLocalChannels(
    List<ChannelStore> channels) async {
  if (channels == null) return null;
  SharedUtil.instance
      .saveString('${Keys.channels}${API.userInfo.id}', json.encode(channels));
  return channels;
}

//删除指定消息频道
Future<void> deleteLocalChannel(int type, int otherId,
    {bool isAll = false, bool isOnlyDeletetLocal = false}) async {
  if (type == 3) {
    await deleteLocalWorkMsg(otherId);
  } else {
    await deleteLocalChat(type, otherId,
        isAll: isAll, isOnlyDeleteLocal: isOnlyDeletetLocal);
  }
  List<ChannelStore> channels = await getLocalChannels();
  if (channels == null || channels.length < 1) return;
  List<ChannelStore> copies = List();
  copies.addAll(channels);
  bool isRemove = false;
  for (ChannelStore channel in channels) {
    if (channel.type == type && channel.id == otherId) {
      copies.remove(channel);
      isRemove = true;
      break;
    }
  }
  if (isRemove)
    SharedUtil.instance
        .saveString('${Keys.channels}${API.userInfo.id}', json.encode(copies));
}

//查询某条消息频道
Future<ChannelStore> getLocalChannel(int type, int userId) async {
  return SharedUtil.instance
      .getString('${Keys.channels}${API.userInfo.id}')
      .then((data) {
    if (strNoEmpty(data)) {
      List jsonList = json.decode(data);
      return jsonList
          .map((t) => ChannelStore.fromJsonMap(t))
          .firstWhere((e) => e.type == type && e.id == userId);
    }
    return null;
  }).catchError((e) {
    debugPrint('本地获取Channels异常/未查询到指定数据: $e');
    return null;
  });
}

//获取本地黑名单列表
Future<List<BlockedStore>> getLocalBlocks() async {
  return SharedUtil.instance
      .getString('${Keys.blocks}${API.userInfo.id}')
      .then((data) {
    if (strNoEmpty(data)) {
      List jsonList = json.decode(data);
      return jsonList.map((t) => BlockedStore.fromJsonMap(t)).toList();
    }
    return List<BlockedStore>();
  }).catchError((e) {
    debugPrint('本地获取Blocks异常: $e');
    return List<BlockedStore>();
  });
}

//更新本地黑名单列表
Future<List<BlockedStore>> updateLocalBlocks(List<BlockedStore> blocks) async {
  if (blocks == null) return null;
  SharedUtil.instance
      .saveString('${Keys.blocks}${API.userInfo.id}', json.encode(blocks));
  return blocks;
}

//添加本地黑名单
Future<bool> addLocalBlock(BlockedStore block) async {
  if (block == null) return null;
  List<BlockedStore> stores = await getLocalBlocks();
  bool isExists = false;
  for (BlockedStore store in stores) {
    if (store.userId == block.userId) {
      isExists = true;
      break;
    }
  }
  if (!isExists) {
    stores.add(block);
    SharedUtil.instance
        .saveString('${Keys.blocks}${API.userInfo.id}', json.encode(stores));
  }
  return !isExists;
}

//移除黑名单
Future<bool> deleteLocalBlock(int userId) async {
  if (userId == null) return null;
  List<BlockedStore> stores = await getLocalBlocks();
  bool isExists = false;
  for (BlockedStore store in stores) {
    if (store.userId == userId) {
      stores.remove(store);
      isExists = true;
      break;
    }
  }
  if (isExists) {
    SharedUtil.instance
        .saveString('${Keys.blocks}${API.userInfo.id}', json.encode(stores));
  }
  return isExists;
}

//获取本地联系人列表
Future<List<ContactStore>> getLocalContacts() async {
  return SharedUtil.instance
      .getString('${Keys.contacts}${API.userInfo?.id}')
      .then((data) {
    if (strNoEmpty(data)) {
      List jsonList = json.decode(data);
      return jsonList.map((t) => ContactStore.fromJsonMap(t)).toList();
    }
    return List<ContactStore>();
  }).catchError((e) {
    debugPrint('本地获取Contacts异常: $e');
    return List<ContactStore>();
  });
}

//更新本地联系人列表
Future<List<ContactStore>> updateLocalContacts(
    List<ContactStore> contacts) async {
  if (contacts == null) return null;
  SharedUtil.instance
      .saveString('${Keys.contacts}${API.userInfo.id}', json.encode(contacts));
  return contacts;
}

//获取本地指定联系人信息
Future<ContactStore> getLocalContact(int contactId) async {
  try {
    List<ContactStore> stores = await getLocalContacts();
    if (stores == null || stores.length < 1) return null;
    return stores.firstWhere((e) => e.uid == contactId);
  } catch (e) {
    return null;
  }
}

//获取本地团队 'teams_$uid'
Future<List<TeamStore>> getLocalTeams() async {
  return SharedUtil.instance
      .getString('${Keys.teams}${API.userInfo?.id}')
      .then((data) {
    if (strNoEmpty(data)) {
      List jsonList = json.decode(data);
      return jsonList.map((t) => TeamStore.fromJsonMap(t)).toList();
    }
    return List<TeamStore>();
  }).catchError((e) {
    debugPrint('本地获取Teams异常: $e');
    return List<TeamStore>();
  });
}

//获取指定 'teamId' 团队
Future<TeamStore> getLocalTeam(int teamId) async {
  List<TeamStore> teams = await getLocalTeams();
  for (int i = 0; i < teams.length; i++) {
    if (teams[i].id == teamId) {
      return teams[i];
    }
  }
  return null;
}

//更新所有团队到本地
Future<List<TeamStore>> updateLocalTeams(List<TeamStore> userTeams) async {
  if (userTeams == null) return null;
  SharedUtil.instance
      .saveString('${Keys.teams}${API.userInfo?.id}', json.encode(userTeams));
  return userTeams;
}

//根据完整的团队信息来更新本地粗略的信息
Future<TeamInfo> updateLocalTeam(TeamInfo team) async {
  if (team == null) return null;
  List<TeamStore> stores = await getLocalTeams();
  bool isUpdate = false;
  TeamStore store;
  for (int i = 0; i < stores.length; i++) {
    if (stores[i].id != team.id) continue;

    store = stores[i];
    if (store.name != team.name) {
      store.name = team.name;
      if (!isUpdate) isUpdate = true;
    }
    if (store.icon != team.icon) {
      store.icon = team.icon;
      if (!isUpdate) isUpdate = true;
    }

    if (team.creator == API.userInfo.id) {
      store.manager = 2;
      if (!isUpdate) isUpdate = true;
    } else {
      if (team.managers.containsKey(API.userInfo.id.toString())) {
        store.manager = 1;
        if (!isUpdate) isUpdate = true;
      } else {
        store.manager = 0;
        if (!isUpdate) isUpdate = true;
      }
    }
    break;
  }
  if (store == null) {
    int man = 0;
    if (team.creator == API.userInfo.id) {
      man = 2;
    } else {
      if (team.managers.containsKey(API.userInfo.id.toString())) {
        man = 1;
      }
    }
    store = TeamStore(team.id, team.name, team.icon, man);
    stores.add(store);
    isUpdate = true;
  }
  if (!isUpdate) return null;
  SharedUtil.instance
      .saveString('${Keys.teams}${API.userInfo?.id}', json.encode(stores));
  return team;
}

//当前用户下所有小组 'groups_$uid'
Future<Map<String, List<TeamGroup>>> getLocalAllGroups() async {
  Map<String, List<TeamGroup>> map = Map();
  return SharedUtil.instance
      .getString('${Keys.groups}${API.userInfo?.id}')
      .then((data) {
    if (strNoEmpty(data)) {
      Map<String, dynamic> map2 = json.decode(data);
      map2.forEach((key, value) {
        map[key] =
            (value as List).map((t) => TeamGroup.fromJsonMap(t)).toList();
      });
    }
    return map;
  }).catchError((e) {
    debugPrint('本地获取All Groups异常: $e');
    return map;
  });
}

//获取指定团队小组列表
Future<List<TeamGroup>> getLocalGroups(int teamId) async {
  Map<String, List<TeamGroup>> map = await getLocalAllGroups();
  return map[teamId.toString()] ?? List<TeamGroup>();
}

//更新当前团队下小组列表
Future<List<TeamGroup>> updateLocalGroups(
    int teamId, List<TeamGroup> groups) async {
  if (groups == null) return null;

  Map<String, List<TeamGroup>> map = await getLocalAllGroups();
  List<TeamGroup> stores = List();
  groups.forEach((group) {
    stores.add(group);
  });
  map[teamId.toString()] = stores;
  SharedUtil.instance
      .saveString('${Keys.groups}${API.userInfo?.id}', json.encode(map));

  return groups;
}

//获取当前登录用户下所有部门 'departments_$uid'
// Future<Map<String, List<DeptStore>>> getLocalAllDepartments() async {
//   Map<String, List<DeptStore>> map = Map();
//   return SharedUtil.instance
//       .getString('${Keys.departments}${API.userInfo?.id}')
//       .then((data) {
//     if (strNoEmpty(data)) {
//       Map<String, dynamic> map2 = json.decode(data);
//       map2.forEach((key, value) {
//         map[key] =
//             (value as List).map((t) => DeptStore.fromJsonMap(t)).toList();
//       });
//     }
//     return map;
//   }).catchError((e) {
//     debugPrint('本地获取All Depts异常: $e');
//     return map;
//   });
// }

//获取本地组织部门
// Future<List<DeptStore>> getLocalDepartments(int teamId) async {
//   Map<String, List<DeptStore>> map = await getLocalAllDepartments();
//   return map[teamId] ?? List<DeptStore>();
// }

//增加本地组织部门
// Future<List<DeptStore>> addLocalDepartments(
//     String teamId, List<Dept> departments) async {
//   if (departments == null) return null;

//   Map<String, List<DeptStore>> map = await getLocalAllDepartments();
//   List<DeptStore> stores = List();
//   stores = map[teamId] ?? [];
//   departments.forEach((dept) {
//     stores.add(DeptStore.fromJsonMap(dept.toJson()));
//   });
//   map[teamId] = stores;

//   SharedUtil.instance
//       .saveString('${Keys.departments}${API.userInfo?.id}', json.encode(map));

//   return stores;
// }

//删除指定部门
// Future<void> deleteLocalDept(String teamId, String deptId) async {
//   Map<String, List<DeptStore>> map = await getLocalAllDepartments();
//   List<DeptStore> stores = List();
//   stores = map[teamId] ?? [];
//   stores.removeWhere((element) => element.id == deptId);
//   map[teamId] = stores;
//   SharedUtil.instance
//       .saveString('${Keys.departments}${API.userInfo?.id}', json.encode(map));
//   return stores;
// }

//更新某个组织部门信息
// Future<void> updateLocalDepartmentInfo(String deptId, Dept dept) async {
//   if (dept == null) return null;

//   Map<String, List<DeptStore>> map = await getLocalAllDepartments();
//   List<DeptStore> stores = List();
//   stores = map[dept.teamId] ?? [];
//   for (var i = 0; i < stores.length; i++) {
//     if (stores[i].id == deptId) {
//       stores[i] = DeptStore.fromJsonMap(dept.toJson());
//       break;
//     }
//   }
//   map[dept.teamId] = stores;
//   SharedUtil.instance
//       .saveString('${Keys.departments}${API.userInfo?.id}', json.encode(map));
//   return stores;
// }

//获取当前用户所有团队下用户 'team_members_$uid'
Future<Map<String, List<TeamMember>>> getLocalAllMembers() async {
  Map<String, List<TeamMember>> map = Map();
  return SharedUtil.instance
      .getString('${Keys.teamMembers}${API.userInfo?.id}')
      .then((data) {
    if (strNoEmpty(data)) {
      Map<String, dynamic> map2 = json.decode(data);
      map2.forEach((key, value) {
        map[key] =
            (value as List).map((t) => TeamMember.fromJsonMap(t)).toList();
      });
    }
    return map;
  }).catchError((e) {
    debugPrint('本地获取TeamMembers异常: $e');
    return map;
  });
}

//把最新的团队成员更新到本地
Future<List<TeamMember>> updateLocalMembers(
    int teamId, List<TeamMember> members) async {
  if (members == null) return List<TeamMember>();

  Map<String, List<TeamMember>> map = await getLocalAllMembers();
  List<TeamMember> stores = List();
  members.forEach((member) {
    stores.insert(0, member);
  });
  map[teamId.toString()] = stores;
  SharedUtil.instance
      .saveString('${Keys.teamMembers}${API.userInfo?.id}', json.encode(map));

  return members;
}

//获取指定团队成员列表
Future<List<TeamMember>> getLocalMembers(int teamId) async {
  Map<String, List<TeamMember>> map = await getLocalAllMembers();
  return map[teamId.toString()] ?? List<TeamMember>();
}
