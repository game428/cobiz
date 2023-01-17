class TeamMember {
  int teamId; //团队id 应该存的字段 目前没有
  int userId; // 成员标识id
  String name; //名称
  String avatar; //头像
  int manager; // 角色: 0.成员 1.管理员 2.创建者
  int leader; // 是否是某部门主管(0.否 1.是)
  String remark; // 备注(type=1时显示部门信息)

  TeamMember(
      {this.teamId,
      this.userId,
      this.name,
      this.avatar,
      this.manager,
      this.leader,
      this.remark});

  TeamMember.fromJsonMap(Map<String, dynamic> map)
      : teamId = map['teamId'],
        userId = map['id'],
        name = map['name'],
        avatar = map['avatar'],
        manager = map['manager'],
        leader = map['leader'],
        remark = map['remark'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['teamId'] = teamId;
    data['id'] = userId;
    data['name'] = name;
    data['avatar'] = avatar;
    data['manager'] = manager;
    data['leader'] = leader;
    data['remark'] = remark;
    return data;
  }

  static List<TeamMember> listFromJson(List<dynamic> ls) {
    var ret = List<TeamMember>();
    for (var obj in ls) {
      ret.add(TeamMember.fromJsonMap(obj));
    }
    return ret;
  }
}
