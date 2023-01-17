//组织架构第一级列表
class TopDept {
  int id; //部门标识id
  bool manager; //是否是主管
  String name; //部门名称
  int num; //部门人数
  int teamId; //所属团队标识id
  int chatId; //群聊标识id

  TopDept(
      {this.id, this.manager, this.name, this.num, this.teamId, this.chatId});

  TopDept.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    manager = json['manager'];
    name = json['name'];
    num = json['num'];
    teamId = json['teamId'];
    chatId = json['chatId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['manager'] = this.manager;
    data['name'] = this.name;
    data['num'] = this.num;
    data['teamId'] = this.teamId;
    data['chatId'] = this.chatId;
    return data;
  }

  static List<TopDept> listFromJson(List<dynamic> ls) {
    var ret = List<TopDept>();
    for (var obj in ls) {
      ret.add(TopDept.fromJson(obj));
    }
    return ret;
  }
}
