import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:flutter/material.dart';

class ChannelListCell extends StatefulWidget {
  final ChannelStore channelStore;
  final bool border;
  ChannelListCell({@required this.channelStore, this.border = true});

  @override
  _ChannelListCellState createState() => _ChannelListCellState();
}

class _ChannelListCellState extends State<ChannelListCell> {
  @override
  void initState() {
    super.initState();
  }

  Widget timeView(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time ?? 0);

    return new SizedBox(
      width: 60.0,
      child: new Text(
        DateUtil.formatTimeForRead(dateTime),
        maxLines: 1,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.0, color: ThemeModel.defaultTextColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String name = '';
    if (widget.channelStore.type == 3) {
      name = '${S.of(context).workNotice}:' + widget.channelStore.name;
    } else if (widget.channelStore.type == 2) {
      name = widget.channelStore.name;
    } else if (widget.channelStore.type == 1) {
      if (widget.channelStore.id == 10) {
        name = S.of(context).kf;
      } else {
        name = widget.channelStore.name;
      }
    }
    return ListItemView(
      color: widget.channelStore.top == 1 ? Colors.grey[100] : Colors.white,
      iconWidget: ChatMsgShow.channelAvatar(widget.channelStore),
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              child: Text(
            name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          )),
          ChatMsgShow.groupWidget(widget.channelStore)
        ],
      ),
      labelWidget: ChatMsgShow.labelWidget(context, widget.channelStore),
      widgetRt1: timeView(widget.channelStore.lastAt),
      widgetRt2: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildReadUnread(widget.channelStore.readUnread),
          widget.channelStore.unread > 0
              ? Container(
                  height: 18,
                  width: widget.channelStore.unread > 99 ? 25 : 18,
                  decoration: new BoxDecoration(
                    // 边色与边宽度
                    color: Colors.red,
                    borderRadius: new BorderRadius.circular(9), // 圆角大小
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.channelStore.unread > 99 ? '99+' : widget.channelStore.unread}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    textScaleFactor: 1.0,
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ))
              : SizedBox(
                  height: 18,
                )
        ],
      ),
      haveBorder: widget.border,
    );
  }
}
