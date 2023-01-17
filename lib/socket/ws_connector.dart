import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/provider_config.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/http/user.dart' as userApi;
import 'package:cobiz_client/pages/login/login_page.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:cobiz_client/socket/ws_response.dart';
import 'package:cobiz_client/socket/ws_request.dart';

typedef WsCallback(data);

enum WsStatus {
  connecting,
  connected,
  failed,
  closed,
}

class WsConnector {
  WsConnector._();

  static final _eventMap = <String, List<WsCallback>>{};
  static WsStatus _status = WsStatus.closed; // 连接状态
  static bool _reconnecting = false; // 是否已经安排了重连

  static WebSocketChannel _channel;

  static get status => _status;

  static ChannelManager channelManager = ChannelManager.getInstance();

  static Timer _timer;
  static int _lastPongTime;

  // 退出登录时要断开连接
  static void disconnect() {
    if (_status == WsStatus.closed) return;
    _status = WsStatus.closed;
    if (_channel != null) _channel.sink.close();

    //同步消息channel
    channelManager.syncMsgChannel();

    _channel = null;
    _lastPongTime = null;
    _timer?.cancel();
    _timer = null;
  }

  // 执行连接，必须登录后才能执行
  static void connect() async {
    if (_status == WsStatus.connected || _status == WsStatus.connecting) {
      return;
    }

    //注：userToken一般不为null 为null时理应跳转登录页面重新登录
    if (!strNoEmpty(API.userToken)) {
      return;
      // throw 'WsConnector not logined';
    }
    _status = WsStatus.connecting;

    //通知重连中
    eventBus.emit(EVENT_SOCKET_IS_RECONNECTION, _status);

    try {
      RouteInfo routeInfo = await userApi.getRouteInfo();
      if (routeInfo == null) {
        throw 'Get routeInfo error';
      }
      // ws地址，链接
      _channel = WebSocketChannel.connect(Uri.parse(routeInfo.address));
      _status = WsStatus.connected;
      _channel.stream
          .listen(msgHandler, onError: errorHandler, onDone: doneHandler);
      _channel.stream.handleError((err) {
        print("WsConnector error: $err");
        reconnect();
      });
      sendMessage(WsRequest.authenticationChallenge());
    } catch (e) {
      // print('Socket connect error: $e');
      if (e == 'unlogin') {
        _status = WsStatus.failed;
        disconnect();
        routePushAndRemove(
            ProviderConfig.getInstance().createLogin(LoginPage()));
      } else {
        reconnect();
      }
    }
  }

  static void msgHandler(msg) {
    if (!strNoEmpty(msg)) {
      return;
    } else if (!(msg.toString().startsWith('{') &&
        msg.toString().endsWith('}'))) {
      msg = AESUtils.decrypt(msg.toString());
    }

    Map<String, dynamic> data = json.decode(msg);

    if (data['event'] != null) {
      try {
        if (data['event'].startsWith('chat1_11_')) {
          WsResponse res = WsResponse.fromJsonMap(data);
          var resChat = res.data as WsResChat;
          if (!strNoEmpty(resChat.id) ||
              resChat.mtype < 1 ||
              !strNoEmpty(resChat.msg)) {
            return;
          }
          var store = jsonDecode(res.data.msg);
          WorkMsgStore workMsgStore = WorkMsgStore.fromJsonMap(store);
          _sendEvent('team_notice_${workMsgStore.teamId}', data);
        } else {
          _sendEvent(data['event'], data);
        }
      } catch (e) {
        _sendEvent(data['event'], data);
      }
    } else if (data['command'] != null) {
      WsResponse res = WsResponse.fromJsonMap(data);
      if (res.command == 1) {
        var data = res.data as WsResLogin;
        if (data.data == 'success') {
          //通知连接成功
          eventBus.emit(EVENT_SOCKET_IS_RECONNECTION, _status);
          if (_timer == null) {
            _lastPongTime = DateTime.now().millisecondsSinceEpoch;
            pingPongCheck();
          }
        }
      }
      if (res.command == 3 && _timer != null) {
        _lastPongTime = DateTime.now().millisecondsSinceEpoch;
      }
      res.command = (res.command ?? 0) - 1;

      channelManager.messageHandler(res);
    } else {
      print('Received: $msg');
    }
  }

  //心跳消息检测
  static void pingPongCheck() {
    _timer = Timer.periodic(Duration(seconds: 30), (t) {
      if (_lastPongTime != null) {
        if (DateTime.now().millisecondsSinceEpoch - _lastPongTime > 30000) {
          disconnect();
          Future.delayed(Duration(seconds: 2), () {
            connect();
          });
        }
      }
    });
  }

  static void errorHandler(error) {
    print('Socket Error: $error');
  }

  static void doneHandler() {
    try {
      if (_channel != null) _channel.sink.close();
      _channel = null;
    } catch (e) {
      // skip
    }
    reconnect();
  }

  // 执行重连操作
  static void reconnect() {
    if (_reconnecting || _status == WsStatus.closed) return;
    _lastPongTime = null;
    _timer?.cancel();
    _timer = null;
    _reconnecting = true;
    _status = WsStatus.failed;

    Future.delayed(Duration(seconds: 2), () {
      _reconnecting = false;
      connect();
    });
  }

  // 发送消息到服务器
  static sendMessage(WsRequest data) {
    if (_status != WsStatus.connected) {
      throw 'unconnect status';
    }
    _channel.sink.add(data.toString());
  }

  static WsCallback addListener(String event, WsCallback call) {
    var callList = _eventMap[event];
    if (callList == null) {
      callList = new List();
      _eventMap[event] = callList;
    }

    callList.add(call);

    return call;
  }

  static removeListenerByEvent(String event) {
    _eventMap.remove(event);
  }

  static removeListener(WsCallback call) {
    final keys = _eventMap.keys.toList(growable: false);
    for (final k in keys) {
      final v = _eventMap[k];

      final remove = v.remove(call);
      if (remove && v.isEmpty) {
        _eventMap.remove(k);
      }
    }
  }

  // ignore: unused_element
  static _sendEventOnce(String event, {data}) {
    final callList = _eventMap[event];

    if (callList != null) {
      for (final item in List.from(callList, growable: false)) {
        removeListener(item);

        _errorWrap(event, item, data);
      }
    }
  }

  static _sendEvent(String event, [data]) {
    var callList = _eventMap[event];

    if (callList != null) {
      for (final item in callList) {
        _errorWrap(event, item, data);
      }
    } else {
      data.remove('event');
      msgHandler(json.encode(data));
    }
  }

  static _errorWrap(String event, WsCallback call, data) {
    try {
      call(json.encode(data));
    } catch (e) {
      print('WsConnector error $e');
    }
  }

  static existsEvent(String event) {
    return _eventMap[event] != null;
  }
}
