import 'common_model.dart';

/// 工作四个列表通用

/* 响应参数
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
class ApprovalDetail {
  int approver;
  List<ApproversAndExecutor> approvers;
  String avatar;
  int beginAt;
  String content;
  List<CopyTo> copyToList;
  int endAt;
  List<ApproversAndExecutor> executorList;
  int id;
  List<String> images;
  int issuer;
  int leaveType;
  String name;
  int state;
  int time;
  String title;
  int type;
  String reason;
  double money;
  String unit;
  List<Comments> comments;

  ApprovalDetail({
    this.approver,
    this.approvers,
    this.avatar,
    this.beginAt,
    this.content,
    this.copyToList,
    this.endAt,
    this.executorList,
    this.id,
    this.images,
    this.issuer,
    this.leaveType,
    this.name,
    this.state,
    this.time,
    this.title,
    this.type,
    this.reason,
    this.money,
    this.unit,
    this.comments,
  });

  ApprovalDetail.fromJson(Map<String, dynamic> json) {
    approver = json['approver'];
    if (json['approvers'] != null) {
      approvers = new List<ApproversAndExecutor>();
      json['approvers'].forEach((v) {
        approvers.add(new ApproversAndExecutor.fromJson(v));
      });
    }
    avatar = json['avatar'];
    beginAt = json['beginAt'];
    content = json['content'];
    if (json['copyTo'] != null) {
      copyToList = new List<CopyTo>();
      json['copyTo'].forEach((v) {
        copyToList.add(new CopyTo.fromJson(v));
      });
    }
    endAt = json['endAt'];
    if (json['executors'] != null) {
      executorList = new List<ApproversAndExecutor>();
      json['executors'].forEach((v) {
        executorList.add(new ApproversAndExecutor.fromJson(v));
      });
    }
    if (json['comments'] != null) {
      comments = new List<Comments>();
      json['comments'].forEach((v) {
        comments.add(new Comments.fromJson(v));
      });
    }
    id = json['id'];
    images = json['images'].cast<String>();
    issuer = json['issuer'];
    leaveType = json['leaveType'];
    name = json['name'];
    state = json['state'];
    time = json['time'];
    title = json['title'];
    type = json['type'];
    reason = json['reason'];
    money = json['money'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['approver'] = this.approver;
    if (this.approvers != null) {
      data['approvers'] = this.approvers.map((v) => v.toJson()).toList();
    }
    data['avatar'] = this.avatar;
    data['beginAt'] = this.beginAt;
    data['content'] = this.content;
    if (this.copyToList != null) {
      data['copyTo'] = this.copyToList.map((v) => v.toJson()).toList();
    }
    data['endAt'] = this.endAt;
    if (this.executorList != null) {
      data['executors'] = this.executorList.map((v) => v.toJson()).toList();
    }
    if (this.comments != null) {
      data['comments'] = this.comments.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['images'] = this.images;
    data['issuer'] = this.issuer;
    data['leaveType'] = this.leaveType;
    data['name'] = this.name;
    data['state'] = this.state;
    data['time'] = this.time;
    data['title'] = this.title;
    data['type'] = this.type;
    data['reason'] = this.reason;
    data['money'] = this.money;
    data['unit'] = this.unit;
    return data;
  }
}

class ApproversAndExecutor {
  int userId;
  String name;
  String avatar;
  int sort;
  int state;
  String msg;
  int time;

  ApproversAndExecutor(
      {this.userId,
      this.name,
      this.avatar,
      this.sort,
      this.state,
      this.msg,
      this.time});

  ApproversAndExecutor.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    avatar = json['avatar'];
    sort = json['sort'];
    state = json['state'];
    msg = json['msg'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['avatar'] = this.avatar;
    data['sort'] = this.sort;
    data['state'] = this.state;
    data['msg'] = this.msg;
    data['time'] = this.time;
    return data;
  }
}

