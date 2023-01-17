import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_msg_show.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/special_text/my_special_text_builder.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WhiteTextDetailPage extends StatelessWidget {
  final String comment;
  const WhiteTextDetailPage(this.comment, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //检测加不加空格
    String msg = httpAddSpace(comment);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 15, vertical: ScreenData.topSafeHeight),
          child: Center(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ExtendedText(
              msg ?? '',
              selectionEnabled: true,
              specialTextSpanBuilder: MySpecialTextSpanBuilder(),
              onSpecialTextTap: (v) async {
                ChatMsgShow.httpLis(v, null, 2);
              },
            ),
          )),
        ),
      ),
    );
  }
}
