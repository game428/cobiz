enum ActionValue {
  LOGIN, // 登录
  MSG, // 业务消息
  PING, // 心跳
  READ, // 已读
  KICK, // 踢下线
  ADDED, // 被添加好友
  AGREE, // 被同意添加申请
  APPLYJOINTEAM, //申请加入团队
  WORK, //工作通知
  TEAMUPDATE, //团队更新（未用）
  SYNCHANNEL //消息列表同步
}

enum ChatType {
  SINGLE, // 私聊
  GROUP, // 群聊
  SYSTEM, //系统消息
}

enum MediaType {
  TEXT, // 文本
  VOICE, // 语音
  PICTURE, // 图片
  VIDEO, // 视频
  CARD, // 名片
  // REDBAG, // 红包
  // NOTE, // 笔记
}

const EVENT_NEW_CONTACT_APPLY = "new_contact_apply"; // 新好友申请消息
const EVENT_UPDATE_CONTACT_LIST =
    "update_contact_list"; // 更新好友列表 增加人 或者 更新头像信息 都一样的
const EVENT_UPDATE_MSG_STATE = "update_msg_state"; // 重新打开的时候，修改阅读状态
const EVENT_UPDATE_MSG_UNREAD = "update_msg_unread"; // 底部是否有红色点点

const EVENT_UPDATE_TEAM_GROUP = "update_team_group"; // 小组更新

const EVENT_SOCKET_IS_RECONNECTION = "socket_is_reconnection"; // SOCKET 是否重连

const EVENT_UPDATE_TEAM_JOIN = "update_team_join"; // 有人申请加入团队

const EVENT_UPDATE_TEAM = "update_team"; // 申请加入团队被同意，刷新团队

const EVENT_UPDATE_WORK = "update_work"; // 申请加入团队被同意，刷新团队

const EVENT_HTTP_FORWARD = "http_froward"; //网址页面转发监听

const EVENT_WAKE_IN_BACKGROUND = "wake_in_background"; //从后台唤醒

const EVENT_ENTER_THE_BACKGROUND = "enter_the_background"; //进入后台

const EVENT_VOICE_ONTOUCH = "voice_on_touch"; //语音点击

const EVENT_VOICE_ONLISTEN = "voice_on_listen"; //语音监听回调

const EVENT_FONT_SIZE = "font_size"; //字体大小
