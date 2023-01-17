import 'package:flutter/material.dart';

enum MsgMenuValue { groupChat, addFriend, joinTeam, scan }
enum NoteMenuValue { share, delete, save }
enum DynamicMenuValue { share, delete, hidden, edit }
enum TradeMenuValue { hate, report }
enum TradeMenuValue2 { share, edit, delete }
enum ContactMenuValue { friendVerification, myGroups } //好友验证  //我的群聊
enum AddContactMenuValue { book, scan, qrcode }
enum AddFriendMenuValue { phone, contacts, scan, qrcode } //添加好友
enum AddMemberMenuValue { phone, contacts, qrcode, cobiz } //团队添加成员
enum TeamMenuValue {
  teamMembers, //团队成员
  switchTeam, //切换团队
  createTeam, //创建团队
  joinTeam, //加入团队
  teamSetting, //团队设置
  security, //数据安全
  collaborativeWork, //协同工作
  groups, //我的小组
  organization, //组织架构
  addTeamMember, //团队添加成员
  teamMemberVerify, //团队成员验证通过
}

class PMenuItem {
  final dynamic value;
  final String icon;
  final String title;
  final TextStyle titleStyle;
  final String label;

  PMenuItem(this.value, this.title, this.icon, {this.titleStyle, this.label});
}
