import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/res/team_model/team_member.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';
import 'package:cobiz_client/ui/view/radio_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;

class SelectGroupMembersPage extends StatefulWidget {
  final int groupId; //小组 就是小组id  部门就是部门id
  final int teamId; //团队id
  final List<int> memberList; // 已选中群员
  final int showType; //1：不包含自己 2：包含自己 3：不包含自己 可以取消选中
  final String title;
  const SelectGroupMembersPage(
      {Key key,
      this.groupId,
      this.memberList,
      @required this.teamId,
      this.showType = 1,
      this.title})
      : super(key: key);

  @override
  _SelectGroupMembersPageState createState() => _SelectGroupMembersPageState();
}

class _SelectGroupMembersPageState extends State<SelectGroupMembersPage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;

  List<TeamMemberSelected> _members = List();
  double _suspensionHeight = 30;
  double _itemHeight = 64.4; // 56.3
  String _suspensionTag = '';

  int _selectedNum = 0;
  List<TeamMemberSelected> _selectedList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _getMembers();
  }

  Future _getMembers() async {
    _parseStores(await localStorage.getLocalMembers(widget.teamId));
    List<TeamMember> res =
        await teamApi.getTeamMembers(teamId: widget.teamId, type: 1);
    if (res != null) {
      _parseStores(await localStorage.updateLocalMembers(widget.teamId, res));
    }
  }

  void _parseStores(List<TeamMember> stores) {
    _members.clear();
    _selectedNum = 0;
    _selectedList.clear();
    if ((stores?.length ?? 0) > 0) {
      stores.forEach((store) {
        if (widget.showType == 1) {
          if (store.userId != API.userInfo.id) {
            if (widget.memberList != null &&
                widget.memberList.length > 0 &&
                widget.memberList.contains(store.userId)) {
              _members.add(TeamMemberSelected(
                  userId: store.userId,
                  name: store.name,
                  avatarUrl: store.avatar,
                  teamId: widget.teamId,
                  isSelected: true,
                  isCanChange: false));
            } else {
              _members.add(TeamMemberSelected(
                userId: store.userId,
                name: store.name,
                avatarUrl: store.avatar,
                teamId: widget.teamId,
                isSelected: false,
              ));
            }
          }
        } else if (widget.showType == 2) {
          if (widget.memberList != null &&
              widget.memberList.length > 0 &&
              widget.memberList.contains(store.userId)) {
            _members.add(TeamMemberSelected(
                userId: store.userId,
                name: store.name,
                avatarUrl: store.avatar,
                teamId: widget.teamId,
                isSelected: true,
                isCanChange: false));
          } else {
            _members.add(TeamMemberSelected(
              userId: store.userId,
              name: store.name,
              avatarUrl: store.avatar,
              teamId: widget.teamId,
              isSelected: false,
            ));
          }
        } else {
          if (store.userId != API.userInfo.id) {
            if (widget.memberList != null &&
                widget.memberList.length > 0 &&
                widget.memberList.contains(store.userId)) {
              _members.add(TeamMemberSelected(
                userId: store.userId,
                name: store.name,
                avatarUrl: store.avatar,
                teamId: widget.teamId,
                isSelected: true,
              ));
              _selectedList.add(TeamMemberSelected(
                userId: store.userId,
                name: store.name,
                avatarUrl: store.avatar,
                teamId: widget.teamId,
                isSelected: true,
              ));
              _selectedNum++;
            } else {
              _members.add(TeamMemberSelected(
                userId: store.userId,
                name: store.name,
                avatarUrl: store.avatar,
                teamId: widget.teamId,
                isSelected: false,
              ));
            }
          }
        }
      });
      _handleList();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleList() {
    if (_members == null || _members.isEmpty) return;
    for (int i = 0, length = _members.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_members[i].name);
      String tag =
          strNoEmpty(pinyin) ? pinyin.substring(0, 1).toUpperCase() : '';
      _members[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        _members[i].tagIndex = tag;
      } else {
        _members[i].tagIndex = "#";
      }
    }
    SuspensionUtil.sortListBySuspensionTag(_members);
    _suspensionTag = _members[0].tagIndex;
  }

  void _onSusTagChanged(String tag) {
    if (mounted) {
      setState(() {
        _suspensionTag = tag;
      });
    }
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

  Widget _buildListItem(TeamMemberSelected model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag, true),
        ),
        /* 
          是否是勾选框
          是否是勾选框
        */
        RadioLineView(
          paddingLeft: 20,
          color: model.isCanChange == true
              ? Colors.white
              : greyEAColor.withOpacity(0.3),
          radioIsCanChange: model.isCanChange,
          checkCallback: () {
            if (mounted && model.isCanChange == true) {
              model.isSelected = !model.isSelected;
              List<TeamMemberSelected> selectList = [];
              for (var i = 0; i < _members.length; i++) {
                if (_members[i].isSelected == true &&
                    _members[i].isCanChange == true) {
                  selectList.add(_members[i]);
                }
              }
              _selectedNum = selectList.length;
              _selectedList = selectList;
              setState(() {});
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
              title: '${model.name}',
              iconWidget: ImageView(
                img: cuttingAvatar(model.avatarUrl),
                width: 42.0,
                height: 42.0,
                needLoad: true,
                isRadius: 21.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [
      buildSearch(context, onPressed: () {
        routeMaterialPush(SearchCommonPage(
          pageType: 16,
          data: _members,
        )).then((value) {
          if (value != null && _members[value].isCanChange == true) {
            _members[value].isSelected = !_members[value].isSelected;
            List<TeamMemberSelected> selectList = [];
            for (var i = 0; i < _members.length; i++) {
              if (_members[i].isSelected == true) {
                selectList.add(_members[i]);
              }
            }
            _selectedNum = selectList.length;
            _selectedList = selectList;
            if (mounted) {
              setState(() {});
            }
          }
        });
      })
    ];
    items.add(Expanded(
      child: AzListView(
        data: _members,
        itemBuilder: (context, model) => _buildListItem(model),
        suspensionWidget: _buildSusWidget(_suspensionTag, false),
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget rWidget = buildSureBtn(
        text: S.of(context).selectedNum(_selectedNum),
        textStyle: TextStyles.textF14T2,
        color: AppColors.mainColor,
        onPressed: () {
          List<int> ids = [];
          List<String> names = [];
          _selectedList.forEach((element) {
            ids.add(element.userId);
            names.add(element.name);
          });
          Navigator.pop(context, {
            "ids": ids,
            "names": names,
            "groupId": widget.groupId,
            "teamId": widget.teamId
          });
        });

    return Scaffold(
      appBar: ComMomBar(
        title: widget.title ?? S.of(context).teamAddMember,
        elevation: 0.5,
        rightDMActions: <Widget>[rWidget],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: _isLoading
            ? buildProgressIndicator()
            : Column(
                children: _buildContent(),
              ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
