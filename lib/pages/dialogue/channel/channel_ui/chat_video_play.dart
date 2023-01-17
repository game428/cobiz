import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';

class ChatVideoPlay extends StatefulWidget {
  final String path;
  const ChatVideoPlay({Key key, this.path}) : super(key: key);
  @override
  ChatVideoPlayState createState() => ChatVideoPlayState();
}

class ChatVideoPlayState extends State<ChatVideoPlay> {
  CachedVideoPlayerController _controller;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.path.startsWith('http://') ||
        widget.path.startsWith('https://')) {
      _controller = CachedVideoPlayerController.network(widget.path);
    } else {
      File videoItem = File(widget.path);
      _controller = CachedVideoPlayerController.file(videoItem);
    }
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          isLoading = true;
          _controller.play();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          // color: grey81Color,
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: isLoading == true
                      ? Alignment.bottomCenter
                      : Alignment.center,
                  children: <Widget>[
                    CachedVideoPlayer(_controller),
                    isLoading
                        ? VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: AppColors.mainColor,
                              bufferedColor: greyDFColor,
                              backgroundColor: greyDFColor,
                            ),
                          )
                        : buildProgressIndicator(),
                  ],
                ),
              ),
              !isLoading || _controller.value.isPlaying
                  ? Container()
                  : Container(
                      color: Colors.black26,
                      child: Center(
                        child: ImageView(
                          height: 100,
                          width: 100,
                          img: 'assets/images/chat/play.png',
                        ),
                      ),
                    ),
              _controller.value.isPlaying
                  ? Container()
                  : Positioned(
                      bottom: 20.0,
                      left: 20.0,
                      child: InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: greyF6Color,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          width: 30,
                          height: 30,
                          child: Icon(Icons.close),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
            ],
          ),
        ),
        onTap: () {
          if (_controller.value != null && _controller.value.initialized) {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();

            if (mounted) {
              setState(() {});
            }
          }
        },
      ),
    );
  }
}
