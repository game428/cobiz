//单聊群聊线上消息公用
class HistoryModel {
  String avatar; //头像
  int burn; //消息焚毁
  int from; //发送者
  String id; //消息id
  String msg; //消息内容
  int mtype; //消息类型
  String name; //名字
  int rTime; //已读时间
  int time; //时间
  int to; //接收者

  HistoryModel(
      {this.avatar,
      this.burn,
      this.from,
      this.id,
      this.msg,
      this.mtype,
      this.name,
      this.rTime,
      this.time,
      this.to});

  static List<HistoryModel> listFromJson(List<dynamic> ls) {
    var ret = List<HistoryModel>();
    for (var obj in ls) {
      ret.add(HistoryModel.fromJson(obj));
    }
    return ret;
  }

  HistoryModel.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    burn = json['burn'];
    from = json['from'];
    id = json['id'];
    msg = json['msg'];
    mtype = json['mtype'];
    name = json['name'];
    rTime = json['rtime'];
    time = json['time'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['burn'] = this.burn;
    data['from'] = this.from;
    data['id'] = this.id;
    data['msg'] = this.msg;
    data['mtype'] = this.mtype;
    data['name'] = this.name;
    data['rtime'] = this.rTime;
    data['time'] = this.time;
    data['to'] = this.to;
    return data;
  }
}
