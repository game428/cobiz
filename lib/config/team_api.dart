import 'package:cobiz_client/config/api.dart';

class TeamApi {
  // 搜索团队信息
  static const searchTeam = API.serverUrl + 'api/team/search';
  // 获取指定团队信息
  static const getOneTeam = API.serverUrl + 'api/team/someone';
  // 获取所有团队信息
  static const getAllTeam = API.serverUrl + 'api/team/all';
  // 切换团队
  static const changeTeam = API.serverUrl + 'api/team/change';
  // 创建团队
  static const createTeam = API.serverUrl + 'api/team/create';
  // 解散团队
  static const dismissTeam = API.serverUrl + 'api/team/dismiss';
  // 获取团队成员信息
  static const getMembers = API.serverUrl + 'api/team/members';
  // 添加团队成员
  static const addMembers = API.serverUrl + 'api/team/members/add';
  // 编辑团队成员
  static const editMember = API.serverUrl + 'api/team/member/modify';
  // 删除团队成员
  static const deleteMember = API.serverUrl + 'api/team/member/delete';
  // 查询指定团队成员
  static const querySomebodyInfo = API.serverUrl + 'api/team/member/info';
  // 团队成员退出指定团队
  static const leaveTeam = API.serverUrl + 'api/team/member/out';
  // 申请加入团队
  static const applyJoinTeam = API.serverUrl + 'api/team/apply/add';
  // 加入团队的申请信息列表
  static const applyJoinTeamList = API.serverUrl + 'api/team/apply/list';
  // 处理加入团队的申请信息
  static const dealApplyJoinTeam = API.serverUrl + 'api/team/apply/deal';
  // 修改团队设置
  static const teamSetting = API.serverUrl + 'api/team/setting/modify';
  // 查询开票信息
  static const teamInvoiceInfo = API.serverUrl + 'api/team/invoice/info';
  // 修改开票信息
  static const editTeamInvoiceInfo = API.serverUrl + 'api/team/invoice/modify';
  // 添加/修改 子部门
  static const deptDeal = API.serverUrl + 'api/team/dept/add';
  // 删除子部门
  static const deleteDept = API.serverUrl + 'api/team/dept/delete';
  // 创建小组
  static const createTeamGroup = API.serverUrl + 'api/team/group/create';
  // 添加/删除小组成员
  static const tGroupMemDeal = API.serverUrl + 'api/team/group/member/select';
  // 获取指定团队小组列表
  static const getTeamGroups = API.serverUrl + 'api/team/group/list';
  // 获取指定团队下属第一级部门列表信息
  static const getTopDepts = API.serverUrl + 'api/team/dept/top';
  // 获取指定团队指定小组的成员列表
  static const getGroupMembers = API.serverUrl + 'api/team/group/members';
  // 删除指定小组
  static const deleteTeamGroup = API.serverUrl + 'api/team/group/delete';
  // 添加子部门成员
  static const addDeptMember = API.serverUrl + 'api/team/dept/member/add';
}
