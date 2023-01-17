import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTileView extends StatelessWidget {
  final VoidCallback onPressed;
  final String title; //标题
  final String label; //标题下方的描述
  final String rightLabel; //标题右边的描述
  final String icon;
  final double width;
  final double horizontal;
  final TextStyle titleStyle;
  final bool isLabel;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BoxFit fit;
  final bool rightArrow;
  final bool isLine;
  final double lineWidth;
  final Color lineColor;
  final Color textColor;

  ListTileView({
    this.onPressed,
    this.title,
    this.label,
    this.rightLabel,
    this.padding = const EdgeInsets.symmetric(vertical: 15.0),
    this.isLabel = true,
    this.icon = 'assets/images/favorite.webp',
    this.titleStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    this.margin,
    this.fit,
    this.width = 45.0,
    this.horizontal = 10.0,
    this.rightArrow = true,
    this.isLine = false,
    this.lineWidth = 0.3,
    this.lineColor = Colors.grey,
    this.textColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    var view = [
      isLabel
          ? new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(title ?? '', style: titleStyle ?? null),
                new Text(
                  label ?? '',
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ],
            )
          : new Text(title, style: titleStyle),
      new Spacer(),
      rightLabel != null
          ? new Text(rightLabel,
              style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontWeight: FontWeight.w400))
          : new Container(),
      new Container(
        width: 7.0,
        margin: EdgeInsets.only(left: 10),
        child: rightArrow
            ? new Icon(CupertinoIcons.right_chevron,
                color: textColor.withOpacity(0.5))
            : new Container(width: 10.0),
      ),
    ];

    var row = new Row(
      children: <Widget>[
        new Container(
          width: width - 5,
          margin: EdgeInsets.symmetric(horizontal: horizontal),
          child: new ImageView(img: icon, width: width, fit: fit),
        ),
        new Container(
          width: winWidth(context) - 60,
          padding: padding,
          decoration: BoxDecoration(
            border: isLine
                ? Border(bottom: BorderSide(color: lineColor, width: lineWidth))
                : null,
          ),
          child: new Row(children: view),
        ),
      ],
    );

    return new Container(
      margin: margin,
      child: new FlatButton(
        color: Colors.white,
        padding: EdgeInsets.all(0),
        onPressed: onPressed ?? () {},
        child: row,
      ),
    );
  }
}
