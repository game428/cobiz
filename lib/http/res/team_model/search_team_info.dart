//搜索出来的团队信息
class SearchTeamInfo {
  String icon;
  int id;
  bool joined;
  String name;
  int type;

  SearchTeamInfo({this.icon, this.id, this.joined, this.name, this.type});

  SearchTeamInfo.fromJson(Map<String, dynamic> json) {
    icon = json['icon'];
    id = json['id'];
    joined = json['joined'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['id'] = this.id;
    data['joined'] = this.joined;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }

  static List<SearchTeamInfo> listFromJson(List<dynamic> ls) {
    var ret = List<SearchTeamInfo>();
    for (var obj in ls) {
      ret.add(SearchTeamInfo.fromJson(obj));
    }
    return ret;
  }
}
