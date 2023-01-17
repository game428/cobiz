import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

typedef InputRowTextChange(String value);

// ignore: must_be_immutable
class InputRow extends StatelessWidget {
  final String label;
  final double labelWidth;
  final bool underLine;
  final bool topLine;
  final Widget rightWidget;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double lineWidth;
  final Color lineColor;
  final Color labelColor;
  final Color backgroundColor;
  final InputRowTextChange onTextChange;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final String hintText;
  final TextInputAction textInputAction;
  final TextAlign textAlign;
  TextEditingController textController;

  InputRow({
    this.label, //标签
    this.labelWidth = 70, //标签宽度
    this.labelColor = Colors.grey, //标签颜色
    this.backgroundColor = Colors.white,
    this.rightWidget, //输入框右侧组件
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
    this.underLine = false, //是否显示下划线
    this.topLine = false, //是否显示上划线
    this.lineWidth = 0.3, //上/下划线宽度
    this.lineColor = Colors.grey, //上/下划线颜色
    this.onTextChange, //文本变化回调
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.textInputAction,
    this.textAlign = TextAlign.end,
    this.textController,
    String value, //默认值
  }) {
    if (textController == null) {
      this.textController = TextEditingController();
    }
    if (value != null) {
      textController.text = value;
    }
  }

  String get value => textController.text;

  set value(v) => textController.text = v;

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: margin,
      color: backgroundColor,
      child: Container(
        padding: padding,
        margin: EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          border: (underLine || topLine)
              ? Border(
                  top: topLine
                      ? BorderSide(color: lineColor, width: lineWidth)
                      : BorderSide.none,
                  bottom: underLine
                      ? BorderSide(color: lineColor, width: lineWidth)
                      : BorderSide.none)
              : null,
        ),
        child: new Row(
          children: <Widget>[
            new SizedBox(
              width: labelWidth,
              child: new Text(
                label ?? '',
                style: TextStyle(fontSize: 17.0),
              ),
            ),
//          new Spacer(),
            Expanded(
              child: new TextField(
                controller: textController,
                textInputAction: textInputAction,
                maxLines: 1,
                textAlign: textAlign,
                style: TextStyle(textBaseline: TextBaseline.alphabetic),
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                decoration: InputDecoration(
                    hintText: hintText, border: InputBorder.none),
                onChanged: (text) {
                  if (onTextChange != null) onTextChange(text);
                },
              ),
            ),
            rightWidget != null ? rightWidget : new Container(),
          ],
        ),
      ),
    );
  }
}
