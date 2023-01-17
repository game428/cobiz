import 'package:flutter/foundation.dart';

//团队
/*
  id          long    团队标识id
  name        String  团队名称
  icon        String  图标
  manager     int     角色: 0.成员 1.管理员 2.创建者
 */
class TeamStore {
  int id;
  String name;
  String icon;
  int manager;

  TeamStore(this.id, this.name, this.icon, this.manager);

  TeamStore.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        icon = map['icon'],
        manager = map['manager'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    data['manager'] = manager;
    return data;
  }

  static List<TeamStore> listFromJson(List<dynamic> ls) {
    var ret = List<TeamStore>();
    for (var obj in ls) {
      ret.add(TeamStore.fromJsonMap(obj));
    }
    return ret;
  }
}

// //小组
// class GroupStore {
//   String id;
//   String name;
//   String creatorId;

//   GroupStore(this.id, this.name, this.creatorId);

//   GroupStore.fromJsonMap(Map<String, dynamic> map)
//       : id = map['id'],
//         name = map['display_name'],
//         creatorId = map['creator_id'];

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = id;
//     data['display_name'] = name;
//     data['creator_id'] = creatorId;
//     return data;
//   }
// }

//部门
class DeptStore {
  String id;
  String pid;
  String mid;
  String name;

  DeptStore(this.id, this.pid, this.mid, this.name);

  DeptStore.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        pid = map['parent_id'],
        mid = map['master_id'],
        name = map['name'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['parent_id'] = pid;
    data['master_id'] = mid;
    data['name'] = name;
    return data;
  }
}

//成员
class MemberStore {
  int tid; //团队id
  int uid; //用户id
  String name;
  String nickname;
  String lastName;
  String username;
  String deptId; //部门id
  String deptName;

  MemberStore(this.tid, this.uid, this.name, this.nickname, this.lastName,
      this.username, this.deptId, this.deptName);

  MemberStore.fromJsonMap(Map<String, dynamic> map)
      : tid = map['team_id'],
        uid = map['user_id'],
        name = map['name'],
        nickname = map['nickname'],
        lastName = map['last_name'],
        username = map['username'],
        deptId = map['dept_id'],
        deptName = map['dept_name'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['team_id'] = tid;
    data['user_id'] = uid;
    data['name'] = name;
    data['nickname'] = nickname;
    data['last_name'] = lastName;
    data['username'] = username;
    data['dept_id'] = deptId;
    data['dept_name'] = deptName;
    return data;
  }
}

//联系人
class ContactStore {
  int uid;
  String name;
  String avatar;
  int status;
  int top; // 是否置顶(0.否 1.是)
  int dnd; // 是否免打扰(0.否 1.是)
  int burn; // 阅后即焚设置(0.关闭 1.即刻焚毁 2.20秒 3.1分钟 4.5分钟 5.1小时 6.24小时)

  ContactStore(this.uid, this.name, this.avatar, this.status, this.top,
      this.dnd, this.burn);

  ContactStore.fromJsonMap(Map<String, dynamic> map)
      : uid = map['userId'],
        name = map['name'],
        avatar = map['avatarUrl'],
        status = map['status'],
        top = map['top'],
        dnd = map['dnd'],
        burn = map['burn'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = uid;
    data['name'] = name;
    data['avatarUrl'] = avatar;
    data['status'] = status;
    data['top'] = top;
    data['dnd'] = dnd;
    data['burn'] = burn;
    return data;
  }

  static List<ContactStore> listFromJson(List<dynamic> ls) {
    var ret = List<ContactStore>();
    for (var obj in ls) {
      ret.add(ContactStore.fromJsonMap(obj));
    }
    return ret;
  }
}

//工作通知消息
class WorkMsgStore {
  String logoId; //拼接 的唯一id mode_$mode_logoid_$logoid
  int id; //标识id
  int mode;
  int type;
  int teamId;
  int issuer;
  String name;

  int leaveType;
  int beginAt;
  int endAt;

  int state;
  String title;
  String content;

  double money;
  String unit;

  String finished;
  String pending;
  String needed;

  String reviewer; //日志评论者
  int time; // 日志发布时间(毫秒数)
  int sendTime;

  WorkMsgStore(
    this.id,
    this.mode, {
    this.beginAt,
    this.content,
    this.endAt,
    this.finished,
    this.logoId,
    this.issuer,
    this.leaveType,
    this.money,
    this.name,
    this.needed,
    this.pending,
    this.reviewer,
    this.state,
    this.teamId,
    this.time,
    this.title,
    this.type,
    this.unit,
    this.sendTime,
  });

  WorkMsgStore.fromJsonMap(Map<String, dynamic> map) {
    logoId = map['logoId'];
    id = map['id'];
    mode = map['mode'];
    type = map['type'];
    teamId = map['teamId'];
    issuer = map['issuer'];
    name = map['name'];
    leaveType = map['leaveType'];
    beginAt = map['beginAt'];
    endAt = map['endAt'];
    state = map['state'];
    title = map['title'];
    content = map['content'];
    money = map['money'];
    unit = map['unit'];
    finished = map['finished'];
    pending = map['pending'];
    needed = map['needed'];
    reviewer = map['reviewer'];
    time = map['time'];
    sendTime = map['sendTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logoId'] = logoId;
    data['id'] = id;
    data['mode'] = mode;
    data['type'] = type;
    data['teamId'] = teamId;
    data['issuer'] = issuer;
    data['name'] = name;
    data['leaveType'] = leaveType;
    data['beginAt'] = beginAt;
    data['endAt'] = endAt;
    data['state'] = state;
    data['title'] = title;
    data['content'] = content;
    data['money'] = money;
    data['unit'] = unit;
    data['finished'] = finished;
    data['pending'] = pending;
    data['needed'] = needed;
    data['reviewer'] = reviewer;
    data['time'] = time;
    data['sendTime'] = sendTime;
    return data;
  }
}

//消息
class ChatStore {
  String id;
  int type; // 1.私聊 2.群聊
  int sender; // 发送者
  int receiver; // 接收者
  String name; // 发送者昵称
  String avatar; // 发送者头像
  /*
   * 消息类型
   * 1: 文本，2：语音，3：图片，4：视频，5：名片, 8: 团队公告 9：工作通知 11.删除消息
   * 100: 新建群聊
   * 101：邀请进群推送，102：退群推送，103：被移除群推送
   * 104：群信息更新（如删除群成员，或群成员修改头像昵称）
   * 105：群公告，106：已被对方拉黑，201：添加好友推送
   * 108：团员邀请好友加入团队或部门
   * 301: 文本草稿缓存
   */
  int mtype;
  String msg; // 消息内容
  int state; // 状态: -1.发送中 0.未成功 1.已发送 2.对方已读
  int time; // 发送时间

  int burn; //阅后焚烧
  int readTime; //已读时间
  bool isReadVoice; //语音是否已读

  ChatStore(
      this.id, this.type, this.sender, this.receiver, this.mtype, this.msg,
      {this.name,
      this.avatar,
      this.state,
      this.time,
      this.burn,
      this.readTime,
      this.isReadVoice = false});

  ChatStore.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        type = map['type'],
        sender = map['sender'],
        receiver = map['receiver'],
        name = map['name'],
        avatar = map['avatar'],
        mtype = map['mtype'],
        msg = map['msg'],
        state = map['state'],
        time = map['time'],
        burn = map['burn'],
        readTime = map['readTime'],
        isReadVoice = map['isReadVoice'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['type'] = type;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['name'] = name;
    data['avatar'] = avatar;
    data['mtype'] = mtype;
    data['msg'] = msg;
    data['state'] = state;
    data['time'] = time;
    data['burn'] = burn;
    data['readTime'] = readTime;
    data['isReadVoice'] = isReadVoice;
    return data;
  }
}

//模拟消息队列
class ChatStoreItem {
  dynamic chat;
  int otherId;
  int chatType; // 单聊 群聊 工作
  ChannelStore channelStore;
  int mtype; //消息类型 如 文本语音
  ChatStoreItem(
      this.chat, this.otherId, this.chatType, this.channelStore, this.mtype);
}

//消息频道列表
class ChannelStore {
  int type; // 1.私聊 2.群聊 3.工作通知
  int id; // 交谈方标识
  String name;
  String avatar;
  String label; // 消息列表显示的最后一条消息的内容
  int unread; // 别人发的消息是否已读（红点）,0：已读，>0：未读
  int lastAt; // 最后更新时间
  int top; // 是否置顶(0.否 1.是)
  int num; // 成员数
  int gType; //0.普通 1.团队 2.小组 3.部门
  int teamId; //!0
  int readUnread; //自己发的消息 对面是否已读 1：未读，2：已读

  ChannelStore(
      {@required this.type,
      @required this.id,
      @required this.name,
      @required this.avatar,
      @required this.label,
      @required this.unread,
      @required this.lastAt,
      @required this.top,
      this.num,
      this.gType,
      this.teamId,
      this.readUnread});

  ChannelStore.fromJsonMap(Map<String, dynamic> map)
      : type = map['type'],
        id = map['id'],
        name = map['name'],
        avatar = map['avatar'],
        label = map['label'],
        unread = map['unread'],
        lastAt = map['lastAt'],
        top = map['top'],
        num = map['num'],
        gType = map['gType'],
        teamId = map['teamId'],
        readUnread = map['readUnread'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = type;
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['label'] = label;
    data['unread'] = unread;
    data['lastAt'] = lastAt;
    data['top'] = top;
    data['num'] = num;
    data['gType'] = gType;
    data['teamId'] = teamId;
    data['readUnread'] = readUnread;
    return data;
  }
}

//黑名单用户
class BlockedStore {
  int userId;
  String name;
  String avatar;

  BlockedStore.fromJsonMap(Map<String, dynamic> map)
      : userId = map['userId'],
        name = map['name'],
        avatar = map['avatar'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['name'] = name;
    data['avatar'] = avatar;
    return data;
  }

  static List<BlockedStore> listFromJson(List<dynamic> ls) {
    var ret = List<BlockedStore>();
    for (var obj in ls) {
      ret.add(BlockedStore.fromJsonMap(obj));
    }
    return ret;
  }
}
