import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DatePickerSelectedCallback = void Function(
    DateTime time, List<int> selecteds, int index);

typedef DatePickerConfirmCallback = void Function(
    DateTime time, List<int> selecteds);

class DateTimePicker extends StatefulWidget {
  /// 是否隐藏标题栏
  final bool hideHeader;

  /// 标题栏背景颜色
  final Color headerBgColor;
  final Decoration headerDecoration;

  /// 自定义标题栏左键(优先)
  final Widget cancel;

  /// 标题栏取消按钮的文本
  final String cancelText;

  /// 自定义标题栏右键(优先)
  final Widget confirm;

  /// 标题栏确认按钮的文本
  final String confirmText;

  /// 取消按钮的回调事件
  final VoidCallback onCancel;

  /// 选中某项触发的事件
  final DatePickerSelectedCallback onSelect;

  /// 确认按钮的回调事件
  final DatePickerConfirmCallback onConfirm;

  /// 自定义的标题(优先)
  final Widget title;

  /// 标题文本
  final String titleText;

  /// 控件高度
  final double height;

  /// 选项高度
  final double itemExtent;

  /// 选项区域背景色
  final Color itemBgColor;

  /// 是否循环显示(控制所有选项)
  final bool looping;

  /// 是否循环显示(可以独立控制每一项)
  final List<bool> loopings;

  /// 时间类型
  final int dateType;

  /// 年份起止时间
  final int yearBegin, yearEnd;

  /// 初始化时间, 最小最大时间
  final DateTime initValue, minValue, maxValue;

  /// 月份是否显示数字
  final bool isNumberMonth;

  /// 自定义月份
  final List<String> months;

  /// 自定义AM/PM
  final List<String> strAMPM;

  /// 自定义分钟间隔数
  final int minuteInterval;

  /// 年月日数字的后缀
  final String yearSuffix, monthSuffix, daySuffix;

  /// 是否显示两位数的年份
  final bool twoDigitYear;

  /// 文本对齐方式
  final TextAlign textAlign;

  /// 选项发生改变时, 联动项是否恢复到第一个
  final bool changeToFirst;

  /// 是否联动效果
  final bool isLinkage;

  /// 普通选项和选中项的字体样式
  final TextStyle textStyle, selectedTextStyle;

  /// 自定义底部内容
  final Widget footer;

  DateTimePicker(
      {Key key,
      this.hideHeader = false,
      this.headerBgColor,
      this.headerDecoration,
      this.cancel,
      this.cancelText,
      this.confirm,
      this.confirmText,
      this.onCancel,
      this.onSelect,
      this.onConfirm,
      this.title,
      this.titleText,
      this.height = 180.0,
      this.itemExtent = 32.0,
      this.itemBgColor = Colors.white,
      this.looping = false,
      this.loopings,
      this.dateType = DateTimePickerType.kYMD,
      this.yearBegin = 1900,
      this.yearEnd = 2100,
      this.initValue,
      this.minValue,
      this.maxValue,
      this.isNumberMonth = false,
      this.months,
      this.strAMPM,
      this.minuteInterval,
      this.yearSuffix,
      this.monthSuffix,
      this.daySuffix,
      this.twoDigitYear = false,
      this.textAlign = TextAlign.start,
      this.changeToFirst = false,
      this.isLinkage = true,
      this.textStyle,
      this.selectedTextStyle,
      this.footer})
      : assert(minuteInterval == null ||
            (minuteInterval >= 1 &&
                minuteInterval <= 30 &&
                (60 % minuteInterval == 0)));

  @override
  _DateTimePickerState createState() => _DateTimePickerState();

  static String intToStr(int v) {
    if (v < 10) return '0$v';
    return '$v';
  }
}

class _DateTimePickerState extends State<DateTimePicker> {
  static const double defaultTextSize = 15.0;
  static const double defaultSelTextSize = 16.0;

  final List<FixedExtentScrollController> scrollController = [];

  int _maxLevel = 1;
  List<int> selecteds;
  int _colAP = -1;
  int _yearBegin = 0;

  DateTime value;

  bool _isChangeing = false;

  @override
  void initState() {
    _maxLevel = lengths[widget.dateType].length;
    initSelects();
    doShow();
    if (scrollController.length == 0) {
      for (int i = 0; i < _maxLevel; i++)
        scrollController
            .add(FixedExtentScrollController(initialItem: selecteds[i]));
    }
    super.initState();
  }

  void initSelects() {
    value = widget.initValue ?? DateTime.now();
    _yearBegin = widget.yearBegin;
    if (widget.minValue != null && widget.minValue.year > _yearBegin) {
      _yearBegin = widget.minValue.year;
    }
    _colAP = _getAPColIndex();
    if (selecteds == null || selecteds.length == 0) {
      if (selecteds == null) selecteds = List<int>();
      for (int i = 0; i < _maxLevel; i++) selecteds.add(0);
    }
  }

  void doCancel() {
    if (widget.onCancel != null) widget.onCancel();
    Navigator.of(context).pop();
  }

  void doConfirm() {
    if (widget.onConfirm != null) widget.onConfirm(value, selecteds);
    Navigator.of(context).pop();
  }

  List<Widget> _buildHeader() {
    List<Widget> items = [];
    TextStyle btnTextStyle = TextStyle(
      color: Colors.blue,
      fontSize: 14.0,
    );

    if (widget.cancel != null) {
      items.add(widget.cancel);
    } else if (widget.cancelText != null) {
      items.add(CupertinoButton(
        child: Text(
          widget.cancelText,
          style: btnTextStyle,
        ),
        pressedOpacity: 0.8,
        minSize: 36.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        onPressed: () {
          doCancel();
        },
      ));
    }

    items.add(Expanded(
      child: Container(
        alignment: Alignment.center,
        child: widget.title ??
            Text(
              widget.titleText ?? '',
              style: TextStyle(fontSize: defaultTextSize, color: Colors.black),
            ),
      ),
    ));

    if (widget.confirm != null) {
      items.add(widget.confirm);
    } else if (widget.confirmText != null) {
      items.add(CupertinoButton(
        child: Text(
          widget.confirmText,
          style: btnTextStyle,
        ),
        pressedOpacity: 0.8,
        minSize: 36.0,
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        onPressed: () {
          doConfirm();
        },
      ));
    }

    return items;
  }

  Widget buildItem(int col, int index) {
    String _text = '';
    int colType = getColumnType(col);
    switch (colType) {
      case 0:
        if (widget.twoDigitYear != null && widget.twoDigitYear) {
          _text = '${_yearBegin + index}';
          _text =
              '${_text.substring(_text.length - (_text.length - 2), _text.length)}${_checkStr(widget.yearSuffix)}';
        } else
          _text = '${_yearBegin + index}${_checkStr(widget.yearSuffix)}';
        break;
      case 1:
        if (widget.isNumberMonth) {
          _text = '${index + 1}${_checkStr(widget.monthSuffix)}';
        } else {
          if (widget.months != null)
            _text = '${widget.months[index]}';
          else {
            List _months = MonthsList_EN;
            _text = '${_months[index]}';
          }
        }
        break;
      case 2:
        _text = '${index + 1}${_checkStr(widget.daySuffix)}';
        break;
      case 3:
      case 5:
        _text = '${DateTimePicker.intToStr(index)}';
        break;
      case 4:
        if (widget.minuteInterval == null || widget.minuteInterval < 2)
          _text = '${DateTimePicker.intToStr(index)}';
        else
          _text = '${DateTimePicker.intToStr(index * widget.minuteInterval)}';
        break;
      case 6:
        List _ampm = widget.strAMPM; // strAMPM ?? ['上午', '下午'];
        if (_ampm == null) _ampm = const ['AM', 'PM'];
        _text = '${_ampm[index]}';
        break;
      case 7:
        _text = '${DateTimePicker.intToStr(index + 1)}';
        break;
    }

    return makeText(null, _text, selecteds[col] == index);
  }

  Widget makeText(Widget child, String text, bool isSel) {
    return new Container(
      alignment: Alignment.center,
      child: DefaultTextStyle(
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        textAlign: widget.textAlign,
        style: widget.textStyle ??
            TextStyle(
              color: Colors.black87,
              fontSize: defaultTextSize,
              fontWeight: FontWeight.w500,
            ),
        child: child ??
            new Text(text ?? '',
                style: (isSel
                    ? (widget.selectedTextStyle ??
                        TextStyle(fontSize: defaultSelTextSize))
                    : null)),
      ),
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [];

    int _count = lengths[widget.dateType].length;
    for (int i = 0; i < _count; i++) {
      int _length = getLength(i);

      bool isLooping = widget.looping;
      if (widget.loopings != null && widget.loopings.length > i) {
        isLooping = widget.loopings[i];
      }

      items.add(Expanded(
        flex: 1,
        child: Container(
          height: widget.height,
          color: Colors.white,
          child: CupertinoPicker(
            backgroundColor: widget.itemBgColor,
            scrollController: scrollController[i],
            itemExtent: widget.itemExtent,
            looping: isLooping,
            onSelectedItemChanged: (int index) {
              setState(() {
                selecteds[i] = index;
                updateScrollController(i);
                doSelect(i, index);
                if (widget.changeToFirst) {
                  for (int j = i + 1; j < selecteds.length; j++) {
                    selecteds[j] = 0;
                    scrollController[j].jumpTo(0.0);
                  }
                }
                if (widget.onSelect != null) {
                  widget.onSelect(value, selecteds, i);
                }
              });
            },
            children: List<Widget>.generate(_length, (int index) {
              return buildItem(i, index);
            }),
          ),
        ),
      ));

      if (!widget.changeToFirst && selecteds[i] >= _length) {
        Timer(Duration(milliseconds: 100), () {
          scrollController[i].jumpToItem(_length - 1);
        });
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        (widget.hideHeader)
            ? SizedBox()
            : Container(
                child: Row(
                  children: _buildHeader(),
                ),
                decoration: widget.headerDecoration ??
                    BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                      color: widget.headerBgColor ?? Colors.white,
                    ),
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildContent(),
        ),
        widget.footer ??
            SizedBox(
              height: 0.0,
            ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void doShow() {
    for (int i = 0; i < _maxLevel; i++) {
      int colType = getColumnType(i);
      switch (colType) {
        case 0:
          selecteds[i] = value.year - _yearBegin;
          break;
        case 1:
          selecteds[i] = value.month - 1;
          break;
        case 2:
          selecteds[i] = value.day - 1;
          break;
        case 3:
          selecteds[i] = value.hour;
          break;
        case 4:
          selecteds[i] =
              widget.minuteInterval == null || widget.minuteInterval < 2
                  ? value.minute
                  : value.minute ~/ widget.minuteInterval;
          break;
        case 5:
          selecteds[i] = value.second;
          break;
        case 6:
          selecteds[i] = (value.hour > 12 || value.hour == 0) ? 1 : 0;
          break;
        case 7:
          selecteds[i] = value.hour == 0
              ? 11
              : (value.hour > 12) ? value.hour - 12 - 1 : value.hour - 1;
          break;
      }
    }
  }

  void doSelect(int column, int index) {
    int year, month, day, h, m, s;
    year = value.year;
    month = value.month;
    day = value.day;
    h = value.hour;
    m = value.minute;
    s = value.second;
    if (widget.dateType != 2 && widget.dateType != 6) s = 0;

    int colType = getColumnType(column);
    switch (colType) {
      case 0:
        year = _yearBegin + index;
        break;
      case 1:
        month = index + 1;
        break;
      case 2:
        day = index + 1;
        break;
      case 3:
        h = index;
        break;
      case 4:
        m = (widget.minuteInterval == null || widget.minuteInterval < 2)
            ? index
            : index * widget.minuteInterval;
        break;
      case 5:
        s = index;
        break;
      case 6:
        if (selecteds[_colAP] == 0) {
          if (h == 0) h = 12;
          if (h > 12) h = h - 12;
        } else {
          if (h < 12) h = h + 12;
          if (h == 12) h = 0;
        }
        break;
      case 7:
        h = index + 1;
        if (_colAP >= 0 && selecteds[_colAP] == 1) h = h + 12;
        if (h > 23) h = 0;
        break;
    }
    int __day = _calDateCount(year, month);
    if (day > __day) day = __day;
    value = new DateTime(year, month, day, h, m, s);

    if (widget.minValue != null &&
        (value.millisecondsSinceEpoch <
            widget.minValue.millisecondsSinceEpoch)) {
      value = widget.minValue;
      notifyDataChanged();
    } else if (widget.maxValue != null &&
        value.millisecondsSinceEpoch > widget.maxValue.millisecondsSinceEpoch) {
      value = widget.maxValue;
      notifyDataChanged();
    }
  }

  void notifyDataChanged() {
    doShow();
    initSelects();
    for (int j = 0; j < selecteds.length; j++)
      scrollController[j].jumpToItem(selecteds[j]);
  }

  void updateScrollController(int i) {
    if (_isChangeing || !widget.isLinkage) return;
    _isChangeing = true;
    for (int j = 0; j < selecteds.length; j++) {
      if (j != i) {
        if (scrollController[j].position.maxScrollExtent == null) continue;
        scrollController[j].position.notifyListeners();
      }
    }
    _isChangeing = false;
  }

  int getLength(int col) {
    int v = lengths[widget.dateType][col];
    if (v == 0) {
      int ye = widget.yearEnd;
      if (widget.maxValue != null) ye = widget.maxValue.year;
      return ye - _yearBegin + 1;
    }
    if (v == 31) return _calDateCount(value.year, value.month);
    if (widget.minuteInterval != null && widget.minuteInterval > 1) {
      int _type = getColumnType(col);
      if (_type == 4) {
        return v ~/ widget.minuteInterval;
      }
    }
    return v;
  }

  int getColumnType(int index) {
    List<int> items = columnType[widget.dateType];
    if (index >= items.length) return -1;
    return items[index];
  }

  int _getAPColIndex() {
    List<int> items = columnType[widget.dateType];
    for (int i = 0; i < items.length; i++) {
      if (items[i] == 6) return i;
    }
    return -1;
  }

  int _calDateCount(int year, int month) {
    if (leapYearMonths.contains(month)) {
      return 31;
    } else if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
      }
      return 28;
    }
    return 30;
  }

  String _checkStr(String v) {
    return v == null ? '' : v;
  }

  static const List<List<int>> lengths = const [
    [12, 31, 0],
    [24, 60],
    [24, 60, 60],
    [12, 60, 2],
    [12, 31, 0, 24, 60],
    [12, 31, 0, 12, 60, 2],
    [12, 31, 0, 24, 60, 60],
    [0, 12, 31],
    [0, 12, 31, 24, 60],
    [0, 12, 31, 24, 60, 60],
    [0, 12, 31, 2, 12, 60],
    [0, 12],
    [31, 12, 0],
    [0, 12, 31, 2],
    [60, 60, 60, 60]
  ];

  /// year 0, month 1, day 2, hour 3, minute 4, sec 5, am/pm 6, hour-ap: 7
  static const List<List<int>> columnType = const [
    [1, 2, 0],
    [3, 4],
    [3, 4, 5],
    [7, 4, 6],
    [1, 2, 0, 3, 4],
    [1, 2, 0, 7, 4, 6],
    [1, 2, 0, 3, 4, 5],
    [0, 1, 2],
    [0, 1, 2, 3, 4],
    [0, 1, 2, 3, 4, 5],
    [0, 1, 2, 6, 7, 4],
    [0, 1],
    [2, 1, 0],
    [0, 1, 2, 6],
    [3, 4, 3, 4],
  ];

  static const List<int> leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

  static const List<String> MonthsList_EN = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
}

/// Picker DateTime Adapter Type
class DateTimePickerType {
  static const int kMDY = 0; // m, d, y
  static const int kHM = 1; // hh, mm
  static const int kHMS = 2; // hh, mm, ss
  static const int kHM_AP = 3; // hh, mm, ap(AM/PM)
  static const int kMDYHM = 4; // m, d, y, hh, mm
  static const int kMDYHM_AP = 5; // m, d, y, hh, mm, AM/PM
  static const int kMDYHMS = 6; // m, d, y, hh, mm, ss

  static const int kYMD = 7; // y, m, d
  static const int kYMDHM = 8; // y, m, d, hh, mm
  static const int kYMDHMS = 9; // y, m, d, hh, mm, ss
  static const int kYMD_AP_HM = 10; // y, m, d, ap, hh, mm

  static const int kYM = 11; // y, m
  static const int kDMY = 12; // d, m, y

  static const int kYMD_AP = 13; // y, m, d, ap

  static const int hmhm = 14; // hh, mm, hh, mm
}

Future<T> showDateTimePicker<T>(
    BuildContext context, DateTimePicker picker) async {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext buildContext) {
      return picker;
    },
  );
}
