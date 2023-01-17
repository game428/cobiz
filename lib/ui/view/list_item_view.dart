import 'package:cobiz_client/config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/provider/theme_model.dart';

import 'image_view.dart';

class ListItemView extends StatelessWidget {
  final String icon; // 左侧图标路径
  final Widget iconWidget; // 左侧图标Widget对象(优先)
  final double iconSize; // 图标大小
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
  final double titleSize; // 标题大小
  final double paddingLeft; // 左边距(默认:15.0)
  final double paddingRight; // 右边距(默认:15.0)
  final double horizontal; // 左右边距(默认:0.0)
  final double vertical; // 上下边距(默认:0.0)
  final bool dense;
  final double labelSize; // 副标题大小
  final double trailSize; // 右侧文字大小
  final Color color; //背景颜色
  final Widget trailing;

  const ListItemView(
      {Key key,
      this.icon,
      this.iconWidget,
      this.iconSize = 42.0,
      this.title,
      this.titleWidget,
      this.label,
      this.labelWidget,
      this.haveBorder = true,
      this.msgRt1,
      this.msgRt2,
      this.widgetRt1,
      this.widgetRt2,
      this.msgUp,
      this.onPressed,
      this.titleSize = 16.0,
      this.paddingLeft = 15.0,
      this.paddingRight = 15.0,
      this.horizontal = 0.0,
      this.vertical = 0.0,
      this.dense,
      this.labelSize = 12.0,
      this.trailSize = 12.0,
      this.color = Colors.white,
      this.trailing})
      : super(key: key);

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
      padding: EdgeInsets.only(top: 3.0, bottom: 4.0),
      child: Column(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trails,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
      child: Container(
        decoration: BoxDecoration(
          border: (haveBorder
              ? Border(
                  bottom: BorderSide(
                    width: 0.4,
                    color: greyDFColor,
                  ),
                )
              : null),
        ),
        child: ListTile(
          dense: dense ?? (labelWidget != null || label != null ? true : false),
          contentPadding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: vertical,
          ),
          leading: (iconWidget != null
              ? iconWidget
              : (icon != null
                  ? Container(
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusDirectional.circular(10.0),
                          side: BorderSide(
                              color: ThemeModel.defaultLineColor, width: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: ImageView(
                          img: icon,
                          width: iconSize,
                          height: iconSize,
                        ),
                      ),
                    )
                  : null)),
          title: (titleWidget != null
              ? titleWidget
              : (Text(
                  title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.black,
                  ),
                ))),
          subtitle: (labelWidget != null
              ? labelWidget
              : (label != null
                  ? Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: labelSize),
                    )
                  : null)),
          trailing: trailing != null ? trailing : _getTrail(),
          onTap: onPressed ?? null,
        ),
      ),
    );
  }
}

class ListItemInfo {
  final int id;
  final String icon;
  final String name;
  final String label;
  final String msg1;
  final String msg2;

  ListItemInfo(
      {this.id, this.icon, this.name, this.label, this.msg1, this.msg2});
}
