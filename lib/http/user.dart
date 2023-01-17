import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/dialog/loading_dialog.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';

import 'req.dart';
import 'res/res.dart';

/// 登录
Future<void> loginByPhone(BuildContext context, String phone, String code,
    String captcha, Function callback) async {
  Loading.before(context: context);
  var str = await Req.post(API.loginUrl,
      params: {
        'phone': phone,
        'code': code,
        'captcha': captcha,
        'platform': isIOS() ? 2 : (isAndroid() ? 1 : 0)
      },
      headers: API.jsonHeader());
  if (!strNoEmpty(str)) {
    Loading.complete();
    showToast(
        context, '${S.of(context).loginFail}, ${S.of(context).tryAgainLater}');
    return;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    String token = res.data['token'];
    final model = Provider.of<GlobalModel>(context, listen: false);
    model.token = token;
    model.goToLogin = false;
    await SharedUtil.instance.saveString(Keys.token, token);

    User user = await getUserInfo();
    Loading.complete();
    if (user == null) {
      showToast(context, S.of(context).tryAgainLater);
    } else {
      model.userInfo = user;
      await SharedUtil.instance
          .saveString(Keys.userInfo, json.encode(user.toJson()));
      model.refresh();
      callback(res.data['register'] || !strNoEmpty(user.nickname));
    }
  } else {
    Loading.complete();
    showToast(
        context,
        res.msg ??
            '${S.of(context).loginFail}, ${S.of(context).tryAgainLater}');
  }
}

/// 密码登录
/*
 * phone       String      手机号码 (必传)
 * code        String      手机号码国际编码 (必传)
 * passwd      String      密码(md5加密) (必传)
 * data: {
 *    token       String
 *    register    bool
 * }
 */
Future<void> loginByPwd(BuildContext context, String phone, String code,
    String passwd, Function callback) async {
  Loading.before(context: context);
  var content = new Utf8Encoder().convert(passwd);
  var str = await Req.post(API.pwdLoginUrl,
      params: {
        'phone': phone,
        'code': code,
        'passwd': md5.convert(content).toString()
      },
      headers: API.jsonHeader());
  if (!strNoEmpty(str)) {
    Loading.complete();
    showToast(
        context, '${S.of(context).loginFail}, ${S.of(context).tryAgainLater}');
    return;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    String token = res.data['token'];
    final model = Provider.of<GlobalModel>(context, listen: false);
    model.token = token;
    model.goToLogin = false;
    await SharedUtil.instance.saveString(Keys.token, token);

    User user = await getUserInfo();
    if (user == null) {
      Loading.complete();
      showToast(context, S.of(context).tryAgainLater);
    } else {
      model.userInfo = user;
      await SharedUtil.instance
          .saveString(Keys.userInfo, json.encode(user.toJson()));
      await SharedUtil.instance.saveString(Keys.phoneCode, code);
      await SharedUtil.instance.saveString(Keys.phone, phone);
      model.refresh();
      callback(res.data['register'] || !strNoEmpty(user.nickname));
    }
  } else {
    Loading.complete();
    showToast(
        context,
        res?.msg ??
            '${S.of(context).loginFail}, ${S.of(context).tryAgainLater}');
  }
}

/// 注册/忘记密码
/*
 * phone       String      手机号码 (必传)
 * code        String      手机号码国际编码 (必传)
 * captcha     String      短信验证码 (必传)
 * passwd      String      密码(md5加密) (必传)
 * type        int         操作类型: 1.注册 2.忘记密码 (必传)
 * platform    int         设备平台: 1.安卓 2.IOS (当type=1时必传, type=2时不传)
 * data: {
 *    token       String
 *    register    bool
 * }
 */
Future<bool> register(BuildContext context, String phone, String code,
    String passwd, String captcha, int type) async {
  var content = new Utf8Encoder().convert(passwd);
  var str = await Req.post(API.registerUrl,
      params: {
        'phone': phone,
        'code': code,
        'passwd': md5.convert(content).toString(),
        'captcha': captcha,
        'type': type,
        'platform': isIOS() ? 2 : (isAndroid() ? 1 : 0)
      },
      headers: API.jsonHeader());
  if (!strNoEmpty(str)) {
    if (type == 1) {
      showToast(context, S.of(context).registerFail);
    } else {
      showToast(context, S.of(context).checkData);
    }
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return true;
  } else {
    showToast(
        context,
        res?.msg ??
            '${type == 1 ? S.of(context).registerFail : S.of(context).retrieveFail}, ${S.of(context).tryAgainLater}');
  }
  return false;
}

Future<String> sendVerifyCode(
    BuildContext context, String phone, String code) async {
  var str = await Req.post(API.sendVerifyCode1Url,
      params: {'phone': phone, 'code': code, 'source': 1},
      headers: API.jsonHeader());
  if (!strNoEmpty(str)) {
    showToast(context, S.of(context).sendFail);
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    var data = res.data;
    if (data != null) {
      return data;
    }
    return '';
  } else {
    showToast(context,
        res.msg ?? '${S.of(context).sendFail}, ${S.of(context).tryAgainLater}');
  }
  return null;
}

Future<void> sendVerifyCode2(BuildContext context, Function callback) async {
  var str = await Req.post(API.sendVerifyCode2Url, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    showToast(context, S.of(context).sendFail);
    return;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    callback();
    var data = res.data;
    if (data != null) {
      showToast(context, '验证码: $data');
    }
  } else {
    showToast(context,
        res.msg ?? '${S.of(context).sendFail}, ${S.of(context).tryAgainLater}');
  }
}

Future<RouteInfo> getRouteInfo() async {
  var str = await Req.post(API.routeUrl,
      params: {'source': 1}, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 3) {
    throw 'unlogin';
  } else if (res.code != 0) {
    throw res.msg;
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return RouteInfo.fromJsonMap(res.data);
  } else {
    return RouteInfo.fromJsonMap(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 获取指定用户的基础信息, 如果查询自己则 userId 不用传值
Future<dynamic> getUserInfo({int userId}) async {
  var str = await Req.post('${API.userInfoUrl}${userId ?? 0}',
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '') {
    return null;
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return ((userId ?? 0) < 1 || (userId ?? 0) == API.userInfo.id)
        ? User.fromJsonMap(res.data)
        : UserInfo.fromJsonMap(res.data);
  } else {
    return ((userId ?? 0) < 1 || (userId ?? 0) == API.userInfo.id)
        ? User.fromJsonMap(json.decode(AESUtils.decrypt(res.data)))
        : UserInfo.fromJsonMap(json.decode(AESUtils.decrypt(res.data)));
  }
}

/// 通过手机号查询用户
Future<int> getUserByPhone(String phone) async {
  var str = await Req.post2(API.findPhoneUrl,
      params: AESUtils.encrypt(json.encode({'phone': phone})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0 || res.data == null || res.data.toString().trim() == '') {
    return null;
  }
  if (res.data.toString().startsWith('{') &&
      res.data.toString().endsWith('}')) {
    return res.data['userId'];
  } else {
    return json.decode(AESUtils.decrypt(res.data))['userId'];
  }
}

/// 修改个人信息
/// 返回: 0.成功 1.失败 2.昵称不能为空 3.数据异常 4.绑定邀请码失败
Future<int> modifyInfo(BuildContext context, String nickname,
    {String avatar,
    int gender = 0,
    String birthday,
    int area1 = 0,
    int area2 = 0,
    int area3 = 0,
    String mark,
    String inviteCode}) async {
  var str = await Req.post2(API.userModifyUrl,
      params: AESUtils.encrypt(json.encode({
        'nickname': nickname,
        'avatar': avatar,
        'gender': gender,
        'birthday': birthday,
        'area1': area1,
        'area2': area2,
        'area3': area3,
        'mark': mark,
        'inviteCode': inviteCode
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 1;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    User user = await getUserInfo();
    if (user != null) {
      final model = Provider.of<GlobalModel>(context, listen: false);
      model.userInfo = user;
      await SharedUtil.instance
          .saveString(Keys.userInfo, json.encode(user.toJson()));
      model.refresh();
    }
  }
  return res.code;
}

/// 修改个人设置
Future<void> modifySettings(BuildContext context, bool newNotice,
    bool noticeDetail, bool voiceOpen, bool vibration) async {
  var str = await Req.post2(API.settingsModifyUrl,
      params: AESUtils.encrypt(json.encode({
        'newNotice': newNotice,
        'noticeDetail': noticeDetail,
        'voiceOpen': voiceOpen,
        'vibration': vibration
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return;
  }
  final model = Provider.of<GlobalModel>(context, listen: false);
  User user = model.userInfo;
  user.newNotice = newNotice;
  user.noticeDetail = noticeDetail;
  user.voiceOpen = voiceOpen;
  user.vibration = vibration;
  model.userInfo = user;
  await SharedUtil.instance
      .saveString(Keys.userInfo, json.encode(model.userInfo.toJson()));
  model.refresh();
}

/// 申请官方认证
/// 返回: 0.成功 1.申请失败, 请稍候重试 2.两个邀请码不能是同一个经纪人
/// 3.邀请码1不是经纪人 4.邀请码2不是经纪人
Future<int> applyAuth(BuildContext context, String code1, String code2) async {
  var str = await Req.post2(API.applyAuthUrl,
      params: AESUtils.encrypt(json.encode({'code1': code1, 'code2': code2})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 1;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    final model = Provider.of<GlobalModel>(context, listen: false);
    model.userInfo.broker = true;
    await SharedUtil.instance
        .saveString(Keys.userInfo, json.encode(model.userInfo.toJson()));
    model.refresh();
  }
  return res.code;
}

/// 提交意见反馈
/// content: 文本内容
/// assets: 图片资源数组字符串
Future<bool> subFeedback(String content, String assets) async {
  var str = await Req.post2(API.subFeedbackUrl,
      params: AESUtils.encrypt(json.encode({
        'content': content,
        'assets': assets,
        'source': 1,
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 提交投诉信息
/// type: 类型 0.其他 1.发布不适当内容 2.存在欺诈骗钱行为 3.账号可能被盗用 4.存在侵权行为 5.发布伪冒品 6.冒充他人
/// from: 来源 1.用户 2.群聊
/// targetId: 目标id(from=1则传被投诉的用户id, from=2则传被投诉的群id)
/// content: 文本内容
/// assets: 图片资源数组字符串
Future<bool> subComplain(
    int type, int from, int targetId, String content, String assets) async {
  var str = await Req.post2(API.subComplainUrl,
      params: AESUtils.encrypt(json.encode({
        'type': type,
        'from': from,
        'targetId': targetId,
        'content': content,
        'assets': assets,
        'source': 1
      })),
      headers: API.tokenHeader(isJson: true));
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code == 0;
}

/// 退出
Future<bool> logout(BuildContext context) async {
  await Req.post(API.logoutUrl, headers: API.tokenHeader());
  WsConnector.disconnect();
  final model = Provider.of<GlobalModel>(context, listen: false);
  model.token = null;
  model.userInfo = null;
  model.goToLogin = true;
  await SharedUtil.instance.remove(Keys.token);
  await SharedUtil.instance.remove(Keys.userInfo);
  model.refresh();
  return true;
}
