import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/mobPush_manager.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/burn_model.dart';
import 'package:cobiz_client/http/res/history_msg_model.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_emoji.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_input_bar.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_more.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/channel_offstage.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_method.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/forward_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_widget.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_chat_msg_cell.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/socket/ws_response.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'single_chat/single_info_page.dart';

//个人 聊天界面
enum ButtonType { voice, emoji, more } //语音 表情 更多

class SingleChatPage extends StatefulWidget {
  final int userId;
  final String name;
  final String avatar;
  final int whereToChat; //1:home,群组,搜索聊天,团队成员 2:联系人好友信息界面进入 直接返回上一页 3.客服
  final int tempBurn; //whereToChat 2 当从信息界面进入 并且操作人更改了 burn
  SingleChatPage(
      {Key key,
      @required this.userId,
      @required this.name,
      @required this.avatar,
      @required this.whereToChat,
      this.tempBurn})
      : super(key: key);

  @override
  _SingleChatPageState createState() => _SingleChatPageState();
}

class _SingleChatPageState extends State<SingleChatPage> {
  final int _chatType = 1;
  ChannelManager _channelManager = ChannelManager.getInstance();
  double _keyboardHeight = 270.0;
  List<ChatStore> _allLocalChat = [];
  List<ChatStore> _chatMsg = [];
  bool _isVoice = false;
  bool _isMore = false;
  bool _isEmoji = false;
  bool _isInited = false;
  bool _isTextChange = false;
  bool _isSelect = false; //勾选消息
  List _selectList = []; //已选中的消息
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

  bool _isUpdate = false;

  static const int _onlineHisSize = 1000; //拉取线上数量
  static const int _pageSize = 20; //分页数量
  static const int _firstPageSize = 40; //首次加载
  static const int _maxUnreadNum = 100; //未读加载方式临界点
  String _firstUnreadMsgId; //记录未读消息第一条id

  String _nickName;

  Timer _timer; //阅后焚毁定时器
  BurnModel _burnModel;

  bool _isScrollLoading = false; //是否通过滚动加载
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
    _init();
    _burnTimer();
  }

  _dispose() {
    _timer?.cancel();
    _burnNow();
    eventBus.off('open_multiple_choice');
    eventBus.off(EVENT_UPDATE_MSG_STATE);
    eventBus.off(EVENT_HTTP_FORWARD);
    eventBus.off(EVENT_VOICE_ONTOUCH);
    eventBus.off(EVENT_ENTER_THE_BACKGROUND);
    _audioPlayer.dispose();
    WsConnector.removeListenerByEvent(event ?? '');
    _textController.dispose();
    _pageController.dispose();
    _textFocus.dispose();
    _scrollController.dispose();
  }

  //处理即刻焚毁 和更新外部label
  _burnNow() async {
    List<String> burn1ids = [];
    List<ChatStore> stores =
        await localStorage.getLocalChats(_chatType, widget.userId);
    for (var i = 0; i < stores?.length ?? 0; i++) {
      if ((stores[i]?.burn ?? 0) == 1 && stores[i]?.state == 2) {
        burn1ids.add(stores[i].id);
      }
    }
    if (burn1ids.isNotEmpty) {
      await localStorage.deleteLocalChats(_chatType, widget.userId, burn1ids);
    }

    // 查询一次最新的 然后去更新外面
    List<ChatStore> newStores =
        await localStorage.getLocalChats(_chatType, widget.userId);

    //查询外面的单条
    ChannelStore channel = await localStorage.getLocalChannel(1, widget.userId);

    if (channel == null && !strNoEmpty(_textController.text)) {
      return;
    }

    ChatStore newChat;
    if (strNoEmpty(_textController.text)) {
      var msg = {
        'text': _textController.text,
      };
      newChat = ChatStore(
        null,
        _chatType,
        API.userInfo.id,
        widget.userId,
        301,
        jsonEncode(msg),
        state: -1,
        time: DateTime.now().millisecondsSinceEpoch,
        readTime: DateTime.now().millisecondsSinceEpoch,
        burn: 0,
        name: API.userInfo.nickname,
      );
    } else if ((newStores?.length ?? 0) < 1) {
      newChat = ChatStore(
        null,
        _chatType,
        API.userInfo.id,
        widget.userId,
        1,
        '',
        state: -1,
        time: channel?.lastAt ?? DateTime.now().millisecondsSinceEpoch,
        readTime: DateTime.now().millisecondsSinceEpoch,
        burn: 0,
        name: API.userInfo.nickname,
      );
    } else {
      newChat = newStores[0];
    }

    if (channel?.label != json.encode(newChat)) {
      await localStorage.updateLocalChannel(
          ChannelStore(
            type: _chatType,
            id: widget.userId,
            name: _nickName ?? widget.name,
            avatar: widget.avatar,
            label: json.encode(newChat),
            unread: 0,
            lastAt: newChat.time,
            top: channel?.top,
            // 只有自己发的，非推送消息才显示已读未读状态
            readUnread: (newChat.sender == API.userInfo.id &&
                    newChat.mtype != 201 &&
                    newChat.mtype != 106 &&
                    strNoEmpty(json.encode(newChat)))
                ? newChat.state
                : null,
          ),
          msgType: newChat.mtype);
    }
    _channelManager.refresh();
  }

  _burnTimer() async {
    _burnModel = await chatApi.queryUserSetting(widget.userId);

    if (_burnModel == null) {
      return;
    }

    //当从信息界面进入
    if (widget.whereToChat == 2 &&
        widget.tempBurn != null &&
        widget.tempBurn != _burnModel?.burn) {
      _burnModel.burn = widget.tempBurn;
    }

    _timer = Timer.periodic(Duration(seconds: 5), (t) {
      _queryBurnMsg();
    });
    if (mounted) {
      setState(() {});
    }
  }

  // 清空 _imgList  _voiceList 重新添加
  _dealMediaList() {
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

  //查询焚烧消息
  _queryBurnMsg() async {
    List<String> burnids = [];
    //即刻焚毁 和更新外面channel 退出时单独处理
    for (var i = 0; i < _chatMsg.length; i++) {
      if (_chatMsg[i].burn != null &&
          _chatMsg[i].burn != 0 &&
          _chatMsg[i].burn != 1 &&
          _chatMsg[i].state == 2) {
        int burn = getBurnByType(_chatMsg[i].burn);
        int readTime = _chatMsg[i].readTime ?? 0;
        int burnTime = readTime + burn;
        if (DateTime.now().millisecondsSinceEpoch >= burnTime) {
          burnids.add(_chatMsg[i].id);
          _delMsg(_chatMsg[i]);
        }
      }
    }

    if (burnids.isEmpty) {
      return;
    }
    //删本地
    await localStorage.deleteLocalChats(_chatType, widget.userId, burnids);

    //删除之后 判断当前列表是否有20条 没有的话隐式刷新一下填充消息列表
    if (_chatMsg.length < _pageSize) {
      List<ChatStore> data = await _fakePage(onLoad: true);
      // 取消无数据提示
      if (data.isNotEmpty) {
        _chatMsg.addAll(data);
      }

      _dealMediaList();
    }

    if (mounted) {
      setState(() {});
    }
  }

  //滚动监听
  _scrollListerner() {
    _scrollController.addListener(() {
      //下拉
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
            _dealMediaList();
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
          _dealMediaList();
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
      _chatMsg.addAll(await _fakePage(firstSize: _firstPageSize));
      _dealMediaList();
      _isReadUnread = false;
    }

    if (mounted) {
      setState(() {});
    }
    if (_scrollController.position.pixels != 0) {
      _scrollController.jumpTo(0.0);
    }
  }

  //初始化操作
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
    event =
        'chat${_chatType}_${widget.userId > API.userInfo.id ? API.userInfo.id : widget.userId}_${widget.userId > API.userInfo.id ? widget.userId : API.userInfo.id}';
    WsConnector.addListener(event, _dealChat);
    //查询外面的单条 判断是否展示未读按钮
    ChannelStore channel = await localStorage.getLocalChannel(1, widget.userId);
    _unreadNum = channel?.unread ?? 0;
    if (strNoEmpty(channel?.label)) {
      var data = jsonDecode(channel.label);
      ChatStore labelData = ChatStore.fromJsonMap(data);
      if (labelData.mtype == 301 && strIsJson(labelData.msg)) {
        _textController.text = jsonDecode(labelData.msg)['text'];
      }
    }

    await localStorage.readLocalChannel(_chatType, widget.userId);
    _pushRead();
    /**
     * 拉取线上比对首尾 决定是否替换 strat
     */
    await _loadLocal();
    await _onlineLoad();
    /**
     * 拉取线上比对首尾 决定是否替换 end
     */
    Future.delayed(Duration(milliseconds: 500), () async {
      _isInited = true;
      _channelManager.refresh();
    });
  }

  _loadLocal() async {
    List<ChatStore> stores =
        await localStorage.getLocalChats(_chatType, widget.userId);
    _allLocalChat.clear();
    _chatMsg.clear();
    if (stores != null && stores.length > 0) {
      if (_unreadNum >= stores.length) {
        _unreadNum = stores.length;
      }
      if (_unreadNum > _firstPageSize) {
        _isShowGoTop = true;
        _firstUnreadMsgId = stores[_unreadNum - 1].id;
      }
      _allLocalChat.addAll(stores);
      _chatMsg.addAll(await _fakePage(firstSize: _firstPageSize));
      _dealMediaList();
      //进入的时候 先把该删的删了
      _queryBurnMsg();
    }
    if (mounted) setState(() {});
  }

  //线上本地比对
  _onlineLoad() async {
    List<ChatStore> stores =
        await localStorage.getLocalChats(_chatType, widget.userId);
    List<HistoryModel> _onlinHisList =
        await chatApi.querySingleChat(widget.userId, size: _onlineHisSize);
    if (_onlinHisList != null) {
      //线上没有数据 清空本地
      if (_onlinHisList.isEmpty) {
        stores.clear();
        await localStorage.deleteLocalChat(_chatType, widget.userId,
            isOnlyDeleteLocal: true);
        //同步了线上1
        await _loadLocal();
      } else {
        if ((stores.isNotEmpty &&
                (_onlinHisList.first.id != stores.first.id ||
                    _onlinHisList.last.id != stores.last.id)) ||
            stores.isEmpty) {
          stores.clear();
          List<String> dIds = [];
          _onlinHisList.forEach((element) {
            if (isShowMsg(element.mtype)) {
              ChatStore _chat = ChatStore(element.id, _chatType, element.from,
                  element.to, element.mtype, element.msg,
                  name: element.name,
                  avatar: element.avatar,
                  state: ((element.rTime ?? 0) > 0) ? 2 : 1,
                  time: element.time,
                  burn: element.burn,
                  readTime: element.rTime);
              //添加好友消息线上msg都是一样的 显示对方的名字 暂时的做法
              if (_chat.mtype == 201) {
                if (_chat.msg == API.userInfo.nickname) {
                  _chat.msg = _chat.name;
                }
              }
              stores.add(_chat);
            } else {
              dIds.add(element.id);
            }
          });
          await localStorage.addLocalAllChats(stores, widget.userId, _chatType);
          //同步了线上2
          await _loadLocal();
          if (dIds.isNotEmpty) {
            chatApi.deleteOnlineChat([
              {
                'type': _chatType,
                'otherId': widget.userId,
                'ids': dIds,
                'isAll': false
              }
            ]);
          }
        }
      }
    }
  }

  //假分页 下拉
  Future<List<ChatStore>> _fakePage(
      {bool onLoad = false, bool unRead = false, int firstSize}) async {
    // onLoad 分页加载
    // unRead 未读加载
    // pageSize 分页条数
    int start = 0; // 起点
    int end; // 终点
    int size = firstSize ?? _pageSize; // 分页条数，默认为 _pageSize;

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

    print('start >> $start end >> $end');
    if (start >= end) {
      ///本地数据已经查到底 从线上拉取
      List<HistoryModel> _onlinHisList = await chatApi.querySingleChat(
          widget.userId,
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
            _allLocalChat, widget.userId, _chatType);
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
    if (_unreadNum >= _maxUnreadNum) {
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
      _dealMediaList();

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
  _quote(ChatStore chatStore) {
    setState(() {
      _quoteMsg = chatStore;
      if (_quoteMsg != null) {
        switch (_quoteMsg.mtype) {
          case 1:
            _quoteText =
                '${_quoteMsg.name ?? ''}：${_quoteMsg == null ? '' : jsonDecode(_quoteMsg.msg)['text']}';
            break;
          case 3:
            _quoteText = '${_quoteMsg.name ?? ''}：[${S.of(context).photo}]';
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

  // 删除消息
  _delMsg(ChatStore chat) {
    _allLocalChat.remove(chat);
    _chatMsg.remove(chat);
    // if (_selectList.isNotEmpty) {
    //   _selectList.remove(chat);
    // }
    if (chat.mtype == 3 && _imgList.isNotEmpty) {
      _imgList.remove(chat);
    }
    if (chat.mtype == 2 && _voiceList.isNotEmpty) {
      _voiceList.remove(chat);
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
        if (data.mtype == 11) {
          List msg = jsonDecode(data.msg);
          List<String> list = [];
          msg.forEach((id) {
            list.add(id.toString());
          });
          if (list != null && list.isNotEmpty) {
            if (list.length == 1 && list[0].startsWith('clear_')) {
              setState(() {
                _isShowGoTop = false;
                _chatMsg.clear();
                _allLocalChat.clear();
                _imgList.clear();
                _voiceList.clear();
              });
              await localStorage.deleteLocalChannel(1, data.from,
                  isOnlyDeletetLocal: true);
              _channelManager.refresh();
            } else {
              _deleteMtype(list);
            }
          }
          return;
        }
        ChatStore store = ChatStore(
            data.id, data.type, data.from, data.to, data.mtype, data.msg,
            state: 2,
            time: data.time ?? DateTime.now().millisecondsSinceEpoch,
            burn: _burnModel?.burn ?? 0,
            name: data.name,
            readTime: DateTime.now().millisecondsSinceEpoch);
        if (data.mtype == MediaType.PICTURE.index + 1) {
          _imgList.add(store);
        }
        if (data.mtype == MediaType.VOICE.index + 1) {
          _voiceList.add(store);
        }
        if (mounted) {
          setState(() {
            if (store.mtype == 10) {
              //更新burn
              _burnModel.burn = data.burn;
            } else {
              // 若在查看很多未读消息 则不往里面直接插入
              _allLocalChat.insert(0, store);
              if (!_isReadUnread) {
                _chatMsg.insert(0, store);
              }
            }
          });
        }
        if (strNoEmpty(data.id) &&
            data.to == API.userInfo.id &&
            data.type == _chatType &&
            data.mtype > 0 &&
            strNoEmpty(data.msg)) {
          _channelManager.addSingleChat(
              data.from, data.name, data.avatar, false, store);
        }
        if (PushManager.isBackstage == true) {
          _isUpdate = true;
          ContactStore sender = await localStorage.getLocalContact(data.from);
          if (sender == null || sender.dnd == 0) {
            PushManager.sendJpush(data: data, type: 1);
          }
        } else {
          _pushRead();
        }
        break;
      case ActionValue.READ:
        String _id = res.data['id'];
        if (strNoEmpty(_id)) {
          for (ChatStore chat in _chatMsg) {
            if (chat.id == _id) {
              chat.state = 2;
              chat.readTime = DateTime.now().millisecondsSinceEpoch;
              if (mounted) {
                setState(() {});
              }
              localStorage.readLocalChat(_chatType, widget.userId, _id);
              await localStorage
                  .readMyMsgLocalChannel(widget.userId); //更新消息列表已读
              break;
            }
          }
        } else {
          bool isModify = false;
          for (ChatStore chat in _chatMsg) {
            if (chat.receiver == widget.userId && chat.state < 2) {
              chat.readTime = DateTime.now().millisecondsSinceEpoch;
              chat.state = 2;
              isModify = true;
            }
          }
          if (isModify) {
            if (mounted) setState(() {});
            localStorage.readLocalChats(_chatType, widget.userId, true);
            await localStorage.readMyMsgLocalChannel(widget.userId); //更新消息列表已读
          }
        }
        break;
      default:
    }
  }

  //接收到mtype11
  _deleteMtype(List<String> ids) {
    List<ChatStore> _copyChat = [];
    _copyChat.addAll(_allLocalChat);
    //删本地
    _copyChat.forEach((chat) {
      if (ids.contains(chat.id)) {
        _delMsg(chat);
      }
    });

    if (_isSelect = true) {
      GlobalModel.getInstance().setTotal(0);
      _selectList.clear();
      _isSelect = false;
    }

    if (mounted) {
      setState(() {});
    }
    localStorage.deleteLocalChats(_chatType, widget.userId, ids,
        isAll: false, isOnlyDeleteLocal: true);
  }

  // 设置为已读
  void _pushRead() {
    chatApi.readMsg({'sender': API.userInfo.id, 'receiver': widget.userId});
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
    eventBus.on(EVENT_UPDATE_MSG_STATE, (arg) {
      if (arg == true && _isUpdate) {
        _pushRead();
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
        // 转发到当前页面 让消息显示
        if (arg['value'] is ChannelStore) {
          if (arg['value'].type == arg['msg'].type &&
              widget.userId == arg['value'].id) {
            _echo(arg['msg']);
          }
        }
        if (arg['value'] is ContactExtendIsSelected) {
          if (arg['msg'].type == 1 && widget.userId == arg['value'].userId) {
            _echo(arg['msg']);
          }
        }
      }
    });
    //app进入后台关闭语音
    eventBus.on(EVENT_ENTER_THE_BACKGROUND, (arg) {
      if (arg == true) {
        ChatCommonMethod.stopAudioPlayer(_audioPlayer);
      }
    });
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

  //转发消息 通用
  _forwardMsg(ChatStore chatStore) {
    if ((chatStore.mtype == 3 || chatStore.mtype == 4) &&
        !isNetWorkImg(chatStore.msg)) {
      showToast(context, S.of(context).tryAgainLater);
    } else {
      routeMaterialPush(ForwardPage(forwardType: 1, chatStore: chatStore))
          .then((value) {
        if (value != null) {
          // 转发到当前页面 让消息显示
          if (value is ChannelStore) {
            if (value.type == chatStore.type && widget.userId == value.id) {
              _echo(chatStore);
            }
          }
          if (value is ContactExtendIsSelected) {
            if (chatStore.type == 1 && widget.userId == value.userId) {
              _echo(chatStore);
            }
          }
        }
      });
    }
  }

  //转发回显
  _echo(ChatStore ecStore) {
    String id = getOnlyId();
    //文本消息 格式化
    String msg = '';
    if (ecStore.mtype == 1) {
      if (strIsJson(ecStore.msg)) {
        msg = jsonDecode(ecStore.msg)['text'];
      } else {
        msg = ecStore.msg;
      }
      msg = jsonEncode({'text': msg});
    } else {
      msg = ecStore.msg;
    }
    ChatStore chat = ChatStore(id, _chatType, API.userInfo.id, widget.userId,
        MediaType.values[ecStore.mtype - 1].index + 1, msg,
        state: 1,
        time: DateTime.now().millisecondsSinceEpoch,
        name: ecStore.name,
        burn: _burnModel?.burn ?? 0);
    _jumpBot(chatStore: chat);
  }

  //图片放大后 转发图片
  _forwardByImgview(ChatStore chatStore, dynamic data) {
    if (data is ChannelStore) {
      if (data.type == chatStore.type && widget.userId == data.id) {
        _echo(chatStore);
      }
    }
    if (data is ContactExtendIsSelected) {
      if (1 == chatStore.type && widget.userId == data.userId) {
        _echo(chatStore);
      }
    }
  }

  _deleteMsg(ChatStore chatStore, bool isAll) async {
    //删本地
    await localStorage.deleteLocalChats(
        _chatType, widget.userId, [chatStore.id],
        isAll: isAll);
    _delMsg(chatStore);
    //删除之后 判断当前列表是否有20条 没有的话隐式刷新填充消息列表
    if (_chatMsg.length < _pageSize) {
      List<ChatStore> data = await _fakePage(onLoad: true);
      // 取消无数据提示
      if (data.isNotEmpty) {
        _chatMsg.addAll(data);
        _dealMediaList();
      }
    }

    _isShowGoTop = false;

    if (mounted) {
      setState(() {});
    }
  }

  //删除单条消息
  _delteOneMsg(ChatStore chatStore) async {
    showSureModal(context, S.of(context).sureDeleteTheChat, () {
      _deleteMsg(chatStore, false);
    },
        text2: _chatType == 1
            ? S.of(context).deleteOther(_nickName ?? widget.name)
            : null,
        onPressed2: _chatType == 1
            ? () {
                _deleteMsg(chatStore, true);
              }
            : null);
  }

  //多选删除消息
  _deleteMuchMsg(bool isAll) async {
    List<String> ids = [];
    _selectList.forEach((element) {
      ids.add(element.id.toString());
      _delMsg(element);
    });
    //删本地
    await localStorage.deleteLocalChats(_chatType, widget.userId, ids,
        isAll: isAll);
    //删除之后 判断当前列表是否有20条 没有的话隐式刷新一下填充消息列表
    if (_chatMsg.length < _pageSize) {
      List<ChatStore> data = await _fakePage(onLoad: true);
      // 取消无数据提示
      if (data.isNotEmpty) {
        _chatMsg.addAll(data);
        _dealMediaList();
      }
    }

    _isShowGoTop = false;

    if (mounted) {
      setState(() {
        _selectList.clear();
        _isSelect = false;
      });
    }
  }

  //勾选操作 1:转发 2：收藏 3：删除
  void _selectAction(int id) {
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
        showSureModal(context, S.of(context).sureDeleteSelectMsg, () {
          _deleteMuchMsg(false);
        },
            text2: _chatType == 1
                ? S.of(context).deleteOther(_nickName ?? widget.name)
                : null,
            onPressed2: _chatType == 1
                ? () {
                    _deleteMuchMsg(true);
                  }
                : null);
        break;
      default:
    }
  }

  ///发送语音
  Future<void> _sendVoice(Map path) async {
    try {
      if (path == null) return;
      ChatStore chat = _parseToChat(MediaType.VOICE, jsonEncode(path));
      var result = await commonApi.uploadFile(path['path'], backFullPath: true);
      if (result != null) {
        path['path'] = result;
        ChatStore store = ChatStore(chat.id, chat.type, chat.sender,
            chat.receiver, chat.mtype, jsonEncode(path),
            state: chat.state,
            time: DateTime.now().millisecondsSinceEpoch,
            name: API.userInfo.nickname,
            burn: _burnModel?.burn ?? 0);
        Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
        chat.state = (res != null && res['code'] == null) ? 1 : 0;
        store.state = chat.state;
        store.isReadVoice = true;
        if (mounted) setState(() {});
        isBlock(res, store, MediaType.VOICE);
      }
    } catch (e) {
      print('语音异常: $e');
    }
  }

  //发送文本
  Future<void> _sendText() async {
    String message = _textController.text;
    if (!strNoEmpty(message)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textController.clear();
    });

    Map<String, dynamic> msg = {'text': message};

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
    await _send(MediaType.TEXT, message);
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
            chat.msg = value;
            ChatStore store = ChatStore(chat.id, chat.type, chat.sender,
                chat.receiver, chat.mtype, value,
                state: chat.state,
                time: DateTime.now().millisecondsSinceEpoch,
                name: API.userInfo.nickname,
                burn: _burnModel?.burn ?? 0);
            Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
            chat.state = (res != null && res['code'] == null) ? 1 : 0;
            store.state = chat.state;
            if (mounted) setState(() {});
            await isBlock(res, store, MediaType.TEXT);
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
          chat.id, chat.type, chat.sender, chat.receiver, chat.mtype, result,
          state: chat.state,
          time: DateTime.now().millisecondsSinceEpoch,
          name: API.userInfo.nickname,
          burn: _burnModel?.burn ?? 0);
      Map res = await chatApi.sendMsg(WsRequest.upMsg(store));
      chat.state = (res != null && res['code'] == null) ? 1 : 0;
      store.state = chat.state;
      if (mounted) setState(() {});
      isBlock(res, store, MediaType.PICTURE);
    } catch (e) {
      print('拍摄图片异常: $e');
    }
  }

  Future<void> _send(MediaType mediaType, String message) async {
    ChatStore chat = _parseToChat(mediaType, message);
    Map result = await chatApi.sendMsg(WsRequest.upMsg(chat));
    chat.state = (result != null && result['code'] == null) ? 1 : 0;
    if (mounted) setState(() {});
    isBlock(result, chat, mediaType);
  }

  // 把发送的消息写入本地，并判断是否已被拉黑
  Future isBlock(Map res, ChatStore store, MediaType msgType) async {
    await _channelManager.addSingleChat(
        widget.userId, widget.name, widget.avatar, false, store);
    if (res != null && res['code'] != null) {
      ChatStore blockChat = _parseToChat(msgType, S.of(context).blockedTip,
          isBlocked: true, state: 1);
      _channelManager.addSingleChat(
          widget.userId, widget.name, widget.avatar, false, blockChat);
    }
  }

  // 格式化
  ChatStore _parseToChat(MediaType mediaType, String message,
      {bool isBlocked = false, int state = -1}) {
    String id = getOnlyId();
    ChatStore chat = ChatStore(id, _chatType, API.userInfo.id, widget.userId,
        isBlocked ? 106 : (mediaType.index + 1), message,
        state: state,
        time: DateTime.now().millisecondsSinceEpoch,
        avatar: API.userInfo.avatar,
        name: API.userInfo.nickname,
        burn: _burnModel?.burn ?? 0);
    if (!isBlocked && mediaType == MediaType.PICTURE) {
      _imgList.add(chat);
    }
    if (!isBlocked && mediaType == MediaType.VOICE) {
      _voiceList.add(chat);
    }
    _allLocalChat.insert(0, chat);
    _chatMsg.insert(0, chat);
    _jumpBot();
    return chat;
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
                  }
                  return SingleChatMsgCell(
                    _chatMsg[index],
                    _isSelect,
                    _audioPlayer,
                    _tempData,
                    _imgList,
                    valueCall: (v) {
                      if (v != null) {
                        _clearQuote();
                        switch (v['type']) {
                          case 'delete':
                            _delteOneMsg(v['data']);
                            break;
                          case 'forward':
                            _forwardMsg(v['data']);
                            break;
                          case 'forwardInImgDetail':
                            _forwardByImgview(
                                v['data']['chatStore'], v['data']['value']);
                            break;
                          case 'quote':
                            _quote(v['data']);
                            break;
                          default:
                        }
                      }
                    },
                  );
                },
                shrinkWrap: true,
                reverse: true,
                itemCount: _chatMsg.length + 1,
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
        joinFromWhere: 5,
        avatar: widget.avatar,
        id: widget.userId,
        name: widget.name,
        gtype: -1,
      )
    ];
    return items;
  }

  //appbar right widget
  List<Widget> _rWidget() {
    List<Widget> _rItems = [];
    if (_burnModel?.burn != null && _burnModel?.burn != 0) {
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
    //     onPressed: () {
    //       print('端对端加密');
    //     }));
    _rItems.add(InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 8.0,
          ),
          child: ImageView(
            img: cuttingAvatar(widget.avatar),
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
            needLoad: true,
            isRadius: 20,
          ),
        ),
        highlightColor: Colors.transparent,
        onTap: () async {
          if (widget.userId == 10) {
            return;
          }
          if (widget.whereToChat == 2) {
            Navigator.pop(context);
            return;
          }

          ChatCommonMethod.stopAudioPlayer(_audioPlayer);

          var result = await routePush(SingleInfoPage(
            userId: widget.userId,
            whereToInfo: widget.whereToChat,
          ));
          if (result == null) return;
          Map map = jsonDecode(result);
          if (map['delFriend'] == true && mounted) {
            setState(() {
              _chatMsg.clear();
              _allLocalChat.clear();
              Navigator.pop(context);
            });
          }
          if (map['_isClearChat'] == true && mounted) {
            setState(() {
              _isShowGoTop = false;
              _chatMsg.clear();
              _allLocalChat.clear();
              _imgList.clear();
              _voiceList.clear();
            });
          }
          if (strNoEmpty(map['name']) &&
              map['name'] != widget.name &&
              mounted) {
            setState(() {
              _nickName = map['name'];
            });
          }
          if (map['burn'] != null &&
              map['burn'] != (_burnModel?.burn ?? 0) &&
              mounted) {
            _burnModel.burn = map['burn'];
            setState(() {});
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
              title: _nickName ??
                  (widget.userId == 10 ? S.of(context).kf : widget.name),
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
