import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'list_item_view.dart';

class SwitchLineView extends StatelessWidget {
  final String title;
  final bool value;
  final bool haveBorder;
  final bool isArrow;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPressed;

  const SwitchLineView({
    Key key,
    this.title,
    this.value,
    this.haveBorder = true,
    this.isArrow = false,
    this.onChanged,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListItemView(
      title: title,
      haveBorder: haveBorder,
      onPressed: onPressed ?? () {},
      widgetRt1: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSwitch(
            // activeColor: blueDEColor,
            value: value,
            onChanged: onChanged,
          ),
          isArrow
              ? Container(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12.0,
                  ),
                  margin: EdgeInsets.only(right: 5.0, left: 10.0),
                )
              : Container(),
        ],
      ),
    );
  }
}
