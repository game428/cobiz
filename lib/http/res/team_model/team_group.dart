// 团队小组
class TeamGroup {
  int teamGroupId; //小组标识id
  int teamId; // 所属团队标识id
  int chatId; //聊天标识id
  String name; //小组名称
  bool manager;
  int number;

  TeamGroup(
      {this.teamGroupId,
      this.teamId,
      this.chatId,
      this.name,
      this.manager,
      this.number});

  TeamGroup.fromJsonMap(Map<String, dynamic> map)
      : teamGroupId = map['id'],
        teamId = map['teamId'],
        chatId = map['chatId'],
        name = map['name'],
        manager = map['manager'],
        number = map['num'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = teamGroupId;
    data['teamId'] = teamId;
    data['chatId'] = chatId;
    data['name'] = name;
    data['manager'] = manager;
    data['num'] = number;
    return data;
  }

  static List<TeamGroup> listFromJson(List<dynamic> ls) {
    var ret = List<TeamGroup>();
    for (var obj in ls) {
      ret.add(TeamGroup.fromJsonMap(obj));
    }
    return ret;
  }
}
