import 'package:cobiz_client/http/res/team_model/team_member.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';

//团队成员
class TeamMemberExtend extends ISuspensionBean {
  TeamMember member;
  int teamId;
  String tagIndex;
  String namePinyin;

  TeamMemberExtend({this.member, this.teamId, this.tagIndex, this.namePinyin});

  @override
  String getSuspensionTag() => tagIndex;
}

// 选中的团队成员
class TeamMemberSelected extends ISuspensionBean {
  int userId;
  String name;
  String avatarUrl;
  int teamId;
  String tagIndex;
  String namePinyin;
  bool isSelected; //是否选中
  bool isCanChange; //能否改变勾选状态

  TeamMemberSelected(
      {this.userId,
      this.name,
      this.avatarUrl,
      this.teamId,
      this.tagIndex,
      this.namePinyin,
      this.isSelected = false,
      this.isCanChange = true});

  @override
  String getSuspensionTag() => tagIndex;
}

//手机通讯录
class MyContact extends ISuspensionBean {
  final String fullName;
  final String phoneNumber;
  String tagIndex;
  String namePinyin;
  int userId;
  String userName;
  String userAvatar;
  bool isFriend;

  MyContact(
      {this.fullName,
      this.phoneNumber,
      this.tagIndex,
      this.namePinyin,
      this.userId,
      this.userName,
      this.userAvatar,
      this.isFriend = false});

  @override
  String getSuspensionTag() => tagIndex;
}

//Cobiz联系人
class ContactExtend extends ISuspensionBean {
  int userId;
  String name;
  String avatarUrl;
  int status;
  String tagIndex;
  String namePinyin;

  ContactExtend({
    this.userId,
    this.name,
    this.avatarUrl,
    this.status,
    this.tagIndex,
    this.namePinyin,
  });

  @override
  String getSuspensionTag() => tagIndex;
}

// 选中的联系人
class ContactExtendIsSelected extends ISuspensionBean {
  int userId;
  String name;
  String avatarUrl;
  int status;
  String tagIndex;
  String namePinyin;
  bool isSelected; //是否选中
  bool isCanChange; //能否改变勾选状态

  ContactExtendIsSelected(
      {this.userId,
      this.name,
      this.avatarUrl,
      this.status,
      this.tagIndex,
      this.namePinyin,
      this.isSelected = false,
      this.isCanChange = true});

  @override
  String getSuspensionTag() => tagIndex;
}
