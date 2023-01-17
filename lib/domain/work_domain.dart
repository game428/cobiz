enum ApplyTypeValue {
  leave,  // 请假
  evection, // 出差
  general, // 通用
  expense, // 报销
  log, // 写日志
  logging, // 日志记录
  task, // 发布任务
  pending, // 待处理
  processed, // 已处理
  initiated, // 已发起
  copyMe, // 抄送我
  meeting, // 会议纪要
}

class TempMember {
  int userId;
  String name;
  String head;

  TempMember({this.userId, this.name, this.head});
}
