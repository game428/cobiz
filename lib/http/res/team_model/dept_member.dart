class DeptAndMember {
  List<Members> members;
  List<Depts> depts;

  DeptAndMember({this.members, this.depts});

  DeptAndMember.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = new List<Members>();
      json['members'].forEach((v) {
        members.add(new Members.fromJson(v));
      });
    }
    if (json['depts'] != null) {
      depts = new List<Depts>();
      json['depts'].forEach((v) {
        depts.add(new Depts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    if (this.depts != null) {
      data['depts'] = this.depts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Members {
  String avatar; //头像
  int id; //成员标识id
  int leader; //是否是某部门主管(0.否 1.是)
  int manager; //角色: 0.成员 1.管理员 2.创建者
  String name;
  String remark; //备注(type=1时显示部门信息)
  int teamId; //所属团队标识id

  Members(
      {this.avatar,
      this.id,
      this.leader,
      this.manager,
      this.name,
      this.remark,
      this.teamId});

  Members.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    id = json['id'];
    leader = json['leader'];
    manager = json['manager'];
    name = json['name'];
    remark = json['remark'];
    teamId = json['teamId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['id'] = this.id;
    data['leader'] = this.leader;
    data['manager'] = this.manager;
    data['name'] = this.name;
    data['remark'] = this.remark;
    data['teamId'] = this.teamId;
    return data;
  }
}

class Depts {
  List<Depts> childs; //子部门
  int id; //部门id
  int managerId; //主管
  List<int> memberIds; //成员
  String name; //部门名字
  int pid; //上级部门id
  int teamId; //团队id
  int chatId; //部门聊天需要的id

  Depts(
      {this.childs,
      this.id,
      this.managerId,
      this.memberIds,
      this.name,
      this.pid,
      this.teamId,
      this.chatId});

  Depts.fromJson(Map<String, dynamic> json) {
    if (json['childs'] != null) {
      childs = new List<Depts>();
      json['childs'].forEach((v) {
        childs.add(new Depts.fromJson(v));
      });
    }
    id = json['id'];
    managerId = json['managerId'];
    memberIds = json['memberIds'].cast<int>();
    name = json['name'];
    pid = json['pid'];
    teamId = json['teamId'];
    chatId = json['chatId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.childs != null) {
      data['childs'] = this.childs.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['managerId'] = this.managerId;
    data['memberIds'] = this.memberIds;
    data['name'] = this.name;
    data['pid'] = this.pid;
    data['teamId'] = this.teamId;
    data['chatId'] = this.chatId;
    return data;
  }
}
