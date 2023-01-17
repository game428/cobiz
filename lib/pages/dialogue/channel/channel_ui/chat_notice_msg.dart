import 'dart:convert';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatNotice extends StatelessWidget {
  final ChatStore _chatStore;
  const ChatNotice(this._chatStore, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShadowCardView(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.fromLTRB(6, 0, 6, 15),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 30.0,
          minWidth: 40.0,
        ),
        padding: EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                ImageView(
                  img: 'assets/images/chat/ic_speaker.png',
                  height: 20,
                  width: 20,
                ),
                Flexible(
                    child: Text(
                  ' ' + S.of(context).teamNotice(_chatStore.name ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    '${DateUtil.formatSeconds(_chatStore.time, format: 'yyyy-MM-dd HH:mm')}',
                    style: TextStyle(fontSize: 12, color: greyA3Color),
                    textAlign: TextAlign.end,
                  ),
                )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                jsonDecode(_chatStore.msg)['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.textF14T4,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
