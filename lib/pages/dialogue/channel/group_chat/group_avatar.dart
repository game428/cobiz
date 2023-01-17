import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupAvatar extends StatelessWidget {
  final List<dynamic> list;
  final String name;
  final int len;
  final int gtype;
  const GroupAvatar(this.list, this.name, this.len, this.gtype, {Key key})
      : super(key: key);

  final double _boxSize = 42.0;

  ///白色边框
  Widget borderBox(Widget child) {
    return Container(
      width: 20,
      height: 20.0,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: child,
    );
  }

  _normalHeader() {
    if (len == null || len == 0) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: greyDFColor),
                borderRadius: BorderRadius.circular(20)),
            width: _boxSize,
            height: _boxSize,
          ),
          Positioned(
              child: borderBox(ClipOval(
            child: ImageView(
              img: cuttingAvatar(''),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.cover,
            ),
          ))),
        ],
      );
    } else if (len >= 3) {
      return Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: greyDFColor),
                borderRadius: BorderRadius.circular(20)),
            width: _boxSize,
            height: _boxSize,
          ),
          Positioned(
              bottom: 5,
              right: 3,
              child: borderBox(ClipOval(
                child: ImageView(
                  img: cuttingAvatar(list[2]),
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.cover,
                ),
              ))),
          Positioned(
              bottom: 5,
              left: 3,
              child: borderBox(ClipOval(
                child: ImageView(
                  img: cuttingAvatar(list[1]),
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.cover,
                ),
              ))),
          Positioned(
              top: 1,
              left: 10,
              child: borderBox(ClipOval(
                child: ImageView(
                  img: cuttingAvatar(list[0]),
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.cover,
                ),
              ))),
        ],
      );
    } else if (len == 2) {
      return Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: greyDFColor),
                borderRadius: BorderRadius.circular(20)),
            width: _boxSize,
            height: _boxSize,
          ),
          Positioned(
              bottom: 10,
              right: 3,
              child: borderBox(ClipOval(
                child: ImageView(
                  img: cuttingAvatar(list[1]),
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.cover,
                ),
              ))),
          Positioned(
              bottom: 10,
              left: 3,
              child: borderBox(ClipOval(
                child: ImageView(
                  img: cuttingAvatar(list[0]),
                  width: 20.0,
                  height: 20.0,
                  fit: BoxFit.cover,
                ),
              ))),
        ],
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(color: greyDFColor),
                borderRadius: BorderRadius.circular(20)),
            width: _boxSize,
            height: _boxSize,
          ),
          Positioned(
              child: borderBox(ClipOval(
            child: ImageView(
              img: cuttingAvatar(list[0]),
              width: 20.0,
              height: 20.0,
              fit: BoxFit.cover,
            ),
          ))),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (gtype) {
      case 1:
        String header = '';
        if (len > 0) {
          header = list[0];
        }
        if (!strNoEmpty(header)) {
          header = logoImageG;
        }
        return ImageView(
          img: cuttingAvatar(header),
          width: 42.0,
          height: 42.0,
          needLoad: true,
          isRadius: 21.0,
          fit: BoxFit.cover,
        );
      case 2:
      case 3:
        return Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.circular(21.0),
              side: BorderSide(color: Colors.grey, width: 0.3),
            ),
            color: AppColors.mainColor,
          ),
          alignment: Alignment.center,
          width: _boxSize,
          height: _boxSize,
          child: Text(name.length >= 2 ? name.substring(0, 2) : name,
              style: TextStyle(
                color: Colors.white,
              )),
        );
      default:
        return _normalHeader();
    }
  }
}
