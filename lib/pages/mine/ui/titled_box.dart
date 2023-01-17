import 'package:flutter/material.dart';

class TitledBox extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  TitledBox(
      {this.title,
      this.titleColor = Colors.black,
      this.backgroundColor = Colors.white,
      this.children,
      this.margin,
      this.padding});

  @override
  Widget build(BuildContext context) {
    List<Widget> chs = [];
    if (title != null) {
      chs.add(Padding(
        padding: EdgeInsets.only(left: 20, top: 10, bottom: 5, right: 10),
        child: Text(
          title,
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 18, color: titleColor, fontWeight: FontWeight.w700),
        ),
      ));
    }
    chs.addAll(children);

    return Container(
      color: backgroundColor,
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chs,
      ),
    );
  }
}
