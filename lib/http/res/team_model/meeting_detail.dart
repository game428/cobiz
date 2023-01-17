import 'common_model.dart';

class MeetingDetail {
  int id; // 标识id
  int issuer; // 发布者标识id
  String name; // 发布者名称
  String avatar; // 发布者头像
  int time; // 发起时间(毫秒数)
  String title; // 标题
  String content; // 内容
  int beginAt; // 会议开始时间
  int endAt; // 会议结束时间

  List<Director> director; // 主持人
  List<CopyTo> copyTo;
  List<Comments> comments;

  MeetingDetail({
    this.id,
    this.issuer,
    this.name,
    this.avatar,
    this.time,
    this.title,
    this.content,
    this.beginAt,
    this.endAt,
    this.director,
    this.copyTo,
    this.comments,
  });

  MeetingDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    issuer = json['issuer'];
    name = json['name'];
    avatar = json['avatar'];
    time = json['time'];
    title = json['title'];
    content = json['content'];
    beginAt = json['beginAt'];
    endAt = json['endAt'];
    if (json['director'] != null) {
      director = new List<Director>();
      json['director'].forEach((v) {
        director.add(new Director.fromJson(v));
      });
    }
    if (json['copyTo'] != null) {
      copyTo = new List<CopyTo>();
      json['copyTo'].forEach((v) {
        copyTo.add(new CopyTo.fromJson(v));
      });
    }
    if (json['comments'] != null) {
      comments = new List<Comments>();
      json['comments'].forEach((v) {
        comments.add(new Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['issuer'] = this.issuer;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['time'] = this.time;
    data['title'] = this.title;
    data['content'] = this.content;
    data['beginAt'] = this.beginAt;
    data['endAt'] = this.endAt;
    if (this.director != null) {
      data['director'] = this.director.map((v) => v.toJson()).toList();
    }
    if (this.copyTo != null) {
      data['copyTo'] = this.copyTo.map((v) => v.toJson()).toList();
    }
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
