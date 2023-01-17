import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatCommonWidget {
  //未读按钮
  static Widget unreadBtn(
      BuildContext context, bool isShow, int unreadNum, Function onTap) {
    return Offstage(
        offstage: !isShow,
        child: Row(
          children: [
            Spacer(),
            InkWell(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                padding: EdgeInsets.fromLTRB(15, 7, 7, 5),
                child: Text(
                  S
                      .of(context)
                      .unreadMsg((unreadNum >= 1000 ? '999+' : '$unreadNum')),
                  style: TextStyle(color: themeColor),
                ),
              ),
            )
          ],
        ));
  }

  //引用展示
  static Widget quoteShow(bool isShow, String quoteText, Function onTap,
      {Color bgColor = Colors.white}) {
    return Offstage(
      offstage: !isShow,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: Row(children: [
          Expanded(
              child: Text(
            quoteText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Color.fromRGBO(123, 123, 123, 1), fontSize: 14),
          )),
          InkWell(
              child: ImageView(img: 'assets/images/ic_delete.webp'),
              onTap: onTap)
        ]),
      ),
    );
  }
}
