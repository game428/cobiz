import 'package:cobiz_client/socket/command.dart';

const WS_RS_LOGIN = 'ws_rs_login';
const WS_RS_PING = 'ws_rs_ping';

class WsResLogin {
  String data;

  WsResLogin.fromJsonMap(Map<String, dynamic> map) : data = map['data'];
}

class WsResPing {
  String data;

  WsResPing.fromJsonMap(Map<String, dynamic> map) : data = map['data'];
}

class WsResChat {
  int type;
  String id;
  int from;
  int to;
  String name;
  String avatar;
  int mtype;
  String msg;
  int time;
  String gname;
  List<dynamic> gavatar;
  int gnum;
  int gType; // 0.普通 1.团队 2.小组 3.部门
  int teamId; // !0
  bool dnd;
  int burn;

  WsResChat.fromJsonMap(Map<String, dynamic> map)
      : type = map['type'],
        id = map['id'],
        from = map['from'],
        to = map['to'],
        name = map['name'],
        avatar = map['avatar'],
        mtype = map['mtype'],
        msg = map['msg'],
        time = map['time'],
        gname = map['gname'],
        gavatar = map['gavatar'],
        gnum = map['gnum'],
        gType = map['gtype'],
        teamId = map['teamId'],
        dnd = map['dnd'],
        burn = map['burn'];
}

typedef dynamic WsResDataFunc(dynamic data);

class WsResponse {
  int command; // 指令类型
  dynamic data; // 消息数据

  WsResponse.fromJsonMap(Map<String, dynamic> map)
      : command = map['command'],
        data = map {
    WsResDataFunc fun = _progressFuncs[command];
    if (fun != null) {
      data = fun(map);
    }
  }

  static Map<int, WsResDataFunc> _progressFuncs = {
    (ActionValue.LOGIN.index + 1): (data) {
      return WsResLogin.fromJsonMap(data);
    },
    (ActionValue.MSG.index + 1): (data) {
      return WsResChat.fromJsonMap(data);
    },
    (ActionValue.PING.index + 1): (data) {
      return WsResPing.fromJsonMap(data);
    },
    (ActionValue.WORK.index + 1): (data) {
      return WsResChat.fromJsonMap(data);
    },
  };
}
