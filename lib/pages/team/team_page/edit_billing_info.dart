import 'package:cobiz_client/http/res/team_model/invoice_info.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

class EditBillingInfoPage extends StatefulWidget {
  final int teamId;
  final bool readOnly;

  const EditBillingInfoPage(
      {Key key, @required this.teamId, this.readOnly = false})
      : super(key: key);

  @override
  _EditBillingInfoPageState createState() => _EditBillingInfoPageState();
}

class _EditBillingInfoPageState extends State<EditBillingInfoPage> {
  bool _isLoaded = false;
  TextEditingController _headerController = TextEditingController();
  TextEditingController _taxIDController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _bankController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addrController = TextEditingController();
  TextEditingController _markController = TextEditingController();

  bool _isShowHeaderClear = false;
  bool _isShowTaxIDClear = false;
  bool _isShowAccountClear = false;
  bool _isShowBankClear = false;
  bool _isShowPhoneClear = false;
  bool _isShowAddrClear = false;
  bool _isShowMarkClear = false;
  bool _isInputFinish = false;

  @override
  void initState() {
    super.initState();
    _getData();
    _initController();
  }

  void _getData() async {
    InvoiceInfo invoiceInfo =
        await teamApi.teamInvoiceInfo(teamId: widget.teamId);
    if (invoiceInfo != null) {
      _headerController.text = invoiceInfo.title ?? '';
      _taxIDController.text = invoiceInfo.taxNum ?? '';
      _accountController.text = invoiceInfo.cardNo ?? '';
      _bankController.text = invoiceInfo.opened ?? '';
      _phoneController.text = invoiceInfo.phone ?? '';
      _addrController.text = invoiceInfo.address ?? '';
      _markController.text = invoiceInfo.remark ?? '';
    }
    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  void _initController() {
    if (widget.readOnly) {
      return;
    }
    _headerController.addListener(() {
      if (mounted) {
        setState(() {
          _inputFinish();
          if (_headerController.text.length > 0) {
            _isShowHeaderClear = true;
          } else {
            _isShowHeaderClear = false;
          }
        });
      }
    });
    _taxIDController.addListener(() {
      if (mounted) {
        setState(() {
          if (_taxIDController.text.length > 0) {
            _isShowTaxIDClear = true;
          } else {
            _isShowTaxIDClear = false;
          }
        });
      }
    });
    _accountController.addListener(() {
      if (mounted) {
        setState(() {
          if (_accountController.text.length > 0) {
            _isShowAccountClear = true;
          } else {
            _isShowAccountClear = false;
          }
        });
      }
    });
    _bankController.addListener(() {
      if (mounted) {
        setState(() {
          if (_bankController.text.length > 0) {
            _isShowBankClear = true;
          } else {
            _isShowBankClear = false;
          }
        });
      }
    });
    _phoneController.addListener(() {
      if (mounted) {
        setState(() {
          if (_phoneController.text.length > 0) {
            _isShowPhoneClear = true;
          } else {
            _isShowPhoneClear = false;
          }
        });
      }
    });
    _addrController.addListener(() {
      if (mounted) {
        setState(() {
          if (_addrController.text.length > 0) {
            _isShowAddrClear = true;
          } else {
            _isShowAddrClear = false;
          }
        });
      }
    });
    _markController.addListener(() {
      if (mounted) {
        setState(() {
          if (_markController.text.length > 0) {
            _isShowMarkClear = true;
          } else {
            _isShowMarkClear = false;
          }
        });
      }
    });
  }

  void _inputFinish() {
    _isInputFinish = _headerController.text.length > 0;
  }

  void _dealSubmit() async {
    if (!_isInputFinish) return;
    Loading.before(context: context);
    bool res = await teamApi.editTeamInvoiceInfo(
        teamId: widget.teamId,
        title: _headerController.text,
        taxNum: _taxIDController.text,
        cardNo: _accountController.text,
        opened: _bankController.text,
        phone: _phoneController.text,
        address: _addrController.text,
        remark: _markController.text);
    Loading.complete();
    if (res) {
      showToast(context, S.of(context).settingOk);
      Navigator.pop(context);
    } else {
      showToast(context, S.of(context).tryAgainLater);
    }
  }

  void _unfocusField() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget _buildColumn() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          EditLineView(
            title: S.of(context).billingHeader,
            hintText:
                widget.readOnly ? '' : S.of(context).billingHeaderHintText,
            maxLen: 50,
            textController: _headerController,
            isShowClear: _isShowHeaderClear,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          EditLineView(
            title: S.of(context).taxID,
            hintText: widget.readOnly ? '' : S.of(context).taxIDHintText,
            maxLen: 30,
            textController: _taxIDController,
            isShowClear: _isShowTaxIDClear,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          EditLineView(
            title: S.of(context).bankAccount,
            hintText: widget.readOnly ? '' : S.of(context).bankAccountHintText,
            maxLen: 20,
            textController: _accountController,
            isShowClear: _isShowAccountClear,
            keyboardType: TextInputType.number,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          EditLineView(
            title: S.of(context).bankOfDeposit,
            hintText:
                widget.readOnly ? '' : S.of(context).bankOfDepositHintText,
            maxLen: 30,
            textController: _bankController,
            isShowClear: _isShowBankClear,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          EditLineView(
            title: S.of(context).phone,
            hintText: widget.readOnly ? '' : S.of(context).hintPhone,
            maxLen: 20,
            textController: _phoneController,
            isShowClear: _isShowPhoneClear,
            keyboardType: TextInputType.phone,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          EditLineView(
            title: S.of(context).registeredAddress,
            hintText:
                widget.readOnly ? '' : S.of(context).registeredAddressHintText,
            maxLen: 70,
            textController: _addrController,
            isShowClear: _isShowAddrClear,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
          EditLineView(
            title: S.of(context).remark,
            hintText: widget.readOnly ? '' : S.of(context).remarkHintText,
            maxLen: 50,
            textController: _markController,
            isShowClear: _isShowMarkClear,
            readOnly: widget.readOnly,
            titleTextOverflow: null,
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _unfocusField();
      },
      child: Scaffold(
        appBar: ComMomBar(
          title: S.of(context).billingInformation,
          elevation: 0.5,
          rightDMActions: <Widget>[
            widget.readOnly || !_isLoaded
                ? Container()
                : buildSureBtn(
                    text: S.of(context).finish,
                    textStyle: _isInputFinish
                        ? TextStyles.textF14T2
                        : TextStyles.textF14T1,
                    color: _isInputFinish ? AppColors.mainColor : greyECColor,
                    onPressed: _dealSubmit,
                  ),
          ],
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: _isLoaded ? _buildColumn() : buildProgressIndicator(),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _taxIDController.dispose();
    _accountController.dispose();
    _bankController.dispose();
    _phoneController.dispose();
    _addrController.dispose();
    _markController.dispose();
    super.dispose();
  }
}
