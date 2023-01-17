import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/my_behavior.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_item_view.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';

class SelectPhoneCodePage extends StatefulWidget {
  final String tel;
  SelectPhoneCodePage({Key key, this.tel = '86'}) : super(key: key);

  @override
  _SelectPhoneCodePageState createState() => _SelectPhoneCodePageState();
}

class _SelectPhoneCodePageState extends State<SelectPhoneCodePage> {
  bool _isChanged = false;
  bool _isLoaded = false;
  List _codes = List();
  List _selectCodes = List();
  String _telCode;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _telCode = widget.tel;
    Future.delayed(Duration(milliseconds: 500), () {
      _getData();
    });
  }

  Future<void> _getData() async {
    GlobalModel model = Provider.of<GlobalModel>(context, listen: false);
    List<String> codes = model.currentLanguageCode;
    rootBundle
        .loadString('assets/data/tel_code_${codes[0]}_${codes[1]}.json')
        .then((value) {
      _codes = json.decode(value);
      _selectCodes = _codes
          .map((code) => {
                'name': code['name'],
                'tel': code['tel'],
                'namePinyin': PinyinHelper.getPinyinE(code['name'] ?? ''),
              })
          .toList();
      _isLoaded = true;
      if (mounted) {
        setState(() {});
      }
    });
  }

  Widget _buildBack() {
    return InkWell(
      child: Container(
        width: 15.0,
        height: 28.0,
        child:
            // Container(
            //   child: Text(
            //     S.of(context).cancelText,
            //     style: TextStyles.textF16,
            //   ),
            //   alignment: Alignment.center,
            // )
            // :
            Icon(CupertinoIcons.back, color: Colors.black),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  void _doSure() {
    if (!_isChanged) return;
    Navigator.pop(context, _telCode);
  }

  _buildAllPhoneCode() {
    Widget check = Icon(
      Icons.check,
      color: AppColors.mainColor,
      size: 18.0,
    );

    List<Widget> items = [];
    items.addAll(_codes.map((code) {
      Widget content;
      if (_telCode == code['tel']) {
        content = check;
      }
      return ListItemView(
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              child: Text('+${code['tel']}'),
            ),
            Flexible(child: Text('${code['name']}'))
          ],
        ),
        trailing: content,
        onPressed: () {
          if (mounted) {
            setState(() {
              _telCode = code['tel'];
              if (_telCode != widget.tel) {
                _isChanged = true;
              } else {
                _isChanged = false;
              }
            });
          }
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
        _buildAllPhoneCode(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        titleW: Container(
          alignment: Alignment.center,
          child: Text(
            S.of(context).chooseAreaCode,
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
            ? Column(
                children: [
                  buildSearch(context, pb: 5.0, onPressed: () {
                    routeMaterialPush(SearchCommonPage(
                      pageType: 7,
                      data: {
                        'codeList': _selectCodes,
                        'telCode': _telCode,
                      },
                    )).then((value) {
                      if (value != null) {
                        if (mounted) {
                          setState(() {
                            _isChanged = value != widget.tel;
                            _telCode = value;
                          });
                        }
                      }
                    });
                  }),
                  Container(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 5.0),
                    width: double.infinity,
                    color: greyECColor,
                    child: Text(S.of(context).all, style: TextStyles.textF14T1),
                  ),
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              )
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
