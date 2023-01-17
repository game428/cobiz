import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';

class ChannelOffstage extends StatefulWidget {
  final String img;
  final String text;
  final bool isShow;
  final Function(bool) call;
  ChannelOffstage(this.isShow, this.img, this.text, {Key key, this.call})
      : super(key: key);

  @override
  _ChannelOffstageState createState() => _ChannelOffstageState();
}

class _ChannelOffstageState extends State<ChannelOffstage> {
  bool _offstage = true;

  @override
  void initState() {
    super.initState();
    _offstage = widget.isShow;
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: _offstage,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
                bottom: BorderSide(
                    color: ThemeModel.defaultLineColor.withOpacity(0.5)))),
        child: Row(
          children: [
            ImageIcon(
              AssetImage(widget.img),
              color: AppColors.mainColor,
            ),
            SizedBox(
              width: 7,
            ),
            Expanded(
              child: Text(
                widget.text ?? '',
                style: TextStyle(
                    fontSize: FontSizes.font_s12, color: AppColors.red),
              ),
            ),
            InkWell(
              child: ImageView(img: 'assets/images/ic_delete.webp'),
              onTap: () {
                setState(() {
                  _offstage = true;
                });
                if (widget.call != null) {
                  widget.call(_offstage);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
