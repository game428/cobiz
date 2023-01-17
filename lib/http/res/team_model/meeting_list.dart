class MeetingList {
  int id; // 标识id
  int issuerId; // 发布者标识
  String issuerName; // 发布者名称
  int time; //  发布时间(毫秒数)
  String title; // 标题
  int beginAt; //  会议开始时间
  int endAt; //  会议结束时间

  MeetingList({
    this.id,
    this.issuerId,
    this.issuerName,
    this.time,
    this.title,
    this.beginAt,
    this.endAt,
  });

  MeetingList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    issuerId = json['issuerId'];
    issuerName = json['issuerName'];
    time = json['time'];
    title = json['title'];
    beginAt = json['beginAt'];
    endAt = json['endAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['issuerId'] = this.issuerId;
    data['issuerName'] = this.issuerName;
    data['time'] = this.time;
    data['title'] = this.title;
    data['beginAt'] = this.beginAt;
    data['endAt'] = this.endAt;
    return data;
  }

  static List<MeetingList> listFromJson(List<dynamic> ls) {
    var ret = List<MeetingList>();
    for (var obj in ls) {
      ret.add(MeetingList.fromJson(obj));
    }
    return ret;
  }
}
