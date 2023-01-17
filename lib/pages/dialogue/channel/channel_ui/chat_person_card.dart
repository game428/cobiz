import 'dart:convert';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPersonCard extends StatelessWidget {
  final bool isSelf;
  final ChatStore _chatStore;
  const ChatPersonCard(this.isSelf, this._chatStore, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadowCardView(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Container(
        constraints: BoxConstraints(
            minHeight: 30.0, minWidth: 40.0, maxWidth: winWidth(context) * 0.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListItemView(
              paddingLeft: 5,
              paddingRight: 5,
              color: Colors.transparent,
              iconWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ImageView(
                    img: cuttingAvatar(jsonDecode(_chatStore.msg)['avatar']),
                    width: 42.0,
                    height: 42.0,
                    needLoad: true,
                    isRadius: 21.0,
                    fit: BoxFit.cover,
                  )
                ],
              ),
              title: jsonDecode(_chatStore.msg)['userName'] ?? '',
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
              alignment: Alignment.centerLeft,
              child: Text(
                '[${S.of(context).personalCard}]',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
