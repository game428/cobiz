import 'dart:convert';

import 'package:cobiz_client/http/res/team_model/common_model.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/pages/work/ui/img_view_save.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/special_text/my_special_text_builder.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//图片查看保存
Widget imgView(List<String> imgList, String url) {
  return InkWell(
    onTap: () {
      routeMaterialPush(ImgViewSavePage(
        imgList: imgList,
        currentUrl: url,
      ));
    },
    child: buildFilletImage(url,
        margin: EdgeInsets.only(
          right: 10.0,
        ),
        needLoad: true),
  );
}

Widget buildWork(List<dynamic> list, String title) {
  List<Widget> itemList = List();
  list.forEach((item) {
    itemList.add(buildItem(
        item['icon'], item['title'], item['callBack'], item['isMsg'] ?? false));
  });
  return Padding(
    padding: EdgeInsets.only(left: 15.0, right: 15.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.textContactTitle,
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 15.0,
            children: itemList,
          ),
        ),
      ],
    ),
  );
}

Widget buildItem(String image, String text, VoidCallback callback, bool isMsg,
    {Color color = radiusBgColor,
    double textWidth = 20,
    double fontSize = 14,
    double space = 3.0}) {
  double boxSize = 50.0;
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: Column(
      children: <Widget>[
        Container(
          width: boxSize,
          height: boxSize,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(10.0),
            ),
            color: color,
          ),
          child: isMsg
              ? Stack(
                  overflow: Overflow.visible,
                  alignment: AlignmentDirectional.center,
                  children: [
                    ImageView(
                      img: image,
                      width: boxSize,
                    ),
                    Positioned(right: 4.0, top: 4.0, child: buildMessaged())
                  ],
                )
              : ImageView(
                  img: image,
                  width: boxSize,
                ),
        ),
        SizedBox(
          height: space,
        ),
        SizedBox(
          width: boxSize + textWidth,
          child: Text(text,
              // maxLines: 1,
              textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: fontSize)),
        )
      ],
    ),
    onTap: callback,
  );
}

Widget buildTip(String image, String text, VoidCallback callback, bool isMsg) {
  double boxSize = 45.0;
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: Column(
      children: <Widget>[
        isMsg
            ? Stack(
                overflow: Overflow.visible,
                children: [
                  ImageView(
                    img: image,
                    height: boxSize,
                  ),
                  Positioned(right: 0, top: 4.0, child: buildMessaged())
                ],
              )
            : Container(
                width: boxSize,
                height: boxSize,
                child: ImageView(
                  img: image,
                ),
              ),
        SizedBox(
          height: 3.0,
        ),
        SizedBox(
          width: boxSize + 20,
          child: Text(text,
              // maxLines: 1,
              textAlign: TextAlign.center,
              // overflow: TextOverflow.ellipsis,
              style: TextStyles.textF14),
        )
      ],
    ),
    onTap: callback,
  );
}

//评论
Widget buildReply(BuildContext context, List<Comments> comments,
    {Function(Comments comment, Map msg) commentCall}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextTitle(
          S.of(context).comment,
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            children: (comments != null && comments.isNotEmpty)
                ? comments.map((comments) {
                    Map<String, dynamic> msg = Map();
                    try {
                      if (comments.msg.startsWith('{') &&
                          comments.msg.endsWith('}')) {
                        msg = json.decode(comments.msg);
                      } else {
                        msg = {
                          "msg": comments.msg,
                        };
                      }
                    } catch (e) {
                      msg = {
                        "msg": comments.msg,
                      };
                    }

                    //处理http消息
                    msg['msg'] = httpAddSpace(msg['msg']);
                    //
                    if (strNoEmpty(msg['commentName']) &&
                        strNoEmpty(msg['commentMsg'])) {
                      msg['commentMsg'] = httpAddSpace(msg['commentMsg']);
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageView(
                              img: cuttingAvatar(comments.avatar),
                              width: 40,
                              height: 40,
                              needLoad: true,
                              isRadius: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: (BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.4, color: greyCAColor),
                                ),
                              )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comments.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Text(
                                        DateUtil.formatSeconds(comments.time),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  strNoEmpty(msg['commentName'])
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 5.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                    decoration: (BoxDecoration(
                                                      color: greyF6Color,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                    )),
                                                    margin: EdgeInsets.only(
                                                        right: 20.0),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.0,
                                                            vertical: 10.0),
                                                    child: ExtendedText(
                                                      '${msg['commentName']}: ${msg['commentMsg']}',
                                                      selectionEnabled: true,
                                                      specialTextSpanBuilder:
                                                          MySpecialTextSpanBuilder(),
                                                      onSpecialTextTap:
                                                          (v) async {
                                                        ChatMsgShow.httpLis(
                                                            v, null, 2);
                                                      },
                                                    )),
                                              ),
                                              InkWell(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                                  child: Text(
                                                    S.of(context).reply,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyles.textF14T5,
                                                  ),
                                                ),
                                                onTap: () {
                                                  commentCall(comments, msg);
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 5.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ExtendedText(
                                            msg['msg'] ?? '',
                                            selectionEnabled: true,
                                            specialTextSpanBuilder:
                                                MySpecialTextSpanBuilder(),
                                            onSpecialTextTap: (v) async {
                                              ChatMsgShow.httpLis(v, null, 2);
                                            },
                                          ),
                                        ),
                                        strNoEmpty(msg['commentName'])
                                            ? Container()
                                            : InkWell(
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      15, 5, 0, 5),
                                                  child: Text(
                                                    S.of(context).reply,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyles.textF14T5,
                                                  ),
                                                ),
                                                onTap: () {
                                                  commentCall(comments, msg);
                                                },
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                : [],
          ),
        )
      ],
    ),
  );
}

//抄送人
Widget buildCopyTo(BuildContext context, List<CopyTo> copyTo, {String title}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextTitle(
          title ?? S.of(context).notifier,
        ),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: (copyTo != null && copyTo.isNotEmpty)
                ? copyTo.map((copyTo) {
                    return Container(
                      width: 60,
                      child: Column(
                        children: [
                          ImageView(
                              img: cuttingAvatar(copyTo.avatar),
                              width: 40,
                              height: 40,
                              needLoad: true,
                              isRadius: 20),
                          Container(
                            alignment: Alignment.center,
                            height: 20.0,
                            child: Text(
                              copyTo.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            copyTo.state == 1
                                ? S.of(context).haveRead
                                : S.of(context).unread,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                color: copyTo.state == 1
                                    ? AppColors.mainColor
                                    : null),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    );
                  }).toList()
                : [],
          ),
        )
      ],
    ),
  );
}
