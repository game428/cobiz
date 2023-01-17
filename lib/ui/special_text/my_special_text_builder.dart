import 'package:cobiz_client/ui/special_text/emoji_text.dart';
import 'package:cobiz_client/ui/special_text/http_text.dart';
import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder({this.showAtBackground = false, this.httpBg = false});

  /// whether show background for @somebody
  final bool showAtBackground;
  final bool httpBg;

  @override
  TextSpan build(String data,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap}) {
    if (kIsWeb) {
      return TextSpan(text: data, style: textStyle);
    }

    return super.build(data, textStyle: textStyle, onTap: onTap);
  }

  @override
  SpecialText createSpecialText(String flag,
      {TextStyle textStyle, SpecialTextGestureTapCallback onTap, int index}) {
    if (flag == null || flag == '') {
      return null;
    }

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle, start: index - (EmojiText.flag.length - 1));
    } else if (isStart(flag, HttpText.flag)) {
      return HttpText(
        textStyle,
        onTap,
        httpBg: httpBg,
        start: index - (HttpText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    }
    // if (isStart(flag, ImageText.flag)) {
    //   return ImageText(textStyle,
    //       start: index - (ImageText.flag.length - 1), onTap: onTap);
    // } else if (isStart(flag, VideoText.flag)) {
    //   return VideoText(textStyle,
    //       start: index - (VideoText.flag.length - 1), onTap: onTap);
    // } else if (isStart(flag, AtText.flag)) {
    //   return AtText(
    //     textStyle,
    //     onTap,
    //     start: index - (AtText.flag.length - 1),
    //     showAtBackground: showAtBackground,
    //   );
    // } else if (isStart(flag, EmojiText.flag)) {
    //   return EmojiText(textStyle, start: index - (EmojiText.flag.length - 1));
    // }
    return null;
  }
}
