import 'dart:convert';

import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectAreaPage extends StatefulWidget {
  final int nation;
  final int province;
  final int city;

  const SelectAreaPage(
      {Key key, this.nation = 0, this.province = 0, this.city = 0})
      : super(key: key);

  @override
  _SelectAreaPageState createState() => _SelectAreaPageState();
}

class _SelectAreaPageState extends State<SelectAreaPage> {
  GlobalModel model;

  bool _isLoaded = false;
  List _nations = List();

  bool _isChanged = false;

  int _nation = 0;
  String _nationName = '';
  int _province = 0;
  String _provinceName = '';
  int _city = 0;
  String _cityName = '';

  int _current = 0;

  @override
  void initState() {
    super.initState();
    model = Provider.of<GlobalModel>(context, listen: false);
    _init();
  }

  Future<void> _init() async {
    _nation = widget.nation;
    _province = widget.province;
    _city = widget.city;
    Future.delayed(Duration(milliseconds: 500), () {
      _getData();
    });
  }

  Future<void> _getData() async {
    await getRegion(context).then((value) {
      _nations = json.decode(value);
      _isLoaded = true;
      if (mounted) setState(() {});
    });
  }

  Widget _buildNations() {
    Widget check = Container(
      alignment: Alignment.centerRight,
      child: Icon(
        Icons.check,
        color: AppColors.mainColor,
        size: 18.0,
      ),
    );

    List<Widget> items = [];
    List list;
    if (_current == 1) {
      list = _nations.where((n) => n['id'] == _nation).first['child'];
    } else if (_current == 2) {
      list = _nations.where((n1) => n1['id'] == _nation).first['child'];
      list = list.where((n1) => n1['id'] == _province).first['child'];
    } else {
      list = _nations;
    }

    items.addAll(list.map((nation) {
      List child = nation['child'];
      Widget content;
      if (child == null || child.length < 1) {
        if ((_current == 0 && nation['id'] == _nation) ||
            (_current == 1 && nation['id'] == _province) ||
            (_current == 2 && nation['id'] == _city)) {
          content = check;
        } else if ((_current == 0 && nation['id'] == widget.nation) ||
            (_current == 1 && nation['id'] == widget.province) ||
            (_current == 2 && nation['id'] == widget.city)) {
          content = check;
        }
      }
      if (content == null &&
          (child != null && child.length > 0) &&
          ((_current == 0 && nation['id'] == widget.nation) ||
              (_current == 1 && nation['id'] == widget.province) ||
              (_current == 2 && nation['id'] == widget.city))) {
        content = Container(
          alignment: Alignment.centerRight,
          child: Text(
            S.of(context).selected,
            style: TextStyles.textF14T1,
          ),
        );
      }
      return EditLineView(
        title: nation['text'],
        top: 10.0,
        minHeight: 40.0,
        titleMaxOdds: content != null ? 0.6 : 0.8,
        haveArrow: (child != null && child.length > 0),
        content: content,
        onPressed: () {
          if (_current == 0) {
            _nation = nation['id'];
            _nationName = nation['text'];
            _province = 0;
            _provinceName = '';
            _city = 0;
            _cityName = '';
          } else if (_current == 1) {
            _province = nation['id'];
            _provinceName = nation['text'];
            _city = 0;
            _cityName = '';
          } else if (_current == 2) {
            _city = nation['id'];
            _cityName = nation['text'];
          }
          if (child != null && child.length > 0) {
            _current += 1;
            _isChanged = false;
          } else {
            _isChanged = true;
          }
          if (mounted) setState(() {});
        },
      );
    }));
    return Column(
      children: items,
    );
  }

  Widget _buildContent() {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
          color: greyECColor,
          child: Text(S.of(context).all, style: TextStyles.textF14T1),
        ),
        _buildNations(),
      ],
    );
  }

  Widget _buildBack() {
    return InkWell(
      child: Container(
        width: 15.0,
        height: 28.0,
        child: (_current == 0
            ? Container(
                child: Text(
                  S.of(context).cancelText,
                  style: TextStyles.textF16,
                ),
                alignment: Alignment.center,
              )
            : Icon(CupertinoIcons.back, color: Colors.black)),
      ),
      onTap: () {
        if (_current > 0) {
          _current -= 1;
          if (_current == 0) {
            _nation = 0;
            _nationName = '';
          }
          _province = 0;
          _provinceName = '';
          _city = 0;
          _cityName = '';
          _isChanged = false;
          if (mounted) setState(() {});
        } else {
          if (Navigator.canPop(context)) {
            FocusScope.of(context).requestFocus(FocusNode());
            Navigator.pop(context);
          }
        }
      },
    );
  }

  void _doSure() {
    if (!_isChanged) return;
    Navigator.pop(context, {
      'nation': _nation,
      'nationName': _nationName,
      'province': _province,
      'provinceName': _provinceName,
      'city': _city,
      'cityName': _cityName
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        titleW: Container(
          alignment: Alignment.center,
          child: Text(
            S.of(context).selectRegion,
            style: TextStyles.textF18,
          ),
        ),
        leadingW: _buildBack(),
        rightDMActions: <Widget>[
          buildSureBtn(
            text: S.of(context).confirmTitle,
            textStyle: _isChanged ? TextStyles.textF14T2 : TextStyles.textF14T1,
            color: _isChanged ? AppColors.mainColor : greyECColor,
            onPressed: _doSure,
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: _isLoaded
            ? _buildContent()
            : Center(
                child: CupertinoActivityIndicator(),
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
