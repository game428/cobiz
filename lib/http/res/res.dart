class Res {
  int code;
  String msg;
  dynamic data;

  Res.fromJsonMap(Map<String, dynamic> map)
      : code = map['code'],
        msg = map['msg'],
        data = map['data'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = code;
    data['msg'] = msg;
    data['data'] = data;
    return data;
  }
}
