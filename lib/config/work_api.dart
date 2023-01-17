import 'package:cobiz_client/config/api.dart';

class WorkAPi {
  // 添加团队公告
  static const addNotice = API.serverUrl + 'api/team/notice/add';
  // 删除团队公告
  static const delNotcie = API.serverUrl + 'api/team/notice/delete';
  // 分页查询最新公告列表信息
  static const getNoticeList = API.serverUrl + 'api/team/notice/list';
  // 查询指定公告信息
  static const getNoticeDetail = API.serverUrl + 'api/team/notice/find';
  // 添加请假审批
  static const leaveAdd = API.serverUrl + 'api/team/approval/leave/add';
  // 添加通用审批
  static const generalAdd = API.serverUrl + 'api/team/approval/general/add';
  // 添加报销审批
  static const expenseAdd = API.serverUrl + 'api/team/approval/expense/add';
  // 添加任务审批
  static const taskAdd = API.serverUrl + 'api/team/approval/task/add';
  // 添加工作日志
  static const worklogAdd = API.serverUrl + 'api/team/worklog/add';
  // 获取日志列表
  static const logList = API.serverUrl + 'api/team/worklog/list';
  // 获取日志详情
  static const logDetail = API.serverUrl + 'api/team/worklog/find';
  // 回复日志
  static const logReply = API.serverUrl + 'api/team/worklog/reply';
  // 获取审批信息列表
  static const getApprovalList = API.serverUrl + 'api/team/approval/list';
  // 获取审批信息详情
  static const getApprovalDetail = API.serverUrl + 'api/team/approval/find';
  // 操作审批状态
  static const modifyApprovalState = API.serverUrl + 'api/team/approval/deal';
  // 回复任务
  static const taskReply = API.serverUrl + 'api/team/approval/reply';
  // 获取未读抄送
  static const getCopytoCount = API.serverUrl + 'api/team/approval/copyto/unread/count';

  // 添加会议纪要
  static const meetingAdd = API.serverUrl + 'api/team/meetinglog/add';
  // 获取会议纪要列表
  static const meetingList = API.serverUrl + 'api/team/meetinglog/list';
  // 获取会议纪要详情
  static const meetingDetail = API.serverUrl + 'api/team/meetinglog/find';
  // 回复会议纪要
  static const meetingReply = API.serverUrl + 'api/team/meetinglog/reply';
}
