import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/chat.dart' as chatApi;
import 'package:cobiz_client/http/res/burn_model.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/common/select_contact.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/dialogue/channel/group_chat/group_avatar.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/ws_request.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//转发消息
class ForwardPage extends StatefulWidget {
  final ChatStore chatStore;
  final int forwardType; //1:分享记录
  ForwardPage({Key key, @required this.forwardType, @required this.chatStore})
      : super(key: key);

  @override
  _ForwardPageState createState() => _ForwardPageState();
}

class _ForwardPageState extends State<ForwardPage> {
  ChannelManager _channelManager = ChannelManager.getInstance();
  List<ChannelStore> list = [];

  @override
  void initState() {
    super.initState();
    list.addAll(_channelManager.channels
        .where((element) => element.type != 3)
        .toList());
  }

  ///转发消息弹窗
  _showForwardDialog(ChannelStore channel) {
    showConfirm(context, sureCallBack: () async {
      String id = getOnlyId();
      //查询给接收者设置的焚烧设置
      BurnModel _burnModel = await chatApi.queryUserSetting(channel.id);
      ChatStore chat = ChatStore(id, channel.type, API.userInfo.id, channel.id,
          widget.chatStore.mtype, widget.chatStore.msg,
          state: 1,
          time: DateTime.now().millisecondsSinceEpoch,
          name: API.userInfo.nickname,
          avatar: API.userInfo.avatar,
          burn: _burnModel?.burn ?? 0);

      String msg = '';
      if (strIsJson(chat.msg)) {
        msg = jsonDecode(chat.msg)['text'];
      } else {
        msg = chat.msg;
      }

      // 如果消息类型为文本，接收方为个人，把消息格式转为个人格式
      if (channel.type == 1 && chat.mtype == 1) {
        chat.msg = jsonEncode({'text': msg});
      }
      // 如果消息类型为文本，接收方为群组，把消息格式转为群组格式
      if (channel.type == 2 && chat.mtype == 1) {
        chat.msg = jsonEncode({'text': msg, 'ats': []});
      }

      Map result = await chatApi.sendMsg(WsRequest.upMsg(chat));
      if (result == null)
        return showToast(context, S.of(context).tryAgainLater);
      if (channel.type == 1) {
        _channelManager.addSingleChat(
            channel.id, channel.name, channel.avatar, false, chat);
      } else {
        _channelManager.addGroupChat(
            channel.id,
            channel.name,
            jsonDecode(channel.avatar),
            channel.num,
            channel.gType,
            channel.teamId,
            false,
            chat);
      }
      Navigator.pop(context, channel);
    },
        title: S.of(context).forwardTo,
        cancelBtn: S.of(context).cancelText,
        sureBtn: S.of(context).send,
        contentWidget: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListItemView(
              iconWidget: channel.type == 1
                  ? ClipOval(
                      child: ImageView(
                      img: cuttingAvatar(channel.avatar),
                      width: 42.0,
                      height: 42.0,
                      needLoad: true,
                      fit: BoxFit.cover,
                    ))
                  : GroupAvatar(jsonDecode(channel.avatar), channel.name,
                      jsonDecode(channel.avatar).length, channel.gType),
              title: channel.name,
            ),
            Container(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
                child: ChatMsgShow.buildMsg(context, widget.chatStore))
          ],
        ));
  }

  //选择联系人
  Widget _chooseContact() {
    return ListItemView(
        onPressed: () {
          switch (widget.forwardType) {
            case 1:
              routeMaterialPush(SelctContatPage(
                joinFromWhere: 4,
                data: widget.chatStore,
              ));
              break;
          }
        },
        title: S.of(context).selectContact,
        haveBorder: false,
        color: Colors.white,
        widgetRt1: Container(
          child: Icon(
            Icons.arrow_forward_ios,
            size: 12.0,
          ),
          margin: EdgeInsets.only(
            right: 5.0,
          ),
        ));
  }

  Widget _recentChat() {
    return Container(
      height: 30.0,
      padding: EdgeInsets.only(
        left: 15.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: greyBCColor),
        ),
        color: greyF6Color,
      ),
      child: Text(
        S.of(context).recentChat,
        softWrap: false,
      ),
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [
      buildSearch(context, onPressed: () {
        routeMaterialPush(SearchCommonPage(
          pageType: 5,
          data: list,
        )).then((value) {
          if (value is ChannelStore) {
            switch (widget.forwardType) {
              case 1:
                if (value.type != 3) {
                  _showForwardDialog(value);
                }
                break;
            }
          }
        });
      }),
      _chooseContact(),
      _recentChat()
    ];
    items.add(Expanded(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: list.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              ChannelStore channel = list[index];
              return ListItemView(
                iconWidget: ChatMsgShow.channelAvatar(channel),
                title: channel.name,
                titleWidget: Row(
                  children: [
                    Flexible(
                        child: Text(
                      (channel.type == 3
                              ? '${S.of(context).workNotice}:' + channel.name
                              : channel.name) ??
                          '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    )),
                    ChatMsgShow.groupWidget(channel)
                  ],
                ),
                labelWidget: ChatMsgShow.labelWidget(context, channel),
                onPressed: () {
                  switch (widget.forwardType) {
                    case 1:
                      if (channel.type != 3) {
                        _showForwardDialog(channel);
                      }
                      break;
                  }
                },
              );
            })));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).chooseOntChat,
        rightDMActions: <Widget>[],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: _buildContent(),
        ),
      ),
    );
  }
}
