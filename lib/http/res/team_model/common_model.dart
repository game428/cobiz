class Comments {
  String avatar;
  String name;
  String msg;
  int time;
  int userId;

  Comments({this.avatar, this.name, this.msg, this.time, this.userId});

  Comments.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    name = json['name'];
    msg = json['msg'];
    time = json['time'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['msg'] = this.msg;
    data['time'] = this.time;
    data['userId'] = this.userId;
    return data;
  }
}

class CopyTo {
  String avatar;
  String name;
  int sort;
  int state;
  int time;
  int userId;

  CopyTo(
      {this.avatar, this.name, this.sort, this.state, this.time, this.userId});

  CopyTo.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    name = json['name'];
    sort = json['sort'];
    state = json['state'];
    time = json['time'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['name'] = this.name;
    data['sort'] = this.sort;
    data['state'] = this.state;
    data['time'] = this.time;
    data['userId'] = this.userId;
    return data;
  }
}

class Director {
  int userId;
  String name;
  String avatar;
  int state;

  Director({
    this.userId,
    this.name,
    this.avatar,
    this.state,
  });

  Director.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    avatar = json['avatar'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['state'] = this.state;
    return data;
  }
}
