class ContactApply {
  int id;
  int userId;
  String name;
  String avatar;
  String msg;
  int state; // 状态: 0.申请中 1.已通过 2.已拒绝
  int time; // 发起申请的时间

  ContactApply.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        userId = map['userId'],
        name = map['name'],
        avatar = map['avatar'],
        msg = map['msg'],
        state = map['state'],
        time = map['time'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['avatar'] = avatar;
    data['msg'] = msg;
    data['state'] = state;
    data['time'] = time;
    return data;
  }

  static List<ContactApply> listFromJson(List<dynamic> ls) {
    var ret = List<ContactApply>();
    for (var obj in ls) {
      ret.add(ContactApply.fromJsonMap(obj));
    }
    return ret;
  }
}

class ContactMatch {
  int userId; // 用户ID
  String phone; // 手机号
  String name; // 昵称
  String avatar; // 头像
  bool isFriend; // 是否是好友

  ContactMatch.fromJsonMap(Map<String, dynamic> map)
      : userId = map['userId'],
        phone = map['phone'],
        name = map['name'],
        avatar = map['avatar'],
        isFriend = map['friend'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['phone'] = phone;
    data['name'] = name;
    data['avatar'] = avatar;
    data['friend'] = isFriend;
    return data;
  }

  static List<ContactMatch> listFromJson(List<dynamic> ls) {
    if (ls == null) {
      return null;
    }
    var ret = List<ContactMatch>();
    for (var obj in ls) {
      ret.add(ContactMatch.fromJsonMap(obj));
    }
    return ret;
  }
}
