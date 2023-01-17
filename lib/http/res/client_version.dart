//应用版本更新
class ClientVersion {
  String version;
  String title;
  String content;
  bool force;
  String url;

  ClientVersion.fromJsonMap(Map<String, dynamic> map)
      : version = map['version'],
        title = map['title'],
        content = map['content'] != null ? map['content'] : null,
        force = map['force'],
        url = map['url'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = version;
    data['title'] = title;
    data['content'] = content;
    data['force'] = force;
    data['url'] = url;
    return data;
  }
}
