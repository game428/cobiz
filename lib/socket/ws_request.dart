import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';

class WsRequest {
  int action; // 操作类型
  Map<String, dynamic> data; //要发送的数据

  WsRequest(this.action, {this.data});

  Map<String, dynamic> toJson() {
    if (data == null) {
      data = Map<String, dynamic>();
    }
    data['command'] = action;
    return data;
  }

  @override
  String toString() {
    if (data == null) {
      data = Map<String, dynamic>();
    }
    data['command'] = action;
    return json.encode(data);
  }

  /// 更新用户键入状态
//  WsRequest.typing(String channelId, {String parentId}) {
//    action = ActionValue.TYPING.index + 1;
//    data = { 'channel_id' : channelId };
//    if (parentId != null) {
//      data['parent_id'] = parentId;
//    }
//  }

  WsRequest.authenticationChallenge() {
    action = ActionValue.LOGIN.index + 1;
    data = {
      'token': API.userToken,
      'platform': isIOS() ? 2 : (isAndroid() ? 1 : 0)
    };
  }

  WsRequest.upMsg(ChatStore chat) {
    action = ActionValue.MSG.index + 1;
    data = {
      'id': chat.id,
      'type': chat.type,
      'to': chat.receiver,
      'mtype': chat.mtype,
      'msg': chat.msg,
      'name': API.userInfo.nickname,
      'avatar': API.userInfo.avatar,
      'burn': chat.burn ?? 0
    };
  }

  WsRequest.upMsg2(Map<String, dynamic> params) {
    action = ActionValue.MSG.index + 1;
    data = params;
  }
}
