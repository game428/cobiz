import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_video_play.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

class ChatVideoMsg extends StatefulWidget {
  final ChatStore chatStore;
  const ChatVideoMsg({
    Key key,
    @required this.chatStore,
  }) : super(key: key);

  @override
  _ChatVideoMsgState createState() => _ChatVideoMsgState();
}

class _ChatVideoMsgState extends State<ChatVideoMsg> {
  CachedVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
  }

  Widget videoItem() {
    Widget videoPng;
    if (widget.chatStore.msg.startsWith('http://') ||
        widget.chatStore.msg.startsWith('https://')) {
      videoPng = ImageView(
        width: 120,
        img: '${widget.chatStore.msg}?vframe/png/offset/0/w/120',
        defType: 3,
        needLoad: true,
        fit: BoxFit.cover,
      );
    } else {
      File videoItem = File(widget.chatStore.msg);
      _controller = CachedVideoPlayerController.file(videoItem);
      Future _initializeVideoPlayerFuture = _controller.initialize();
      videoPng = Container(
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CachedVideoPlayer(_controller);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );
    }
    return Container(
      width: 120,
      constraints: BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: Container(
          constraints: BoxConstraints(maxHeight: 160.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              videoPng,
              ImageView(
                height: 50,
                width: 50,
                img: 'assets/images/chat/play.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: videoItem(),
        onTap: () {
          routeMaterialPush(ChatVideoPlay(path: widget.chatStore.msg));
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
