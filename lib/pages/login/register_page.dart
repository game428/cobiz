import 'package:cobiz_client/pages/common/select_phone_code.dart';
import 'package:cobiz_client/pages/login/privacy_policy.dart';
import 'package:cobiz_client/pages/login/user_agreement.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/user.dart' as userApi;

//注册找回密码公用页面
class RegisterPage extends StatefulWidget {
  final String title;
  final int type; // 1：注册 2：找回密码
  RegisterPage(this.title, this.type, {Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TapGestureRecognizer recognizer1 = TapGestureRecognizer();
  TapGestureRecognizer recognizer2 = TapGestureRecognizer();

  TextEditingController _phoneController = TextEditingController(); //手机号
  TextEditingController _codeController = TextEditingController(); //验证码
  TextEditingController _pwdC1 = TextEditingController(); //密码
  TextEditingController _pwdC2 = TextEditingController(); //确认密码

  FocusNode _phoneFocus = FocusNode();
  FocusNode _codeFocus = FocusNode();

  bool _isShowPhoneClear = false;
  bool _isShowPwd1 = false;
  bool _isShowPwd2 = false;

  String _code = '86';

  int _initCountdown = 120;
  Timer _timer;
  int _seconds;
  String _verifyStr;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    _seconds = _initCountdown;
    _phoneController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowPhoneClear = _phoneController.text.length > 0;
        });
      }
    });
  }

  _done() async {
    if (_phoneController.text.isEmpty) {
      return showToast(context, S.of(context).plzEnterPhone);
    }
    if (_codeController.text.isEmpty) {
      return showToast(context, S.of(context).plzEnterVfiCode);
    }
    if (_pwdC1.text.length < 6 || _pwdC2.text.length < 6) {
      return showToast(context, S.of(context).sixPwd);
    }
    if (_pwdC1.text != _pwdC2.text) {
      return showToast(context, S.of(context).pwdDiff);
    }
    Loading.before(context: context);
    var res = await userApi.register(context, _phoneController.text, _code,
        _pwdC2.text, _codeController.text, widget.type);
    Loading.complete();
    if (res == true) {
      if (widget.type == 1) {
        showToast(context, S.of(context).regOk);
      } else if (widget.type == 2) {
        showToast(context, S.of(context).findOk);
      }
      Navigator.pop(context, {'code': _code, 'phone': _phoneController.text});
    }
  }

  //底部协议
  Widget _buildBottom() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
      child: Center(
        child: Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: S.of(context).loginAndAgree + ' ',
                style: TextStyles.textF13T1,
                children: [
                  TextSpan(
                    text: S.of(context).userAgreement,
                    style: TextStyle(color: themeColor),
                    recognizer: recognizer1
                      ..onTap = () async {
                        if (await SharedUtil.instance
                            .getBoolean(Keys.brokenNetwork)) {
                          showToast(context, S.of(context).noNetwork);
                          return;
                        }
                        routeMaterialPush(UserAgreement());
                      },
                  ),
                  TextSpan(
                    text: ' ${S.of(context).and} ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: S.of(context).privacyPolicy,
                    style: TextStyle(color: themeColor),
                    recognizer: recognizer2
                      ..onTap = () async {
                        if (await SharedUtil.instance
                            .getBoolean(Keys.brokenNetwork)) {
                          showToast(context, S.of(context).noNetwork);
                          return;
                        }
                        routeMaterialPush(PrivacyPolicy());
                      },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              S.of(context).warning,
              textAlign: TextAlign.center,
              style: TextStyles.textF12T1,
            )
          ],
        ),
      ),
    );
  }

  //手机号
  Widget _buildPhoneInput() {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 20.0),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: greyECColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: <Widget>[
          ImageView(img: 'assets/images/mine/phone.png'),
          SizedBox(width: 10),
          InkWell(
            child: Row(
              children: <Widget>[
                Text(
                  '+' + _code,
                  style: TextStyles.textF16,
                ),
                SizedBox(
                  width: 3.0,
                ),
                Text('▾'),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  '|',
                  style: TextStyle(color: greyA0Color),
                ),
                SizedBox(
                  width: 8.0,
                ),
              ],
            ),
            onTap: () {
              routeMaterialPush(SelectPhoneCodePage(
                tel: _code,
              )).then((value) {
                if (value != null && mounted) {
                  _code = value;
                  setState(() {});
                }
              });
            },
          ),
          Expanded(
            child: TextField(
              focusNode: _phoneFocus,
              controller: _phoneController,
              style: TextStyles.textF16,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                ),
                border: InputBorder.none,
                isDense: true,
                hintText: S.of(context).plzEnterPhone,
                hintStyle: TextStyles.textF16T2,
              ),
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20)
              ],
            ),
          ),
          _isShowPhoneClear
              ? InkWell(
                  child: Container(
                    child: ImageView(
                      img: 'assets/images/ic_delete.webp',
                    ),
                    margin: EdgeInsets.only(
                      right: 0.0,
                      bottom: 0.0,
                      left: 5.0,
                    ),
                  ),
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_phoneController != null) {
                        _phoneController.clear();
                      }
                    });
                  },
                )
              : SizedBox(
                  width: 0.0,
                ),
        ],
      ),
    );
  }

  //验证码
  Widget _buildCodeInput() {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: greyECColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: <Widget>[
          ImageView(img: 'assets/images/chat/safety.png'),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: _codeFocus,
              controller: _codeController,
              style: TextStyles.textF16,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                ),
                border: InputBorder.none,
                isDense: true,
                hintText: S.of(context).plzEnterVfiCode,
                hintStyle: TextStyles.textF16T2,
              ),
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(6)
              ],
            ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.only(
                left: 30.0,
                right: 5.0,
              ),
              child: Text(
                  (_verifyStr ?? '').isEmpty
                      ? S.of(context).sendSms
                      : _verifyStr,
                  style: TextStyle(fontSize: 16, color: themeColor)),
            ),
            onTap: (_seconds == _initCountdown) ? _sendVerifyCode : null,
          ),
        ],
      ),
    );
  }

  //密码
  Widget _buildPwdInput() {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: greyECColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: <Widget>[
          ImageView(img: 'assets/images/mine/password.png'),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _pwdC1,
              style: TextStyles.textF16,
              obscureText: !_isShowPwd1,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                ),
                border: InputBorder.none,
                isDense: true,
                hintText: widget.type == 1
                    ? S.of(context).setPwd
                    : S.of(context).setNewPwd,
                hintStyle: TextStyles.textF16T2,
              ),
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20)
              ],
            ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.only(
                left: 30.0,
                right: 5.0,
              ),
              child: ImageView(
                  img:
                      'assets/images/eye_${!_isShowPwd1 ? 'close' : 'open'}.png'),
            ),
            onTap: () {
              if (mounted) {
                setState(() {
                  _isShowPwd1 = !_isShowPwd1;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPwdInput2() {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: greyECColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: <Widget>[
          ImageView(img: 'assets/images/mine/password.png'),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _pwdC2,
              style: TextStyles.textF16,
              obscureText: !_isShowPwd2,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                ),
                border: InputBorder.none,
                isDense: true,
                hintText: widget.type == 1
                    ? S.of(context).checkPwd
                    : S.of(context).checkNewPwd,
                hintStyle: TextStyles.textF16T2,
              ),
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20)
              ],
            ),
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.only(
                left: 30.0,
                right: 5.0,
              ),
              child: ImageView(
                  img:
                      'assets/images/eye_${!_isShowPwd2 ? 'close' : 'open'}.png'),
            ),
            onTap: () {
              if (mounted) {
                setState(() {
                  _isShowPwd2 = !_isShowPwd2;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerifyCode() async {
    String phone = _phoneController.text;
    if (phone.isEmpty) {
      FocusScope.of(context).requestFocus(_phoneFocus);
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    if (await SharedUtil.instance.getBoolean(Keys.brokenNetwork)) {
      showToast(context, S.of(context).noNetwork);
      return;
    }
    _startTimer();
    String code = await userApi.sendVerifyCode(context, phone, _code);
    if (code != null && mounted) {
      if (code == '') {
        FocusScope.of(context).requestFocus(_codeFocus);
      } else {
        setState(() {
          _codeController.text = code;
        });
      }
    } else {
      _cancelTimer();
      _seconds = _initCountdown;
      _verifyStr = S.of(context).reSendSms;
      if (mounted) setState(() {});
    }
  }

  void _startTimer() {
    if (_seconds < _initCountdown) return;
    if (mounted) {
      setState(() {
        _verifyStr = S.of(context).verifyTimerStr(_seconds.toString());
      });
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        _seconds = _initCountdown;
        if (mounted) setState(() {});
        return;
      }
      _seconds--;
      if (_seconds == 0) {
        _verifyStr = S.of(context).reSendSms;
      } else {
        _verifyStr = S.of(context).verifyTimerStr(_seconds.toString());
      }
      if (mounted) setState(() {});
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _pwdC1.dispose();
    _pwdC2.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    recognizer1.dispose();
    recognizer2.dispose();
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: ComMomBar(title: widget.title),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: winHeight(context) - ScreenData.navigationBarHeight,
            child: Column(
              children: [
                SizedBox(height: 15),
                _buildPhoneInput(),
                _buildCodeInput(),
                _buildPwdInput(),
                _buildPwdInput2(),
                buildCommonButton(
                    widget.type == 1
                        ? S.of(context).register
                        : S.of(context).finish,
                    margin: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      // bottom: 60,
                    ),
                    onPressed: _done),
                Spacer(),
                Divider(
                  height: widget.type == 1 ? 1.0 : 0,
                  color: greyECColor,
                ),
                widget.type == 1 ? _buildBottom() : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
