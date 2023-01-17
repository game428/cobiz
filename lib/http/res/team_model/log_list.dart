class LogList {
  String finished;
  int id;
  String issuer;
  String needed;
  String pending;
  int time;
  int type;

  LogList(
      {this.finished,
      this.id,
      this.issuer,
      this.needed,
      this.pending,
      this.time,
      this.type});

  LogList.fromJson(Map<String, dynamic> json) {
    finished = json['finished'];
    id = json['id'];
    issuer = json['issuer'];
    needed = json['needed'];
    pending = json['pending'];
    time = json['time'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['finished'] = this.finished;
    data['id'] = this.id;
    data['issuer'] = this.issuer;
    data['needed'] = this.needed;
    data['pending'] = this.pending;
    data['time'] = this.time;
    data['type'] = this.type;
    return data;
  }

  static List<LogList> listFromJson(List<dynamic> ls) {
    var ret = List<LogList>();
    for (var obj in ls) {
      ret.add(LogList.fromJson(obj));
    }
    return ret;
  }
}