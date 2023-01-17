class User {
  int id; // 标识
  String code; // 号码国家编码
  String phone; // 手机号码
  String nickname; // 昵称
  String avatar; // 头像
  int gender; // 性别
  int birthday; // 生日
  double longitude; // 经度
  double latitude; // 纬度
  int area1; // 国家
  int area2; // 省份
  int area3; // 城市
  int auditStatus; // 实名认证状态
  String mark; // 个性签名
  int gold; // 金币余额
  bool broker; // 是否经纪人
  bool invited; // 是否被邀请
  String inviteCode; // 邀请码
  bool newNotice; // 是否接收新消息通知
  bool noticeDetail; // 收到通知时是否显示详情
  bool voiceOpen; // 运行时收到消息是否有声音
  bool vibration; // 运行时收到消息是否振动

  User.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        code = map['code'],
        phone = map['phone'],
        nickname = map['nickname'],
        avatar = map['avatar'],
        gender = map['gender'],
        birthday = map['birthday'],
        longitude = map['longitude'],
        latitude = map['latitude'],
        area1 = map['area1'],
        area2 = map['area2'],
        area3 = map['area3'],
        auditStatus = map['auditStatus'],
        mark = map['mark'],
        gold = map['gold'],
        broker = map['broker'],
        invited = map['invited'],
        inviteCode = map['inviteCode'],
        newNotice = map['newNotice'],
        noticeDetail = map['noticeDetail'],
        voiceOpen = map['voiceOpen'],
        vibration = map['vibration'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['code'] = code;
    data['phone'] = phone;
    data['nickname'] = nickname;
    data['avatar'] = avatar;
    data['gender'] = gender;
    data['birthday'] = birthday;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['area1'] = area1;
    data['area2'] = area2;
    data['area3'] = area3;
    data['auditStatus'] = auditStatus;
    data['mark'] = mark;
    data['gold'] = gold;
    data['broker'] = broker;
    data['invited'] = invited;
    data['inviteCode'] = inviteCode;
    data['newNotice'] = newNotice;
    data['noticeDetail'] = noticeDetail;
    data['voiceOpen'] = voiceOpen;
    data['vibration'] = vibration;
    return data;
  }

  static List<User> listFromJson(List<dynamic> ls) {
    var ret = List<User>();
    for (var obj in ls) {
      ret.add(User.fromJsonMap(obj));
    }
    return ret;
  }
}

class RouteInfo {
  String address;
  int port;

  RouteInfo.fromJsonMap(Map<String, dynamic> map)
      : address = map['address'],
        port = map['port'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = address;
    data['port'] = port;
    return data;
  }
}

class UserInfo {
  int id;
  String nickname; // 昵称
  String avatar; // 头像
  int gender; // 0.无 1.男 2.女
  int birthday; // 生日
  int area1; // 国
  int area2; // 省
  int area3; // 城
  String mark; // 个性签名
  bool broker; // 是否经纪人
  bool friend; // 是否好友
  String name; // 好友备注名
  bool blacklist; // 是否黑名单
  bool topChat; // 是否聊天置顶
  bool dnd; // 是否免打扰
  int burn; // 阅后即焚设置(0.关闭 1.即刻焚毁 2.20秒 3.1分钟 4.5分钟 5.1小时 6.24小时)

  UserInfo.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        nickname = map['nickname'],
        avatar = map['avatar'],
        gender = map['gender'],
        birthday = map['birthday'],
        area1 = map['area1'],
        area2 = map['area2'],
        area3 = map['area3'],
        mark = map['mark'],
        broker = map['broker'],
        friend = map['friend'],
        name = map['name'],
        blacklist = map['blacklist'],
        topChat = map['topChat'],
        dnd = map['dnd'],
        burn = map['burn'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nickname'] = nickname;
    data['avatar'] = avatar;
    data['gender'] = gender;
    data['birthday'] = birthday;
    data['area1'] = area1;
    data['area2'] = area2;
    data['area3'] = area3;
    data['mark'] = mark;
    data['broker'] = broker;
    data['friend'] = friend;
    data['name'] = name;
    data['blacklist'] = blacklist;
    data['topChat'] = topChat;
    data['dnd'] = dnd;
    data['burn'] = burn;
    return data;
  }
}
