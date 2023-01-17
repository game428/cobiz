//添加好友
import 'package:cobiz_client/domain/menu_domain.dart';
import 'package:cobiz_client/pages/common/scan_deal.dart';
import 'package:cobiz_client/pages/team/friend/invite_qrcode.dart';
import 'package:cobiz_client/pages/team/friend/phone_contacts.dart';
import 'package:cobiz_client/pages/common/search_common.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/operate_line_view.dart';
import 'package:easy_contact_picker/easy_contact_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  AddFriendPage({Key key}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final EasyContactPicker _contactPicker = new EasyContactPicker();
  @override
  void initState() {
    super.initState();
  }

  void _clickTovalue(AddFriendMenuValue addFriendMenuValue) async {
    switch (addFriendMenuValue) {
      case AddFriendMenuValue.phone:
        routePush(SearchCommonPage(
          pageType: 1,
        ));
        break;
      case AddFriendMenuValue.contacts:
        _openAddressBook();
        break;
      case AddFriendMenuValue.scan:
        if (await PermissionManger.cameraPermission()) {
          await Scanner.scanDeal(context);
        } else {
          showConfirm(context, title: S.of(context).cameraPermission,
              sureCallBack: () async {
            await openAppSettings();
          });
        }
        break;
      case AddFriendMenuValue.qrcode:
        routePush(InviteQrcodePage(
          type: 1,
        ));
        break;
    }
  }

  void _openAddressBook() async {
    if (await PermissionManger.contactsPermission()) {
      _getContactData();
    } else {
      showConfirm(context, title: S.of(context).contactPermission,
          sureCallBack: () async {
        await openAppSettings();
      });
    }
  }

  void _getContactData() async {
    List<Contact> list = await _contactPicker.selectContacts();
    routePush(PhoneContactsPage(
      from: 1,
      contacts: list,
    ));
  }

  Widget _buildContent() {
    List<PMenuItem> menus = [
      PMenuItem(AddFriendMenuValue.phone, S.of(context).teamOperateByPhone,
          'assets/images/phone.png'),
      PMenuItem(AddFriendMenuValue.contacts,
          S.of(context).teamOperateByContacts, 'assets/images/contacts.png'),
      PMenuItem(AddFriendMenuValue.scan, S.of(context).scanToAdd,
          'assets/images/ic_scan.png'),
      PMenuItem(AddFriendMenuValue.qrcode, S.of(context).teamOperateByQrcode,
          'assets/images/qrcode.png'),
    ];

    List<Widget> list = [
      buildTextTitle(
        S.of(context).addFriendMark,
        fontSize: FontSizes.font_s14,
        bottom: 10.0,
        haveBorder: true,
        margin: EdgeInsets.symmetric(horizontal: 15.0),
      )
    ];
    list.addAll(menus.map((menu) {
      return OperateLineView(
        icon: menu.icon,
        iconLeft: 0.0,
        title: menu.title,
        spaceSize: 15.0,
        onPressed: () => _clickTovalue(menu.value),
      );
    }));

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
      ),
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: list,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).addFriends,
        elevation: 0.5,
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: _buildContent(),
      ),
    );
  }
}
