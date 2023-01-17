import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/team_api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/req.dart';
import 'package:cobiz_client/http/res/res.dart';
import 'package:cobiz_client/http/res/team_model/dept_member.dart';
import 'package:cobiz_client/http/res/team_model/invoice_info.dart';
import 'package:cobiz_client/http/res/team_model/member_detail_info.dart';
import 'package:cobiz_client/http/res/team_model/search_team_info.dart';
import 'package:cobiz_client/http/res/team_model/team_group.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/res/team_model/team_member.dart';
import 'package:cobiz_client/http/res/team_model/top_depts.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';

import 'res/team_model/team_new_member.dart';
import 'res/y_group.dart';

///搜索团队信息
///search      String    输入待查询的团队名称 二维码 CB#22313
Future<List<SearchTeamInfo>> searchTeam(String tName) async {
  var str = await Req.post2(TeamApi.searchTeam,
      params: AESUtils.encrypt(jsonEncode({'search': tName})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List<SearchTeamInfo>();
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return List<SearchTeamInfo>();
  }
  return SearchTeamInfo.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///获取指定团队信息
///@ teamId  0:查询默认团队
Future<TeamInfo> getSomeoneTeam({int teamId = 0}) async {
  var str = await Req.post2(TeamApi.getOneTeam,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return TeamInfo.fromJsonMap(jsonDecode(AESUtils.decrypt(res.data)));
}

///创建团队
///name        String    团队名称(必传)
///intro       String    团队简介
///type        int       团队类型
///icon        String    团队图标
Future<dynamic> createTeam(
    {@required String tName, String intro, int type, String icon}) async {
  var str = await Req.post2(TeamApi.createTeam,
      params: AESUtils.encrypt(jsonEncode(
          {'name': tName, 'intro': intro, 'type': type, 'icon': icon})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return res.code;
  }
  return TeamInfo.fromJsonMap(jsonDecode(AESUtils.decrypt(res.data)));
}

///获取所有团队信息
Future<List<TeamStore>> getAllTeams() async {
  var str = await Req.post2(TeamApi.getAllTeam, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return TeamStore.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///切换团队信息
Future<bool> switchTeam(int teamId) async {
  var str = await Req.post2(TeamApi.changeTeam,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///解散团队
Future<bool> dismissTeam(int teamId) async {
  var str = await Req.post2(TeamApi.dismissTeam,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///获取团队成员信息
///type      int    查询类型: 1.仅获取成员信息 2.获取成员和组织架构信息
///teamId    int   团队标识id
Future<dynamic> getTeamMembers(
    {@required int teamId, @required int type, int deptId}) async {
  var str = await Req.post2(TeamApi.getMembers,
      params: AESUtils.encrypt(
          jsonEncode({'type': type, 'deptId': deptId, 'teamId': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  if (type == 1) {
    return TeamMember.listFromJson(
        jsonDecode(AESUtils.decrypt(res.data))['members']);
  }
  if (type == 2) {
    return DeptAndMember.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
  }
  return null;
}

///添加团队成员
///teamId      int            团队标识id
///memberIds   List<int>      添加的成员标识id
///0.成功 1.失败 2.没有权限(创建者和管理员) 3.成员超过限制数量
Future<int> addTeamMembers(
    {@required int teamId, @required List<int> memberIds, int deptId}) async {
  var str = await Req.post2(TeamApi.addMembers,
      params: AESUtils.encrypt(jsonEncode(
          {'teamId': teamId, 'memberIds': memberIds, 'deptId': deptId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 1;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code;
}

///编辑团队成员
///id          int        团队成员标识id
///teamId      int        团队标识id
///name        String      姓名
///phone       String      电话
///position    String      职位
///entry       String      入职时间(格式: yyyy-MM-dd)
///remark      String      备注
///workNo      String      工号
///deptIds     List<int>  所属部门标识id集合
///0.成功 1.失败 2.没有权限(创建者和管理员) 3.非团队成员
Future<int> modifyTeamMember(
    {@required int teamId,
    @required int userId,
    String name,
    String phone,
    String position,
    String entry,
    String remark,
    String workNo,
    int curDeptId = 0, //当前编辑用户所在部门标识id(0.表示在最外层操作的)
    List<int> deptIds}) async {
  var str = await Req.post2(TeamApi.editMember,
      params: AESUtils.encrypt(jsonEncode({
        'id': userId,
        'teamId': teamId,
        'name': name,
        'phone': phone,
        'position': position,
        'entry': entry,
        'remark': remark,
        'workNo': workNo,
        'deptIds': deptIds,
        'curDeptId': curDeptId
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 1;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code;
}

///删除团队成员
///teamId      int    所属团队标识id
///id          int    待删除的成员标识id
///0.成功 1.失败 2.没有权限(创建者和管理员)
Future<int> deleteTeamMember(
    {@required int teamId, @required int userId, @required int deptId}) async {
  var str = await Req.post2(TeamApi.deleteMember,
      params: AESUtils.encrypt(
          jsonEncode({'id': userId, 'teamId': teamId, 'deptId': deptId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 1;
  }
  var res = Res.fromJsonMap(json.decode(str));
  return res.code;
}

///查询指定团队成员
///teamId      int    所属团队标识id
///id          int    待删除的成员标识id
Future<MemberDetailInfo> querySomebodyInfo(
    {@required int teamId, @required int userId}) async {
  var str = await Req.post2(TeamApi.querySomebodyInfo,
      params: AESUtils.encrypt(jsonEncode({'id': userId, 'teamId': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return MemberDetailInfo.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///团队成员退出指定团队
///id      int    退出的团队标识id
Future<bool> leaveTeam({@required int teamId}) async {
  var str = await Req.post2(TeamApi.leaveTeam,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///申请加入团队
///teamId      int    团队标识id
///name        String  申请者姓名
///msg         String  验证信息
Future<bool> applyJoinTeam(
    {@required int teamId, int deptId, String name, String msg}) async {
  var str = await Req.post2(TeamApi.applyJoinTeam,
      params: AESUtils.encrypt(jsonEncode(
          {'teamId': teamId, 'deptId': deptId, 'name': name, 'msg': msg})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///加入团队的申请信息列表
///teamId      int    团队标识id
///page        int     页码(从1开始)
///size        int     每页显示数
Future<dynamic> applyJoinTeamList(
    {@required int teamId, int page, int size = 10}) async {
  var str = await Req.post2(TeamApi.applyJoinTeamList,
      params: AESUtils.encrypt(
          jsonEncode({'teamId': teamId, 'page': page, 'size': size})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return TeamNewMember.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///处理加入团队的申请信息
///teamId      int    团队标识id
///applyId     int    申请者标识id
///type        int     操作类型: 1.同意 2.删除
/// code: 0.成功 1.失败 2.没有权限(管理员和创建者) 3.该申请已被处理 4.团队成员数超过上限 5.操作失败
Future<dynamic> dealApplyJoinTeam(
    {@required int teamId, int applyId, int type}) async {
  var str = await Req.post2(TeamApi.dealApplyJoinTeam,
      params: AESUtils.encrypt(
          jsonEncode({'teamId': teamId, 'applyId': applyId, 'type': type})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return true;
  } else {
    print('操作失败${res.code}');
    return res.code;
  }
}

///修改团队设置
///id          long        团队标识id
///name        String      团队名称
///icon        String      团队图标
///intro       String      团队简介
///type        int         团队类型
///managerIds  List<Long>  管理员标识id
Future<dynamic> teamSetting(
    {@required int teamId,
    String name,
    String icon,
    String intro,
    int type,
    List<int> managerIds}) async {
  var str = await Req.post2(TeamApi.teamSetting,
      params: AESUtils.encrypt(jsonEncode({
        'id': teamId,
        'name': name,
        'icon': icon,
        'intro': intro,
        'type': type,
        'managerIds': managerIds
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return true;
}

///查询开票信息
///id      long    团队标识id
Future<InvoiceInfo> teamInvoiceInfo({@required int teamId}) async {
  var str = await Req.post2(TeamApi.teamInvoiceInfo,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return InvoiceInfo.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///修改开票信息
///teamId      long        团队标识id
///title       String      开票抬头
///taxNum      String      税号
///cardNo      String      银行账号
///opened      String      开户行
///phone       String      电话
///address     String      注册地址
///remark      String      备注
Future<bool> editTeamInvoiceInfo(
    {@required int teamId,
    String title,
    String taxNum,
    String cardNo,
    String opened,
    String phone,
    String address,
    String remark}) async {
  var str = await Req.post2(TeamApi.editTeamInvoiceInfo,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'title': title,
        'taxNum': taxNum,
        'cardNo': cardNo,
        'opened': opened,
        'phone': phone,
        'address': address,
        'remark': remark
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///添加/修改 子部门
///id          long    部门标识id(值=0表示新增, >0表示修改)
///teamId      long    团队标识id
///parentId    long    上级部门标识id(一级部门值传0)
///name        String  部门名称
///leaderId    long    主管标识id
Future<dynamic> deptDeal(
    {@required int teamId,
    @required int deptId,
    int parentId,
    @required String name,
    int leaderId}) async {
  var str = await Req.post2(TeamApi.deptDeal,
      params: AESUtils.encrypt(jsonEncode({
        'id': deptId,
        'teamId': teamId,
        'parentId': parentId,
        'name': name,
        'leaderId': leaderId
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return jsonDecode(AESUtils.decrypt(res.data));
}

///获取指定团队下属第一级部门列表信息
///id      long    所属的团队标识id
Future<dynamic> getTopDepts({@required int teamId}) async {
  var str = await Req.post2(TeamApi.getTopDepts,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List<TopDept>();
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return List<TopDept>();
  }
  return TopDept.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///删除子部门
///teamId      long    团队标识id
///deptId      long    待删除的部门标识id
Future<bool> deleteDept({@required int teamId, @required int deptId}) async {
  var str = await Req.post2(TeamApi.deleteDept,
      params:
          AESUtils.encrypt(jsonEncode({'deptId': deptId, 'teamId': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///创建小组
///teamId      long    所属的团队标识id
///name        String  小组名称
Future<dynamic> createTeamGroup(
    {@required int teamId, @required String name}) async {
  var str = await Req.post2(TeamApi.createTeamGroup,
      params: AESUtils.encrypt(jsonEncode({'name': name, 'teamId': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    return json.decode(AESUtils.decrypt(res.data));
  } else {
    return null;
  }
}

///添加/删除小组成员
///teamId      long        所属的团队标识id
///groupId     long        所属的小组标识id
///add         boolean     是否是添加(true.添加 false.删除)
///memberIds   List<Long>  待操作的成员标识id
Future<dynamic> tGroupMemDeal(
    {@required int teamId,
    @required int groupId,
    bool add,
    List<int> memberIds}) async {
  var str = await Req.post2(TeamApi.tGroupMemDeal,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'groupId': groupId,
        'add': add,
        'memberIds': memberIds
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return true;
}

///获取指定团队小组列表
///id      long    所属的团队标识id(必传)
Future<List<TeamGroup>> getTeamGroups({@required int teamId}) async {
  var str = await Req.post2(TeamApi.getTeamGroups,
      params: AESUtils.encrypt(jsonEncode({'id': teamId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return TeamGroup.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///获取指定团队指定小组的成员列表
///id      long    所属的小组标识id(必传)
///teamId  long    所属的团队标识id(必传)
Future<List<GroupMember>> getGroupMembers(
    {@required int teamId, @required int id}) async {
  var str = await Req.post2(TeamApi.getGroupMembers,
      params: AESUtils.encrypt(jsonEncode({'teamId': teamId, 'id': id})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return GroupMember.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

///删除指定小组
///teamId     long    所属的团队标识id(必传)
///id         long    所属的小组标识id(必传)
Future<bool> deleteTeamGroup(int teamId, int tgId) async {
  var str = await Req.post2(TeamApi.deleteTeamGroup,
      params: AESUtils.encrypt(jsonEncode({'teamId': teamId, 'id': tgId})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}

///添加子部门成员
///teamId      long            团队标识id
///deptId      long            子部门标识id
///memberIds   List<Long>      待添加的成员标识id
Future<bool> addDeptMember(int teamId, int deptId, List<int> memberIds) async {
  var str = await Req.post2(TeamApi.addDeptMember,
      params: AESUtils.encrypt(jsonEncode(
          {'teamId': teamId, 'deptId': deptId, 'memberIds': memberIds})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return false;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return false;
  }
  return true;
}
