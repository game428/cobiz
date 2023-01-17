//团队成员详细信息
class MemberDetailInfo {
  String avatar;
  List<int> deptIds;
  List<String> deptNames;
  String entry;
  int id;
  String name;
  String phone;
  String position;
  String remark;
  String workNo;
  bool friend;

  MemberDetailInfo(
      {this.avatar,
      this.deptIds,
      this.deptNames,
      this.entry,
      this.id,
      this.name,
      this.phone,
      this.position,
      this.remark,
      this.workNo,
      this.friend});

  MemberDetailInfo.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    if (json['deptIds'] != null) {
      deptIds = new List<int>();
      json['deptIds'].forEach((v) {
        deptIds.add(v);
      });
    }
    if (json['deptNames'] != null) {
      deptNames = new List<String>();
      json['deptNames'].forEach((v) {
        deptNames.add(v);
      });
    }
    entry = json['entry'];
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    position = json['position'];
    remark = json['remark'];
    workNo = json['workNo'];
    friend = json['friend'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    if (this.deptIds != null) {
      data['deptIds'] = this.deptIds;
    }
    if (this.deptNames != null) {
      data['deptNames'] = this.deptNames;
    }
    data['entry'] = this.entry;
    data['id'] = this.id;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['position'] = this.position;
    data['remark'] = this.remark;
    data['workNo'] = this.workNo;
    data['friend'] = this.friend;
    return data;
  }
}
