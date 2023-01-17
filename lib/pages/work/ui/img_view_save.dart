import 'package:cobiz_client/tools/cobiz.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImgViewSavePage extends StatefulWidget {
  final List<String> imgList;
  final String currentUrl;
  ImgViewSavePage({Key key, @required this.imgList, @required this.currentUrl})
      : super(key: key);

  @override
  _ImgViewSavePageState createState() => _ImgViewSavePageState();
}

class _ImgViewSavePageState extends State<ImgViewSavePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex =
        widget.imgList.indexWhere((element) => element == widget.currentUrl);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImageGesturePageView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: widget.imgList.length,
        onPageChanged: (int index) {
          _currentIndex = index;
        },
        controller: PageController(
          initialPage: _currentIndex,
        ),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          GlobalKey repaintKey = GlobalKey();
          Widget image = Scaffold(
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
                      child: ExtendedImage.network(
                        widget.imgList[index],
                        width: ScreenData.width,
                        mode: ExtendedImageMode.gesture,
                        cache: true,
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
                      ),
                    ),
                    Positioned(
                      bottom: 10.0 + ScreenData.bottomSafeHeight,
                      right: 20.0,
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
                              img: 'assets/images/chat/img_down.png',
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

          if (index == _currentIndex) {
            return Hero(
              tag: widget.imgList[index],
              child: image,
            );
          } else {
            return image;
          }
        });
  }
}
