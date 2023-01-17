import 'package:cobiz_client/http/res/user.dart';

class API {
  // static const serverUrl = 'http://192.168.1.157:8001/';
  static const serverUrl = 'http://192.168.1.174:8001/';
  // static const serverUrl = 'https://www.yangram.io/';

  static String userToken = '';
  static User userInfo;
  static String qrPrefix = 'https://cobiz.io?qr=';
  static Map<String, String> tokenHeader(
      {Map<String, String> headers, bool isJson}) {
    if (headers == null) {
      headers = Map<String, String>();
    }
    headers['token'] = userToken ?? '';
    if (isJson ?? false) {
      return jsonHeader(headers: headers);
    }
    return headers;
  }

  static Map<String, String> jsonHeader({Map<String, String> headers}) {
    if (headers == null) {
      headers = Map<String, String>();
    }
    headers['content-type'] = 'application/json';
    return headers;
  }

  // 版本检测
  static const versionCheckUrl = serverUrl + 'api/client/check';
  // 验证码登录
  static const loginUrl = serverUrl + 'auth/login';
  // 账号密码登录
  static const pwdLoginUrl = serverUrl + 'auth/signin';
  // 注册
  static const registerUrl = serverUrl + 'auth/signup';
  // 退出
  static const logoutUrl = serverUrl + 'auth/offline';
  // 消息列表同步
  static const syncChannel = serverUrl + 'api/channels/sync';
  // 私聊聊天记录
  static const singleChatHistory = serverUrl + 'api/single/chat/history';
  // 群聊聊天记录
  static const groupChatHistory = serverUrl + 'api/group/chat/history';
  // 删除线上聊天记录
  static const deleteChatHistory = serverUrl + 'api/chats/delete';
  // 发送聊天消息
  static const sendMsgUrl = serverUrl + 'api/msg/send';
  // 通知已读取消息
  static const readMsgUrl = serverUrl + 'api/msg/read';
  // 通过手机号获取验证码
  static const sendVerifyCode1Url = serverUrl + 'api/send/phone/code';
  // 通过token获取验证码
  static const sendVerifyCode2Url = serverUrl + 'api/send/verify/code';
  // 获取路由信息
  static const routeUrl = serverUrl + 'auth/route';
  // 交换密钥
  static const swapCipherUrl = serverUrl + 'api/cipher/swap';
  // 获取用户信息
  static const userInfoUrl = serverUrl + 'api/find/someone/';
  // 通过手机号搜索用户
  static const findPhoneUrl = serverUrl + 'api/find/phone';
  // 修改个人信息
  static const userModifyUrl = serverUrl + 'api/user/modify';
  // 修改个人消息设置
  static const settingsModifyUrl = serverUrl + 'api/notice/settings/modify';
  // 申请认证
  static const applyAuthUrl = serverUrl + 'api/user/auth/apply';
  // 提交意见反馈
  static const subFeedbackUrl = serverUrl + 'api/feedback/submit';
  // 提交投诉信息
  static const subComplainUrl = serverUrl + 'api/complain/submit';
  // 获取协议地址
  static const getAgreementUrl = serverUrl + 'api/agreement/url';
  // 获取七牛上传token
  static const qiniuTokenUrl = serverUrl + 'api/qiniu/token';
  // 获取好友列表
  static const contactsUrl = serverUrl + 'api/contact/all';
  // 添加好友
  static const contactAddUrl = serverUrl + 'api/contact/add';
  // 修改好友信息
  static const contactModifyUrl = serverUrl + 'api/contact/modify';
  // 删除好友
  static const contactDeleteUrl = serverUrl + 'api/contact/delete';
  // 好友申请列表
  static const contactAppliesUrl = serverUrl + 'api/contact/applies';
  // 好友申请处理
  static const contactApplyDealUrl = serverUrl + 'api/contact/apply/deal';
  // 黑名单列表
  static const blacklistsUrl = serverUrl + 'api/blacklist/all';
  // 黑名单处理
  static const blacklistDealUrl = serverUrl + 'api/blacklist/deal';
  // 匹配通讯录
  static const matchContactsUrl = serverUrl + 'api/contacts/match';
  // 获取推广地址
  static const getPromoteUrl = serverUrl + 'api/promote/url';
  // 查询好友焚烧信息
  static const queryUserSetting = serverUrl + 'api/contact/setting';

  ///
  ///群聊
  ///
  // 创建群聊
  static const groupCreateUrl = serverUrl + 'api/group/create';
  // 获取群聊信息
  static const groupInfoUrl = serverUrl + 'api/group/info';
  // 删除并退出群聊
  static const groupLeaveUrl = serverUrl + 'api/group/leave';
  // 邀请或删除群聊成员
  static const groupInviteUrl = serverUrl + 'api/group/invite';
  // 修改群名称
  static const groupNameModifyUrl = serverUrl + 'api/group/name/modify';
  // 修改群公告
  static const groupNoticeModifyUrl = serverUrl + 'api/group/notice/modify';
  // 修改群聊设置
  static const groupMemberModifyUrl = serverUrl + 'api/group/member/modify';
  // 查询我的群聊列表
  static const groupKeepingAllUrl = serverUrl + 'api/group/keeping/all';
  // 删除我的群聊
  static const groupDelKeepingUrl = serverUrl + 'api/group/keeping/delete';
  // 查询群聊焚烧信息
  static const queryGroupSetting = serverUrl + 'api/group/setting';
}
