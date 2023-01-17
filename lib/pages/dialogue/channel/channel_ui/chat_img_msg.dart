import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/forward_page.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

class ChatImgMsg extends StatefulWidget {
  final bool isSelf;
  final ChatStore chatStore;
  final List<ChatStore> imgList;
  final String tempImg;
  final Function(dynamic) callValue;

  const ChatImgMsg(
      {Key key,
      this.isSelf,
      this.chatStore,
      this.imgList,
      this.tempImg,
      this.callValue})
      : super(key: key);

  @override
  _ChatImgMsgState createState() => _ChatImgMsgState();
}

class _ChatImgMsgState extends State<ChatImgMsg> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex;
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          color: greyF7Color,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          child: Container(
            constraints: BoxConstraints(maxHeight: 160.0, minHeight: 80),
            child: ImageView(
              img: chatThumbnail(widget.chatStore.msg),
              width: 120,
              defType: 3,
              fit: BoxFit.cover,
              needLoad: true,
              tempImg: widget.tempImg,
            ),
          ),
        ),
      ),
      onTap: () async {
        currentIndex =
            widget.imgList.indexWhere((img) => img.id == widget.chatStore.id);
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ExtendedImageGesturePageView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: widget.imgList.length,
                    onPageChanged: (int index) {
                      currentIndex = index;
                      // rebuild.add(index);
                    },
                    controller: PageController(
                      initialPage: currentIndex,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      GlobalKey repaintKey = GlobalKey();
                      Widget image;
                      if (isNetWorkImg(widget.imgList[index].msg)) {
                        image = ExtendedImage.network(
                          widget.imgList[index].msg,
                          width: ScreenData.width,
                          mode: ExtendedImageMode.gesture,
                          initGestureConfigHandler: (state) {
                            return GestureConfig(
                              minScale: 0.9,
                              animationMinScale: 0.7,
                              maxScale: 10.0,
                              animationMaxScale: 10.5,
                              speed: 1.0,
                              inertialSpeed: 100.0,
                              initialScale: 1.0,
                              inPageView: true,
                              initialAlignment: InitialAlignment.center,
                            );
                          },
                        );
                      } else {
                        File fileItem = File(widget.imgList[index].msg);
                        image = ExtendedImage.file(
                          fileItem,
                          width: ScreenData.width,
                          mode: ExtendedImageMode.gesture,
                          initGestureConfigHandler: (state) {
                            return GestureConfig(
                              minScale: 0.9,
                              animationMinScale: 0.7,
                              maxScale: 10.0,
                              animationMaxScale: 10.5,
                              speed: 1.0,
                              inertialSpeed: 100.0,
                              initialScale: 1.0,
                              inPageView: true,
                              initialAlignment: InitialAlignment.center,
                            );
                          },
                        );
                      }

                      image = Scaffold(
                        primary: false,
                        body: InkWell(
                          child: Container(
                            color: Colors.black87,
                            width: ScreenData.width,
                            height: ScreenData.height,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                RepaintBoundary(
                                  key: repaintKey,
                                  child: image,
                                ),
                                Positioned(
                                  bottom: 10.0 + ScreenData.bottomSafeHeight,
                                  right: 10.0,
                                  child: InkWell(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: Container(
                                        alignment: Alignment.center,
                                        color: grey81Color,
                                        padding: EdgeInsets.all(10.0),
                                        child: ImageView(
                                          width: 20.0,
                                          height: 20.0,
                                          img:
                                              'assets/images/chat/img_share.png',
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      ///转发
                                      if (isNetWorkImg(
                                          widget.imgList[index].msg)) {
                                        routeMaterialPush(ForwardPage(
                                                forwardType: 1,
                                                chatStore:
                                                    widget.imgList[index]))
                                            .then((value) {
                                          if (value != null) {
                                            widget.callValue({
                                              'chatStore':
                                                  widget.imgList[index],
                                              'value': value
                                            });
                                            Navigator.pop(context);
                                          }
                                        });
                                      } else {
                                        showToast(context,
                                            S.of(context).tryAgainLater);
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 10.0 + ScreenData.bottomSafeHeight,
                                  right: 60.0,
                                  child: InkWell(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: Container(
                                        alignment: Alignment.center,
                                        color: grey81Color,
                                        padding: EdgeInsets.all(10.0),
                                        child: ImageView(
                                          width: 20.0,
                                          height: 20.0,
                                          img:
                                              'assets/images/chat/img_down.png',
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      saveToLocal(context, repaintKey);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );

                      if (index == currentIndex) {
                        return Hero(
                          tag: widget.imgList[index].msg + index.toString(),
                          child: image,
                        );
                      } else {
                        return image;
                      }
                    })));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
