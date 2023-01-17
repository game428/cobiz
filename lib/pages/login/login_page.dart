import 'package:cobiz_client/config/jpush_manager.dart';
import 'package:cobiz_client/pages/login/register_page.dart';
import 'package:cobiz_client/pages/mine/improve_data.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/user.dart' as userApi;
import 'package:cobiz_client/pages/common/select_phone_code.dart';
import 'package:cobiz_client/pages/root_page.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:mobpush_plugin/mobpush_plugin.dart';

class LoginPage extends StatefulWidget {
  final bool isKick;

  const LoginPage({Key key, this.isKick = false}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode _phoneFocus = FocusNode();
  FocusNode _pwdFocus = FocusNode();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  bool _isShowPhoneClear = false;

  String _code = '86';

  bool _showPwd = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    String code = await SharedUtil.instance.getString(Keys.phoneCode);
    String phone = await SharedUtil.instance.getString(Keys.phone);
    _code = code ?? '86';
    _phoneController.text = phone ?? '';
    if (widget.isKick) {
      if (Platform.isIOS != null && Platform.isIOS) {
        JPushManager.jpush.deleteAlias();
      } else {
        MobpushPlugin.deleteAlias();
      }
      userApi.logout(context);
    }

    _phoneController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowPhoneClear = _phoneController.text.length > 0;
        });
      }
    });
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.only(bottom: 50.0, top: 30),
      child: Center(
        child: ImageView(
          img: logoImage,
          width: 84.0,
          height: 84.0,
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 20.0),
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
              textInputAction: TextInputAction.next,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(_pwdFocus),
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

  Widget _buildPwdInput() {
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
              focusNode: _pwdFocus,
              controller: _pwdController,
              style: TextStyles.textF16,
              keyboardType: TextInputType.visiblePassword,
              obscureText: !_showPwd,
              textInputAction: TextInputAction.done,
              onEditingComplete: () => _doLogin(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                ),
                border: InputBorder.none,
                isDense: true,
                hintText: S.of(context).plzEnterPwd,
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
                  img: 'assets/images/eye_${!_showPwd ? 'close' : 'open'}.png'),
            ),
            onTap: () {
              if (mounted) {
                setState(() {
                  _showPwd = !_showPwd;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _doLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());
    String phone = _phoneController.text;
    if (phone.isEmpty) {
      showToast(context, S.of(context).plzEnterPhone);
      return;
    }
    String pwd = _pwdController.text;
    if (pwd.isEmpty) {
      showToast(context, S.of(context).plzEnterPwd);
      return;
    }

    //检测网络
    if (await SharedUtil.instance.getBoolean(Keys.brokenNetwork)) {
      showToast(context, S.of(context).noNetwork);
      return;
    }

    userApi.loginByPwd(context, phone, _code, pwd, (needImprove) async {
      await AESUtils.getSharedSecret();
      Loading.complete();
      if (await PermissionManger.notificationPermission()) {
        routePushAndRemove(needImprove
            ? ImproveDataPage(
                from: 1,
              )
            : RootPage());
      } else {
        routePushAndRemove(needImprove
            ? ImproveDataPage(
                from: 1,
              )
            : RootPage());
      }
    });
  }

  Widget _buildBottom() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
      child: Center(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                routePush(RegisterPage(S.of(context).findPwd, 2))
                    .then((value) => {
                          if (value != null)
                            {
                              _code = value['code'] ?? '86',
                              _phoneController.text = value['phone'] ?? '',
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_pwdController != null) {
                                  _pwdController.clear();
                                }
                              }),
                              if (mounted) {setState(() {})}
                            }
                        });
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(S.of(context).forgotPwd),
              ),
            )
          ],
        ),
      ),
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
          automaticallyImplyLeading: false,
          rightDMActions: [
            Padding(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    routePush(RegisterPage(S.of(context).rigister, 1))
                        .then((value) => {
                              if (value != null)
                                {
                                  _code = value['code'] ?? '86',
                                  _phoneController.text = value['phone'] ?? '',
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (_pwdController != null) {
                                      _pwdController.clear();
                                    }
                                  }),
                                  if (mounted) {setState(() {})}
                                }
                            });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    child: Text(S.of(context).register),
                  ),
                ))
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: winHeight(context) - ScreenData.navigationBarHeight,
            child: Column(
              children: [
                _buildLogo(),
                _buildPhoneInput(),
                _buildPwdInput(),
                buildCommonButton(S.of(context).loginBtn,
                    margin: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      // bottom: 60,
                    ),
                    onPressed: _doLogin),
                Spacer(),
                _buildBottom(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneFocus.dispose();
    _pwdFocus.dispose();
    _phoneController.dispose();
    _pwdController.dispose();
    super.dispose();
  }
}
