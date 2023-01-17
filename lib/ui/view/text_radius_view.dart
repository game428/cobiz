import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class TextRadiusView extends StatelessWidget {
  final String text;
  final AlignmentGeometry align;
  final Color bgColor;
  final Color fontColor;
  final double width;
  final double height;
  final double minWidth;
  final double minHeight;
  final double fontSize;
  final double horizontal;
  final double vertical;
  final EdgeInsetsGeometry margin;

  const TextRadiusView(
      {Key key,
      this.text,
      this.align,
      this.bgColor,
      this.fontColor,
      this.width,
      this.height,
      this.minWidth,
      this.minHeight,
      this.fontSize,
      this.horizontal,
      this.vertical,
      this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: align ?? Alignment.center,
      constraints: BoxConstraints(
        minWidth: minWidth ?? 60.0,
        minHeight: minHeight ?? 20.0,
      ),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: bgColor ?? radiusBgColor,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ?? 8.0,
        vertical: vertical ?? 1.0,
      ),
      margin: margin,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? FontSizes.font_s12,
          color: fontColor ?? themeColor,
        ),
      ),
    );
  }
}
