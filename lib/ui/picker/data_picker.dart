import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef DataPickerSelectedCallback = void Function(
    List<DataPickerItem> values, List<int> selecteds, int index);

typedef DataPickerConfirmCallback = void Function(
    List<DataPickerItem> values, List<int> selecteds);

class DataPicker<T> extends StatefulWidget {
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
  final DataPickerSelectedCallback onSelect;

  /// 确认按钮的回调事件
  final DataPickerConfirmCallback onConfirm;

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

  /// true.数组 false.联动
  final bool isArray;

  /// datas 和 jsonData 是两种选项数据的传递方式, 可任选一个传值, 也可同时存在
  final List<DataPickerItem<T>> datas;
  final List jsonData;

  /// 文本对齐方式
  final TextAlign textAlign;

  /// 选项发生改变时, 联动项是否恢复到第一个
  final bool changeToFirst;

  /// 普通选项和选中项的字体样式
  final TextStyle textStyle, selectedTextStyle;

  /// 自定义底部内容
  final Widget footer;

  DataPicker(
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
      this.isArray = false,
      this.datas,
      this.jsonData,
      this.loopings,
      this.textAlign = TextAlign.start,
      this.changeToFirst = false,
      this.textStyle,
      this.selectedTextStyle,
      this.footer})
      : assert(datas != null || jsonData != null),
        super(key: key);

  @override
  _DataPickerState createState() => _DataPickerState();
}

class _DataPickerState<T> extends State<DataPicker<T>> {
  static const double defaultTextSize = 15.0;
  static const double defaultSelTextSize = 16.0;

  final List<FixedExtentScrollController> scrollController = [];

  List<DataPickerItem<T>> data;
  List<DataPickerItem<dynamic>> _datas;

  int _maxLevel = -1;
  List<int> selecteds;
  bool _isChangeing = false;

  @override
  void initState() {
    data = widget.datas;
    _parseData();
    _checkPickerDataLevel(data, 1);
    initSelects();
    if (scrollController.length == 0) {
      for (int i = 0; i < _maxLevel; i++)
        scrollController
            .add(FixedExtentScrollController(initialItem: selecteds[i]));
    }
    super.initState();
  }

  void _parseData() {
    if ((widget.jsonData?.length ?? 0) == 0 || (data?.length ?? 0) > 0) return;
    if (data == null) data = List<DataPickerItem<T>>();
    if (widget.isArray) {
      _parseArrayDataItem();
    } else {
      _parseLinkageDataItem(widget.jsonData, data);
    }
  }

  void _parseArrayDataItem() {
    if (widget.jsonData[0] is List) {
      for (int i = 0; i < widget.jsonData.length; i++) {
        var json = widget.jsonData[i];
        if (!(json is List)) continue;
        List list = json;
        if (list.length == 0) continue;

        DataPickerItem item =
            DataPickerItem(children: List<DataPickerItem<T>>());
        data.add(item);
        for (int j = 0; j < list.length; j++) {
          var tmp = list[j];
          if (tmp is Map) {
            item.children.add(DataPickerItem(
              text: tmp['text'] ?? '',
              value: tmp['value'],
            ));
          } else {
            item.children.add(DataPickerItem(text: tmp.toString()));
          }
        }
      }
    } else {
      DataPickerItem item = DataPickerItem(children: List<DataPickerItem<T>>());
      data.add(item);

      for (int i = 0; i < widget.jsonData.length; i++) {
        var json = widget.jsonData[i];
        if (json is Map) {
          item.children.add(DataPickerItem(
            text: json['text'] ?? '',
            value: json['value'],
          ));
        } else {
          item.children.add(DataPickerItem(text: json.toString()));
        }
      }
    }
  }

  void _parseLinkageDataItem(List json, List<DataPickerItem> list) {
    if (json == null) return;
    for (int i = 0; i < json.length; i++) {
      var item = json[i];
      if (item is Map) {
        final Map map = item;
        if (map.length == 0) continue;
        String text;
        T value;
        List<String> _mapList = map.keys.toList();
        if (_mapList.contains('text')) {
          text = map['text'];
        }
        if (_mapList.contains('value')) {
          value = map['value'];
        }
        var tmp;
        String key;
        for (int j = 0; j < _mapList.length; j++) {
          var _o = map[_mapList[j]];
          if (_o is List && _o.length > 0) {
            tmp = _o;
            key = _mapList[j];
            break;
          }
        }
        List<DataPickerItem> _children;
        if (tmp != null) {
          _children = List<DataPickerItem<T>>();
        }
        if (text == null) {
          text = key ?? _mapList[0];
        }
        list.add(DataPickerItem(text: text, value: value, children: _children));
        if (tmp != null) {
          _parseLinkageDataItem(tmp, _children);
        }
      } else if (T == String && !(item is List)) {
        list.add(DataPickerItem(text: item.toString()));
      } else if (item is T) {
        list.add(DataPickerItem(text: '$item'));
      }
    }
  }

  void _checkPickerDataLevel(List<DataPickerItem> data, int level) {
    if (data == null) return;
    if (widget.isArray) {
      _maxLevel = data.length;
      return;
    }
    for (int i = 0; i < data.length; i++) {
      if (data[i].children != null && data[i].children.length > 0)
        _checkPickerDataLevel(data[i].children, level + 1);
    }
    if (_maxLevel < level) _maxLevel = level;
  }

  void initSelects() {
    if (selecteds == null || selecteds.length == 0) {
      if (selecteds == null) selecteds = List<int>();
      for (int i = 0; i < _maxLevel; i++) selecteds.add(0);
    }
  }

  List<DataPickerItem> getSelectedValues() {
    List<DataPickerItem> _items = [];
    if (selecteds != null) {
      if (widget.isArray) {
        for (int i = 0; i < selecteds.length; i++) {
          int j = selecteds[i];
          if (j < 0 || data[i].children == null || j >= data[i].children.length)
            break;
          _items.add(DataPickerItem(
            text: data[i].children[j].text,
            value: data[i].children[j].value,
          ));
        }
      } else {
        List<DataPickerItem<dynamic>> datas = data;
        for (int i = 0; i < selecteds.length; i++) {
          int j = selecteds[i];
          if (j < 0 || j >= datas.length) break;
          _items
              .add(DataPickerItem(text: datas[j].text, value: datas[j].value));
          datas = datas[j].children;
          if (datas == null || datas.length == 0) break;
        }
      }
    }
    return _items;
  }

  void doCancel() {
    if (widget.onCancel != null) widget.onCancel();
    Navigator.of(context).pop();
  }

  void doConfirm() {
    if (widget.onConfirm != null)
      widget.onConfirm(getSelectedValues(), selecteds);
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
    final DataPickerItem item = _datas[index];
    if (item.item != null) {
      return item.item;
    }
    return makeText(item.item, item.text, index == selecteds[col]);
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

  void setColumn(int index) {
    if (widget.isArray) {
      if (index + 1 < data.length)
        _datas = data[index + 1].children;
      else
        _datas = null;
      return;
    }
    if (index < 0) {
      _datas = data;
    } else {
      var _select = selecteds[index];
      if (_datas != null && _datas.length > _select)
        _datas = _datas[_select].children;
      else
        _datas = null;
    }
  }

  List<Widget> _buildContent() {
    List<Widget> items = [];

    setColumn(-1);

    for (int i = 0; i < _maxLevel; i++) {
      int _length = getLength();

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
                if (widget.changeToFirst) {
                  for (int j = i + 1; j < selecteds.length; j++) {
                    selecteds[j] = 0;
                    scrollController[j].jumpTo(0.0);
                  }
                }
                if (widget.onSelect != null) {
                  widget.onSelect(getSelectedValues(), selecteds, i);
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

      setColumn(i);
    }

    return items;
  }

  void updateScrollController(int i) {
    if (_isChangeing || widget.isArray) return;
    _isChangeing = true;
    for (int j = 0; j < selecteds.length; j++) {
      if (j != i) {
        if (scrollController[j].position.maxScrollExtent == null) continue;
        scrollController[j].position.notifyListeners();
      }
    }
    _isChangeing = false;
  }

  int getLength() {
    return _datas == null ? 0 : _datas.length;
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
}

class DataPickerItem<T> {
  final Widget item;

  final String text;
  final T value;

  final List<DataPickerItem<T>> children;

  DataPickerItem({this.item, this.text, this.value, this.children})
      : assert(text != null || value != null || children != null);
}

Future<T> showDataPicker<T>(BuildContext context, DataPicker picker) async {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext buildContext) {
      return picker;
    },
  );
}
