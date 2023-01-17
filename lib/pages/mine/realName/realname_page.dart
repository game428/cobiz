import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/utils/file_util.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'realname_state_page.dart';

class RealnamePage extends StatefulWidget {
  RealnamePage();

  @override
  _RealNamePageState createState() => _RealNamePageState();
}

class _RealNamePageState extends State<RealnamePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  bool _isShowNameClear = false;
  bool _isShowCodeClear = false;
  bool isSave = false;
  File _cardFile1;
  File _cardFile2;
  File _cardFile3;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = _nameController.text.length > 0;
        });
      }
    });

    _codeController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowCodeClear = _codeController.text.length > 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    routePushReplace(RealnameStatePage());
  }

  Widget _card(int type) {
    String imgUrl = 'assets/images/mine/id_card_$type.png';
    switch (type) {
      case 1:
        if (_cardFile1 != null) {
          imgUrl = _cardFile1.path;
        }
        break;
      case 2:
        if (_cardFile2 != null) {
          imgUrl = _cardFile2.path;
        }
        break;
      case 3:
        if (_cardFile3 != null) {
          imgUrl = _cardFile3.path;
        }
        break;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 155,
          width: 250.0,
          margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/images/mine/id_card_bor.png'),
            ),
          ),
          child: InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ImageView(
                  img: imgUrl,
                  width: 230.0,
                  height: 140,
                  isRadius: 0.0,
                ),
              ],
            ),
            onTap: () {
              _getPhoto(type);
            },
          ),
        )
      ],
    );
  }

  Future _getPhoto(int type) async {
    File result =
        await FileUtil.getInstance().getPhoto(context, isCropper: false);
    if (result == null) return;
    if (mounted) {
      setState(() {
        switch (type) {
          case 1:
            _cardFile1 = result;
            break;
          case 2:
            _cardFile2 = result;
            break;
          case 3:
            _cardFile3 = result;
            break;
        }
      });
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Widget _body() {
    return Expanded(
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20),
        children: <Widget>[
          EditLineView(
            title: S.of(context).teamApplyLabel1,
            hintText: S.of(context).teamApplyHintText1,
            textController: _nameController,
            isShowClear: _isShowNameClear,
            maxLen: 30,
          ),
          EditLineView(
            title: S.of(context).idNum,
            hintText: S.of(context).plzEnterIdNum,
            textController: _codeController,
            isShowClear: _isShowCodeClear,
            maxLen: 30,
          ),
          _card(1),
          _card(2),
          _card(3),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowNameClear ||
        !_isShowCodeClear ||
        _cardFile1 == null ||
        _cardFile2 == null ||
        _cardFile3 == null) {
      isSave = false;
    } else {
      isSave = true;
    }
    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).realNameVerify,
        elevation: 0.5,
        rightDMActions: <Widget>[
          buildSureBtn(
            text: S.of(context).submit,
            textStyle: isSave ? TextStyles.textF14T2 : TextStyles.textF14T1,
            color: isSave ? AppColors.mainColor : greyECColor,
            onPressed: _submit,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _body(),
        ],
      ),
    );
  }
}
