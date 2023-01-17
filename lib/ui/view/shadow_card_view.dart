import 'package:flutter/material.dart';

class ShadowCardView extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blurRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ShadowCardView(
      {Key key,
      this.child,
      this.radius,
      this.blurRadius,
      this.padding,
      this.margin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: blurRadius ?? 5.0,
          )
        ],
      ),
      padding: padding ?? EdgeInsets.all(10.0),
      margin: margin,
      child: child,
    );
  }
}
