import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cobiz_client/tools/cobiz.dart';

// ignore: must_be_immutable
class ImageView extends StatelessWidget {
  final String img;
  final double width;
  final double height;
  final BoxFit fit;
  final double isRadius;
  final bool needLoad;
  final String tempImg;
  Map<String, String> headers;
  final int defType;

  ImageView({
    @required this.img,
    this.height,
    this.width,
    this.fit,
    this.isRadius = 4.0,
    this.needLoad = false,
    this.tempImg,
    this.headers,
    this.defType = 1,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    String defIcon;
    switch (defType) {
      case 1: // 默认头像
        defIcon = 'assets/images/def_avatar.png';
        break;
      case 2: // 默认笔记缩略图
        defIcon = 'assets/images/note_img_def.png';
        break;
      case 3: // 默认聊天缩略图
        defIcon = 'assets/images/chat_img_def.png';
        break;
    }
    if (isNetWorkImg(img)) {
      if (isWeb()) {
        image = new Image.network(img,
            width: width,
            height: height,
            headers: headers,
            fit: width != null && height != null ? BoxFit.fill : fit);
      } else {
        image = new CachedNetworkImage(
          ///增加key 避免图片加载失败时 不更新图像
          key: ValueKey<String>(img),
          errorWidget: (context, value, val) {
            return ImageView(
              img: defIcon,
              width: width,
              height: height,
              fit: fit,
            );
          },
          imageUrl: img,
          width: width,
          height: height,
          fit: fit,
          httpHeaders: headers,
          cacheManager: cacheManager,
          placeholder: needLoad
              ? (context, url) => tempImg == null
                  ? Container(
                      width: width,
                      height: height,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  : ImageView(
                      img: tempImg,
                      width: width,
                      height: height,
                      fit: fit,
                    )
              : null,
        );
      }
    } else if (isAssetsImg(img)) {
      image = new Image.asset(
        img,
        width: width,
        height: height,
        fit: width != null && height != null ? BoxFit.fill : fit,
      );
    } else {
      if (isWeb()) {
        image = new Image.file(
          File(img),
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        if (File(img).existsSync()) {
          image = new Image.file(
            File(img),
            width: width,
            height: height,
            fit: fit,
          );
        }
      }
      if (image == null) {
        image = new Container(
          decoration: BoxDecoration(
              color: Colors.black26.withOpacity(0.1),
              border:
                  Border.all(color: Colors.black.withOpacity(0.2), width: 0.3)),
          child: new Image.asset(
            defIcon,
            width: width - 1,
            height: height - 1,
            fit: width != null && height != null ? BoxFit.fill : fit,
          ),
        );
      }
    }
    return new ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(isRadius),
      ),
      child: image,
    );
  }
}
