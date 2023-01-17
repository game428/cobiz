import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:cobiz_client/tools/shared_util.dart';

class Area {

  final String name;
  final String code;

  Area(this.name, this.code);

  String getCode() {
    return code;
  }

  String toString() {
    return this.name + "(${this.code})";
  }
}

class Location {

  static List<Area> _areas;
  static Area _currentArea;

  static void init(BuildContext context) {
    _areas = [
      Area('中国', '86'),
      Area('澳大利亚', '61'),
      Area('墨西哥', '853'),
      Area('加拿大', '001'),
      Area('美国', '001'),
      Area('中国台湾', '886'),
      Area('中国香港', '852'),
      Area('新加坡', '65'),
    ];
  }

  static void save(Area area) {
    var obj = { 'name': area.name, 'code': area.code };
    var str = json.encode(obj);
    SharedUtil.instance.saveString(Keys.area, str);
  }

  static Future<Area> loadArea({BuildContext context}) async {
    if (_currentArea != null) {
      return _currentArea;
    }

    var str = await SharedUtil.instance.getString(Keys.area);
    if (str != '' && str != null) {
      var obj = json.decode(str);
      return Area(obj['name'], obj['code']);
    }
    if (context != null) {
      return defaultArea(context);
    }
    return Area('', '');
  }

  static Area currentArea() {
    return _currentArea;
  }

  static void setCurrentArea(Area area) {
    _currentArea = area;
  }

  static Area defaultArea(BuildContext context) {
    return Area('中国', "86");
  }

  static Area getAreaByCode(BuildContext context, String code) {
    if (_areas == null) {
      init(context);
    }
    for (Area v in _areas) {
      if (v.code == code) {
        return v;
      }
    }
    return defaultArea(context);
  }

  static areaList(BuildContext context) {
    if (_areas == null) {
      init(context);
    }
    return _areas;
  }


}