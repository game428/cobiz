import 'dart:convert';

import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/history_msg_model.dart';
import 'package:cobiz_client/pages/work/meeting/meeting_detail.dart';
import 'package:cobiz_client/pages/work/workbench/general_approval_details.dart';
import 'package:cobiz_client/pages/work/report/report_detail.dart';
import 'package:cobiz_client/pages/work/work_common.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/socket/ws_response.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/menu/magic_pop.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:cobiz_client/config/api.dart';
import 'channel_ui/chat_common_widget.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;

//工作通知页面
class WorkNoticeMsgPage extends StatefulWidget {
  final int teamId;
  final String title;
  WorkNoticeMsgPage(this.teamId, this.title, {Key key}) : super(key: key);

  @override
  _WorkNoticeMsgPageState createState() => _WorkNoticeMsgPageState();
}

class _WorkNoticeMsgPageState extends State<WorkNoticeMsgPage> {
  int _chatType = 3;
  int otherId = 11;
  int mtype = 9;
  String event;
  ScrollController _scrollController = ScrollController();
  ChannelManager _channelManager = ChannelManager.getInstance();

  int _pageSize = 20;
  int _firstPageSize = 40;

  int _maxMsgNum = 100;

  String _firstUnreadMsgId;

  List<WorkMsgStore> _workMsg = [];
  List<WorkMsgStore> _allLocalWorkMsg = [];
  bool _isScrollLoading = false; //是否通过滚动加载

  bool _isShowGoTop = false; //是否显示未读消息按钮

  bool _isReadUnread = false; //是否在读大量的未读消息

  int _unreadNum = 0; //未读条数 进来查询

  bool _isHistoryMsg = true; // 是否还有线上历史消息

  bool _isSelect = false; //勾选消息
  List<WorkMsgStore> _selectList = []; //已选中的消息
  Set<String> _selectIds = Set(); //已选择消息id

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _updateCannel();
    WsConnector.removeListenerByEvent(event ?? '');
    super.dispose();
  }

  // 更新消息列表最新一条消息展示
  _updateCannel() async {
    //查询外面的单条
    ChannelStore channel =
        await localStorage.getLocalChannel(_chatType, widget.teamId);

    if (channel == null) {
      return;
    }

    WorkMsgStore newWorkMsg;
    if ((_allLocalWorkMsg?.length ?? 0) > 0) {
      newWorkMsg = _allLocalWorkMsg[0];
    }
    ChatStore newChat = ChatStore(
      newWorkMsg?.logoId ?? null,
      _chatType,
      otherId,
      API.userInfo.id,
      mtype,
      newWorkMsg != null ? json.encode(newWorkMsg) : '',
      state: -1,
      time: newWorkMsg?.sendTime ?? DateTime.now().millisecondsSinceEpoch,
    );
    if (channel?.label != json.encode(newChat)) {
      await localStorage.updateLocalChannel(
          ChannelStore(
            type: 3,
            id: widget.teamId,
            name: channel?.name,
            avatar: channel?.avatar,
            label: json.encode(newChat),
            unread: 0,
            lastAt: newChat.time,
            top: channel?.top,
            // 只有自己发的，非推送消息才显示已读未读状态
            readUnread: null,
          ),
          msgType: newChat.mtype);
    }
    _channelManager.refresh();
  }

  //初始化 获取数据
  _init() async {
    _scrollListerner();
    event = 'team_notice_${widget.teamId}';
    WsConnector.addListener(event, _dealMsg);
    ChannelStore channel =
        await localStorage.getLocalChannel(_chatType, widget.teamId);
    if (channel != null) {
      _unreadNum = channel.unread ?? 0;
    }
    await localStorage.readLocalChannel(_chatType, widget.teamId);
    List<WorkMsgStore> stores =
        await localStorage.getLocalWorkMsgs(widget.teamId);
    if (stores != null && stores.length > 0) {
      if (_unreadNum > stores.length) {
        _unreadNum = stores.length;
      }
      if (_unreadNum > _firstPageSize) {
        _isShowGoTop = true;
        _firstUnreadMsgId = stores[_unreadNum - 1].logoId;
      }
      _allLocalWorkMsg.clear();
      _workMsg.clear();
      _allLocalWorkMsg.addAll(stores);
      List<WorkMsgStore> data = await _fakePage(pageSize: _firstPageSize);
      _workMsg.addAll(data);
    }
    _initOlMsg();
    if (mounted) setState(() {});
  }

  // 初始化从线上获取最新消息
  void _initOlMsg() async {
    List<HistoryModel> msgWorkList = await _getOlMsg('', size: 1000, direct: 0);
    if (msgWorkList.length > 0) {
      if (msgWorkList.length > _allLocalWorkMsg.length ||
          msgWorkList.first.id != _allLocalWorkMsg.first.logoId ||
          msgWorkList.last.id !=
              _allLocalWorkMsg[msgWorkList.length - 1].logoId) {
        List<WorkMsgStore> stores = _formatOlMsg(msgWorkList);
        _allLocalWorkMsg.clear();
        _workMsg.clear();
        _allLocalWorkMsg.addAll(stores);
        List<WorkMsgStore> data = await _fakePage(pageSize: _firstPageSize);
        _workMsg.addAll(data);
        if (_unreadNum > stores.length) {
          _unreadNum = stores.length;
        }
        if (_unreadNum > _firstPageSize) {
          _firstUnreadMsgId = stores[_unreadNum - 1].logoId;
        }
        _updateLocalMsg();
      }
    }
    if (mounted) {
      setState(() {
        if (_unreadNum > _firstPageSize) {
          _isShowGoTop = true;
        }
      });
    }
  }

  // 更新本地缓存
  Future<void> _updateLocalMsg() async {
    List<String> list = _allLocalWorkMsg.map((e) => json.encode(e)).toList();
    await SharedUtil.instance.saveStringList(
        '${Keys.workMsg}${API.userInfo.id}_${widget.teamId}', list);
  }

  // 从线上获取消息
  Future<List<HistoryModel>> _getOlMsg(String id,
      {int size = 1000, direct = 0}) async {
    List<HistoryModel> msgList = await chatApi.querySingleChat(otherId,
        teamId: widget.teamId, direct: direct, size: size, msgId: id);
    if (msgList.length < size) {
      _isHistoryMsg = false;
    }
    if (msgList.length > 0) {
      return msgList;
    }
    return [];
  }

  // 格式化线上消息
  List<WorkMsgStore> _formatOlMsg(List<HistoryModel> olMsg) {
    List<WorkMsgStore> olNewMsg = [];
    olMsg.forEach((history) {
      var store = jsonDecode(history.msg);
      store['sendTime'] = history.time;
      store['logoId'] = history.id;
      WorkMsgStore workMsgStore = WorkMsgStore.fromJsonMap(store);
      olNewMsg.add(workMsgStore);
    });
    return olNewMsg;
  }

  // 在线接收消息处理
  Future<void> _dealMsg(message) async {
    Map<String, dynamic> map = json.decode(message);
    WsResponse res = WsResponse.fromJsonMap(map);
    if (res.command > ActionValue.values.length) {
      print('未定义ActionValue${res.command}');
      return;
    }
    var store = jsonDecode(res.data.msg);
    store['sendTime'] = res.data.time;
    store['logoId'] = res.data.id;
    // 若在查看很多未读消息 则不往里面直接插入
    WorkMsgStore workMsgStore = WorkMsgStore.fromJsonMap(store);
    if (mounted) {
      setState(() {
        if (!strNoEmpty(workMsgStore.reviewer) && workMsgStore.state > 0) {
          WorkMsgStore workStore = _allLocalWorkMsg
              .firstWhere((work) => work.logoId == workMsgStore.logoId);
          if (workStore != null) {
            _allLocalWorkMsg.remove(workStore);
            _workMsg.remove(workStore);
          }
          // for (int i = 0; i < _allLocalWorkMsg.length; i++) {
          //   WorkMsgStore workStore = _allLocalWorkMsg[i];
          //   if (workStore.logoId == workMsgStore.logoId) {
          //     _allLocalWorkMsg.remove(workStore);
          //     _workMsg.remove(workStore);
          //     break;
          //   }
          // }
        }

        _allLocalWorkMsg.insert(0, workMsgStore);
        if (!_isReadUnread) {
          _workMsg.insert(0, workMsgStore);
        }
      });
    }
    _channelManager.addLocalWork(
        res.data.from,
        res.data.name,
        res.data.avatar,
        false,
        ChatStore(res.data.id, res.data.type, res.data.from, res.data.to,
            res.data.mtype, res.data.msg,
            state: 0,
            time: res.data.time ?? DateTime.now().millisecondsSinceEpoch),
        workMsgStore);
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
          List<WorkMsgStore> data = await _fakePage(onLoad: true);
          // 取消无数据提示
          if (data.isNotEmpty) {
            _workMsg.addAll(data);
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
        List<WorkMsgStore> data = _slideUp(onSlideUp: true);
        if (data.isNotEmpty) {
          _workMsg.insertAll(0, data);
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

  // 未读消息加载
  List<WorkMsgStore> _slideUp({bool onSlideUp = false}) {
    // onSlideUp 是否是上滑加载
    int end; // 终点
    int start; // 起点

    if (onSlideUp) {
      // 如果是上滑加载
      end = _allLocalWorkMsg
          .indexWhere((element) => element.logoId == _workMsg.first.logoId);
    } else {
      // 不是上滑，则为滚动到第一条未读消息，且未读消息超过最大限制条数
      end = _allLocalWorkMsg
              .indexWhere((element) => element.logoId == _firstUnreadMsgId) +
          1;
      if (end == 0) {
        // 如果没找到
        if (_unreadNum > _allLocalWorkMsg.length) {
          // 如果已经删除，未读条数大于总条数
          end = _allLocalWorkMsg.length;
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
    return _allLocalWorkMsg.sublist(start, end);
  }

  //假分页
  Future<List<WorkMsgStore>> _fakePage({
    bool onLoad = false,
    bool unRead = false,
    int pageSize,
  }) async {
    // onLoad 分页加载
    // unRead 未读加载
    // pageSize 分页条数
    int start = 0; // 起点
    int end; // 终点
    int size = pageSize ?? _pageSize; // 分页条数，默认为 _pageSize;

    if (onLoad) {
      //计算当前下标从何处开始
      start = _allLocalWorkMsg
              .indexWhere((element) => element.logoId == _workMsg.last.logoId) +
          1;
    }

    //数量少的时候未读消息end
    if (unRead) {
      end = _allLocalWorkMsg
              .indexWhere((element) => element.logoId == _firstUnreadMsgId) +
          1;
      if (end == 0) {
        end = _unreadNum;
      }
    } else {
      end = start + size;
    }
    if (end >= _allLocalWorkMsg.length) {
      end = _allLocalWorkMsg.length;
    }
    if (start >= end) {
      if (onLoad == true && _isHistoryMsg == true) {
        List<HistoryModel> hisList = await _getOlMsg(
            _allLocalWorkMsg.last.logoId,
            size: pageSize,
            direct: 1);
        List<WorkMsgStore> msgWorkList = _formatOlMsg(hisList);
        _allLocalWorkMsg.addAll(msgWorkList.reversed);
        await _updateLocalMsg();
        return msgWorkList.reversed;
      }
      return [];
    }
    return _allLocalWorkMsg.sublist(start, end);
  }

  //点击未读消息按钮相关操作
  void _onTapUnreadBtn() async {
    if (_unreadNum <= _firstPageSize) {
      return;
    }
    List<WorkMsgStore> data = [];
    //数量多 清空 然后跳转
    if (_unreadNum >= _maxMsgNum) {
      _isReadUnread = true;
      data = _slideUp();
      _workMsg.clear();
    } else {
      data = await _fakePage(onLoad: true, unRead: true);
    }

    if (data.isNotEmpty) {
      _workMsg.addAll(data);

      _isShowGoTop = false;

      if (mounted) {
        setState(() {});
      }
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 1 * _workMsg.length),
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

  // 审批信息
  List<Widget> _buildApproItem(WorkMsgStore item) {
    List<Widget> contents = List();
    String title = '';
    String texTitle = '';
    String stateTitle = '';
    Color stateColor = blueDEColor;
    switch (item.state) {
      case 0: // 未处理
        stateTitle = S.of(context).todo;
        stateColor = blueDEColor;
        break;
      case 1: // 已同意
        stateTitle = S.of(context).agreed;
        stateColor = AppColors.mainColor;
        break;
      case 2: // 已拒绝
        stateTitle = S.of(context).rejected;
        stateColor = AppColors.red;
        break;
      case 3: // 已撤销
        stateTitle = S.of(context).revoked;
        stateColor = AppColors.font_c2;
        break;
    }
    switch (item.type) {
      case 1: // 通用
        title = S.of(context).universal;
        texTitle = S.of(context).universalTitle(item.name);
        contents
            .add(buildAnnotation(S.of(context).applyContent, item.title ?? ''));
        if (strNoEmpty(item.content)) {
          contents
              .add(buildAnnotation(S.of(context).applyDetail, item.content));
        }
        break;
      case 2: // 请假
        String format;
        if ([1, 2, 3, 10].contains(item.leaveType)) {
          format = 'yyyy-MM-dd HH:mm';
        } else {
          format = 'yyyy-MM-dd';
        }
        title = S.of(context).leave;
        texTitle = S.of(context).leaveTitle(item.name);
        contents.add(buildAnnotation(
            S.of(context).typeOfLeave, leaveTypeName(item.leaveType, context)));
        contents.add(buildAnnotation(S.of(context).beginTime,
            DateUtil.formatSeconds(item.beginAt, format: format)));
        contents.add(buildAnnotation(S.of(context).endTime,
            DateUtil.formatSeconds(item.endAt, format: format)));
        break;
      case 3: // 报销
        title = S.of(context).reimbursement;
        texTitle = S.of(context).reimbursementTitle(item.name);
        contents
            .add(buildAnnotation(S.of(context).expenseType, item.title ?? ''));
        contents.add(buildAnnotation(S.of(context).expenseTotal,
            '${item.money.toString()} (${item.unit})'));
        if (strNoEmpty(item.content)) {
          contents
              .add(buildAnnotation(S.of(context).expenseDetail, item.content));
        }
        break;
    }
    contents.insert(
        0,
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            texTitle,
            style: TextStyles.textF16T9,
          ),
        ));
    contents.insert(
        0,
        Text(
          title,
          style: TextStyles.textF16T8,
        ));

    contents.add(Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        stateTitle,
        style: TextStyle(fontSize: FontSizes.font_s16, color: stateColor),
      ),
    ));
    return contents;
  }

  // 审批回复
  List<Widget> _buildApprReply(WorkMsgStore item) {
    List<Widget> contents = List();
    String title;
    switch (item.type) {
      case 1:
        title = S.of(context).universal;
        break;
      case 2:
        title = S.of(context).leave;
        break;
      case 3:
        title = S.of(context).reimbursement;
        break;
    }
    String texTitle = S.of(context).someRevAppr(item.reviewer, item.name);
    contents.add(Text(
      title,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        texTitle,
        style: TextStyles.textF16T9,
      ),
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: buildAnnotation(S.of(context).comment, item.content),
    ));

    return contents;
  }

  // 任务信息
  List<Widget> _buildTaskItem(WorkMsgStore item) {
    List<Widget> contents = List();
    String stateTitle = '';
    Color stateColor = blueDEColor;
    switch (item.state) {
      case 0: // 待处理
        stateTitle = S.of(context).todo;
        stateColor = blueDEColor;
        break;
      case 1: // 已完成
        stateTitle = S.of(context).completed;
        stateColor = AppColors.mainColor;
        break;
      case 3: // 已撤销
        stateTitle = S.of(context).revoked;
        stateColor = AppColors.font_c2;
        break;
    }
    contents.add(Text(
      S.of(context).task,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        S.of(context).taskTitle(item.name),
        style: TextStyles.textF16T9,
      ),
    ));
    contents.add(buildAnnotation(S.of(context).taskName, item.title ?? ''));
    contents.add(buildAnnotation(S.of(context).taskDetail, item.content ?? ''));
    contents.add(buildAnnotation(S.of(context).finishTime,
        DateUtil.formatSeconds(item.endAt, format: 'yyyy-MM-dd HH:mm')));
    contents.add(Padding(
      padding: EdgeInsets.only(top: 15),
      child: Text(
        stateTitle,
        style: TextStyle(fontSize: FontSizes.font_s16, color: stateColor),
      ),
    ));
    return contents;
  }

  // 任务回复
  List<Widget> _buildTaskReply(WorkMsgStore item) {
    List<Widget> contents = List();
    String title = S.of(context).task;
    String texTitle = S.of(context).someRevTask(item.reviewer, item.name);
    contents.add(Text(
      title,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        texTitle,
        style: TextStyles.textF16T9,
      ),
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: buildAnnotation(S.of(context).comment, item.content),
    ));

    return contents;
  }

  // 日报信息
  List<Widget> _buildLogItem(WorkMsgStore item) {
    List<Widget> contents = List();
    String title = '';
    String texTitle = S.of(context).logTitle(item.name);
    switch (item.type) {
      case 1: // 日报
        title = S.of(context).daily;
        break;
      case 2: // 周报
        title = S.of(context).weekly;
        break;
      case 3: // 月报
        title = S.of(context).monthlyReport;
        break;
    }
    contents.add(Text(
      title,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        texTitle,
        style: TextStyles.textF16T9,
      ),
    ));
    if (strNoEmpty(item.finished)) {
      contents.add(buildAnnotation(S.of(context).workDone, item.finished));
    }
    if (strNoEmpty(item.pending)) {
      contents.add(buildAnnotation(S.of(context).unfinishedWork, item.pending));
    }
    if (strNoEmpty(item.needed)) {
      contents.add(buildAnnotation(S.of(context).coordinate, item.needed));
    }

    return contents;
  }

  // 会议纪要信息
  List<Widget> _buildMeetingItem(WorkMsgStore item) {
    List<Widget> contents = List();
    String texTitle = S.of(context).meetingMinTitle(item.name);
    contents.add(Text(
      S.of(context).meeting,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        texTitle,
        style: TextStyles.textF16T9,
      ),
    ));
    if (strNoEmpty(item.title)) {
      contents.add(buildAnnotation(S.of(context).meetingTitle, item.title));
    }
    if (strNoEmpty((item.beginAt ?? 0).toString())) {
      contents.add(buildAnnotation(S.of(context).beginTime,
          DateUtil.formatSeconds(item.beginAt, format: 'yyyy-MM-dd HH:mm')));
    }
    if (strNoEmpty((item.endAt ?? 0).toString())) {
      contents.add(buildAnnotation(S.of(context).endTime,
          DateUtil.formatSeconds(item.endAt, format: 'yyyy-MM-dd HH:mm')));
    }

    return contents;
  }

  //会议纪要回复
  List<Widget> _buildMeetingMinutesItem(WorkMsgStore item) {
    List<Widget> contents = List();
    String texTitle = S.of(context).someRevMeeting(item.reviewer, item.name);
    contents.add(Text(
      S.of(context).meeting,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        texTitle,
        style: TextStyles.textF16T9,
      ),
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: buildAnnotation(S.of(context).comment, item.content),
    ));

    return contents;
  }

  // 日报回复
  List<Widget> _buildReplyItem(WorkMsgStore item) {
    List<Widget> contents = List();
    String title = '';
    String texTitle = S.of(context).someRev(item.reviewer, item.name);
    switch (item.type) {
      case 1:
        title = S.of(context).daily;
        break;
      case 2:
        title = S.of(context).weekly;
        break;
      case 3:
        title = S.of(context).monthlyReport;
        break;
    }
    contents.add(Text(
      title,
      style: TextStyles.textF16T8,
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        texTitle,
        style: TextStyles.textF16T9,
      ),
    ));
    contents.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: buildAnnotation(S.of(context).comment, item.content),
    ));

    return contents;
  }

  //长按菜单
  Widget _magicPop(Widget child, WorkMsgStore item) {
    List<MagicPopAction> actions = [
      MagicPopAction(S.of(context).delete, 1),
      MagicPopAction(S.of(context).checkbox, 2),
    ];

    return MagicPop(
      onValueChanged: (value) async {
        switch (value.value) {
          case 1:
            _delteOneMsg(item);
            break;
          case 2:
            if (mounted && _isSelect == false) {
              setState(() {
                _isSelect = true;
              });
            }
            break;
          default:
        }
      },
      actions: actions,
      child: child,
      isSelf: false,
      pageMaxChildCount: 3,
      menuHeight: 32,
    );
  }

  // item右侧显示
  Widget _buildItem(WorkMsgStore item) {
    List<Widget> list;
    if (item.mode == 1) {
      if (item.type == 4) {
        if (strNoEmpty(item.reviewer)) {
          list = _buildTaskReply(item);
        } else {
          list = _buildTaskItem(item);
        }
      } else {
        if (strNoEmpty(item.reviewer)) {
          list = _buildApprReply(item);
        } else {
          list = _buildApproItem(item);
        }
      }
    } else if (item.mode == 2) {
      if (strNoEmpty(item.reviewer)) {
        list = _buildReplyItem(item);
      } else {
        list = _buildLogItem(item);
      }
    } else if (item.mode == 3) {
      if (strNoEmpty(item.reviewer)) {
        list = _buildMeetingMinutesItem(item);
      } else {
        list = _buildMeetingItem(item);
      }
    } else {
      list = [
        Text(
          S.of(context).notSupportThisMsg,
        )
      ];
    }
    return InkWell(
      onTap: () {
        if (item.mode == 1) {
          routePush(GeneralApprovalDetails(
            id: item.id,
            teamId: widget.teamId,
          ));
        } else if (item.mode == 2) {
          routePush(ReportDetailPage(
            id: item.id,
            teamId: widget.teamId,
          ));
        } else if (item.mode == 3) {
          routePush(MeetingDetailPage(
            id: item.id,
            teamId: widget.teamId,
          ));
        }
      },
      child: Container(
        padding: EdgeInsets.all(10),
        width: winWidth(context) * (_isSelect == true ? 0.55 : 0.7),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.circular((8.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      ),
    );
  }

  // Item渲染
  Widget _buildItems(int index) {
    Widget rowItem = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(21.0),
              side: BorderSide(color: Colors.grey, width: 0.3),
            ),
            color: _workMsg[index].mode == 1
                ? _workMsg[index].type == 4 ? blueDEColor : red68Color
                : AppColors.mainColor,
          ),
          alignment: Alignment.center,
          width: 40.0,
          height: 40.0,
          child: ImageView(
            width: 20,
            height: 20,
            img:
                'assets/images/team/${_workMsg[index].mode == 1 ? _workMsg[index].type == 4 ? 'task' : 'appro' : 'log'}.png',
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10, left: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
                constraints: BoxConstraints(maxWidth: winWidth(context) * 0.7),
                child: Text(
                  _workMsg[index].mode == 1
                      ? _workMsg[index].type == 4
                          ? S.of(context).task
                          : S.of(context).approve
                      : S.of(context).dailyRecord,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
              _magicPop(_buildItem(_workMsg[index]), _workMsg[index]),
            ],
          ),
        ),
      ],
    );
    return rowItem;
  }

  //删除单条消息
  _delteOneMsg(WorkMsgStore workMsg) async {
    //删本地
    await localStorage.deleteLocalWork(widget.teamId, [workMsg.logoId]);
    _allLocalWorkMsg.remove(workMsg);
    _workMsg.remove(workMsg);
    //删除之后 判断当前列表是否有20条 没有的话隐式刷新填充消息列表
    if (_workMsg.length < _pageSize) {
      List<WorkMsgStore> data = await _fakePage(onLoad: true);
      // 取消无数据提示
      if (data.isNotEmpty) {
        _workMsg.addAll(data);
      }
    }

    _isShowGoTop = false;

    if (mounted) {
      setState(() {});
    }
  }

  //多选删除消息
  _deleteMuchMsg() async {
    _selectList.forEach((element) {
      if (_selectIds.contains(element.logoId)) {
        _allLocalWorkMsg.remove(element);
        _workMsg.remove(element);
      }
    });
    //删本地
    await localStorage.deleteLocalWork(widget.teamId, _selectIds.toList());
    //删除之后 判断当前列表是否有20条 没有的话隐式刷新一下填充消息列表
    if (_workMsg.length < _pageSize) {
      List<WorkMsgStore> data = await _fakePage(onLoad: true);
      // 取消无数据提示
      if (data.isNotEmpty) {
        _workMsg.addAll(data);
      }
    }

    _isShowGoTop = false;

    if (mounted) {
      setState(() {
        _selectList.clear();
        _selectIds.clear();
        _isSelect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          _selectList.clear();
                          _selectIds.clear();
                          _isSelect = false;
                        });
                      }
                    })
              ],
            )
          : ComMomBar(
              title: '${S.of(context).workNotice}:${widget.title}',
              centerTitle: false,
              backgroundColor: AppColors.white,
              elevation: 0.5,
            ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: AppColors.specialBgGray,
        child: GestureDetector(
          child: Column(
            children: [
              Flexible(
                child: Stack(
                  children: [
                    Container(
                      child: ListView.builder(
                        padding: EdgeInsets.all(15.0),
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index == _workMsg.length) {
                            return _isScrollLoading
                                ? buildProgressIndicator(
                                    isLoading: _isScrollLoading)
                                : Container();
                          } else {
                            return _isSelect
                                ? RadioLineView(
                                    paddingLeft:
                                        NavigationToolbar.kMiddleSpacing - 7,
                                    checkCallback: () {
                                      WorkMsgStore workMsg = _workMsg[index];
                                      bool checked =
                                          _selectIds.contains(workMsg.logoId);
                                      if (_selectIds.length >= 99 && !checked) {
                                        showToast(context,
                                            S.of(context).max100selected);
                                        return;
                                      }
                                      setState(() {
                                        if (checked == true) {
                                          _selectIds.remove(workMsg.logoId);
                                          _selectList.remove(workMsg);
                                        } else {
                                          _selectIds
                                              .add(_workMsg[index].logoId);
                                          _selectList.add(workMsg);
                                        }
                                      });
                                    },
                                    checked: _selectIds
                                        .contains(_workMsg[index].logoId),
                                    content: IgnorePointer(
                                        child: _buildItems(index)))
                                : _buildItems(index);
                          }
                        },
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: _workMsg.length + 1,
                        dragStartBehavior: DragStartBehavior.down,
                        physics: BouncingScrollPhysics(),
                      ),
                    ),
                    //未读按钮
                    ChatCommonWidget.unreadBtn(
                        context, _isShowGoTop, _unreadNum, _onTapUnreadBtn)
                  ],
                ),
              ),
              _isSelect
                  ? InkWell(
                      onTap: () {
                        _deleteMuchMsg();
                      },
                      child: Container(
                        width: winWidth(context),
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ImageView(img: 'assets/images/ic_delete.png'),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              S.of(context).deleteMsg,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.textF12T1,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
      ),
    );
  }
}
