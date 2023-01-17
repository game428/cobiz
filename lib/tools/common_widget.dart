import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///暂无数据 暂无内容
Widget buildDefaultNoContent(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 100.0),
    child: Center(
      child: Column(
        children: [
          ImageView(img: noContent),
          Text(S.of(context).noContent, style: TextStyles.textF17T3)
        ],
      ),
    ),
  );
}

///线
Widget buildDivider({double height, Color color}) {
  return Container(
    height: height ?? null,
    color: color ?? ThemeModel.defaultLineColor,
  );
}

// 按钮
Widget buildCommonButton(
  String text, {
  EdgeInsetsGeometry margin,
  double paddingV = 6.0,
  double paddingH = 0.0,
  Color backgroundColor,
  Color sizeColor,
  VoidCallback onPressed,
  double fontSize = FontSizes.font_s18,
  double minHeight = 46.0,
  double radius = 5.0,
}) {
  return Container(
    margin: margin ??
        EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
    constraints: BoxConstraints(minHeight: minHeight),
    width: ScreenData.width,
    child: FlatButton(
      color: backgroundColor ?? AppColors.mainColor,
      padding: EdgeInsets.symmetric(
        vertical: paddingV,
        horizontal: paddingH,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: sizeColor ?? Colors.white, fontSize: fontSize),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      onPressed: onPressed ?? () {},
    ),
  );
}

// 图片icon label
Widget buildLabel(String text, String icon) {
  return Container(
    padding: EdgeInsets.only(
      top: 10.0,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textNoneLabel,
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        ImageView(
          img: icon,
        )
      ],
    ),
  );
}

//loading widget
Widget buildProgressIndicator(
    {bool isLoading = true, double size = 20.0, EdgeInsetsGeometry padding}) {
  return Center(
    child: Padding(
      padding: padding ?? EdgeInsets.all(8.0),
      child: Opacity(
        opacity: isLoading ? 1.0 : 0.0,
        child: SizedBox(
            width: size, height: size, child: CupertinoActivityIndicator()),
      ),
    ),
  );
}

// 带switch的行组件
Widget buildSwitch(String title, bool value, Function(bool) onChanged,
    {bool isLine = true, String label}) {
  return ListItemView(
    title: title,
    label: label,
    haveBorder: isLine,
    widgetRt1: SizedBox(
      height: 25.0,
      child: CupertinoSwitch(
        value: value,
        activeColor: AppColors.mainColor,
        onChanged: onChanged,
      ),
    ),
    onPressed: () {},
  );
}

//带数字红点
Widget buildNumtip(int number, {bool isSmall = false}) {
  String text = '$number';
  if (number > 99) {
    text = '99+';
  }
  return Container(
    padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: red68Color,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: (isSmall ? TextStyles.textF12T1 : TextStyles.textF12T2),
    ),
  );
}

//第一个大写
String parseTextFirstUpper(String text) {
  if ((text?.length ?? 0) == 0) return text;
  String tmp = text.substring(0, 1).toUpperCase();
  if (text.length > 1) {
    return tmp + text.substring(1);
  } else {
    return tmp;
  }
}

//第一个小写
String parseTextFirstLower(String text) {
  if ((text?.length ?? 0) == 0) return text;
  String tmp = text.substring(0, 1).toLowerCase();
  if (text.length > 1) {
    return tmp + text.substring(1);
  } else {
    return tmp;
  }
}

//checkRadio
Widget buildRadio(bool checked,
    {double size = 16.0, EdgeInsetsGeometry margin, bool radioIsCanChange}) {
  return Container(
    width: size,
    height: size,
    margin: margin,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(
        color: (checked
            ? (radioIsCanChange ? themeColor : greyA3Color)
            : greyC1Color),
        width: 1.0,
      ),
      color: checked
          ? (radioIsCanChange ? themeColor : greyA3Color)
          : Colors.white,
      shape: BoxShape.circle,
    ),
  );
}

Widget buildFilletImage(
  String image, {
  double imgSize = 42.0,
  double radius = 21.0,
  double borderWidth,
  String text,
  Color borderColor,
  EdgeInsetsGeometry margin,
  bool needLoad = false,
}) {
  return Container(
    margin: margin,
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.circular(radius),
        side: BorderSide(
          color: borderColor ?? ThemeModel.defaultLineColor,
          width: borderWidth ?? 0.3,
        ),
      ),
    ),
    alignment: Alignment.center,
    width: imgSize,
    height: imgSize,
    child: strNoEmpty(image)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: ImageView(
              img: cuttingAvatar(image),
              width: imgSize,
              height: imgSize,
              needLoad: needLoad,
            ),
          )
        : Text(text ?? ' '),
  );
}

///红点
Widget buildMessaged({Color color = red68Color, double size = 8.0}) {
  return ClipOval(
    child: Container(
      width: size,
      height: size,
      color: color,
    ),
  );
}

///消息列表页面已读未读' √ '
Widget buildReadUnread(int state) {
  switch (state) {
    case 1:
      return Container(
        child: Icon(
          Icons.done,
          size: 16.0,
          color: AppColors.mainColor,
        ),
      );
      break;
    case 2:
      return Container(
        child: Icon(
          Icons.done_all,
          size: 16.0,
          color: AppColors.mainColor,
        ),
      );
      break;
    default:
      return Container();
  }
}

//搜索框
Widget buildSearch(BuildContext context,
    {Function onPressed,
    double pl = 15.0,
    double pt = 5.0,
    double pr = 15.0,
    double pb = 0.0}) {
  return Container(
    width: ScreenData.width,
    padding: EdgeInsets.fromLTRB(pl, pt, pr, pb),
    child: FlatButton(
      shape: StadiumBorder(),
      child: Row(
        children: <Widget>[
          ImageView(
            img: searchImage,
          ),
          Expanded(
            child: Text(
              S.of(context).search,
              style: TextStyles.textF14T1,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
        ],
      ),
      color: greyF6Color,
      onPressed: onPressed,
    ),
  );
}

// 标题右上角按钮
Widget buildSureBtn(
    {String text,
    TextStyle textStyle,
    Color color,
    VoidCallback onPressed,
    EdgeInsetsGeometry padding}) {
  return Container(
    padding:
        padding == null ? EdgeInsets.fromLTRB(0, 14.0, 15.0, 14.0) : padding,
    child: CupertinoButton(
      child: Text(
        text,
        style: textStyle,
      ),
      color: color,
      pressedOpacity: 0.8,
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      borderRadius: BorderRadius.circular(5.0),
      onPressed: onPressed,
    ),
  );
}

///底部往上弹窗
void showSureModal(BuildContext context, String text, VoidCallback onPressed,
    {String promptText,
    TextAlign textAlign,
    String text2,
    VoidCallback onPressed2}) {
  double radius = 15.0;
  // double height = 108.0;
  BorderRadiusGeometry borderRadius = BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
  );
  ShapeBorder shapeBorder = RoundedRectangleBorder(
    borderRadius: borderRadius,
  );
  showModalBottomSheet(
    context: context,
    shape: shapeBorder,
    builder: (BuildContext bct) {
      return Stack(
        children: <Widget>[
          Container(
            // height: height,
            padding: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
            decoration:
                BoxDecoration(color: Colors.white, borderRadius: borderRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                promptText != null
                    ? Container(
                        child: Text(
                          promptText,
                          textAlign: textAlign,
                          style: TextStyles.textF14T1,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: grey81Color,
                              width: 0.2,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10.0),
                        width: double.infinity,
                        alignment: Alignment.center,
                      )
                    : Container(),
                FlatButton(
                  child: Container(
                    child: Text(
                      text,
                      style: TextStyles.textF16T5,
                      textAlign: TextAlign.center,
                    ),
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 50.0),
                    alignment: Alignment.center,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onPressed();
                  },
                  shape: shapeBorder,
                ),
                text2 != null
                    ? Container(
                        height: 0.2,
                        color: grey81Color,
                      )
                    : Container(),
                text2 != null
                    ? FlatButton(
                        child: Container(
                          child: Text(
                            text2,
                            style: TextStyles.textF16T5,
                            textAlign: TextAlign.center,
                          ),
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 50.0),
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onPressed2();
                        },
                        shape: shapeBorder,
                      )
                    : Container(),
                Container(
                  height: 8.0,
                  color: greyECColor,
                ),
                FlatButton(
                  child: Container(
                    child: Text(
                      S.of(context).cancelText,
                      style: TextStyles.textF16,
                    ),
                    width: double.infinity,
                    height: 50.0,
                    alignment: Alignment.center,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// 好友申请的备注框
Widget buildTextTitle(
  String title, {
  double top,
  double left,
  double right,
  double bottom,
  double fontSize,
  AlignmentGeometry alignment,
  bool haveBorder = false,
  EdgeInsetsGeometry margin,
}) {
  return Container(
    child: Text(title, style: TextStyle(fontSize: fontSize ?? 16.0)),
    padding: EdgeInsets.only(
      top: top ?? 10.0,
      bottom: bottom ?? 0.0,
      left: left ?? 0.0,
      right: right ?? 0.0,
    ),
    margin: margin,
    decoration: BoxDecoration(
      border: (haveBorder
          ? Border(
              bottom: BorderSide(width: 0.3, color: Color(0xFFBCBCBC)),
            )
          : null),
    ),
    alignment: alignment ?? Alignment.centerLeft,
  );
}
