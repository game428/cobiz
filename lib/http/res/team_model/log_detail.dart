import 'common_model.dart';

class LogDetail {
  String avatar;
  String finished;
  int id;
  int issuer;
  String name;
  String needed;
  String pending;
  int time;
  int type;
  List<String> images;
  List<CopyTo> copyTo;
  List<Comments> comments;

  LogDetail(
      {this.avatar,
      this.finished,
      this.id,
      this.issuer,
      this.name,
      this.needed,
      this.pending,
      this.time,
      this.type,
      this.images,
      this.copyTo,
      this.comments});

  LogDetail.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    finished = json['finished'];
    id = json['id'];
    issuer = json['issuer'];
    name = json['name'];
    needed = json['needed'];
    pending = json['pending'];
    time = json['time'];
    type = json['type'];
    images = json['images'].cast<String>();
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
    data['avatar'] = this.avatar;
    data['finished'] = this.finished;
    data['id'] = this.id;
    data['issuer'] = this.issuer;
    data['name'] = this.name;
    data['needed'] = this.needed;
    data['pending'] = this.pending;
    data['time'] = this.time;
    data['type'] = this.type;
    data['images'] = this.images;
    if (this.copyTo != null) {
      data['copyTo'] = this.copyTo.map((v) => v.toJson()).toList();
    }
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
