import 'package:flutter/material.dart';

import 'image_view.dart';

// Row的做法
class ListRowView extends StatelessWidget {
  final String icon; // 左侧图标路径
  final Widget iconWidget; // 左侧图标Widget对象(优先)
  final double iconSize; // 图标大小
  final double iconRt; // 图标与标题的距离
  final String title; // 标题
  final Widget titleWidget; // 标题(优先)
  final String label; // 标记内容
  final Widget labelWidget; // 标记内容(优先)
  final bool haveBorder; // 是否有下划线
  final String msgRt1; // 右侧上面文字提示
  final String msgRt2; // 右侧下面文字提示
  final Widget widgetRt1; // 右侧上面提示Widget(优先)
  final Widget widgetRt2; // 右侧下面提示Widget(优先)
  final bool msgUp; // 右侧提示只有一条时控制是否显示在上面(true.上面 false.下面)
  final VoidCallback onPressed; // 点击回调
  final double paddingLeft; // 左边距(默认:15.0)
  final double paddingRight; // 右边距(默认:15.0)
  final double paddingTop; // 上边距(默认:5.0)
  final double paddingBottom; // 下边距(默认:5.0)
  final double minHeight;
  final EdgeInsetsGeometry margin; // 外距
  final double titleSize; // 标题大小
  final double labelSize; // 副标题大小
  final double trailSize; // 右侧文字大小
  final Color color; //背景颜色
  final CrossAxisAlignment crossAxisAlignment;

  const ListRowView(
      {Key key,
      this.icon,
      this.iconWidget,
      this.iconSize = 25.0,
      this.iconRt = 20.0,
      this.title,
      this.titleWidget,
      this.label,
      this.labelWidget,
      this.haveBorder = false,
      this.msgRt1,
      this.msgRt2,
      this.widgetRt1,
      this.widgetRt2,
      this.msgUp,
      this.onPressed,
      this.paddingLeft = 15.0,
      this.paddingRight = 15.0,
      this.paddingTop = 5.0,
      this.paddingBottom = 5.0,
      this.minHeight,
      this.margin,
      this.titleSize = 16.0,
      this.labelSize = 12.0,
      this.trailSize = 12.0,
      this.color,
      this.crossAxisAlignment = CrossAxisAlignment.center})
      : super(key: key);

  Widget _buildRow(BuildContext context) {
    List<Widget> items = [];
    if (iconWidget != null) {
      items.add(iconWidget);
      items.add(SizedBox(
        width: iconRt,
      ));
    } else if (icon != null) {
      items.add(ImageView(
        img: icon,
        width: iconSize,
        height: iconSize,
      ));
      items.add(SizedBox(
        width: iconRt,
      ));
    }

    List<Widget> content = [
      titleWidget ??
          Text(
            title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: titleSize),
          )
    ];
    if (labelWidget != null) {
      content.add(labelWidget);
    } else if (label != null) {
      content.add(Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: labelSize,
          color: Color(0xFFBCBCBC),
        ),
      ));
    }

    items.add(Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: content.length > 0
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: content,
      ),
    ));

    Widget trail = _getTrail();
    if (trail != null) {
      items.add(SizedBox(width: 10.0));
      items.add(trail);
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: items,
    );
  }

  Widget _getTrail() {
    TextStyle fontStyle = TextStyle(
        fontSize: trailSize, fontWeight: FontWeight.w400, color: Colors.grey);

    List<Widget> trails = [];

    if (widgetRt1 != null) {
      trails.add(widgetRt1);
    } else if (msgRt1 != null) {
      trails.add(Text(msgRt1, style: fontStyle));
    }

    if (widgetRt2 != null) {
      trails.add(widgetRt2);
    } else if (msgRt2 != null) {
      trails.add(Text(msgRt2, style: fontStyle));
    }

    if (trails.length == 0) return null;

    MainAxisAlignment alignment = MainAxisAlignment.spaceBetween;
    if (trails.length < 2) {
      if (msgUp == null) {
        alignment = MainAxisAlignment.center;
      } else if (msgUp) {
        alignment = MainAxisAlignment.start;
      } else {
        alignment = MainAxisAlignment.end;
      }
    }

    return Container(
      child: Column(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        constraints:
            minHeight != null ? BoxConstraints(minHeight: minHeight) : null,
        padding: EdgeInsets.only(
          left: paddingLeft,
          right: paddingRight,
          top: paddingTop,
          bottom: paddingBottom,
        ),
        margin: margin,
        decoration: BoxDecoration(
          color: color,
          border: (haveBorder
              ? Border(
                  bottom: BorderSide(width: 0.3, color: Color(0xFFBCBCBC)),
                )
              : null),
        ),
        child: _buildRow(context),
      ),
      onTap: onPressed ?? () {},
    );
  }
}
