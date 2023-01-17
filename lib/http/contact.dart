import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/contact.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as storageApi;
import 'package:cobiz_client/tools/cobiz.dart';

import 'req.dart';
import 'res/res.dart';

/// 获取好友列表
Future<List<ContactStore>> getContacts() async {
  var str = await Req.post(API.contactsUrl, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '') {
    return null;
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return ContactStore.listFromJson(res.data);
  } else {
    return ContactStore.listFromJson(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 申请添加好友
/// type: 1.通过标识添加 2.通过手机号添加 3.通过二维码添加
/// 返回: 0.成功 1.申请失败 2.指定添加的账号不存在 3.已是好友 4.指定添加的账号异常 5.已被对方拉黑 6.申请失败
Future<int> addContact(int type,
    {int userId, String phone, String code, String msg, String mark}) async {
  var str = await Req.post2(API.contactAddUrl,
      params: AESUtils.encrypt(json.encode({
        'type': type,
        'userId': userId ?? 0,
        'phone': phone,
        'code': code,
        'msg': msg,
        'mark': mark
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 1;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code;
}

/// 修改好友
Future<bool> modifyContact(
  int userId, {
  String name,
  String avatar,
  bool top = false,
  bool dnd = false,
  int burn = 0,
  bool blacklist = false,
  String nickname,
}) async {
  var str = await Req.post2(API.contactModifyUrl,
      params: AESUtils.encrypt(json.encode({
        'userId': userId,
        'name': name,
        'top': top,
        'dnd': dnd,
        'burn': burn,
        'blacklist': blacklist
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) return false;
  if (blacklist) {
    await storageApi.addLocalBlock(BlockedStore.fromJsonMap({
      'userId': userId,
      'name': name != null && name != '' ? name : nickname,
      'avatar': avatar
    }));
  } else {
    await storageApi.deleteLocalBlock(userId);
  }
  eventBus.emit(EVENT_UPDATE_CONTACT_LIST, true);
  return true;
}

/// 删除好友
Future<bool> deleteContact(int userId) async {
  var str = await Req.post2(API.contactDeleteUrl,
      params: AESUtils.encrypt(json.encode({'userId': userId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 获取好友申请列表信息
Future<List<ContactApply>> getApplies() async {
  var str = await Req.post(API.contactAppliesUrl, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List();
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '')
    return List();
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return ContactApply.listFromJson(res.data);
  } else {
    return ContactApply.listFromJson(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 处理申请信息
/// type: 1.同意 2.删除
/// 返回: true.成功 false.失败
Future<bool> dealApply(int type, int id, {String name, String avatar}) async {
  var str = await Req.post2(API.contactApplyDealUrl,
      params: AESUtils.encrypt(json.encode({'type': type, 'id': id})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    if (type == 1) {
      ChannelManager.getInstance().addSingleChat(
          id,
          name,
          avatar,
          true,
          ChatStore(getOnlyId(), 1, API.userInfo.id, id, 201, name,
              state: 2, time: DateTime.now().millisecondsSinceEpoch));
    }
    return true;
  }
  return false;
}

/// 获取黑名单列表
Future<List<BlockedStore>> getBlacklists() async {
  var str = await Req.post(API.blacklistsUrl, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '')
    return List();
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return BlockedStore.listFromJson(res.data);
  } else {
    return BlockedStore.listFromJson(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 添加/移除黑名单处理
/// type: 1.添加 2.移除
Future<bool> dealBlacklist(int type, int userId,
    {String name, String avatar, String nickname}) async {
  var str = await Req.post2(API.blacklistDealUrl,
      params: AESUtils.encrypt(json.encode({'type': type, 'userId': userId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    if ((type == 1 &&
            await storageApi.addLocalBlock(BlockedStore.fromJsonMap({
              'userId': userId,
              'name': name != null && name != '' ? name : nickname,
              'avatar': avatar
            }))) ||
        (type == 2 && await storageApi.deleteLocalBlock(userId))) {
      ChannelManager.getInstance().refresh();
      eventBus.emit(EVENT_UPDATE_CONTACT_LIST, true);
    }
  }
  return res.code == 0;
}

/// 匹配通讯录
Future<List<ContactMatch>> matchContacts(List<String> phones) async {
  var str = await Req.post2(API.matchContactsUrl,
      params: AESUtils.encrypt(json.encode({'phones': phones})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '') {
    return null;
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return ContactMatch.listFromJson(res.data);
  } else {
    return ContactMatch.listFromJson(json.decode(AESUtils.decrypt(res.data)));
  }
}
