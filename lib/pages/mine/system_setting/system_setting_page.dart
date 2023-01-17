import 'package:cobiz_client/config/jpush_manager.dart';
import 'package:cobiz_client/http/user.dart' as userApi;
import 'package:cobiz_client/pages/login/login_page.dart';
import 'package:cobiz_client/pages/mine/system_setting/about.dart';
import 'package:cobiz_client/pages/mine/system_setting/font_size_set.dart';
import 'package:cobiz_client/pages/mine/system_setting/language_page.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/common_widget.dart';
import 'package:cobiz_client/tools/temporary_cache.dart';
import 'package:cobiz_client/ui/dialog/loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobpush_plugin/mobpush_plugin.dart';

import 'black_list.dart';
import 'notify_settings_page.dart';

enum _SystemSettingType {
  notificationSound, // 通知声音
  fontsize,
  // privacySecurity, // 隐私安全
  // dataStorage, // 数据存储
  language, // 语言
  clearCache, // 清除缓存
  blacklist, // 黑名单列表
  about //关于
}

class _SettingItem {
  String title;
  String description;
  String icon;
  bool bottomMargin; //下方是否留空
  _SystemSettingType type;

  _SettingItem(this.title, this.icon, this.type,
      {this.description, this.bottomMargin = false});
}

class SystemSettingPage extends StatefulWidget {
  SystemSettingPage({Key key}) : super(key: key);

  @override
  _SystemSettingPageState createState() => _SystemSettingPageState();
}

class _SystemSettingPageState extends State<SystemSettingPage> {
  String _cache = '';

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  _initCache() async {
    _cache = await TemporaryCache.loadCache();
    if (mounted) {
      setState(() {});
    }
  }

  void action(_SettingItem item) async {
    switch (item.type) {
      case _SystemSettingType.notificationSound:
        _changeNoticeSettings();
        break;
      // case _SystemSettingType.privacySecurity:
      //   routePush(PrivacySettingsPage());
      // break;
      // case _SystemSettingType.dataStorage:
      //   routePush(StoreSettingsPage());
      //   break;
      case _SystemSettingType.language:
        routePush(LanguagePage());
        break;
      case _SystemSettingType.clearCache:
        showSureModal(context, S.of(context).clearCache, () {
          Loading.before(context: context, text: S.of(context).clearCache);
          StorageManager.sp.getKeys().forEach((element) async {
            if (element.startsWith(Keys.contactInfo) ||
                element.startsWith(Keys.groupInfo)) {
              await SharedUtil.instance.remove(element);
            }
          });
          TemporaryCache.clearCache();
          Future.delayed(Duration(seconds: 2), () {
            Loading.complete();
            _initCache();
            showToast(context, S.of(context).clearSuccess);
          });
        });
        break;
      case _SystemSettingType.blacklist:
        routePush(BlackListPage());
        break;
      case _SystemSettingType.about:
        routePush(AboutPage());
        break;
      case _SystemSettingType.fontsize:
        routePush(FontSizePage());
        break;
    }
  }

  // 消息设置
  Future<void> _changeNoticeSettings() async {
    final Map result = await routePush(NotifySettingsPage());
    if (result == null || result.length < 1) return;
    userApi.modifySettings(context, result['newMsg'], result['msgDetail'],
        result['voice'], result['vibrate']);
  }

  // 退出登录
  void _logout() async {
    Loading.before(context: context);
    await userApi.logout(context);
    Loading.complete();
    if (Platform.isIOS != null && Platform.isIOS) {
      JPushManager.jpush.deleteAlias();
    } else {
      MobpushPlugin.deleteAlias();
    }
    routePushAndRemove(LoginPage());
  }

  List<Widget> buildItems() {
    List<Widget> list = [];
    List<_SettingItem> data = [
      _SettingItem(S.of(context).notificationSettings,
          'assets/images/mine/sound.png', _SystemSettingType.notificationSound),
      _SettingItem(S.of(context).changeLanguage,
          'assets/images/mine/language.png', _SystemSettingType.language),
      _SettingItem(S.of(context).fontSize, 'assets/images/mine/font_size.png',
          _SystemSettingType.fontsize),
      // _SettingItem(
      //     S.of(context).privacySecurity,
      //     'assets/images/mine/password.png',
      //     _SystemSettingType.privacySecurity),
      // _SettingItem(S.of(context).dataStore, 'assets/images/mine/backup.png',
      //     _SystemSettingType.dataStorage),
      _SettingItem(S.of(context).clearCache,
          'assets/images/mine/clear_cache.png', _SystemSettingType.clearCache),
      _SettingItem(S.of(context).blacklist, 'assets/images/mine/black_list.png',
          _SystemSettingType.blacklist),
      _SettingItem(S.of(context).aboutUs, logoImage, _SystemSettingType.about),
    ];

    data.forEach((e) {
      list.add(OperateLineView(
        title: e.title,
        icon: e.icon,
        rightWidget: e.type == _SystemSettingType.clearCache
            ? Flexible(
                child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  _cache,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: grey81Color, fontSize: 14),
                  maxLines: 1,
                ),
              ))
            : null,
        onPressed: () => action(e),
      ));
    });

    list.add(Spacer());
    list.add(buildCommonButton(
      S.of(context).signOut,
      backgroundColor: red68Color,
      margin: EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 20.0,
      ),
      onPressed: () {
        showSureModal(context, S.of(context).signOutInfo, _logout);
      },
    ));

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context, listen: false);
    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).systemSettings,
        elevation: 0.5,
      ),
      body: Container(
        color: model.currentTheme.primaryTheme.backgroundColor,
        child: Column(
          children: buildItems(),
        ),
      ),
    );
  }
}
