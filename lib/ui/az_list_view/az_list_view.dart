import 'package:flutter/material.dart';
import 'package:cobiz_client/generated/l10n.dart';

import 'az_common.dart';
import 'index_bar.dart';
import 'suspension_view.dart';

/// Called to build children for the listview.
typedef Widget ItemWidgetBuilder(BuildContext context, ISuspensionBean model);

/// Called to build IndexBar.
typedef Widget IndexBarBuilder(
    BuildContext context, List<String> tags, IndexBarTouchCallback onTouch);

/// Called to build index hint.
typedef Widget IndexHintBuilder(BuildContext context, String hint);

/// _Header.
class _Header extends ISuspensionBean {
  String tag;

  @override
  String getSuspensionTag() => tag;

  @override
  bool get isShowSuspension => false;
}

/// AzListView.
class AzListView extends StatefulWidget {
  AzListView({
    Key key,
    this.data,
    this.topData,
    this.itemBuilder,
    this.controller,
    this.physics,
    this.shrinkWrap = true,
    this.padding = EdgeInsets.zero,
    this.suspensionWidget,
    this.isUseRealIndex = true,
    this.itemHeight = 50,
    this.suspensionHeight = 40,
    this.onSusTagChanged,
    this.header,
    this.indexBarBuilder,
    this.indexHintBuilder,
    this.showIndexHint = true,
    this.barTouchDownColor = Colors.transparent,
    this.curTag = '',
    this.showStat = false,
    this.showSus = true,
  })  : assert(itemBuilder != null),
        super(key: key);

  ///with ISuspensionBean Data
  final List<ISuspensionBean> data;

  ///with ISuspensionBean topData, Do not participate in [A-Z] sorting (such as hotList).
  final List<ISuspensionBean> topData;

  final ItemWidgetBuilder itemBuilder;

  final ScrollController controller;

  final ScrollPhysics physics;

  final bool shrinkWrap;

  final EdgeInsetsGeometry padding;

  ///suspension widget.
  final Widget suspensionWidget;

  ///is use real index data.(false: use INDEX_DATA_DEF)
  final bool isUseRealIndex;

  ///item Height.
  final double itemHeight;

  ///suspension widget Height.
  final double suspensionHeight;

  ///on sus tag change callback.
  final ValueChanged<String> onSusTagChanged;

  final AzListViewHeader header;

  final IndexBarBuilder indexBarBuilder;

  final IndexHintBuilder indexHintBuilder;

  final bool showIndexHint;

  final Color barTouchDownColor;

  final String curTag;

  final bool showStat;

  final bool showSus;

  @override
  State<StatefulWidget> createState() {
    return new _AzListViewState();
  }
}

class _AzListViewState extends State<AzListView> {
  Map<String, double> _suspensionSectionMap = Map();
  List<ISuspensionBean> _list = List();
  List<String> _indexTagList = List();
  bool _isShowIndexBarHint = false;
  String _indexBarHint = '';

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _onIndexBarTouch(IndexBarDetails model) {
    setState(() {
      _indexBarHint = model.tag;
//      _isShowIndexBarHint = model.isTouchDown;  // 取消点击索引时屏幕中的提示显示
      double offset = _suspensionSectionMap[model.tag];
      if (offset != null) {
        _scrollController.jumpTo(offset
            .toDouble()
            .clamp(.0, _scrollController.position.maxScrollExtent));
      }
    });
  }

  void _init() {
    _list.clear();
    if (widget.topData != null && widget.topData.isNotEmpty) {
      _list.addAll(widget.topData);
    }
    List<ISuspensionBean> list = widget.data;
    if (list != null && list.isNotEmpty) {
      SuspensionUtil.sortListBySuspensionTag(list);
      _list.addAll(list);
    }

    SuspensionUtil.setShowSuspensionStatus(_list);

    if (widget.header != null) {
      _list.insert(0, _Header()..tag = widget.header.tag);
    }
    _indexTagList.clear();
    if (widget.isUseRealIndex) {
      _indexTagList.addAll(SuspensionUtil.getTagIndexList(_list));
    } else {
      _indexTagList.addAll(INDEX_DATA_DEF);
    }
  }

  @override
  Widget build(BuildContext context) {
    _init();
    var children = <Widget>[
      SuspensionView(
        data: widget.header == null ? _list : _list.sublist(1),
        contentWidget: ListView.builder(
            controller: _scrollController,
            physics: widget.physics,
            shrinkWrap: widget.shrinkWrap,
            padding: widget.padding,
            itemCount: _list.length + (widget.showStat ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0 && _list[index] is _Header) {
                return SizedBox(
                    height: widget.header.height.toDouble(),
                    child: widget.header.builder(context));
              } else if (widget.showStat && index == _list.length) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    '${S.of(context).contactStat(widget.data.length)}',
                    style: TextStyle(color: Color(0xFFB1B1B1)),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 20.0,
                  ),
                );
              }
              return widget.itemBuilder(context, _list[index]);
            }),
        suspensionWidget: widget.suspensionWidget,
        controller: _scrollController,
        suspensionHeight: widget.suspensionHeight,
        itemHeight: widget.itemHeight,
        onSusTagChanged: widget.onSusTagChanged,
        header: widget.header,
        onSusSectionInited: (Map<String, double> map) =>
            _suspensionSectionMap = map,
      )
    ];

    Widget indexBar;
    if (widget.indexBarBuilder == null) {
      indexBar = IndexBar(
        data: _indexTagList,
        width: 30,
        touchDownColor: widget.barTouchDownColor,
        onTouch: _onIndexBarTouch,
        curTag: widget.curTag,
      );
    } else {
      indexBar = widget.indexBarBuilder(
        context,
        _indexTagList,
        _onIndexBarTouch,
      );
    }
    if (widget.showSus == true) {
      children.add(Align(
        alignment: Alignment.centerRight,
        child: indexBar,
      ));
    }

    Widget indexHint;
    if (widget.indexHintBuilder != null) {
      indexHint = widget.indexHintBuilder(context, '$_indexBarHint');
    } else {
      indexHint = Card(
        color: Colors.black54,
        child: Container(
          alignment: Alignment.center,
          width: 80.0,
          height: 80.0,
          child: Text(
            '$_indexBarHint',
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_isShowIndexBarHint && widget.showIndexHint) {
      children.add(Center(
        child: indexHint,
      ));
    }

    return new Stack(children: children);
  }
}
