import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/team_model/search_team_info.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_method.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_info_page.dart';
import 'package:cobiz_client/pages/team/team_page/apply_join.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/menu/magic_pop.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:cobiz_client/http/team.dart' as teamApi;

class SingleChatMsgCell extends StatefulWidget {
  final ChatStore chatStore;
  final bool isShowRadio;
  final AudioPlayer audioPlayer;
  final Map<String, String> tempData;
  final List<dynamic> imgList;
  final Function(dynamic) valueCall;
  SingleChatMsgCell(this.chatStore, this.isShowRadio, this.audioPlayer,
      this.tempData, this.imgList,
      {Key key, this.valueCall})
      : super(key: key);

  @override
  _SingleChatMsgCellState createState() => _SingleChatMsgCellState();
}

class _SingleChatMsgCellState extends State<SingleChatMsgCell> {
  bool checkd = false;
  //是否发送成功
  Widget _isSendOk(ChatStore chatStore) {
    if (chatStore.state == -1) {
      return buildProgressIndicator(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), size: 18);
    } else if (chatStore.state == 0) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: InkWell(
          onTap: () {
            _resend(chatStore);
          },
          child: ImageView(img: 'assets/images/mine/warn.png'),
        ),
      );
    } else {
      return Container();
    }
  }

  // 重发
  Future<void> _resend(ChatStore chat) async {
    if (chat.state != 0) return;
    if (mounted) {
      setState(() {
        chat.state = -1;
      });
    }
    Map result = await chatApi.sendMsg(WsRequest.upMsg(chat));
    chat.state = (result != null && result['code'] == null) ? 1 : 0;
    if (result != null) {
      chat.time = DateTime.now().millisecondsSinceEpoch;
    }
    if (mounted) {
      setState(() {});
    }
    if (chat.state > 0) await localStorage.updateLocalChat(chat, chat.receiver);
  }

  //长按菜单
  Widget _magicPop(Widget child, bool isSelf, ChatStore chatStore) {
    List<MagicPopAction> actions = [
      MagicPopAction(S.of(context).delete, 3),
      MagicPopAction(S.of(context).checkbox, 4),
    ];
    if (chatStore.mtype != 2) {
      actions.insert(
        0,
        MagicPopAction(S.of(context).forward, 2),
      );
    }

    if (chatStore.mtype == 1) {
      actions.insert(0, MagicPopAction(S.of(context).copy, 1));
    }

    //图片和文本引用
    if (chatStore.mtype == 1 || chatStore.mtype == 3) {
      actions.add(MagicPopAction(S.of(context).quote, 5));
    }

    return MagicPop(
      onValueChanged: (value) async {
        switch (value.value) {
          case 1:
            String msg = '';
            if (strIsJson(chatStore.msg)) {
              msg = jsonDecode(chatStore.msg)['text'];
            } else {
              msg = chatStore.msg;
            }
            Clipboard.setData(ClipboardData(text: msg));
            showToast(context, S.of(context).copySuccess);
            break;
          case 2:
            widget.valueCall({'type': 'forward', 'data': chatStore});
            break;
          case 3:
            widget.valueCall({'type': 'delete', 'data': chatStore});
            break;
          case 4:
            eventBus.emit('open_multiple_choice');
            break;
          case 5:
            widget.valueCall({'type': 'quote', 'data': chatStore});
            break;
          default:
        }
      },
      actions: actions,
      child: child,
      isSelf: isSelf,
      pageMaxChildCount: 3,
      menuHeight: 32,
    );
  }

  Widget _msgDisplay(ChatStore chatStore) {
    int msgType = chatStore.mtype; //消息类型
    bool isMe = chatStore.sender == API.userInfo.id; //是否自己发的
    Widget content; //消息体
    Widget child;
    switch (msgType) {
      case 1: //文本
        child = _magicPop(
            ChatMsgShow.textMsg(context, isMe, chatStore, widget.isShowRadio),
            isMe,
            chatStore);
        break;
      case 2: //语音
        child = _magicPop(
            ChatMsgShow.voiceMsg(context, isMe, chatStore, widget.audioPlayer,
                widget.isShowRadio),
            isMe,
            chatStore);
        break;
      case 3: //图片
        child = _magicPop(
          ChatMsgShow.imgMsg(context, isMe, chatStore,
              widget.tempData[chatStore.id], widget.imgList, call: (v) {
            if (v != null) {
              widget.valueCall({'type': 'forwardInImgDetail', 'data': v});
            }
          }),
          isMe,
          chatStore,
        );
        break;
      case 4: //视频
        child = _magicPop(
            ChatMsgShow.videoMsg(context, isMe, chatStore), isMe, chatStore);
        break;
      case 5: //名片
        child = _magicPop(
            InkWell(
              onTap: () {
                ChatCommonMethod.stopAudioPlayer(widget.audioPlayer);
                routeMaterialPush(SingleInfoPage(
                  userId: jsonDecode(chatStore.msg)['userId'],
                  whereToInfo: 3,
                ));
              },
              child: ChatMsgShow.peopleCardMsg(context, isMe, chatStore),
            ),
            isMe,
            chatStore);
        break;
      case 106:
        child = ChatMsgShow.blockW(chatStore);
        break;
      case 108:
        child = InkWell(
          onTap: () async {
            ChatCommonMethod.stopAudioPlayer(widget.audioPlayer);
            var msg = jsonDecode(chatStore.msg);
            String code = '#CB#${msg['teamCode']}';
            List<SearchTeamInfo> _teamItems = await teamApi.searchTeam(code);
            if (_teamItems != null && _teamItems.isNotEmpty) {
              routePush(ApplyJoinTeamPage(
                  type: 1, team: _teamItems[0], deptId: msg['deptId']));
            } else {
              showToast(context, S.of(context).teamNotExist);
            }
          },
          child: ChatMsgShow.inviteJoinTeam(context, isMe, chatStore),
        );
        break;
      case 201:
        child = ChatMsgShow.addFriend(context, chatStore);
        break;
      default:
        child = ChatMsgShow.notSupport(
            context, isMe, chatStore, widget.isShowRadio);
    }
    if (chatStore.mtype == 106 || chatStore.mtype == 201) {
      return child;
    }
    content = Container(
      padding: EdgeInsets.only(bottom: 10),
      child: isMe
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_isSendOk(chatStore), child],
                ),
                ChatMsgShow.quoteTextMsg(chatStore, context)
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [child, ChatMsgShow.quoteTextMsg(chatStore, context)],
            ),
    );
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [content],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isShowRadio == false) {
      checkd = false;
    }
    return widget.isShowRadio
        ? RadioLineView(
            paddingLeft: NavigationToolbar.kMiddleSpacing - 7,
            checkCallback: () {
              if (GlobalModel.getInstance().total > 99 && !checkd) {
                showToast(context, S.of(context).max100selected);
                return;
              }
              setState(() {
                checkd = !checkd;
              });
              eventBus.emit('open_multiple_choice',
                  {'isSelect': checkd, 'msg': widget.chatStore});
            },
            checked: checkd,
            content: IgnorePointer(child: _msgDisplay(widget.chatStore)))
        : _msgDisplay(widget.chatStore);
  }
}
