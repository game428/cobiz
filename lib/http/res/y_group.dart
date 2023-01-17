class GroupBase {
  int id; // 群标识
  String name; // 群名称
  List<dynamic> avatar; // 群头像
  int num; // 当前群成员数

  GroupBase.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        avatar = map['avatar'],
        num = map['num'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    data['num'] = num;
    return data;
  }
}

class GroupInfo {
  int type; // 0.普通 1.团队 2.小组 3.部门
  int teamId; // 团队标识id
  int thirdId; // 小组/部门标识id
  int role; // 0.成员 1.管理员 2.创建者 3.部门主管
  int id;
  int creator;
  String name; // 群名称
  List<dynamic> avatars; // 群头像
  String notice; // 公告
  int noticeAt; // 公告时间
  int num;
  String nickname; // 在群里的昵称
  bool saved; // 是否已保存
  bool dnd; // 是否免打扰
  int burn;
  List<GroupMember> members;

  GroupInfo.fromJsonMap(Map<String, dynamic> map)
      : type = map['type'],
        teamId = map['teamId'],
        thirdId = map['thirdId'],
        role = map['role'],
        id = map['id'],
        creator = map['creator'],
        name = map['name'],
        avatars = map['avatars'],
        notice = map['notice'],
        noticeAt = map['noticeAt'],
        num = map['num'],
        nickname = map['nickname'],
        saved = map['saved'],
        dnd = map['dnd'],
        burn = map['burn'],
        members = GroupMember.listFromJson(map['members']);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = type;
    data['teamId'] = teamId;
    data['thirdId'] = thirdId;
    data['role'] = role;
    data['id'] = id;
    data['creator'] = creator;
    data['name'] = name;
    data['avatars'] = avatars;
    data['notice'] = notice;
    data['noticeAt'] = noticeAt;
    data['num'] = num;
    data['nickname'] = nickname;
    data['saved'] = saved;
    data['dnd'] = dnd;
    data['burn'] = burn;
    data['members'] = members;
    return data;
  }
}

class GroupMember {
  int userId;
  String nickname;
  String avatar;
  bool creator;

  GroupMember.fromJsonMap(Map<String, dynamic> map)
      : userId = map['userId'],
        nickname = map['nickname'],
        avatar = map['avatar'],
        creator = map['creator'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['nickname'] = nickname;
    data['avatar'] = avatar;
    data['creator'] = creator;
    return data;
  }

  static List<GroupMember> listFromJson(List<dynamic> ls) {
    var ret = List<GroupMember>();
    for (var obj in ls) {
      ret.add(GroupMember.fromJsonMap(obj));
    }
    return ret;
  }
}

class MyGroup {
  int groupId;
  String name; // 群名称
  List<dynamic> avatars; // 群头像
  int num;
  int gtype;
  int teamId;

  MyGroup.fromJsonMap(Map<String, dynamic> map)
      : groupId = map['groupId'],
        name = map['name'],
        avatars = map['avatars'],
        num = map['num'],
        gtype = map['gtype'],
        teamId = map['teamId'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupId'] = groupId;
    data['name'] = name;
    data['avatars'] = avatars;
    data['num'] = num;
    data['gtype'] = gtype;
    data['teamId'] = teamId;
    return data;
  }

  static List<MyGroup> listFromJson(List<dynamic> ls) {
    var ret = List<MyGroup>();
    for (var obj in ls) {
      ret.add(MyGroup.fromJsonMap(obj));
    }
    return ret;
  }
}
