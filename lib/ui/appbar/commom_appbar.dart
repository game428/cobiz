import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cobiz_client/provider/global_model.dart';

class ComMomBar extends StatelessWidget implements PreferredSizeWidget {
  const ComMomBar(
      {this.title = '',
      this.rightDMActions,
      this.backgroundColor,
      this.mainColor = Colors.black,
      this.titleW,
      this.bottom,
      this.leadingImg = '',
      this.elevation = 0.0,
      this.leadingW,
      this.backData,
      this.backCall,
      this.automaticallyImplyLeading = true,
      this.centerTitle = true});

  final String title;
  final List<Widget> rightDMActions;
  final Color backgroundColor;
  final Color mainColor;
  final Widget titleW;
  final PreferredSizeWidget bottom;
  final String leadingImg;
  final double elevation;
  final Widget leadingW;
  final dynamic backData;
  final VoidCallback backCall;
  final bool centerTitle;
  final bool automaticallyImplyLeading; //是否有返回按钮

  @override
  Size get preferredSize => Size.fromHeight(
      ScreenData.navigationBarHeight - ScreenData.topSafeHeight);

  Widget leading(BuildContext context, GlobalModel model) {
    final bool isShow = Navigator.canPop(context);
    if (isShow) {
      return InkWell(
        child: Container(
          color: backgroundColor ?? Colors.white,
          width: 15,
          height: 28,
          child: leadingImg != ''
              ? Image.asset(leadingImg)
              : Icon(CupertinoIcons.back, color: mainColor),
        ),
        onTap: () {
          if (Navigator.canPop(context)) {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context, backData);
          }
          if (backCall != null) {
            backCall();
          }
        },
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context, listen: false);
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading
          ? (leadingW ?? leading(context, model))
          : null,
      title: titleW == null
          ? Text(
              title,
              style: TextStyle(
                color: mainColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            )
          : titleW,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation,
      brightness: Brightness.light,
      centerTitle: centerTitle,
      titleSpacing: automaticallyImplyLeading ? 0.0 : 15.0,
      actions: rightDMActions ?? [Center()],
      bottom: bottom != null ? bottom : null,
    );
  }
}
