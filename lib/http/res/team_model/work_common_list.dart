/// 工作四个列表通用
class WorkCommonListItem {
  int beginAt;
  int endAt;
  int id;
  String issuer;
  int leaveType;
  int state;
  int time;
  String title;
  int type;
  String content;
  double money;
  String unit;
  int read;

  WorkCommonListItem({
    this.beginAt,
    this.endAt,
    this.id,
    this.issuer,
    this.leaveType,
    this.state,
    this.time,
    this.title,
    this.type,
    this.content,
    this.money,
    this.unit,
    this.read,
  });

  WorkCommonListItem.fromJson(Map<String, dynamic> json) {
    beginAt = json['beginAt'];
    endAt = json['endAt'];
    id = json['id'];
    issuer = json['issuer'];
    leaveType = json['leaveType'];
    state = json['state'];
    time = json['time'];
    title = json['title'];
    type = json['type'];
    content = json['content'];
    money = json['money'];
    unit = json['unit'];
    read = json['read'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['beginAt'] = this.beginAt;
    data['endAt'] = this.endAt;
    data['id'] = this.id;
    data['issuer'] = this.issuer;
    data['leaveType'] = this.leaveType;
    data['state'] = this.state;
    data['time'] = this.time;
    data['title'] = this.title;
    data['type'] = this.type;
    data['content'] = this.content;
    data['money'] = this.money;
    data['unit'] = this.unit;
    data['read'] = this.read;
    return data;
  }

  static List<WorkCommonListItem> listFromJson(List<dynamic> ls) {
    var ret = List<WorkCommonListItem>();
    for (var obj in ls) {
      ret.add(WorkCommonListItem.fromJson(obj));
    }
    return ret;
  }
}
