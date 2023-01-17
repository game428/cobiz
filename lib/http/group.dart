import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';

import 'req.dart';
import 'res/res.dart';
import 'res/y_group.dart';

/// 创建群聊
Future<dynamic> createGroup(String name, List<int> members) async {
  var str = await Req.post2(API.groupCreateUrl,
      params: AESUtils.encrypt(json.encode({'name': name, 'members': members})),
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
    return GroupBase.fromJsonMap(res.data);
  } else {
    return GroupBase.fromJsonMap(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 获取指定群聊信息
Future<dynamic> getGroup(int groupId) async {
  var str = await Req.post2(API.groupInfoUrl,
      params: AESUtils.encrypt(json.encode({'id': groupId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }

  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '') {
    return res.code; //4.团队不存在 5.小组不存在 6.部门不存在
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return GroupInfo.fromJsonMap(res.data);
  } else {
    return GroupInfo.fromJsonMap(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 删除并退出群聊
Future<bool> leave(int groupId) async {
  var str = await Req.post2(API.groupLeaveUrl,
      params: AESUtils.encrypt(json.encode({'id': groupId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 邀请添加群聊
Future<bool> inviteToGroup(int groupId, List<int> members) async {
  var str = await Req.post2(API.groupInviteUrl,
      params: AESUtils.encrypt(
          json.encode({'groupId': groupId, 'type': 1, 'members': members})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 移出添加群聊
Future<bool> removeToGroup(int groupId, List<int> members) async {
  var str = await Req.post2(API.groupInviteUrl,
      params: AESUtils.encrypt(
          json.encode({'groupId': groupId, 'type': 2, 'members': members})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 修改群名称(名称限长30)
Future<bool> modifyName(int groupId, String name) async {
  var str = await Req.post2(API.groupNameModifyUrl,
      params:
          AESUtils.encrypt(json.encode({'groupId': groupId, 'content': name})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 修改群公告(公告限长100)
Future<bool> modifyNotice(int groupId, String notice) async {
  var str = await Req.post2(API.groupNoticeModifyUrl,
      params: AESUtils.encrypt(
          json.encode({'groupId': groupId, 'content': notice})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 修改群聊设置
Future<bool> modifySettings(
    int groupId, String name, bool saved, bool dnd, int burn) async {
  var str = await Req.post2(API.groupMemberModifyUrl,
      params: AESUtils.encrypt(json.encode({
        'groupId': groupId,
        'name': name,
        'saved': saved,
        'dnd': dnd,
        'burn': burn
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 获取我的群聊列表
Future<List<MyGroup>> getMyGroups() async {
  var str = await Req.post(API.groupKeepingAllUrl, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List();
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '') {
    return List();
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return MyGroup.listFromJson(res.data);
  } else {
    return MyGroup.listFromJson(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 删除指定的我的群聊
Future<bool> deleteMyGroup(int groupId) async {
  var str = await Req.post(API.groupDelKeepingUrl,
      params: {'id': groupId}, headers: API.tokenHeader(isJson: true));
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}
