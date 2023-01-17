import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HttpText extends SpecialText {
  static const String flag = 'http';
  final int start;
  final bool httpBg;

  HttpText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.showAtBackground = false, this.start, this.httpBg = false})
      : super(flag, ' ', textStyle, onTap: onTap);

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    final TextStyle textStyle = this.textStyle?.copyWith(
          fontSize: 16.0,
          // decoration: TextDecoration.underline,
          color: this.httpBg == false ? Color(0xFF566f7c) : Color(0xFF29405d),
          // color: Color(0xFF566f7c),
          // color: Color(0xFF0c3466),
        );

    final String httpText = toString();

    return showAtBackground
        ? BackgroundTextSpan(
            background: Paint()..color = Colors.blue.withOpacity(0.15),
            text: httpText,
            actualText: httpText,
            start: start,

            ///caret can move into special text
            deleteAll: true,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) {
                  onTap(httpText);
                }
              }))
        : SpecialTextSpan(
            text: httpText,
            actualText: httpText,
            start: start,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) {
                  onTap(httpText);
                }
              }));
  }
}
