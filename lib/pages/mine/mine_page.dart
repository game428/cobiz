import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat_page.dart';
import 'package:cobiz_client/pages/team/friend/my_contacts.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:cobiz_client/ui/view/operate_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'improve_data.dart';
import 'feedback.dart';
import 'realName/realname_page.dart';
import 'realName/realname_state_page.dart';
import 'system_setting/about.dart';
import 'system_setting/system_setting_page.dart';
import 'package:cobiz_client/tools/storage_utils.dart' as localStorage;
import 'package:cobiz_client/pages/team/friend/invite_qrcode.dart';

class _SettingItem {
  String title;
  String description;
  String icon;
  bool bottomMargin; //下方是否留空
  _SettingType type;

  _SettingItem(this.title, this.icon, this.type,
      {this.description, this.bottomMargin = false});
}

enum _SettingType {
  invite, //邀请好友
  realName, // 实名认证
  contactUs, //联系我们
  feedback, //意见反馈
  setting, //设置
  about, //关于我们
  contacts, //我的联系人
  qr, //我的二维码
}

class MinePage extends StatefulWidget {
  MinePage({Key key}) : super(key: key);

  @override
  _MineBarState createState() => _MineBarState();
}

class _MineBarState extends State<MinePage> with AutomaticKeepAliveClientMixin {
  GlobalModel model;
  User _user;
  ChannelStore service;
  bool _haveNewContactApply = false; //是否有新的好友申请

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    model = Provider.of<GlobalModel>(context, listen: false);
    _init();
    if (mounted) {
      setState(() {
        _user = model.userInfo;
      });
    }
  }

  void _init() async {
    ChannelStore channel = await localStorage.getLocalChannel(1, 10);
    if (mounted) {
      setState(() {
        service = channel;
      });
    }
    // 新的好友申请
    eventBus.on(EVENT_NEW_CONTACT_APPLY, (arg) {
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
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void action(BuildContext context, _SettingItem item) async {
    switch (item.type) {
      case _SettingType.invite:
        showToast(context, "敬请期待");
        break;
      case _SettingType.realName:
        if (_user.auditStatus == null) {
          routePush(RealnamePage());
        } else {
          routePush(RealnameStatePage());
        }
        break;
      case _SettingType.contactUs:
        routePush(SingleChatPage(
          userId: 10,
          name: S.of(context).kf,
          avatar: 'assets/images/mine/service.png',
          whereToChat: 3,
        ));
        // showToast(context, "敬请期待");
        break;
      case _SettingType.feedback:
        routePush(FeedBackPage());
        break;
      case _SettingType.setting:
        routePush(SystemSettingPage());
        break;
      case _SettingType.about:
        routePush(AboutPage());
        break;
      case _SettingType.contacts:
        routePush(MyContactPage(
          true,
          newApply: _haveNewContactApply,
        ));
        break;
      case _SettingType.qr:
        routePush(InviteQrcodePage(
          type: 1,
          title: S.of(context).qrCodeCard,
        ));
        break;
    }
  }

  Widget _body(BuildContext context) {
    List<_SettingItem> data = [
      // _SettingItem(S.of(context).realNameVerify,
      //     'assets/images/mine/real_name.png', _SettingType.realName),
      _SettingItem(S.of(context).teamMyContacts,
          'assets/images/team/my_contact.png', _SettingType.contacts),
      _SettingItem(
          S.of(context).myQrc, 'assets/images/qrcode.png', _SettingType.qr),
      _SettingItem(S.of(context).contactUs, 'assets/images/mine/service.png',
          _SettingType.contactUs),
      _SettingItem(S.of(context).feedback, 'assets/images/mine/feedback.png',
          _SettingType.feedback),
      _SettingItem(S.of(context).settings, 'assets/images/mine/setting.png',
          _SettingType.setting),
    ];
    return Expanded(
        child: SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
          children: data
              .map((item) => OperateLineView(
                    icon: item.icon,
                    title: item.title,
                    rightWidget: (item.type == _SettingType.contactUs &&
                                (service?.unread ?? 0) > 0) ||
                            (item.type == _SettingType.contacts &&
                                _haveNewContactApply)
                        ? buildMessaged()
                        : SizedBox(
                            height: 18,
                          ),
                    onPressed: () => action(context, item),
                  ))
              .toList()),
    ));
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15),
              bottomRight: Radius.circular(15))),
      padding: EdgeInsets.only(top: ScreenData.topSafeHeight, bottom: 20.0),
      child: ListRowView(
        color: AppColors.mainColor,
        haveBorder: false,
        paddingRight: 15.0,
        paddingLeft: 15.0,
        paddingTop: 30.0,
        iconRt: 15.0,
        iconWidget: InkWell(
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.circular(40.0),
                side: BorderSide(color: Colors.grey, width: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: ImageView(
                img: cuttingAvatar(_user?.avatar ?? ''),
                needLoad: true,
                width: 65,
                height: 65,
              ),
            ),
          ),
          // onTap: () => onProfileImageClick(model),
        ),
        titleWidget: Text(
          _user?.nickname ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.myStyle,
        ),
        labelWidget: Container(
          padding: EdgeInsets.only(
            top: 5.0,
          ),
          child: Text(
            '+${_user?.code}-${_user?.phone}',
            style: TextStyles.textF14T2,
          ),
        ),
        widgetRt1: Container(
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
            ),
          ),
        ),
        // onPressed: () => routePush(UpdateUserPage()),
        onPressed: () async {
          bool isChange = await routePush(ImproveDataPage(
            from: 2,
          ));
          if (isChange == true && mounted) {
            setState(() {
              _user = model.userInfo;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.specialBgGray,
      body: Column(
        children: [
          _header(context),
          _body(context),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
