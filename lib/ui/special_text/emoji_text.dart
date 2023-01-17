import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

import 'emoji_util.dart';

class EmojiText extends SpecialText {
  static const String flag = '[';
  final int start;
  EmojiText(TextStyle textStyle, {this.start})
      : super(EmojiText.flag, ']', textStyle);

  @override
  InlineSpan finishText() {
    var key = toString();
    for (Emoji emoji in EmojiUitl.instance.emojis.values) {
      if (emoji.text == key) {
        final double size = 20.0;

        return ImageSpan(AssetImage(emoji.path),
            actualText: key,
            imageWidth: size,
            imageHeight: size,
            start: start,
            fit: BoxFit.fill,
            margin: EdgeInsets.only(left: 2.0, right: 2.0));
      }
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}
