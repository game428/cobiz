import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/http/contact.dart' as contactApi;
import 'package:cobiz_client/http/res/contact.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat_page.dart';
import 'package:cobiz_client/pages/team/friend/friend_verify_msg.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/pinyin/pinyin_helper.dart';
import 'package:cobiz_client/ui/az_list_view/azlistview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_contact_picker/easy_contact_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneContactsPage extends StatefulWidget {
  final int from; // 1.好友 2.团队
  final List<Contact> contacts;
  final int teamId;

  const PhoneContactsPage({Key key, this.from, this.contacts, this.teamId})
      : super(key: key);

  @override
  _PhoneContactsPageState createState() => _PhoneContactsPageState();
}

class _PhoneContactsPageState extends State<PhoneContactsPage>
    with AutomaticKeepAliveClientMixin {
  List<MyContact> _contacts = [];
  double _suspensionHeight = 30;
  double _itemHeight = 64.4; // 56.3
  String _suspensionTag = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    List<String> _phones = [];
    if ((widget.contacts?.length ?? 0) > 0) {
      widget.contacts.forEach((contact) {
        _contacts.add(MyContact(
          fullName: contact.fullName,
          phoneNumber: contact.phoneNumber,
          tagIndex: contact.firstLetter,
        ));
        _phones.add(
            contact.phoneNumber.trim().replaceAll(' ', '').replaceAll('-', ''));
      });
    }

    _handleList();
    _matchData(_phones);
  }

  Future<void> _matchData(List<String> phones) async {
    int defaultSize = 1000;
    List<List<String>> list = [];
    int count = phones.length ~/ defaultSize +
        (phones.length % defaultSize > 0 ? 1 : 0);
    for (var i = 0; i < count; i++) {
      var tmp = i * defaultSize + defaultSize;
      list.add(phones.sublist(
          i * defaultSize, phones.length > tmp ? tmp : phones.length));
    }
    bool _isModify = false;
    for (List<String> tmp in list) {
      List<ContactMatch> matches = await contactApi.matchContacts(tmp);
      if (matches == null || matches.length < 1) continue;
      for (MyContact contact in _contacts) {
        for (ContactMatch match in matches) {
          if (contact.phoneNumber
                  .trim()
                  .replaceAll(' ', '')
                  .replaceAll('-', '') ==
              match.phone) {
            contact.userId = match.userId;
            contact.userName = match.name;
            contact.userAvatar = match.avatar;
            contact.isFriend = match.isFriend;
            _isModify = true;
            break;
          }
        }
      }
    }
    if (_isModify && mounted) {
      setState(() {});
    }
  }

  void _handleList() {
    if (_contacts == null || _contacts.isEmpty) return;
    for (int i = 0, length = _contacts.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(_contacts[i].fullName);
      String tag = pinyin.substring(0, 1).toUpperCase();
      _contacts[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        _contacts[i].tagIndex = tag;
      } else {
        _contacts[i].tagIndex = "#";
      }
    }
    _suspensionTag = _contacts[0].tagIndex;
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
          bottom: BorderSide(width: 0.3, color: Color(0xFFBCBCBC)),
        ),
        color: normal ? Colors.white : greyF6Color,
      ),
      child: Text(
        '$susTag',
        softWrap: false,
      ),
    );
  }

  Future _invite(MyContact myContact) async {
    if (widget.from == 1) {
      routePush(FriendVerifyMsg(myContact: myContact));
    } else {
      print('邀请他加入 还是直接把他添加进来');
    }
  }

  Widget _buildListItem(MyContact model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag, true),
        ),
        ListItemView(
          iconWidget: model.isFriend == true
              ? ImageView(
                  img: cuttingAvatar(model.userAvatar),
                  width: 42.0,
                  height: 42.0,
                  needLoad: true,
                  isRadius: 21,
                )
              : Container(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(21.0),
                      side: BorderSide(color: Colors.grey, width: 0.3),
                    ),
                    color: AppColors.mainColor,
                  ),
                  alignment: Alignment.center,
                  width: 42.0,
                  height: 42.0,
                  child: Text(
                      model.fullName.length > 2
                          ? model.fullName.substring(
                              model.fullName.length - 2, model.fullName.length)
                          : model.fullName,
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
          titleWidget: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: model.userName == null
                            ? ''
                            : ' (${model.userName})',
                        style: TextStyle(fontSize: 12, color: greyBCColor))
                  ],
                  text: model.fullName,
                  style: TextStyle(fontSize: 16, color: Colors.black))),
          label: model.phoneNumber,
          dense: true,
          paddingRight: 20.0,
          widgetRt1: model.isFriend == true
              ? Text(
                  S.of(context).added,
                  style: TextStyle(color: greyC6Color),
                )
              : CupertinoButton(
                  child: ImageView(
                    img: 'assets/images/ic_add.png',
                  ),
                  minSize: 40.0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  onPressed: () => _invite(model),
                ),
          onPressed: () async {
            if (model.isFriend == true) {
              if (widget.from == 1) {
                routePushReplace(SingleChatPage(
                  userId: model.userId,
                  name: model.userName,
                  avatar: model.userAvatar,
                  whereToChat: 1,
                ));
              }
            } else {
              showSureModal(
                  context, S.of(context).confirmCallPhone(model.phoneNumber),
                  () async {
                String url = "tel:${model.phoneNumber}";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              });
            }
          },
        ),
      ],
    );
  }

  List<Widget> _buildContent() {
    List<Widget> items = [];
    if (_contacts.isEmpty) {
      items.add(buildDefaultNoContent(context));
    } else {
      items.add(Expanded(
        child: AzListView(
          data: _contacts,
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
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: ComMomBar(
          title: S.of(context).phoneContacts,
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: Column(
            children: _buildContent(),
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
