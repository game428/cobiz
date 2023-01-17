import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/config/work_api.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';

import 'req.dart';
import 'res/res.dart';
import 'res/team_model/log_detail.dart';
import 'res/team_model/log_list.dart';
import 'res/team_model/meeting_detail.dart';
import 'res/team_model/meeting_list.dart';
import 'res/team_model/work_notice.dart';
import 'res/team_model/work_common_list.dart';
import 'res/team_model/work_common_detail.dart';

///添加团队公告
/// teamId      long        所属的团队标识id(必传)
/// title       String      标题(长度限50, 必传)
/// author      String      作者(长度限30, 非必传)
/// content     String      内容(长度限500, 必传)
Future<bool> addNotice(
    {int teamId, String title, String author, String content}) async {
  var str = await Req.post2(WorkAPi.addNotice,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'title': title,
        'author': author,
        'content': content
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

///删除团队公告
/// teamId      long        所属的团队标识id(必传)
/// id          long    公告标识id(必传)
Future<bool> delNotice({int teamId, int id}) async {
  var str = await Req.post2(WorkAPi.delNotcie,
      params: AESUtils.encrypt(jsonEncode({'teamId': teamId, 'id': id})),
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

/// 分页查询最新公告列表信息
/// teamId      long    所属的团队标识id(必传)
/// page        int     页码(从1开始)
/// size        int     每页显示数
Future<List<Notice>> noticeList(
    {int teamId, int page = 1, int size = 5}) async {
  var str = await Req.post2(WorkAPi.getNoticeList,
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
  return Notice.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 查询指定公告信息
/// teamId      long        所属的团队标识id(必传)
/// id          long    公告标识id(必传)
Future<Notice> getNotice({int teamId, int id}) async {
  var str = await Req.post2(WorkAPi.getNoticeDetail,
      params: AESUtils.encrypt(jsonEncode({'teamId': teamId, 'id': id})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return Notice.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 添加请假审批
/*
  teamId          long            所属的团队标识id(必传)(必传)
  type            int             类型: 1.事假 2.调休 3.病假 4.年假 5.产假 6.陪产假 7.婚假 8.例假 9.丧假 10.哺乳假(必传)
  beginAt         String          开始时间(格式: yyyy-MM-dd HH:mm 或 yyyy-MM-dd)(必传)
  endAt           String          结束时间(格式: yyyy-MM-dd HH:mm 或 yyyy-MM-dd)(必传)
  reason          String          理由(100)(必传)
  images          List<String>    图片路径字符串数组(6图)(非必传)
  approvers       List<Long>      审批人(按顺序依次)(必传)
  copyTo          List<Long>      抄送人(非必传)
  msg             String          留言(50)(非必传)

  code: 0.成功 1.失败
*/
Future<bool> leaveAdd(
    {@required int teamId,
    @required int type,
    @required String beginAt,
    @required String endAt,
    @required String reason,
    List<String> images,
    @required List<int> approvers,
    List<int> copyTo,
    String msg}) async {
  var str = await Req.post2(WorkAPi.leaveAdd,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'type': type,
        'beginAt': beginAt,
        'endAt': endAt,
        'reason': reason,
        'images': images,
        'approvers': approvers,
        'copyTo': copyTo,
        'msg': msg
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

/// 添加通用审批
/*
  teamId          long            所属的团队标识id(必传)
  title           String          申请内容(50)(必传)
  content         String          审批详情(200)(非必传)
  images          List<String>    图片路径字符串数组(6图)(非必传)
  approvers       List<Long>      审批人(按顺序依次)(必传)
  copyTo          List<Long>      抄送人(非必传)
  msg             String          留言(50)(非必传)

  code: 0.成功 1.失败
*/
Future<bool> generalAdd(
    {@required int teamId,
    @required String title,
    String content,
    List<String> images,
    @required List<int> approvers,
    List<int> copyTo,
    String msg}) async {
  var str = await Req.post2(WorkAPi.generalAdd,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'title': title,
        'content': content,
        'images': images,
        'approvers': approvers,
        'copyTo': copyTo,
        'msg': msg
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

/// 添加报销审批
/*
  teamId          long            所属的团队标识id(必传)
  num             double          报销金额(必传)
  unit            String          报销金额单位(10)(必传)
  title           String          申请内容(50)(必传)报销类别
  content         String          审批详情(200)(非必传)
  images          List<String>    图片路径字符串数组(6图)(非必传)
  approvers       List<Long>      审批人(按顺序依次)(必传)
  copyTo          List<Long>      抄送人(非必传)
  msg             String          留言(50)(非必传)

  code: 0.成功 1.失败
*/
Future<bool> expenseAdd(
    {@required int teamId,
    @required double moneyNum,
    @required String unit,
    @required String title,
    String content,
    List<String> images,
    @required List<int> approvers,
    List<int> copyTo,
    String msg}) async {
  var str = await Req.post2(WorkAPi.expenseAdd,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'num': moneyNum,
        'unit': unit,
        'title': title,
        'content': content,
        'images': images,
        'approvers': approvers,
        'copyTo': copyTo,
        'msg': msg
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

/// 发布任务
/*
  teamId          long            所属的团队标识id(必传)
  title           String          任务名称(50)(必传)
  content         String          任务详情(200)(必传)
  endAt           String          完成时间(格式: yyyy-MM-dd HH:mm)(必传)
  remind          int             提醒时间(单位: 分钟)(非必传)
  executors       List<Long>      执行人(必传)
  copyTo          List<Long>      抄送人(非必传)

  code: 0.成功 1.失败
*/
Future<bool> taskAdd({
  @required int teamId,
  @required String title,
  @required String content,
  @required String endAt,
  int remind,
  @required List<int> executors,
  List<int> copyTo,
}) async {
  var str = await Req.post2(WorkAPi.taskAdd,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'title': title,
        'content': content,
        'endAt': endAt,
        'remind': remind,
        'executors': executors,
        'copyTo': copyTo
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

/// 回复任务
/*
 * teamId         long            所属的团队标识id(必传)
 * id             long            所属的审批标识id(必传)
 * content        String          回复的文本内容(300)(必传)
 */

Future<bool> replyTask({
  @required int teamId,
  @required int id,
  @required String content,
}) async {
  var str = await Req.post2(WorkAPi.taskReply,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'id': id,
        'content': content,
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

/// 添加工作日志
/*
  teamId          long            所属的团队标识id(必传)
  type            int             类型: 1.日报 2.周报 3.月报(必传)
  finished        String          已完成的工作(200) [三选一]
  pending         String          未完成的工作(200) [三选一]
  needed          String          需要协调的工作(200) [三选一]
  images          List<String>    图片路径字符串数组(6图)(非必传)
  copyTo          List<Long>      抄送人(必传)
  msg             String          留言(50)(非必传)

  code: 0.成功 1.失败
*/
Future<bool> worklogAdd({
  @required int teamId,
  @required int type,
  String finished,
  String pending,
  String needed,
  List<String> images,
  @required List<int> copyTo,
  String msg,
}) async {
  var str = await Req.post2(WorkAPi.worklogAdd,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'type': type,
        'finished': finished,
        'pending': pending,
        'needed': needed,
        'images': images,
        'copyTo': copyTo,
        'msg': msg
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

/// 获取审批信息
/*
  teamId      long        所属的团队标识id(必传)
  type        int         类型: 1.待处理 2.已处理 3.已发起 4.抄送我(必传)
  page        int         页码(从1开始)
  size        int         每页显示数
*/

/* 响应参数
 * {
 *  code: 0.成功 1.失败
 *  data: [{
 *   id              long        标识id
 *   type            int         类型: 1.通用 2.请假 3.报销 4.任务 
 *   issuer          String      发起者名称
 *   time            long        发起时间(毫秒数)
 *   state           int         状态: 0.未处理 1.已同意 2.已拒绝 3.已撤销
 *   title           String      标题(type=1/3/4时)
 *   content         String      内容(type=1/3/4时)
 *   leaveType       int         请假类型(type=2时)
 *   beginAt         long        开始时间(毫秒数)(type=2时)
 *   endAt           long        结束时间(毫秒数)(type=2/4时)
 *   money           double      金额(type=3时)
 *   unit            String      单位(type=3时)
 *  }]
 * }
 */
Future<List<WorkCommonListItem>> getApprovalList({
  @required int teamId,
  @required int type,
  @required int page,
  int size = 20,
}) async {
  var str = await Req.post2(WorkAPi.getApprovalList,
      params: AESUtils.encrypt(jsonEncode(
          {'teamId': teamId, 'type': type, 'page': page, 'size': size})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List<WorkCommonListItem>();
  }
  var res = Res.fromJsonMap(json.decode(str));

  if (res.code != 0) {
    return List<WorkCommonListItem>();
  }
  return WorkCommonListItem.listFromJson(
      jsonDecode(AESUtils.decrypt(res.data)));
}

/// 获取审批详情信息
/* 请求参数 query
 * teamId      long    所属的团队标识id(必传)
 * id          long    审批标识id(必传)
 *
 响应参数
 * id              long            审批标识id
 * type            int             类型: 1.通用 2.请假 3.报销 4.任务
 * issuer          long            发布者标识id
 * name            String          发布者名称
 * avatar          String          发布者头像
 * approver        long            当前审批者标识id(为0则无)
 * time            long            审批发布时间(毫秒数)
 * state           int             审批状态: 0.处理中 1.已完成 2.已拒绝 3.已撤销
 * title           String          标题(type=1/3/4)
 * content         String          内容(type=1/3/4)
 * leaveType       int             请假类型(type=2)
 * beginAt         long            开始时间(type=2)
 * endAt           long            结束/完成时间(type=2/4)
 * reason          String          请假理由(type=2)
 * money           double          报销金额(type=3)
 * unit            String          报销金额单位(type=3)
 * images          List<String>    图片数组(type=1/2/3)
 * approvers: [{                   审批者(type=1/2/3)
 *   userId      long        审批者标识id
 *   name        String      审批者名称
 *   avatar      String      审批者头像
 *   sort        int         审批顺序(升序依次)
 *   state       int         审批人状态: 0.未处理 1.同意 2.拒绝
 *   msg         String      审批意见
 *   time        long        审批时间(state=0时值为0表示无时间)
 * }]
 * copyTo: [{                      抄送者(type=1/2/3/4)
 *   userId      long        抄送者标识id
 *   name        String      抄送者名称
 *   avatar      String      抄送者头像
 *   state       int         抄送人状态: 0.未读 1.已读
 *   time        long        读取时间(state=0时值为0表示无时间)
 * }]
 * executors: [{                   执行者(type=4)
 *   userId      long        执行者标识id
 *   name        String      执行者名称
 *   avatar      String      执行者头像
 *   state       int         执行人状态: 0.未读 1.已读 2.已完成
 *   msg         String      完成时提交的意见
 *   time        long        完成时间(state=0时值为0表示无时间)
 * }]
 */

Future<ApprovalDetail> getApprovalDetail({
  @required int teamId,
  @required int id,
}) async {
  var str = await Req.post2(WorkAPi.getApprovalDetail,
      params: AESUtils.encrypt(jsonEncode({'teamId': teamId, 'id': id})),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));

  if (res.code != 0) {
    return null;
  }
  return ApprovalDetail.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 操作审批状态
/*
 * teamId          long            所属的团队标识id(必传) 
 * id              long            审批标识id(必传)
 * type            int             操作类型: 1.同意 2.拒绝 3.撤销 4.完成(必传)
 * msg             String          留言(100)(非必传)
 */
Future<bool> modifyApprovalState({
  @required int teamId,
  @required int id,
  @required int type,
  String msg,
}) async {
  var str = await Req.post2(WorkAPi.modifyApprovalState,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'id': id,
        'type': type,
        'msg': msg,
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

/// 获取日志列表
/*
 * teamId          long            所属的团队标识id(必传) 
 * type            int             类型: 1.待查阅 2.已查阅 3.已发起
 * page        int         页码(从1开始)
 * size        int         每页显示数
 */
Future<List<LogList>> getLogList({
  @required int teamId,
  @required int type,
  int page,
  int size = 20,
}) async {
  var str = await Req.post2(WorkAPi.logList,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'type': type,
        'page': page,
        'size': size,
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List<LogList>();
  }
  var res = Res.fromJsonMap(json.decode(str));

  if (res.code != 0) {
    return List<LogList>();
  }
  return LogList.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 获取日志详情
/*
 * teamId          long            所属的团队标识id(必传) 
 * id          long        日志标识id
 *
 * data: [{
        id              long        标识id
        type            int         类型: 1.日报 2.周报 3.月报
        issuer          long        发布者标识id
        name            String      发布者名称
        avatar          String      发布者头像
        time            long        发起时间(毫秒数)
        finished        String      已完成
        pending         String      未完成
        needed          String      需协调
        images          List<String>    图片数组
        copyTo: [{                  抄送者
            userId      long        抄送者标识id
            name        String      抄送者名称
            avatar      String      抄送者头像
            state       int         读取状态: 0.未读 1.已读
        }]
        comments: [{                评论者
            userId      long        评论者标识id
            name        String      评论者名称
            avatar      String      评论者头像
            msg         String      评论内容
            time        long        评论时间(毫秒数)
        }]
    }]
 */
Future<LogDetail> getLogDetail({
  @required int teamId,
  @required int id,
}) async {
  var str = await Req.post2(WorkAPi.logDetail,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'id': id,
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return LogDetail.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 回复日志
/*
 * logId          long            所属的工作日志标识id(必传)
 * content        String          回复的文本内容(300)
 */

Future<bool> replyLog({
  @required int logId,
  @required String content,
}) async {
  var str = await Req.post2(WorkAPi.logReply,
      params: AESUtils.encrypt(jsonEncode({
        'logId': logId,
        'content': content,
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

/// 获取未读抄送
/*
 * id          long            所属的团队标识id(必传) 
 */
Future<int> getCopytoCount({
  @required int teamId,
}) async {
  var str = await Req.post2(WorkAPi.getCopytoCount,
      params: AESUtils.encrypt(jsonEncode({
        'id': teamId,
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return 0;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return 0;
  }
  return jsonDecode(AESUtils.decrypt(res.data))['num'];
}

/// 添加会议纪要
/*
  teamId          long            所属的团队标识id(必传)
  title           String          标题(100)(必传)
  content         String          内容(1000)(必传)
  beginAt         String          开始时间(yyyy-MM-dd HH:mm)(必传)
  endAt           String          结束时间(yyyy-MM-dd HH:mm)(必传)
  approvers       List<Long>      主持人(非必传)
  copyTo          List<Long>      参与人(非必传)

  code: 0.成功 1.失败
*/
Future<bool> meetingAdd({
  @required int teamId,
  @required String title,
  String content,
  String beginAt,
  String endAt,
  List<int> approvers,
  @required List<int> copyTo,
}) async {
  var str = await Req.post2(WorkAPi.meetingAdd,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'title': title,
        'content': content,
        'beginAt': beginAt,
        'endAt': endAt,
        'approvers': approvers,
        'copyTo': copyTo,
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

/// 获取会议纪要列表
/*
 * teamId          long            所属的团队标识id(必传) 
 * type            int             类型: 1.待查阅 2.已查阅 3.已发起
 * page        int         页码(从1开始)
 * size        int         每页显示数
 */
Future<List<MeetingList>> getMeetingList({
  @required int teamId,
  @required int type,
  int page,
  int size = 20,
}) async {
  var str = await Req.post2(WorkAPi.meetingList,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'type': type,
        'page': page,
        'size': size,
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return List<MeetingList>();
  }
  var res = Res.fromJsonMap(json.decode(str));

  if (res.code != 0) {
    return List<MeetingList>();
  }
  return MeetingList.listFromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 获取会议纪要详情
/*
 * teamId          long            所属的团队标识id(必传) 
 * id          long        日志标识id
 *
 * data: [{
    id              long            标识id
    issuer          long            发布者标识id
    name            String          发布者名称
    avatar          String          发布者头像
    time            long            发起时间(毫秒数)
    title           String          标题
    content         String          内容
    beginAt         long            会议开始时间
    endAt           long            会议结束时间
    director: [{                    主持人
        userId      long            主持人标识id
        name        String          主持人名称
        avatar      String          主持人头像
        state       int             读取状态: 0.未读 1.已读
    }]
    copyTo: [{                      参与人员
        userId      long            参与者标识id
        name        String          参与者名称
        avatar      String          参与者头像
        state       int             读取状态: 0.未读 1.已读
    }]
    comments: [{                    评论者
        userId      long            评论者标识id
        name        String          评论者名称
        avatar      String          评论者头像
        msg         String          评论内容
        time        long            评论时间(毫秒数)
    }]
}]
 */
Future<MeetingDetail> getMeetingDetail({
  @required int teamId,
  @required int id,
}) async {
  var str = await Req.post2(WorkAPi.meetingDetail,
      params: AESUtils.encrypt(jsonEncode({
        'teamId': teamId,
        'id': id,
      })),
      headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return MeetingDetail.fromJson(jsonDecode(AESUtils.decrypt(res.data)));
}

/// 回复日志
/*
 * logId          long            所属的工作日志标识id(必传)
 * content        String          回复的文本内容(300)
 */

Future<bool> replyMeeting({
  @required int logId,
  @required String content,
}) async {
  var str = await Req.post2(WorkAPi.meetingReply,
      params: AESUtils.encrypt(jsonEncode({
        'logId': logId,
        'content': content,
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
