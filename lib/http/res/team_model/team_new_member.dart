class TeamNewMember {
  String avatar; //头像
  int id; // 申请ID
  String msg; // 备注信息
  String name; //名称
  int state; // 0.申请中 1.已通过 2.已拒绝
  int userId; // 成员标识id
  int time; // 时间戳

  TeamNewMember({
    this.avatar,
    this.userId,
    this.name,
    this.state,
    this.msg,
  });

  TeamNewMember.fromJson(Map<String, dynamic> map)
      : avatar = map['avatar'],
        id = map['id'],
        msg = map['msg'],
        name = map['name'],
        state = map['state'],
        userId = map['userId'],
        time = map['time'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = avatar;
    data['id'] = id;
    data['msg'] = msg;
    data['name'] = name;
    data['state'] = state;
    data['userId'] = userId;
    data['time'] = time;
    return data;
  }

  static List<TeamNewMember> listFromJson(List<dynamic> ls) {
    var ret = List<TeamNewMember>();
    for (var obj in ls) {
      ret.add(TeamNewMember.fromJson(obj));
    }
    return ret;
  }
}
