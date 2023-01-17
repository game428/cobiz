//我的联系人
import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_info_page.dart';
import 'package:cobiz_client/pages/team/friend/add_friend.dart';
import 'package:cobiz_client/pages/team/friend/friend_verify.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/pages/team/friend/my_groups.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/common_widget.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';
import 'package:cobiz_client/ui/view/list_item_view.dart';
import 'package:cobiz_client/ui/view/operate_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as storageApi;
import 'package:cobiz_client/http/contact.dart' as contactApi;
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/domain/storage_domain.dart';

class MyContactPage extends StatefulWidget {
  final bool hasTeam;
  final bool newApply;
  MyContactPage(this.hasTeam, {Key key, this.newApply = false})
      : super(key: key);

  @override
  _MyContactPageState createState() => _MyContactPageState();
}

class _MyContactPageState extends State<MyContactPage> {
  List<ContactExtend> _contacts = List();
  bool _haveNewContactApply = false;
  bool _isLoading = true;
  double _suspensionHeight = 30;
  double _itemHeight = 56.5;
  String _suspensionTag = '';

  Type typeOf<T>() => T;
  ScrollController _innerC;

  int _resNum = 0;

  @override
  void initState() {
    super.initState();

    ///没有团队时 获取头部主控制器
    if (widget.hasTeam == false) {
      PrimaryScrollController primaryScrollController =
          // ignore: deprecated_member_use
          context.ancestorWidgetOfExactType(typeOf<PrimaryScrollController>());
      _innerC = primaryScrollController.controller;
    }

    _initListener();
    _localData();
  }

  @override
  void dispose() {
    eventBus.off(EVENT_NEW_CONTACT_APPLY, _contactApplyEvent);
    eventBus.off(EVENT_UPDATE_CONTACT_LIST, _contactJoin);
    super.dispose();
  }

  _initListener() {
    _haveNewContactApply = widget.newApply;
    eventBus.on(EVENT_NEW_CONTACT_APPLY, _contactApplyEvent);
    eventBus.on(EVENT_UPDATE_CONTACT_LIST, _contactJoin);
  }

  _contactJoin(arg) {
    if (arg == true) {
      _isLoading = true;
      _loadData();
    }
  }

  _contactApplyEvent(arg) {
    if (arg == true && _haveNewContactApply == false) {
      if (mounted) {
        setState(() {
          _haveNewContactApply = true;
        });
      }
    }
    if (arg == false && _haveNewContactApply == true) {
      if (mounted) {
        setState(() {
          _haveNewContactApply = false;
        });
      }
    }
  }

  void _action(ContactMenuValue contactMenuValue) {
    switch (contactMenuValue) {
      case ContactMenuValue.friendVerification:
        routePush(FriendVerifyPage()).then((value) {
          if (mounted && _haveNewContactApply == true) {
            ///更新底部已读
            eventBus.emit(EVENT_NEW_CONTACT_APPLY, false);
            setState(() {
              _haveNewContactApply = false;
            });
          }
        });
        break;
      case ContactMenuValue.myGroups:
        routePush(MyGropusPage());
        break;
    }
  }

  // 使用本地数据
  Future _localData() async {
    _parseStores(await storageApi.getLocalContacts());
    _loadData();
  }

  // 获取线上数据
  Future _loadData() async {
    try {
      _resNum++;
      List<ContactStore> contacts;
      if (_resNum == 1) {
        contacts = await contactApi.getContacts();
        if (contacts != null) {
          _parseStores(await storageApi.updateLocalContacts(contacts));
        } else {
          if (_resNum < 4) {
            Future.delayed(Duration(seconds: 3), () async {
              _loadData();
            });
          }
        }
      } else {
        Future.delayed(Duration(seconds: 3), () async {
          contacts = await contactApi.getContacts();
          if (contacts != null) {
            _parseStores(await storageApi.updateLocalContacts(contacts));
          } else {
            if (_resNum < 4) {
              _loadData();
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Load contacts error: $e');
    }
  }

  void _parseStores(List<ContactStore> stores) {
    _contacts.clear();
    if ((stores?.length ?? 0) > 0) {
      stores.forEach((store) {
        _contacts.add(ContactExtend(
            userId: store.uid,
            name: store.name,
            avatarUrl: store.avatar,
            status: store.status));
      });
      _handleList();
    }
    _isLoading = false;
    if (mounted) setState(() {});
  }

  void _handleList() {
    if (_contacts == null || _contacts.isEmpty) return;
    for (int i = 0, length = _contacts.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_contacts[i].name ?? '',
          isLast: strNoEmpty(_contacts[i].name) &&
              (_contacts[i].name.startsWith('曾') ||
                  _contacts[i].name.startsWith('曽')));
      String tag =
          strNoEmpty(pinyin) ? pinyin.substring(0, 1).toUpperCase() : '';
      _contacts[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        _contacts[i].tagIndex = tag;
      } else {
        _contacts[i].tagIndex = "#";
      }
    }
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
          bottom: BorderSide(width: 0.3, color: greyDFColor),
        ),
        color: normal ? Colors.white : greyF6Color,
      ),
      child: Text(
        '$susTag',
        softWrap: false,
      ),
    );
  }

  Widget _buildListItem(ContactExtend model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag, true),
        ),
        ListItemView(
          iconWidget: ImageView(
            img: cuttingAvatar(model.avatarUrl),
            width: 42.0,
            height: 42.0,
            needLoad: true,
            isRadius: 21.0,
            fit: BoxFit.cover,
          ),
          title: model.name,
          onPressed: () {
            routePush(SingleInfoPage(
              userId: model.userId,
              whereToInfo: 2,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    List<PMenuItem> menus = [
      PMenuItem(ContactMenuValue.friendVerification, S.of(context).friendVerify,
          'assets/images/team/new_member.png'),
      PMenuItem(ContactMenuValue.myGroups, S.of(context).myGroups,
          'assets/images/team/team.png'),
    ];

    List<Widget> items = [
      buildSearch(context, onPressed: () {
        routeMaterialPush(SearchCommonPage(
          pageType: 4,
          data: _contacts,
        ));
      })
    ];
    items.addAll(menus.map((menu) {
      return OperateLineView(
        icon: menu.icon,
        iconLeft: 0.0,
        title: menu.title,
        rightWidget: (menu.value == ContactMenuValue.friendVerification &&
                _haveNewContactApply)
            ? buildMessaged()
            : null,
        onPressed: () => _action(menu.value),
      );
    }).toList());
    return Column(
      children: items,
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [];
    items.add(Expanded(
      child: AzListView(
        data: _contacts,
        controller: _innerC,
        header: AzListViewHeader(
            tag: '+',
            height: _itemHeight * 3,
            builder: (context) {
              return _buildHeader();
            }),
        itemBuilder: (context, model) => _buildListItem(model),
        suspensionWidget: _buildSusWidget(_suspensionTag, false),
        showStat: true,
        isUseRealIndex: true,
        showSus: _innerC == null,
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
    Widget rWidget = InkWell(
      child: Container(
        child: ImageView(
          img: 'assets/images/ic_add.png',
        ),
      ),
      onTap: () {
        routePush(AddFriendPage());
      },
    );

    return Scaffold(
      appBar: widget.hasTeam
          ? ComMomBar(
              title: S.of(context).teamMyContacts,
              elevation: 0.5,
              centerTitle: widget.hasTeam,
              rightDMActions: [rWidget],
            )
          : null,
      body: _isLoading
          ? buildProgressIndicator()
          : ScrollConfiguration(
              behavior: MyBehavior(),
              child: Column(
                children: _buildContent(),
              )),
    );
  }
}
