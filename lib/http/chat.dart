import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/burn_model.dart';
import 'package:cobiz_client/http/res/history_msg_model.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';

import 'req.dart';
import 'res/res.dart';

///删除聊天记录
///type        int             类型:1.私聊 2.群聊 3.工作通知
///otherId     long            type=1时表示对方用户标识id, type=2时表示群聊标识id, type=3时表示teamId
///ids         List<String>    指定删除的消息id集(ids[0]="clear_id"表示全删)
Future<bool> deleteOnlineChat(List<dynamic> list) async {
  var str = await Req.post2(API.deleteChatHistory,
      params: AESUtils.encrypt(jsonEncode(list)), headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return true;
  } else {
    return false;
  }
}

// 查询单聊消息记录
///otherId     私聊对方(工作通知传: 11)
///teamId      当otherId=11时, 传值, 否则默认0
///chatId      默认空, 上一页最后一条消息的标识id
///size        每页显示数
///direct   方向: 0.最新 1.历史
Future<List<HistoryModel>> querySingleChat(int otherId,
    {int teamId = 0, String msgId, int size = 20, int direct = 0}) async {
  var str = await Req.post2(API.singleChatHistory,
      params: AESUtils.encrypt(jsonEncode({
        'otherId': otherId,
        'teamId': teamId,
        'chatId': msgId,
        'size': size,
        'direct': direct
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return HistoryModel.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
  } else {
    return null;
  }
}

// 查询群聊消息记录
///otherId     私聊对方(工作通知传: 11)
///chatId      默认空, 上一页最后一条消息的标识id
///size        每页显示数
///direct   方向: 0.最新 1.历史
Future<List<HistoryModel>> queryGroupChat(int groupId,
    {String msgId, int size = 20, int direct = 0}) async {
  var str = await Req.post2(API.groupChatHistory,
      params: AESUtils.encrypt(jsonEncode({
        'groupId': groupId,
        'chatId': msgId,
        'size': size,
        'direct': direct
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return HistoryModel.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
  } else {
    return null;
  }
}

// 消息列表同步
Future<bool> syncChannel(String data) async {
  var str = await Req.post2(API.syncChannel,
      params: AESUtils.encrypt(strNoEmpty(data) == true ? data : '[]'),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return true;
  } else {
    return false;
  }
}

// 查询好友设置
Future queryUserSetting(int userId) async {
  var str = await Req.post2(API.queryUserSetting,
      params: AESUtils.encrypt(jsonEncode({'userId': userId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return BurnModel.fromJsonMap(jsonDecode(AESUtils.decrypt(res.data)));
}

// 查询群聊设置
Future queryGroupSetting(int id) async {
  var str = await Req.post2(API.queryGroupSetting,
      params: AESUtils.encrypt(jsonEncode({'id': id})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return BurnModel.fromJsonMap(jsonDecode(AESUtils.decrypt(res.data)));
}

// 发送消息
Future<dynamic> sendMsg(WsRequest data) async {
  var str = await Req.post2(API.sendMsgUrl,
      params: AESUtils.encrypt(data.toString()), headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 2) {
    // 发送失败，你已被对方拉黑
    return {'code': res.code};
  } else if (res.code == 0) {
    return res.data;
  }
  return null;
}

Future<dynamic> readMsg(Map<String, dynamic> params) async {
  var str = await Req.post2(API.readMsgUrl,
      params: AESUtils.encrypt(json.encode(params)),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return res.data;
}
