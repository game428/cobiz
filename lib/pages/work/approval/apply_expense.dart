import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:cobiz_client/pages/work/ui/approval_process_view.dart';
import 'package:cobiz_client/pages/work/ui/select_images_view.dart';
import 'package:flutter/material.dart';
import '../../../domain/work_domain.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/work.dart' as workApi;

class ApplyExpensePage extends StatefulWidget {
  final int teamId;
  final String teamName;

  const ApplyExpensePage({Key key, this.teamId, this.teamName})
      : super(key: key);

  @override
  _ApplyExpensePageState createState() => _ApplyExpensePageState();
}

class _ApplyExpensePageState extends State<ApplyExpensePage> {
  TextEditingController _msgController = TextEditingController();
  TextEditingController _moneyControllers = TextEditingController();
  TextEditingController _typeControllers = TextEditingController();
  TextEditingController _detailControllers = TextEditingController();

  // ignore: unused_field
  bool _isShowMsgClear = false;
  bool _isMoneyClear = false;
  bool _isTypeClear = false;
  bool _isDetailClear = false;
  String _defaultCurrency = "RMB";
  List _currencyList = [
    {
      'value': 1,
      'text': "RMB",
    },
    {
      'value': 2,
      'text': "USD",
    },
    {
      'value': 3,
      'text': "USDT",
    },
  ];

  List<File> _images = List();

  List<TempMember> _approvers = List();
  List<TempMember> _copies = List();

  @override
  void initState() {
    super.initState();
    _msgController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowMsgClear = _msgController.text.length > 0;
        });
      }
    });
    _moneyControllers.addListener(() {
      if (mounted) {
        setState(() {
          _isMoneyClear = _moneyControllers.text.length > 0;
        });
      }
    });
    _typeControllers.addListener(() {
      if (mounted) {
        setState(() {
          _isTypeClear = _typeControllers.text.length > 0;
        });
      }
    });
    _detailControllers.addListener(() {
      if (mounted) {
        setState(() {
          _isDetailClear = _detailControllers.text.length > 0;
        });
      }
    });
  }

  void _unfocusField() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _selectCurrency() {
    _unfocusField();
    showDataPicker(
        context,
        DataPicker(
          jsonData: _currencyList,
          isArray: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selecteds) {
            if (mounted) {
              setState(() {
                _defaultCurrency = values[0].text;
              });
            }
          },
        ));
  }

  Future _dealSubmit() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_moneyControllers.text.isEmpty) {
      return showToast(context, S.of(context).pEnterMoney);
    } else if (_typeControllers.text.isEmpty) {
      return showToast(context, S.of(context).pEnterReimbursementType);
    } else if (_approvers.length < 1) {
      return showToast(context, S.of(context).selectApprover);
    }
    try {
      double money = double.parse(_moneyControllers.text);
      if (money <= 0) {
        return showToast(context, S.of(context).pEnterRightMoney);
      }
    } catch (e) {
      return showToast(context, S.of(context).pEnterRightMoney);
    }
    Loading.before(context: context);
    List<String> img = [];
    List<int> approvers = [];
    List<int> copyTo = [];
    //图片
    if (_images.isNotEmpty) {
      Set<String> paths = Set();
      _images.forEach((element) {
        paths.add(element.path);
      });
      Map<String, String> result =
          await commonApi.uploadFilesCompressMap(paths, bucket: 5);
      if (result == null || result.length < 1)
        return showToast(context, S.of(context).imageUploadFailed);
      result.forEach((key, value) {
        img.add(value);
      });
    }
    //审批人
    if (_approvers.isNotEmpty) {
      _approvers.forEach((element) {
        approvers.add(element.userId);
      });
    }
    //抄送人
    if (_copies.isNotEmpty) {
      _copies.forEach((element) {
        copyTo.add(element.userId);
      });
    }
    bool res = await workApi.expenseAdd(
        teamId: widget.teamId,
        moneyNum: double.parse(_moneyControllers.text),
        unit: _defaultCurrency,
        title: _typeControllers.text,
        content: _detailControllers.text,
        images: img,
        approvers: approvers,
        copyTo: copyTo,
        msg: _msgController.text);
    Loading.complete();
    if (res == true) {
      Navigator.pop(context, approvers[0] == API.userInfo.id);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  Widget _buildExpense() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 5.0, color: greyECColor),
        ),
      ),
      child: Column(
        children: <Widget>[
          EditLineView(
            title: S.of(context).expenseTotal,
            hintText: S.of(context).pEnterMoney,
            maxLen: 12,
            rightW: InkWell(
              child: Text(_defaultCurrency),
              onTap: () {
                _selectCurrency();
              },
            ),
            textController: _moneyControllers,
            isShowClear: _isMoneyClear,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputFormatter: FilteringTextInputFormatter.allow(
                RegExp("^[0-9]+(\.[0-9]{0,2})?\$")),
          ),
          EditLineView(
            title: S.of(context).expenseType,
            hintText: S.of(context).egAcFunding,
            textController: _typeControllers,
            isShowClear: _isTypeClear,
            maxLen: 50,
          ),
          ListItemView(
            title: S.of(context).expenseDetail,
            haveBorder: false,
          ),
          EditLineView(
            minHeight: 40.0,
            hintText: S.of(context).pEnterMoneyDetail,
            top: 5.0,
            textAlign: TextAlign.left,
            textFieldLines: 3,
            textController: _detailControllers,
            isShowClear: _isDetailClear,
            haveBorder: true,
            maxLen: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildExpense(),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 5.0, color: greyECColor),
            ),
          ),
          child: Column(
            children: <Widget>[
              SelectImagesView(
                images: _images,
                onPressed: _unfocusField,
                haveBorder: true,
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            children: <Widget>[
              ApprovalProcessView(
                approvers: _approvers,
                copies: _copies,
                teamId: widget.teamId,
                teamName: widget.teamName,
                margin: EdgeInsets.only(bottom: 10.0, left: 15.0, right: 15.0),
              ),
              // ListItemView(
              //   title: S.of(context).leaveAMessage,
              //   haveBorder: false,
              // ),
              // EditLineView(
              //   minHeight: 40.0,
              //   hintText: S.of(context).pEnterMessage,
              //   top: 5.0,
              //   textAlign: TextAlign.left,
              //   textFieldLines: 3,
              //   textController: _msgController,
              //   isShowClear: _isShowMsgClear,
              //   maxLen: 50,
              // ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: ComMomBar(
            title: S.of(context).reimbursementApplication,
            elevation: 0.5,
            rightDMActions: <Widget>[
              buildSureBtn(
                text: S.of(context).finish,
                textStyle: TextStyles.textF14T2,
                color: AppColors.mainColor,
                onPressed: _dealSubmit,
              ),
            ],
          ),
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              children: <Widget>[
                _buildColumn(),
              ],
            ),
          ),
          backgroundColor: Colors.white,
        ));
  }

  @override
  void dispose() {
    _msgController.dispose();
    _moneyControllers.dispose();
    _typeControllers.dispose();
    _detailControllers.dispose();

    super.dispose();
  }
}
