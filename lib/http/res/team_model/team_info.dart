class TeamInfo {
  int id; // 团队标识id
  String name; //名称
  String icon; //图标
  String code; //编码
  String shorter; // 简称
  String intro; //简介
  int type; //类型
  int creator; //创建者标识
  String creatorName; //创建者名字
  int numB; //总人数
  Map<String, dynamic> managers; //管理员信息(key: 标识id, value: 名称)
  int chatId; //团队聊天

  TeamInfo(
      {this.id,
      this.name,
      this.icon,
      this.code,
      this.shorter,
      this.intro,
      this.type,
      this.creator,
      this.creatorName,
      this.numB,
      this.managers,
      this.chatId});

  TeamInfo.fromJsonMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        icon = map['icon'],
        code = map['code'],
        shorter = map['shorter'],
        intro = map['intro'],
        type = map['type'],
        creator = map['creator'],
        creatorName = map['creatorName'],
        numB = map['num'],
        managers = map['managers'],
        chatId = map['chatId'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    data['code'] = code;
    data['shorter'] = shorter;
    data['intro'] = intro;
    data['type'] = type;
    data['creator'] = creator;
    data['creatorName'] = creatorName;
    data['num'] = numB;
    data['managers'] = managers;
    data['chatId'] = chatId;
    return data;
  }
}
