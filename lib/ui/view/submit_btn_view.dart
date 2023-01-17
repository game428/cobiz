import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class SubmitBtnView extends StatelessWidget {
  final String text;
  final bool haveValue;
  final Color textColor;
  final Color bgColor;
  final bool haveBorder;
  final double fontSize;
  final double top;
  final double bottom;
  final double right;
  final EdgeInsets padding;
  final VoidCallback onPressed;
  final Widget leftWidget;
  final VoidCallback leftPressed;

  const SubmitBtnView({
    Key key,
    this.text,
    this.haveValue = false,
    this.textColor,
    this.bgColor,
    this.haveBorder = false,
    this.top,
    this.bottom,
    this.right,
    this.fontSize,
    this.padding,
    this.onPressed,
    this.leftWidget,
    this.leftPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      text,
      style: TextStyle(
        color: (textColor != null
            ? textColor
            : (haveValue ? Colors.white : Colors.black)),
        fontSize: fontSize ?? FontSizes.font_s15,
      ),
    );
    Widget rightBtn;
    if (haveBorder) {
      rightBtn = OutlineButton(
        shape: StadiumBorder(),
        padding: padding,
        highlightedBorderColor: greyEAColor,
        child: textWidget,
//        splashColor: Colors.cyanAccent,
        onPressed: onPressed ?? () {},
      );
    } else {
      rightBtn = FlatButton(
        shape: StadiumBorder(),
        padding: padding,
        child: textWidget,
        color: bgColor ?? (haveValue ? themeColor : radiusBgColor),
//        splashColor: Colors.cyanAccent,
        onPressed: onPressed ?? () {},
      );
    }
    Widget content;
    if (leftWidget != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          leftWidget,
          rightBtn,
        ],
      );
    }
    return Container(
      alignment: Alignment.centerRight,
      margin: EdgeInsets.only(
        top: top ?? 10.0,
        bottom: bottom ?? 0.0,
        right: right ?? 0.0,
      ),
      child: leftWidget != null ? content : rightBtn,
    );
  }
}
