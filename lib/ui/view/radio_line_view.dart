import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:flutter/material.dart';

class RadioLineView extends StatelessWidget {
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry radioPadding;
  final double minHeight;
  final bool haveBorder;
  final Color color;
  final bool radioIsCanChange;

  final bool checked;
  final double iconRt;
  final Widget content;
  final String text;

  final Widget trail;
  final bool arrowRt;
  final bool arrowUp;

  final VoidCallback checkCallback;
  final VoidCallback onPressed;

  const RadioLineView(
      {Key key,
      this.paddingLeft = 0.0,
      this.paddingRight = 0.0,
      this.paddingTop = 0.0,
      this.paddingBottom = 0.0,
      this.margin,
      this.radioPadding,
      this.minHeight,
      this.haveBorder = false,
      this.checked,
      this.iconRt = 20.0,
      this.content,
      this.text,
      this.trail,
      this.arrowRt = false,
      this.arrowUp,
      this.checkCallback,
      this.color,
      this.radioIsCanChange = true,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListRowView(
      color: color,
      haveBorder: haveBorder,
      margin: margin,
      minHeight: minHeight,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
      paddingRight: paddingRight,
      paddingLeft: paddingLeft,
      iconWidget: (checked != null
          ? Container(
              margin: EdgeInsets.only(right: iconRt),
              child: InkWell(
                child: buildRadio(checked, margin: radioPadding, radioIsCanChange: radioIsCanChange),
                onTap: checkCallback ?? () {},
              ),
            )
          : null),
      titleWidget: (content ??
          Row(
            children: <Widget>[
              ImageView(
                img: 'assets/images/team/branch1.png',
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: Text(
                  text ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.textF16,
                ),
              ),
            ],
          )),
      widgetRt1: (trail ??
          (arrowRt
              ? ImageView(
                  img: arrowRtImage,
                )
              : (arrowUp != null
                  ? Icon(
                      arrowUp
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: greyCAColor,
                      size: 20.0,
                    )
                  : null))),
      onPressed: () {
        if (trail == null &&
            !arrowRt &&
            checked != null &&
            checkCallback != null) {
          checkCallback();
        } else if (onPressed != null) {
          onPressed();
        }
      },
    );
  }
}
