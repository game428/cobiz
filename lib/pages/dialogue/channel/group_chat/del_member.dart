import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/group.dart' as groupApi;
import 'package:cobiz_client/http/res/y_group.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

///联系人选择页面
class DelMemberPage extends StatefulWidget {
  final List<GroupMember> members;
  final int groupId;
  final int groupType;
  final GroupInfo groupInfo;
  DelMemberPage(this.members, this.groupId, this.groupInfo, this.groupType,
      {Key key})
      : super(key: key);

  @override
  _DelMemberPageState createState() => _DelMemberPageState();
}

class _DelMemberPageState extends State<DelMemberPage> {
  List<ContactExtendIsSelected> _contacts = List();
  GroupMember userM;
  double _suspensionHeight = 30;
  String _suspensionTag = '';
  double _itemHeight = 56.5;
  int memberNum = 0;

  @override
  void initState() {
    super.initState();
    _localData();
  }

  void _localData() {
    _contacts.clear();
    if ((widget.members?.length ?? 0) > 0) {
      widget.members.forEach((member) {
        if (member.userId != API.userInfo.id) {
          _contacts.add(ContactExtendIsSelected(
              userId: member.userId,
              name: member.nickname,
              avatarUrl: member.avatar,
              isSelected: false));
        } else {
          userM = member;
        }
      });
      _handleList();
    }
  }

  void _handleList() {
    if (_contacts == null || _contacts.isEmpty) return;
    for (int i = 0, length = _contacts.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_contacts[i].name ?? '');
      String tag =
          strNoEmpty(pinyin) ? pinyin.substring(0, 1).toUpperCase() : '';
      _contacts[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        _contacts[i].tagIndex = tag;
      } else {
        _contacts[i].tagIndex = "#";
      }
    }
    SuspensionUtil.sortListBySuspensionTag(_contacts);
    _suspensionTag = _contacts[0].tagIndex;
  }

  Widget _buildSusWidget(String susTag, bool normal) {
    return Container(
      height: _suspensionHeight.toDouble(),
      margin: normal
          ? EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            )
          : null,
      padding: EdgeInsets.only(
        left: normal ? 15.0 : 30.0,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.3, color: greyBCColor),
        ),
        color: normal ? Colors.white : greyF6Color,
      ),
      child: Text(
        '$susTag',
        softWrap: false,
      ),
    );
  }

  Widget _buildListItem(ContactExtendIsSelected model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag, true),
        ),
        RadioLineView(
            paddingLeft: 20,
            color: model.isCanChange == true
                ? Colors.white
                : greyEAColor.withOpacity(0.3),
            radioIsCanChange: model.isCanChange,
            checkCallback: () {
              model.isSelected = !model.isSelected;
              List<ContactExtendIsSelected> selectList =
                  _contacts.where((item) => item.isSelected).toList();
              if (mounted) {
                setState(() {
                  memberNum = selectList.length;
                });
              }
            },
            checked: model.isSelected,
            iconRt: 0,
            content: IgnorePointer(
                child: ListItemView(
                    color: model.isCanChange == true
                        ? Colors.white
                        : greyEAColor.withOpacity(0.3),
                    paddingLeft: 0,
                    title: model.name,
                    iconWidget: ImageView(
                      img: cuttingAvatar(model.avatarUrl),
                      width: 42.0,
                      height: 42.0,
                      needLoad: true,
                      isRadius: 21.0,
                      fit: BoxFit.cover,
                    ))))
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: ScreenData.width,
      padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
      child: FlatButton(
        shape: StadiumBorder(),
        child: Row(
          children: <Widget>[
            ImageView(
              img: searchImage,
            ),
            Expanded(
              child: Text(
                S.of(context).search,
                style: TextStyles.textF14T1,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
          ],
        ),
        color: greyF6Color,
        onPressed: () {
          routeMaterialPush(SearchCommonPage(
            pageType: 2,
            data: _contacts,
          )).then((value) {
            if (value == null) return;
            ContactExtendIsSelected searchItem = _contacts[value];
            searchItem.isSelected = !searchItem.isSelected;
            List<ContactExtendIsSelected> selectList =
                _contacts.where((item) => item.isSelected).toList();
            if (mounted) {
              setState(() {
                memberNum = selectList.length;
              });
            }
          });
        },
      ),
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [_buildHeader()];
    items.add(Expanded(
      child: AzListView(
        data: _contacts,
        physics: BouncingScrollPhysics(),
        header: AzListViewHeader(
            tag: '+',
            height: 0,
            builder: (context) {
              return Container();
            }),
        itemBuilder: (context, model) => _buildListItem(model),
        suspensionWidget: _buildSusWidget(_suspensionTag, false),
        showStat: false,
        isUseRealIndex: true,
        curTag: _suspensionTag,
        itemHeight: _itemHeight,
        suspensionHeight: _suspensionHeight,
        onSusTagChanged: _onSusTagChanged,
        indexHintBuilder: (context, hint) {
          return Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            decoration:
                BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            child: Text(hint,
                style: TextStyle(color: Colors.white, fontSize: 30.0)),
          );
        },
      ),
    ));
    return items;
  }

  void _onSusTagChanged(String tag) {
    if (mounted) {
      setState(() {
        _suspensionTag = tag;
      });
    }
  }

  Widget _rightW() {
    return buildSureBtn(
      text: '${S.of(context).remove}(${memberNum ?? 0})',
      textStyle:
          (memberNum ?? 0) > 0 ? TextStyles.textF14T2 : TextStyles.textF14T1,
      color: (memberNum ?? 0) > 0 ? Colors.red : greyECColor,
      onPressed: () async {
        if ((memberNum ?? 0) == 0) return;
        List<int> intList = List();
        List<GroupMember> membersList = [userM];
        _contacts.forEach((item) {
          if (item.isSelected == true) {
            intList.add(item.userId);
          } else {
            membersList.add(GroupMember.fromJsonMap({
              "userId": item.userId,
              "nickname": item.name,
              "avatar": item.avatarUrl
            }));
          }
        });

        if (widget.groupType == 0) {
          bool state = await groupApi.removeToGroup(widget.groupId, intList);
          if (state) {
            Navigator.pop(context, membersList);
          }
        } else if (widget.groupType == 2) {
          bool removeState = await teamApi.tGroupMemDeal(
              teamId: widget.groupInfo.teamId,
              groupId: widget.groupInfo.thirdId,
              add: false,
              memberIds: intList);
          if (removeState) {
            Navigator.pop(context, membersList);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).deleteGroupPerson,
        rightDMActions: <Widget>[_rightW()],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: _buildContent(),
        ),
      ),
    );
  }
}
