class Notice {
  int id;
  String title;
  String name;
  String content;
  int time;

  Notice({this.id, this.title, this.name, this.content, this.time});

  Notice.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    name = json['name'];
    content = json['content'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['name'] = this.name;
    data['content'] = this.content;
    data['time'] = this.time;
    return data;
  }

  static List<Notice> listFromJson(List<dynamic> ls) {
    var ret = List<Notice>();
    for (var obj in ls) {
      ret.add(Notice.fromJson(obj));
    }
    return ret;
  }
}
