import 'package:cobiz_client/config/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cobiz_client/tools/win_media.dart';
import 'package:cobiz_client/ui/view/image_view.dart';

class EditLineView extends StatelessWidget {
  final String title;
  final double bottom;
  final double top;
  final bool haveArrow;
  // content, text, hintText 三者只能存在一个
  final Widget content;
  final String text;
  final String hintText;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final VoidCallback onPressed;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final bool isShowClear;
  final VoidCallback clearCallback;
  final double minHeight;
  final int textFieldLines;
  final int maxLen;
  final bool showMaxLen;
  final Widget rightW;
  final String rightText;
  final bool haveBorder;
  final EdgeInsetsGeometry margin;
  final TextInputFormatter textInputFormatter;
  final bool autofocus;
  final double titleMaxOdds;
  final bool readOnly;
  final TextOverflow titleTextOverflow;
  final CrossAxisAlignment crossAxisAlignment;

  const EditLineView(
      {Key key,
      this.title,
      this.titleTextOverflow = TextOverflow.ellipsis,
      this.crossAxisAlignment = CrossAxisAlignment.end,
      this.autofocus = false,
      this.textInputFormatter,
      this.bottom = 10.0,
      this.top = 20.0,
      this.haveArrow = false,
      this.content,
      this.text,
      this.hintText,
      this.textAlign = TextAlign.right,
      this.keyboardType,
      this.onPressed,
      this.textController,
      this.onChanged,
      this.focusNode,
      this.isShowClear = false,
      this.clearCallback,
      this.minHeight = 55.0,
      this.textFieldLines = 1,
      this.maxLen,
      this.showMaxLen = false,
      this.rightW,
      this.rightText,
      this.haveBorder = true,
      this.margin,
      this.titleMaxOdds = 0.3,
      this.readOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget right;
    if (content != null) {
      right = content;
    } else if (text != null) {
      right = Text(
        text,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.textF16T4,
      );
    } else if (hintText != null) {
      right = TextField(
        readOnly: readOnly,
        focusNode: focusNode,
        controller: textController,
        style: TextStyles.textF16T4,
        textAlign: textAlign,
        minLines: textFieldLines,
        maxLines: textFieldLines,
        keyboardType: keyboardType,
        maxLength: showMaxLen ? maxLen : null,
        autofocus: autofocus,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
          ),
          border: InputBorder.none,
          isDense: true,
          hintText: hintText,
          hintStyle: TextStyles.textF16,
        ),
        inputFormatters: maxLen != null
            ? (textInputFormatter == null
                ? <TextInputFormatter>[LengthLimitingTextInputFormatter(maxLen)]
                : <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(maxLen),
                    textInputFormatter
                  ])
            : null,
        onChanged: onChanged ?? (str) {},
      );
    } else {
      right = Container();
    }
    List<Widget> list = [
      Container(
        constraints: (title != null
            ? BoxConstraints(
                minWidth: winWidth(context) * 0.25,
                maxWidth: winWidth(context) * titleMaxOdds,
              )
            : null),
        alignment: Alignment.centerLeft,
        child: Text(
          title ?? '',
          style: TextStyles.textF16,
          overflow: titleTextOverflow,
        ),
      ),
      SizedBox(
        width: (title != null ? 10.0 : 0.0),
      ),
      Expanded(
        child: right,
      )
    ];
    if (haveArrow) {
      list.add(Container(
//        child: ImageView(img: arrowRtImage,),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 12.0,
        ),
        margin: EdgeInsets.only(
          right: 5.0,
          bottom: 5.0,
          left: 10.0,
        ),
      ));
    } else if (isShowClear) {
      list.add(InkWell(
        child: Container(
          child: ImageView(
            img: 'assets/images/ic_delete.webp',
          ),
          margin: EdgeInsets.only(
            right: 0.0,
            bottom: 0.0,
            left: 5.0,
          ),
        ),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (textController != null) {
              textController.clear();
            }
            if (clearCallback != null) {
              clearCallback();
            }
          });
        },
      ));
    }
    if (rightW != null) {
      list.add(SizedBox(
        width: 5.0,
      ));
      list.add(rightW);
    } else if (rightText != null) {
      list.add(SizedBox(
        width: 5.0,
      ));
      list.add(Text(
        rightText,
        textAlign: textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyles.textF16,
      ));
    }
    return InkWell(
      highlightColor: Colors.white.withOpacity(0),
      splashColor: Colors.white.withOpacity(0),
      focusColor: Colors.white.withOpacity(0),
      child: Container(
        padding: EdgeInsets.only(bottom: bottom, top: top),
        margin: margin ??
            EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 0.0,
            ),
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          border: (haveBorder
              ? Border(
                  bottom: BorderSide(
                    width: 0.4,
                    color: greyDFColor,
                  ),
                )
              : null),
          color: Colors.white,
        ),
        child: Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: crossAxisAlignment,
          children: list,
        ),
      ),
      onTap: onPressed,
    );
  }
}
