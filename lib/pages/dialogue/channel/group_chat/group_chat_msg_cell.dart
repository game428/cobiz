import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_method.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_info_page.dart';
import 'package:cobiz_client/pages/team/member/team_member_info.dart';
import 'package:cobiz_client/pages/work/notice/notice_detail.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/menu/magic_pop.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;

class GroupChatMsgCell extends StatefulWidget {
  final ChatStore chatStore;
  final bool isShowRadio;
  final AudioPlayer audioPlayer;
  final Map<String, String> tempData;
  final List<dynamic> imgList;
  final Function(dynamic) valueCall;
  final int gType;
  final int teamId;
  GroupChatMsgCell(this.chatStore, this.isShowRadio, this.audioPlayer,
      this.tempData, this.imgList, this.gType, this.teamId,
      {Key key, this.valueCall})
      : super(key: key);

  @override
  _GroupChatMsgCellState createState() => _GroupChatMsgCellState();
}

class _GroupChatMsgCellState extends State<GroupChatMsgCell> {
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
            Clipboard.setData(
                ClipboardData(text: jsonDecode(chatStore.msg)['text']));
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

  Widget _msgDisplay(ChatStore groupChatStore) {
    int msgType = groupChatStore.mtype; //消息类型
    bool isMe = groupChatStore.sender == API.userInfo.id; //是否自己发的
    Widget content; //消息体
    Widget child;
    switch (msgType) {
      case 1:
        child = _magicPop(
            ChatMsgShow.textMsg(
                context, isMe, groupChatStore, widget.isShowRadio),
            isMe,
            groupChatStore);
        break;
      case 2:
        child = _magicPop(
            ChatMsgShow.voiceMsg(context, isMe, groupChatStore,
                widget.audioPlayer, widget.isShowRadio),
            isMe,
            groupChatStore);
        break;
      case 3:
        child = _magicPop(
            ChatMsgShow.imgMsg(
              context,
              isMe,
              groupChatStore,
              widget.tempData[groupChatStore.id],
              widget.imgList,
              call: (v) {
                if (v != null) {
                  widget.valueCall({'type': 'forwardInImgDetail', 'data': v});
                }
              },
            ),
            isMe,
            groupChatStore);
        break;
      case 4:
        child = _magicPop(ChatMsgShow.videoMsg(context, isMe, groupChatStore),
            isMe, groupChatStore);
        break;
      case 5: //名片
        child = _magicPop(
            InkWell(
              onTap: () {
                ChatCommonMethod.stopAudioPlayer(widget.audioPlayer);
                routeMaterialPush(SingleInfoPage(
                  userId: jsonDecode(groupChatStore.msg)['userId'],
                  whereToInfo: 3,
                ));
              },
              child: ChatMsgShow.peopleCardMsg(context, isMe, groupChatStore),
            ),
            isMe,
            groupChatStore);
        break;
      case 8: // 公告
        child = InkWell(
          onTap: () {
            ChatCommonMethod.stopAudioPlayer(widget.audioPlayer);
            routeMaterialPush(NoticeDetailPage(
              id: jsonDecode(groupChatStore.msg)['nid'],
              teamId: jsonDecode(groupChatStore.msg)['teamId'],
            ));
          },
          child: ChatMsgShow.noticeMsg(groupChatStore),
        );
        return child;
      case 101:
        child = ChatMsgShow.addGroup(context, groupChatStore);
        return child;
      case 102:
        child = ChatMsgShow.leaveGroup(context, groupChatStore);
        return child;
      case 105:
        child = ChatMsgShow.groupNotice(context, groupChatStore);
        return child;
      default:
        child = ChatMsgShow.notSupport(
            context, isMe, groupChatStore, widget.isShowRadio);
    }
    content = Container(
      padding: EdgeInsets.only(bottom: 10, left: 5),
      child: isMe
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_isSendOk(groupChatStore), child],
                ),
                ChatMsgShow.quoteTextMsg(groupChatStore, context)
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(6, 0, 6, 2),
                  constraints:
                      BoxConstraints(maxWidth: winWidth(context) * 0.5),
                  child: Text(
                    '${groupChatStore.name ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10, color: Color.fromRGBO(163, 163, 163, 1)),
                  ),
                ),
                child,
                ChatMsgShow.quoteTextMsg(groupChatStore, context)
              ],
            ),
    );
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMe
            ? Container()
            : InkWell(
                onTap: () {
                  ChatCommonMethod.stopAudioPlayer(widget.audioPlayer);
                  if (widget.gType == 0 || widget.teamId == 0) {
                    routePush(SingleInfoPage(
                      userId: groupChatStore.sender,
                      whereToInfo: 3,
                    ));
                  } else {
                    routePush(TeamMemberInfo(
                        teamId: widget.teamId,
                        userId: groupChatStore.sender,
                        fromWhere: 2));
                  }
                },
                child: ImageView(
                  img: cuttingAvatar(groupChatStore.avatar),
                  width: 42.0,
                  height: 42.0,
                  needLoad: true,
                  isRadius: 21.0,
                  fit: BoxFit.cover,
                ),
              ),
        content
      ],
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
