import 'package:cobiz_client/config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/check.dart';
import 'package:cobiz_client/ui/view/image_view.dart';

import 'list_item_view.dart';

class OperateLineView extends StatelessWidget {
  final String icon;
  final double iconLeft;
  final String title;
  final bool dense;
  final Widget rightWidget;
  final double spaceSize;
  final bool haveBorder;
  final Color color;
  final VoidCallback onPressed;
  final bool bottomMargin;
  final bool isArrow;

  const OperateLineView(
      {Key key,
      this.icon,
      this.iconLeft = 2.0,
      this.title,
      this.dense,
      this.rightWidget,
      this.spaceSize = 15.0,
      this.haveBorder = true,
      this.color = Colors.white,
      this.bottomMargin = false,
      this.isArrow = true,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: bottomMargin ? EdgeInsets.only(bottom: 7) : null,
      child: ListItemView(
        iconWidget: strNoEmpty(icon)
            ? Container(
                padding: EdgeInsets.only(left: iconLeft),
                child: ImageView(
                  img: icon,
                  width: 25.0,
                ),
              )
            : null,
        title: title,
        dense: dense,
        color: color,
        titleWidget: (rightWidget != null
            ? Row(
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.textF16,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[rightWidget],
                    ),
                  ),
                ],
              )
            : null),
        widgetRt1: isArrow
            ? Container(
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12.0,
                ),
                margin: EdgeInsets.only(
                  right: 5.0,
                ),
              )
            : null,
        paddingLeft: spaceSize,
        paddingRight: spaceSize,
        haveBorder: haveBorder,
        onPressed: onPressed ?? () {},
      ),
    );
  }
}
