import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cobiz_client/config/app_styles.dart';
import 'package:cobiz_client/generated/l10n.dart';
import 'package:cobiz_client/tools/check.dart';

import 'image_view.dart';

class SearchNavbarView extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool autoFocus;
  final String hintText;
  final double elevation;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final ValueChanged onChanged;
  final ValueChanged onSubmitted;
  final List<TextInputFormatter> inputFormatters;
  const SearchNavbarView(
      {Key key,
      this.textController,
      this.focusNode,
      this.autoFocus = true,
      this.hintText,
      this.elevation = 0.5,
      this.textInputType,
      this.textInputAction,
      this.onChanged,
      this.onSubmitted,
      this.inputFormatters})
      : super(key: key);

  @override
  Size get preferredSize => new Size(100, 50);

  @override
  Widget build(BuildContext context) {
    Widget inputRow = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 30.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: greyF6Color,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 8.0),
            child: TextField(
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.only(left: -10.0, bottom: 0.0, right: 10.0),
                border: InputBorder.none,
                isDense: true,
                icon: ImageView(img: searchImage, width: 20.0),
                hintText: hintText ?? S.of(context).search,
                hintStyle: TextStyles.textF14T1,
              ),
              inputFormatters: inputFormatters,
              style: TextStyles.textF14,
              autofocus: autoFocus,
              controller: textController,
              focusNode: focusNode,
              keyboardType: textInputType,
              textInputAction: textInputAction,
              onChanged: onChanged ?? (str) {},
              onSubmitted: onSubmitted ?? (str) {},
            ),
          ),
        ),
        SizedBox(
          width: isIOS() ? 15.0 : 0,
        ),
      ],
    );

    Widget cancelBtn = InkWell(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(right: 15.0),
        child: Row(
          children: <Widget>[
            Text(
              S.of(context).cancelText,
              style: TextStyles.textF16,
            )
          ],
        ),
      ),
      onTap: () => Navigator.of(context).pop(),
    );

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: elevation,
      title: inputRow,
      actions: <Widget>[cancelBtn],
    );
  }
}
