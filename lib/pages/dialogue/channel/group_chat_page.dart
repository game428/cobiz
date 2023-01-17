import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/mobPush_manager.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/history_msg_model.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_offstage.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_method.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/forward_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/at_group_user.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_emoji.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_avatar.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_chat_msg_cell.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_info_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_input_bar.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_more.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/socket/ws_response.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cobiz_client/http/res/burn_model.dart';
import 'channel_ui/chat_common_widget.dart';

//群 聊天界面
enum ButtonType { voice, emoji, more } //语音 表情 更多

class GroupChatPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final List<dynamic> groupAvatar;
  final int groupNum;
  final int gType; // 0.普通 1.团队 2.小组 3.部
  final int teamId; // !0
  final Function(dynamic) backCall;
  GroupChatPage(
      {Key key,
      @required this.groupId,
      @required this.groupName,
      @required this.groupAvatar,
      @required this.groupNum,
      @required this.gType,
      @required this.teamId,
      this.backCall})
      : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final int _chatType = 2;
  ChannelManager _channelManager = ChannelManager.getInstance();

  String _groupName;
  int _groupNum;

  double _keyboardHeight = 270.0;
  List<ChatStore> _allLocalChat = List();
  List<ChatStore> _chatMsg = List();
  bool _isVoice = false; //底部显示录音
  bool _isMore = false; //底部显示菜单
  bool _isEmoji = false; //底部显示表情
  bool _isInited = false; //初始化
  bool _isTextChange = false;
  bool _isSelect = false; //勾选消息
  List _selectList = List(); //已选中的消息
  String event;
  TextEditingController _textController = TextEditingController();
  PageController _pageController = new PageController();
  ScrollController _scrollController = ScrollController();
  FocusNode _textFocus = new FocusNode();
  AudioPlayer _audioPlayer = AudioPlayer(
      playerId: 'cobiz_audio_player', mode: PlayerMode.MEDIA_PLAYER);

  //图片本机文件地址
  Map<String, String> _tempData = Map();

  //图片消息浏览
  List<ChatStore> _imgList = List();

  static const int _onlineHisSize = 1000; //拉取线上数量
  int _pageSize = 20; //分页数量
  int _firstPageSize = 40; //首次加载
  int _maxMsgNum = 100; //未读加载方式临界点
  String _firstUnreadMsgId; //记录未读消息第一条id

  List<Map> _atList = List(); //@
  List<int> _atIds = List(); //@ids

  Timer _timer; //阅后焚毁定时器
  BurnModel _burnModel; //焚毁类

  bool _isScrollLoading = false; // 是否通过滚动加载
  bool _isShowGoTop = false; //是否显示未读消息按钮
  bool _isReadUnread = false; //是否在读大量的未读消息
  int _unreadNum = 0; //未读条数 进来查询

  bool _isCloseJiaMi = false; //是否关闭加密

  bool _isQuote = false; //是否引用
  ChatStore _quoteMsg; //引用消息
  String _quoteText = ''; //引用展示文本

  String _currentVoicePath; //当前语音url
  String _currentVoiceMid; //当前语音消息id
  List<ChatStore> _voiceList = [];
  bool _isAutoplay = false;

  @override
  void initState() {
    super.initState();
    _updateBurn();
    _init();
    _burnTimer();
  }

  // 实时监测阅后即焚
  _burnTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (t) {
      if (_chatMsg.isNotEmpty) {
        _formatChatList(_chatMsg);
      }
    });
  }

  _updateBurn() async {
    _burnModel = await chatApi.queryGroupSetting(widget.groupId);
    if (mounted) setState(() {});
  }

  _dispose() {
    if (widget.backCall != null) {
      widget.backCall(_groupNum != null && (_groupNum != widget.groupNum));
    }
    eventBus.off('open_multiple_choice');
    eventBus.off(EVENT_HTTP_FORWARD);
    eventBus.off(EVENT_VOICE_ONTOUCH);
    eventBus.off(EVENT_ENTER_THE_BACKGROUND);
    _burnNow();
    _audioPlayer.dispose();
    WsConnector.removeListenerByEvent(event ?? '');
    _textController.dispose();
    _pageController.dispose();
    _textFocus.dispose();
    _scrollController.dispose();
    _timer?.cancel();
  }

  //处理即刻焚毁 和更新外部label
  _burnNow() async {
    List<String> burn1ids = [];
    List<ChatStore> stores =
        await localStorage.getLocalChats(_chatType, widget.groupId);
    for (var i = 0; i < stores?.length ?? 0; i++) {
      if ((stores[i]?.burn ?? 0) == 1) {
        // 需要焚烧删除的，加入焚烧列表
        burn1ids.add(stores[i].id);
      }
    }
    if (burn1ids.isNotEmpty) {
      await localStorage.deleteLocalChats(_chatType, widget.groupId, burn1ids);
    }

    ChannelStore channel =
        await localStorage.getLocalChannel(2, widget.groupId);
    //外面查出来 就没有 就什么都不管
    if (channel == null && !strNoEmpty(_textController.text)) {
      return;
    }

    // 查询一次最新的 然后去更新外面
    List<ChatStore> newStores =
        await localStorage.getLocalChats(_chatType, widget.groupId);
    //查询外面的单条
    ChatStore newChat;
    if (strNoEmpty(_textController.text)) {
      var msg = {
        'text': _textController.text,
        'atList': _atList,
      };
      newChat = ChatStore(
        null,
        _chatType,
        API.userInfo.id,
        widget.groupId,
        301,
        jsonEncode(msg),
        state: -1,
        time: DateTime.now().millisecondsSinceEpoch,
        readTime: DateTime.now().millisecondsSinceEpoch,
        burn: 0,
        name: API.userInfo.nickname,
      );
    } else if ((newStores?.length ?? 0) < 1) {
      var msg = {
        'text': '',
        'ats': _atIds,
      };
      newChat = ChatStore(
        null,
        _chatType,
        API.userInfo.id,
        widget.groupId,
        1,
        jsonEncode(msg),
        state: -1,
        time: channel?.lastAt ?? DateTime.now().millisecondsSinceEpoch,
        readTime: DateTime.now().millisecondsSinceEpoch,
        burn: _burnModel?.burn ?? 0,
        name: API.userInfo.nickname,
      );
    } else {
      newChat = newStores[0];
    }
    if (channel?.label != json.encode(newChat)) {
      await localStorage.updateLocalChannel(
          ChannelStore(
              type: _chatType,
              id: widget.groupId,
              name: _groupName ?? widget.groupName,
              avatar: jsonEncode(widget.groupAvatar),
              label: json.encode(newChat),
              unread: 0,
              lastAt: newChat?.time ?? 0,
              top: 0,
              num: _groupNum ?? widget.groupNum),
          msgType: newChat.mtype);
      _channelManager.refresh();
    }
  }

  //event事件流
  _eventStream() {
    eventBus.on(EVENT_VOICE_ONTOUCH, (arg) {
      if (arg != null && arg['type'] == 'sendTouch') {
        _currentVoicePath = arg['path'];
        _currentVoiceMid = arg['mId'];
        _isAutoplay = arg['autoplay'];
      }
    });
    eventBus.on('open_multiple_choice', (arg) {
      _clearQuote();
      if (_isSelect && arg != null) {
        Map data = arg;
        if (_selectList.contains(data['msg']) && data['isSelect'] == false) {
          _selectList.remove(data['msg']);
        }
        if (!_selectList.contains(data['msg']) && data['isSelect'] == true) {
          _selectList.add(data['msg']);
        }
        GlobalModel.getInstance().setTotal(_selectList.length);
      }
      if (!_isSelect && mounted) {
        setState(() {
          _isEmoji = false;
          _isVoice = false;
          _isMore = false;
          _isSelect = true;
          GlobalModel.getInstance().setTotal(0);
        });
      }
    });
    eventBus.on(EVENT_HTTP_FORWARD, (arg) {
      if (arg != null) {
        // 转发到当前聊天群的时候
        _echo(arg['msg'], arg['value']);
      }
    });
    //app进入后台关闭语音
    eventBus.on(EVENT_ENTER_THE_BACKGROUND, (arg) {
      if (arg == true) {
        ChatCommonMethod.stopAudioPlayer(_audioPlayer);
      }
    });
  }

  _init() async {
    _scrollListerner();
    _textController.addListener(() {
      if (_textController.text.length > 0 && !_isTextChange) {
        if (mounted) {
          setState(() {
            _isTextChange = true;
          });
        }
      } else if (_textController.text.length < 1 && _isTextChange) {
        if (mounted) {
          setState(() {
            _isTextChange = false;
          });
        }
      }
    });
    _textFocus.addListener(() {
      if (_textFocus.hasFocus) {
        _jumpBot();
      }
      if (_textFocus.hasFocus && (_isVoice || _isEmoji || _isMore)) {
        _isVoice = false;
        _isEmoji = false;
        _isMore = false;
      }
    });
    _eventStream();
    _audioPlayerListen();
    event = 'chat${_chatType}_${widget.groupId}_${API.userInfo.id}';
    WsConnector.addListener(event, _dealChat);
    ChannelStore channel =
        await localStorage.getLocalChannel(2, widget.groupId);
    if (channel != null) {
      _unreadNum = channel.unread ?? 0;
      if (strNoEmpty(channel?.label) && strIsJson(channel?.label)) {
        var data = jsonDecode(channel.label);
        if (data['atMe'] != null) {
          data = jsonDecode(data['text']);
        }
        ChatStore labelData = ChatStore.fromJsonMap(data);
        if (strIsJson(labelData.msg)) {
          var msg = jsonDecode(labelData.msg);
          if (labelData.mtype == 301) {
            if (mounted) {
              setState(() {
                _textController.text = msg['text'];
                if (msg['atList'] != null && msg['atList'].length > 0) {
                  msg['atList'].forEach((item) {
                    _atList
                        .add({'nickname': item['nickname'], 'id': item['id']});
                  });
                }
              });
            }
          }
        }
      }
    }
    await localStorage.readLocalChannel(_chatType, widget.groupId);
    /**
     * 拉取线上比对首尾 决定是否替换 strat
     */
    await _loadLocal();
    await _loadOnlineMsg();
    /**
     * 拉取线上比对首尾 决定是否替换 end
     */
    Future.delayed(Duration(milliseconds: 500), () async {
      _isInited = true;
      _channelManager.refresh();
    });
  }

  //本地消息加载
  _loadLocal() async {
    List<ChatStore> stores =
        await localStorage.getLocalChats(_chatType, widget.groupId);
    _allLocalChat.clear();
    _chatMsg.clear();
    if (stores.isNotEmpty) {
      // 删除焚烧消息
      await _formatChatList(stores, isInit: true);
      stores = await localStorage.getLocalChats(_chatType, widget.groupId);
    }
    if (stores.isNotEmpty) {
      if (_unreadNum >= stores.length) {
        _unreadNum = stores.length;
      }
      if (_unreadNum > _firstPageSize) {
        _isShowGoTop = true;
        _firstUnreadMsgId = stores[_unreadNum - 1].id;
      }
      _allLocalChat.addAll(stores);
      _chatMsg.addAll(await _fakePage(pageSize: _firstPageSize));

      _imgListReset();
    }
    if (mounted) setState(() {});
  }

  //线上消息加载对比
  _loadOnlineMsg() async {
    //本地数据
    List<ChatStore> stores =
        await localStorage.getLocalChats(_chatType, widget.groupId);
    //线上数据
    List<HistoryModel> _onlinHisList =
        await chatApi.queryGroupChat(widget.groupId, size: _onlineHisSize);
    if (_onlinHisList != null) {
      //线上没有数据 清空本地

      if (_onlinHisList.isEmpty) {
        stores.clear();
        await localStorage.deleteLocalChat(_chatType, widget.groupId,
            isOnlyDeleteLocal: true);
        print('线上没有 本地全部清空了');
        await _loadLocal();
      } else {
        if ((stores.isEmpty) ||
            (stores.isNotEmpty &&
                (_onlinHisList.first.id != stores.first.id ||
                    _onlinHisList.last.id != stores.last.id))) {
          stores.clear();
          List<String> dIds = [];
          _onlinHisList.forEach((element) {
            if (isShowMsg(element.mtype)) {
              ChatStore _chat = ChatStore(element.id, _chatType, element.from,
                  element.to, element.mtype, element.msg,
                  name: element.name,
                  avatar: element.avatar,
                  state: 1,
                  time: element.time,
                  burn: element.burn,
                  readTime: element.rTime);
              stores.add(_chat);
            } else {
              dIds.add(element.id);
            }
          });
          await localStorage.addLocalAllChats(
              stores, widget.groupId, _chatType);
          print('线上有 且和本地匹配不上 同步');
          await _loadLocal();
          if (dIds.isNotEmpty) {
            chatApi.deleteOnlineChat([
              {
                'type': _chatType,
                'otherId': widget.groupId,
                'ids': dIds,
                'isAll': false
              }
            ]);
          }
        }
      }
    }
  }

  //语音播放监听
  _audioPlayerListen() {
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.STOPPED ||
          event == AudioPlayerState.COMPLETED) {
        eventBus.emit(EVENT_VOICE_ONLISTEN, {
          'type': 'onPlayerStateChanged',
          'path': _currentVoicePath,
          'mId': _currentVoiceMid
        });
      }
      //AudioPlayerState.COMPLETED 时查询是否有需要播放的下一条
      if (event == AudioPlayerState.COMPLETED) {
        int startIndex =
            _voiceList.indexWhere((element) => element.id == _currentVoiceMid) +
                1;
        for (var i = startIndex; i < _voiceList.length; i++) {
          if (_voiceList[i].sender != API.userInfo.id &&
              _voiceList[startIndex - 1].sender != API.userInfo.id &&
              _voiceList[i].isReadVoice == false &&
              _isAutoplay) {
            eventBus.emit(EVENT_VOICE_ONLISTEN, {
              'type': 'autoplay',
              'path': _voiceList[i].msg,
              'mId': _voiceList[i].id
            });
            break;
          }
        }
      }
    });
    if (Platform.isIOS) {
      _audioPlayer.onAudioPositionChanged.listen((event) {
        eventBus.emit(EVENT_VOICE_ONLISTEN, {
          'type': 'onAudioPositionChanged',
          'path': _currentVoicePath,
          'mId': _currentVoiceMid
        });
      });
    }
    if (Platform.isAndroid) {
      _audioPlayer.onDurationChanged.listen((event) {
        eventBus.emit(EVENT_VOICE_ONLISTEN, {
          'type': 'onDurationChanged',
          'path': _currentVoicePath,
          'mId': _currentVoiceMid
        });
      });
    }
  }

  // 清空图片,语音预览数组，重新添加数据
  _imgListReset() {
    _imgList.clear();
    _voiceList.clear();
    _chatMsg.forEach((element) {
      if (element.mtype == 3) {
        _imgList.insert(0, element);
      }
      if (element.mtype == 2) {
        _voiceList.insert(0, element);
      }
    });
  }

  //滚动监听
  _scrollListerner() {
    _scrollController.addListener(() {
      // 下拉
      if (((_scrollController.position.pixels -
                  _scrollController.position.maxScrollExtent) >
              100) &&
          !_isScrollLoading) {
        if (mounted) {
          setState(() {
            _isScrollLoading = true;
          });
        }
        Future.delayed(Duration(seconds: 1), () async {
          List<ChatStore> data = await _fakePage(onLoad: true);
          // 取消无数据提示
          if (data.isNotEmpty) {
            _chatMsg.addAll(data);
            _imgListReset();
          }
          _isScrollLoading = false;
          if (mounted) {
            setState(() {});
          }
        });
      }
      //上滑
      if (_scrollController.position.pixels == 0 && _isReadUnread) {
        double before = _scrollController.position.maxScrollExtent;
        List<ChatStore> data = _slideUp(onSlideUp: true);
        if (data.isNotEmpty) {
          _chatMsg.insertAll(0, data);
          _imgListReset();
          if (mounted) {
            setState(() {});
          }
          Future.delayed(Duration(milliseconds: 500), () {
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent - before,
                duration: Duration(milliseconds: 20),
                curve: Curves.ease);
          });
        } else {
          _isReadUnread = false;
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
  }

  // 滚动到最底部
  _jumpBot({ChatStore chatStore}) async {
    if (chatStore != null) {
      if (chatStore.mtype == 3) {
        _imgList.add(chatStore);
      }
      if (chatStore.mtype == 2) {
        _voiceList.add(chatStore);
      }
      _allLocalChat.insert(0, chatStore);
      _chatMsg.insert(0, chatStore);
    }

    if (_isReadUnread) {
      _chatMsg.clear();
      _chatMsg.addAll(await _fakePage(pageSize: _firstPageSize));
      _imgListReset();
      _isReadUnread = false;
    }

    if (mounted) {
      setState(() {});
    }
    if (_scrollController.position.pixels != 0) {
      _scrollController.jumpTo(0.0);
    }
  }

  //消息接收
  Future<void> _dealChat(message) async {
    Map<String, dynamic> map = json.decode(message);
    WsResponse res = WsResponse.fromJsonMap(map);
    if (res.command >= ActionValue.values.length) {
      print('未定义ActionValue${res.command}');
      return;
    }
    res.command = (res.command ?? 0) - 1;
    switch (ActionValue.values[res.command]) {
      case ActionValue.MSG:
        var data = res.data as WsResChat;
        if (data.mtype == 10) {
          if (mounted) {
            setState(() {
              _burnModel.burn = data.burn;
            });
          }
          return;
        }
        if (!strNoEmpty(data.id) ||
            data.mtype < 1 ||
            !strNoEmpty(data.msg) ||
            data.type != 2) return;
        if (data.mtype == 103) {
          // showToast(context, S.of(context).removeGroup);
          await localStorage.deleteLocalChannel(2, widget.groupId);
          ChannelManager.getInstance().refresh();
          Navigator.pop(context);
          return;
        }
        ChatStore store = ChatStore(
          data.id,
          data.type,
          data.from,
          data.to,
          data.mtype,
          data.msg,
          state: 2,
          name: data.name,
          avatar: data.avatar,
          time: data.time ?? DateTime.now().millisecondsSinceEpoch,
          readTime: DateTime.now().millisecondsSinceEpoch,
          burn: _burnModel?.burn ?? 0,
        );

        if (data.mtype == MediaType.PICTURE.index + 1) {
          _imgList.add(store);
        }
        if (data.mtype == MediaType.VOICE.index + 1) {
          _voiceList.add(store);
        }
        if (store.mtype != 104) {
          if (mounted) {
            setState(() {
              _chatMsg.insert(0, store);
            });
          }
        }
        _channelManager.addGroupChat(data.to, data.gname, data.gavatar,
            data.gnum, widget.gType, widget.teamId, false, store);
        if (!data.dnd) {
          PushManager.sendJpush(data: data, type: 1);
        }
        break;
      default:
    }
  }

  // 删除焚烧消息
  Future<void> _formatChatList(List<ChatStore> list,
      {bool isInit = false}) async {
    List<ChatStore> _forList = List();
    _forList.addAll(list);
    _forList.forEach((chat) async {
      switch (chat.burn) {
        case 0:
          break;
        case 1:
          if (isInit == true) {
            await _deleteOneMsg(chat, isInit: isInit);
          }
          break;
        case 2:
        case 3:
        case 4:
        case 5:
          int burn = getBurnByType(chat.burn);
          int time = (chat.readTime ?? 0) + burn;
          if (time <= DateTime.now().millisecondsSinceEpoch) {
            await _deleteOneMsg(chat, isInit: isInit);
          }
          break;
        default:
          break;
      }
    });
  }

  //假分页
  Future<List<ChatStore>> _fakePage(
      {bool onLoad = false, bool unRead = false, int pageSize}) async {
    // onLoad 分页加载
    // unRead 未读加载
    // pageSize 分页条数
    int start = 0; // 起点
    int end; // 终点
    int size = pageSize ?? _pageSize; // 分页条数，默认为 _pageSize;
    if (onLoad) {
      //计算当前下标从何处开始
      start = _allLocalChat
              .indexWhere((element) => element.id == _chatMsg.last.id) +
          1;
    }

    //数量少的时候未读消息end
    if (unRead) {
      end = _allLocalChat
              .indexWhere((element) => element.id == _firstUnreadMsgId) +
          1;
      if (end == 0) {
        end = _unreadNum;
      }
    } else {
      end = start + size;
    }
    if (end >= _allLocalChat.length) {
      end = _allLocalChat.length;
    }
    print('start $start end $end');

    //未读按钮在 但是用户又在自己拉取记录的时候 取消按钮
    if (_isShowGoTop) {
      int tempUnReadId = _allLocalChat
              .indexWhere((element) => element.id == _firstUnreadMsgId) +
          1;
      if (tempUnReadId == 0) {
        tempUnReadId = _unreadNum;
      }
      if (end >= tempUnReadId) {
        _isShowGoTop = false;
      }
    }

    if (start >= end) {
      ///本地数据已经查到底 从线上拉取
      List<HistoryModel> _onlinHisList = await chatApi.queryGroupChat(
          widget.groupId,
          msgId: _allLocalChat.isNotEmpty ? _allLocalChat.last.id : null,
          direct: 1);
      if (_onlinHisList == null) {
        return [];
      } else {
        List<ChatStore> _cList = [];
        _onlinHisList.forEach((element) {
          ChatStore _chat = ChatStore(element.id, _chatType, element.from,
              element.to, element.mtype, element.msg,
              name: element.name,
              avatar: element.avatar,
              state: ((element.rTime ?? 0) > 0) ? 2 : 1,
              time: element.time,
              burn: element.burn,
              readTime: element.rTime);
          _allLocalChat.add(_chat);
          _cList.add(_chat);
        });
        await localStorage.addLocalAllChats(
            _allLocalChat, widget.groupId, _chatType);
        return _cList;
      }
    }
    return _allLocalChat.sublist(start, end);
  }

  // 未读消息加载
  List<ChatStore> _slideUp({bool onSlideUp = false}) {
    // onSlideUp 是否是上滑加载
    int end; // 终点
    int start; // 起点

    if (onSlideUp) {
      // 如果是上滑加载
      end = _allLocalChat
          .indexWhere((element) => element.id == _chatMsg.first.id);
    } else {
      // 不是上滑，则为滚动到第一条未读消息，且未读消息超过最大限制条数
      end = _allLocalChat
              .indexWhere((element) => element.id == _firstUnreadMsgId) +
          1;
      if (end == 0) {
        // 如果没找到
        if (_unreadNum > _allLocalChat.length) {
          // 如果已经删除，未读条数大于总条数
          end = _allLocalChat.length;
        } else {
          end = _unreadNum;
        }
      }
    }

    if (end < 1) {
      return [];
    }
    if (end > _pageSize) {
      start = end - _pageSize;
    } else {
      start = 0;
    }
    return _allLocalChat.sublist(start, end);
  }

  //点击未读消息按钮相关操作
  void _onTapUnreadBtn() async {
    if (_unreadNum <= _firstPageSize) {
      _isShowGoTop = false;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    List<ChatStore> data = [];
    //数量多 清空 然后跳转
    if (_unreadNum >= _maxMsgNum) {
      _isReadUnread = true;
      data = _slideUp();
      _chatMsg.clear();
      _imgList.clear();
      _voiceList.clear();
    } else {
      data = await _fakePage(onLoad: true, unRead: true);
    }

    if (data.isNotEmpty) {
      _chatMsg.addAll(data);
      _imgListReset();

      _isShowGoTop = false;

      if (mounted) {
        setState(() {});
      }
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1 * _chatMsg.length),
          curve: Curves.ease);
      // 注：好像最大高度只有当滚动的时候才能获取 故滚动两次
      Future.delayed(Duration(milliseconds: 800), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      _isShowGoTop = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  //引用消息
  _quote(ChatStore groupChatStore) {
    setState(() {
      _quoteMsg = groupChatStore;
      if (_quoteMsg != null) {
        switch (_quoteMsg.mtype) {
          case 1:
            _quoteText =
                '${_quoteMsg.name}：${_quoteMsg == null ? '' : jsonDecode(_quoteMsg.msg)['text']}';
            break;
          case 3:
            _quoteText = '${_quoteMsg.name}：[${S.of(context).photo}]';
            break;
          default:
            _quoteText = '';
        }
      }
      _isQuote = true;
    });
  }

  //清除引用
  _clearQuote() {
    if (_isQuote) {
      _isQuote = false;
      _quoteMsg = null;
      _quoteText = '';
    }
  }

  //隐藏引用
  _hideQuote() {
    if (mounted) {
      setState(() {
        _isQuote = false;
        _quoteMsg = null;
        _quoteText = '';
      });
    }
  }

  //转发消息 通用
  _forwardMsg(ChatStore groupChatStore) {
    if ((groupChatStore.mtype == 3 || groupChatStore.mtype == 4) &&
        !isNetWorkImg(groupChatStore.msg)) {
      showToast(context, S.of(context).tryAgainLater);
    } else {
      routeMaterialPush(ForwardPage(forwardType: 1, chatStore: groupChatStore))
          .then((value) {
        // 转发到当前聊天群的时候
        _echo(groupChatStore, value);
      });
    }
  }

  // 转发到当前聊天群的时候,进行回显
  _echo(ChatStore groupChatStore, dynamic data) {
    if (data != null && data is ChannelStore) {
      if (data.type == groupChatStore.type && widget.groupId == data.id) {
        String id = getOnlyId();
        //文本消息 格式化
        String msg = '';
        if (groupChatStore.mtype == 1) {
          if (strIsJson(groupChatStore.msg)) {
            msg = jsonDecode(groupChatStore.msg)['text'];
          } else {
            msg = groupChatStore.msg;
          }
          msg = jsonEncode({'text': msg, 'ats': []});
        } else {
          msg = groupChatStore.msg;
        }
        ChatStore chat = ChatStore(
          id,
          _chatType,
          API.userInfo.id,
          widget.groupId,
          MediaType.values[groupChatStore.mtype - 1].index + 1,
          msg,
          state: 1,
          time: DateTime.now().millisecondsSinceEpoch,
          readTime: DateTime.now().millisecondsSinceEpoch,
          name: groupChatStore.name,
          burn: _burnModel?.burn ?? 0,
        );
        _jumpBot(chatStore: chat);
      }
    }
  }

  //删除单条消息
  Future<void> _deleteOneMsg(ChatStore chatStore, {bool isInit = false}) async {
    if (isInit == true) {
      //删本地
      await localStorage
          .deleteLocalChats(_chatType, widget.groupId, [chatStore.id]);
    } else {
      _allLocalChat.remove(chatStore);
      _chatMsg.remove(chatStore);
      if (chatStore.mtype == 3 && _imgList.isNotEmpty) {
        _imgList.remove(chatStore);
      }
      if (chatStore.mtype == 2 && _voiceList.isNotEmpty) {
        _voiceList.remove(chatStore);
      }
      //删本地
      await localStorage
          .deleteLocalChats(_chatType, widget.groupId, [chatStore.id]);
      _moreMsg();
      if (mounted) {
        setState(() {});
      }
    }
  }

  //多选删除消息
  _deleteMuchMsg() async {
    List<String> ids = [];
    _selectList.forEach((element) {
      ids.add(element.id.toString());
      _allLocalChat.remove(element);
      _chatMsg.remove(element);
      if (element.mtype == 3) {
        _imgList.remove(element);
      }
      if (element.mtype == 2) {
        _voiceList.remove(element);
      }
    });
    //删本地
    await localStorage.deleteLocalChats(_chatType, widget.groupId, ids);
    _moreMsg();
    if (mounted) {
      setState(() {
        _selectList.clear();
        _isSelect = false;
      });
    }
  }

  // 判断当前条数是否大于二十
  _moreMsg() async {
    //删除之后 判断当前列表是否有20条 没有的话隐式刷新一下填充消息列表
    if (_chatMsg.length < _pageSize) {
      List<ChatStore> data = await _fakePage(onLoad: true);
      // 取消无数据提示
      if (data.isNotEmpty) {
        _chatMsg.addAll(data);
      }
      _imgListReset();
    }
  }

  //勾选操作 1:转发 2：收藏 3：删除
  void _selectAction(int id) async {
    if (_selectList.isEmpty)
      return showToast(context, S.of(context).noMessagesSelected);
    switch (id) {
      case 1:
        print('转发');
        break;
      case 2:
        print('收藏');
        break;
      case 3:
        showConfirm(context,
            title: S.of(context).sureDeleteSelectMsg,
            sureCallBack: _deleteMuchMsg);
        break;
      default:
    }
  }

  // 格式化
  ChatStore _parseToChat(MediaType mediaType, String message) {
    String id = getOnlyId();
    ChatStore chat = ChatStore(
      id,
      _chatType,
      API.userInfo.id,
      widget.groupId,
      mediaType.index + 1,
      message,
      state: -1,
      time: DateTime.now().millisecondsSinceEpoch,
      readTime: DateTime.now().millisecondsSinceEpoch,
      burn: _burnModel?.burn ?? 0,
      name: API.userInfo.nickname,
    );
    _jumpBot(chatStore: chat);
    return chat;
  }

  ///发送名片
  Future<void> _sendCard(ContactExtendIsSelected cardInfo) async {
    var data = {
      'userId': cardInfo.userId,
      'userName': cardInfo.name,
      'avatar': cardInfo.avatarUrl
    };
    String message = jsonEncode(data);

    if (!strNoEmpty(message)) return;
    await _send(MediaType.CARD, message);
  }

  ///发送照片
  Future<void> _sendPhoto(List<AssetEntity> images) async {
    try {
      if (images == null || images.length < 1) return;
      Set<String> paths = Set();
      List<ChatStore> chats = [];
      for (AssetEntity image in images) {
        File file = await image.file;
        // var resultFile = await commonApi.singleCompressVideo(file);
        paths.add(file.path);
        if (image.type == AssetType.video) {
          chats.add(_parseToChat(MediaType.VIDEO, file.path));
        } else if (image.type == AssetType.image) {
          chats.add(_parseToChat(MediaType.PICTURE, file.path));
        }
      }
      Map<String, String> result =
          await commonApi.uploadFilesCompress(chats, backFullPath: true);
      if (result == null || result.length < 1) return;
      result.forEach((key, value) async {
        for (ChatStore chat in chats) {
          if (chat.id == key) {
            _tempData[chat.id] = chat.msg;
            ChatStore store = ChatStore(
              chat.id,
              chat.type,
              chat.sender,
              chat.receiver,
              chat.mtype,
              value,
              state: chat.state,
              time: DateTime.now().millisecondsSinceEpoch,
              readTime: DateTime.now().millisecondsSinceEpoch,
              burn: _burnModel?.burn ?? 0,
              name: chat.name,
            );
            Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
            chat.state = res != null ? 2 : 0;
            store.state = chat.state;
            chat.msg = value;
            if (mounted) setState(() {});
            _savaGroupChat(store);
            break;
          }
        }
      });
    } catch (e) {
      print('聊天发送图片异常: $e');
    }
  }

  // 发送拍摄
  Future<void> _sendCamera(File _imageFile) async {
    try {
      if (_imageFile == null) return;
      ChatStore chat = _parseToChat(MediaType.PICTURE, _imageFile.path);
      var result = await commonApi.uploadFileCompress(_imageFile.path,
          type: MediaType.PICTURE.index + 1, backFullPath: true);
      if (result == null) return;
      _tempData[chat.id] = _imageFile.path;
      chat.msg = result;
      ChatStore store = ChatStore(
        chat.id,
        chat.type,
        chat.sender,
        chat.receiver,
        chat.mtype,
        result,
        state: chat.state,
        time: DateTime.now().millisecondsSinceEpoch,
        readTime: DateTime.now().millisecondsSinceEpoch,
        burn: _burnModel?.burn ?? 0,
        name: chat.name,
      );
      Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
      chat.state = res != null ? 2 : 0;
      store.state = chat.state;
      if (mounted) setState(() {});
      _savaGroupChat(store);
    } catch (e) {
      print('拍摄图片异常: $e');
    }
  }

  // 发送
  Future<void> _send(MediaType mediaType, String message) async {
    ChatStore chat = _parseToChat(mediaType, message);
    Map result = await chatApi.sendMsg(WsRequest.upMsg(chat));
    chat.state = result != null ? 2 : 0;
    if (mounted) {
      setState(() {});
    }
    _savaGroupChat(chat);
  }

  ///发送语音
  Future<void> _sendVoice(Map path) async {
    try {
      if (path == null) return;
      ChatStore chat = _parseToChat(MediaType.VOICE, jsonEncode(path));
      var result = await commonApi.uploadFile(path['path'], backFullPath: true);
      if (result != null) {
        path['path'] = result;
        ChatStore store = ChatStore(
          chat.id,
          chat.type,
          chat.sender,
          chat.receiver,
          chat.mtype,
          jsonEncode(path),
          state: chat.state,
          time: DateTime.now().millisecondsSinceEpoch,
          readTime: DateTime.now().millisecondsSinceEpoch,
          burn: _burnModel?.burn ?? 0,
          name: chat.name,
        );
        Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
        chat.state = res != null ? 2 : 0;
        store.state = chat.state;
        if (mounted) setState(() {});
        _savaGroupChat(chat);
      }
    } catch (e) {
      print('语音异常: $e');
    }
  }

  //存本地群聊
  _savaGroupChat(ChatStore chat) {
    _channelManager.addGroupChat(
        widget.groupId,
        widget.groupName,
        widget.groupAvatar,
        widget.groupNum,
        widget.gType,
        widget.teamId,
        false,
        chat);
  }

  //发送文本
  Future<void> _sendText() async {
    _atIds.clear();
    String message = _textController.text;
    if (!strNoEmpty(message)) return;
    _atList.forEach((element) {
      if (message.contains('@${element['nickname']} ')) {
        _atIds.add(element['id']);
      }
    });
    var msg = {
      'text': message,
      'ats': _atIds,
    };

    //文本消息 引用
    if (_isQuote && _quoteMsg != null) {
      msg['quoteName'] = _quoteMsg.name;
      msg['quoteMType'] = _quoteMsg.mtype;
      msg['quoteUid'] = _quoteMsg.sender;
      msg['quoteMsgId'] = _quoteMsg.id;
      switch (_quoteMsg.mtype) {
        case 1:
          msg['quoteMsg'] = jsonDecode(_quoteMsg.msg)['text'];
          break;
        case 3:
          msg['quoteMsg'] = _quoteMsg.msg;
          break;
        default:
          msg['quoteMsg'] = '';
      }
      _clearQuote();
    }
    message = jsonEncode(msg);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _atList.clear();
      _atIds.clear();
      _textController.clear();
    });
    await _send(MediaType.TEXT, message);
  }

  // @
  _onChanged(v) {
    if (v.endsWith('@')) {
      routeMaterialPush(AtGroupUser(widget.groupId)).then((value) {
        if (value != null) {
          if (!_atIds.contains(value['id'])) {
            _atIds.add(value['id']);
            _atList.add(value);
          }
          _insertText(value['nickname'] + " ");
        }
      });
    }
  }

  //body
  List<Widget> _buildContent() {
    List _selectData = [
      // {
      //   'id': 1,
      //   'name': S.of(context).forward,
      //   'icon': 'assets/images/mine/forward.png'
      // },
      // {
      //   'id': 2,
      //   'name': S.of(context).collectionBackup,
      //   'icon': 'assets/images/mine/backup.png'
      // },
      {
        'id': 3,
        'name': S.of(context).deleteMsg,
        'icon': 'assets/images/ic_delete.png'
      }
    ];
    List<Widget> items = [
      Flexible(
        child: Stack(
          children: [
            Container(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                    15, _isCloseJiaMi || _chatMsg.length > 5 ? 15 : 40, 15, 15),
                itemBuilder: (context, index) {
                  if (index == _chatMsg.length) {
                    return _isScrollLoading
                        ? buildProgressIndicator(isLoading: _isScrollLoading)
                        : Container();
                  } else {
                    return GroupChatMsgCell(
                        _chatMsg[index],
                        _isSelect,
                        _audioPlayer,
                        _tempData,
                        _imgList,
                        widget.gType,
                        widget.teamId, valueCall: (v) {
                      if (v != null) {
                        _clearQuote();
                        switch (v['type']) {
                          case 'delete':
                            // 删除消息
                            _deleteOneMsg(v['data']);
                            break;
                          case 'forward':
                            // 转发消息
                            _forwardMsg(v['data']);
                            break;
                          case 'forwardInImgDetail':
                            // 图片放大后 转发图片，回显
                            _echo(v['data']['chatStore'], v['data']['value']);
                            break;
                          case 'quote':
                            _quote(v['data']);
                            break;
                          default:
                        }
                      }
                    });
                  }
                },
                reverse: true,
                shrinkWrap: true,
                itemCount: (_chatMsg.length + 1),
                dragStartBehavior: DragStartBehavior.down,
                physics: BouncingScrollPhysics(),
              ),
            ),
            Column(
              children: [
                ChannelOffstage(
                  false,
                  'assets/images/chat/safety.png',
                  S.of(context).endToEndEncryption,
                  call: (v) {
                    _isCloseJiaMi = v;
                    if (_isCloseJiaMi && _chatMsg.length <= 5) {
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                ),
                //未读按钮
                ChatCommonWidget.unreadBtn(
                    context, _isShowGoTop, _unreadNum, _onTapUnreadBtn)
                // ChannelOffstage(
                //     false, 'assets/images/chat/fire_selected.png', 'xxxx'),
              ],
            )
          ],
        ),
      ),
      ChatCommonWidget.quoteShow(_isQuote, _quoteText, _hideQuote),
      !_isSelect
          ? ChannelInputBar(
              isEmoji: _isEmoji,
              isMore: _isMore,
              isVoice: _isVoice,
              textFocus: _textFocus,
              textController: _textController,
              voiceTap: () => _onTapHandle(ButtonType.voice),
              emojiTap: () => _onTapHandle(ButtonType.emoji),
              moreTap: () => _onTapHandle(ButtonType.more),
              onTapSend: _sendText,
              onChanged: _onChanged,
              sendVoice: (path) {
                if (path != null) {
                  _clearQuote();
                  _sendVoice(path);
                }
              },
            )
          : Container(
              child: Row(
                children: List.generate(
                    _selectData.length,
                    (index) => _buildSelectItem(
                        _selectData[index]['id'],
                        _selectData[index]['name'],
                        _selectData[index]['icon'])),
              ),
              // constraints: BoxConstraints(minHeight: 50.0, maxHeight: 120.0),
              padding: EdgeInsets.only(
                  left: 8, right: 8, bottom: ScreenData.bottomSafeHeight),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.3),
                  bottom: BorderSide(color: Colors.grey, width: 0.3),
                ),
              )),
      ChannelEmoji(
        isEmoji: _isEmoji,
        isInited: _isInited,
        keyboardHeight: _keyboardHeight,
        textFocus: _textFocus,
        textController: _textController,
        isChanged: _isTextChange,
        onEmojiSelected: (emoji) {
          _insertText(emoji);
        },
        onTapSend: _sendText,
      ),
      ChannelMore(
        isInited: _isInited,
        isMore: _isMore,
        pageController: _pageController,
        call: (v) {
          if (v != null) {
            _clearQuote();
            switch (v.keys.toList()[0]) {
              case MediaType.PICTURE:
                var result = v[MediaType.PICTURE];
                if (result.runtimeType.toString() == '_File') {
                  _sendCamera(result);
                } else {
                  _sendPhoto(result);
                }
                break;
              case MediaType.CARD:
                _sendCard(v[MediaType.CARD]);
                break;
            }
          }
        },
        joinFromWhere: 6,
        avatar: widget.groupAvatar,
        id: widget.groupId,
        name: widget.groupName,
        gtype: widget.gType,
      )
    ];
    return items;
  }

  //appbar right widget
  List<Widget> _rWidget() {
    List<Widget> _rItems = [];
    if ((_burnModel?.burn ?? 0) != 0) {
      _rItems.add(IconButton(
          icon: ImageIcon(
            AssetImage('assets/images/chat/fire_selected.png'),
            color: AppColors.mainColor,
          ),
          onPressed: null));
    }
    // _rItems.add(IconButton(
    //     icon: ImageIcon(
    //       AssetImage('assets/images/chat/safety.png'),
    //       color: AppColors.mainColor,
    //     ),
    //     onPressed: () {}));
    _rItems.add(InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 8.0,
          ),
          child: ClipOval(
              child: GroupAvatar(widget.groupAvatar, widget.groupName,
                  widget.groupAvatar.length, widget.gType)),
        ),
        onTap: () async {
          ChatCommonMethod.stopAudioPlayer(_audioPlayer);
          var result = await routePush(GroupInfoPage(widget.groupId));
          if (result == null) return;
          if (result == true) {
            Navigator.pop(context);
          } else {
            if (result['num'] != widget.groupNum && result['num'] > 0) {
              _groupNum = result['num'];
            }
            if (result['name'] != widget.groupName &&
                strNoEmpty(result['name'])) {
              _groupName = result['name'];
            }
            if (result['burn'] != null && result['burn'] != _burnModel.burn) {
              _burnModel.burn = result['burn'];
            }
            if (result['isClearChat'] == true) {
              _chatMsg.clear();
              _allLocalChat.clear();
              _imgList.clear();
              _voiceList.clear();
            }
            if (mounted) {
              setState(() {});
            }
          }
        }));
    return _rItems;
  }

  Widget _buildSelectItem(int id, String title, String icon) {
    return Expanded(
        child: InkWell(
      onTap: () => _selectAction(id),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ImageView(img: icon),
            SizedBox(
              height: 5.0,
            ),
            Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.textF12T1,
            ),
          ],
        ),
      ),
    ));
  }

  // 添加表情
  void _insertText(String text) {
    var value = _textController.value;
    var start = value.selection.baseOffset;
    var end = value.selection.extentOffset;
    if (start == null) {
      start = value.text.length;
    }
    if (end == null) {
      end = value.text.length;
    }
    start = value.text.length;
    end = value.text.length;
    if (start != -1) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          try {
            newText += value.text.substring(0, end);
          } catch (e) {
            newText = value.text;
          }
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textController.value = TextEditingValue(
          text: text,
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)));
    }
  }

  // 更多类型的消息
  _onTapHandle(ButtonType type) async {
    FocusScope.of(context).requestFocus(FocusNode());
    switch (type) {
      case ButtonType.voice:
        _clearQuote();
        if (await PermissionManger.microphonePermission()) {
          _isVoice = !_isVoice;
          _isMore = false;
          _isEmoji = false;
        } else {
          showConfirm(context, title: S.of(context).recordPermissionDenied,
              sureCallBack: () async {
            await openAppSettings();
          });
        }
        break;
      case ButtonType.emoji:
        _isEmoji = !_isEmoji;
        _isVoice = false;
        _isMore = false;
        break;
      case ButtonType.more:
        _clearQuote();
        _isMore = !_isMore;
        _isVoice = false;
        _isEmoji = false;
        break;
      default:
    }
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_keyboardHeight == 270.0 && winKeyHeight(context) != 0) {
      _keyboardHeight = winKeyHeight(context);
    }
    return Scaffold(
      appBar: _isSelect
          ? ComMomBar(
              automaticallyImplyLeading: false,
              titleW: Padding(
                padding:
                    EdgeInsets.only(left: NavigationToolbar.kMiddleSpacing),
                child: Text(
                  S.of(context).selectMsg,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              centerTitle: false,
              backgroundColor: AppColors.white,
              elevation: 0.5,
              rightDMActions: [
                IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      if (_isSelect && mounted) {
                        setState(() {
                          GlobalModel.getInstance().setTotal(0);
                          _selectList.clear();
                          _isSelect = false;
                        });
                      }
                    })
              ],
            )
          : ComMomBar(
              titleW: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                      child: Text(
                    '${_groupName ?? widget.groupName}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    textWidthBasis: TextWidthBasis.longestLine,
                    overflow: TextOverflow.ellipsis,
                  )),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    '(${_groupNum ?? widget.groupNum ?? 0})',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              centerTitle: false,
              backgroundColor: AppColors.white,
              elevation: 0.5,
              rightDMActions: _rWidget(),
            ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.specialBgGray,
        child: GestureDetector(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildContent(),
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            if (_isEmoji == true || _isMore == true) {
              _isEmoji = false;
              _isMore = false;
              if (mounted) setState(() {});
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}
