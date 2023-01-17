import 'package:cobiz_client/config/jpush_manager.dart';
import 'package:cobiz_client/config/mobPush_manager.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/res/client_version.dart';
import 'package:cobiz_client/pages/android_back_top.dart';
import 'package:cobiz_client/pages/common/upgrade_dialog.dart';
import 'package:cobiz_client/pages/dialogue/dialogue_page.dart';
import 'package:cobiz_client/pages/mine/mine_page.dart';
import 'package:cobiz_client/pages/team/team_page.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/socket/ws_connector.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class RootPage extends StatefulWidget {
  RootPage({Key key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  int _tabIndex = 0;
  List<Widget> _pages = [];
  bool _newMsg = false; //是否有新消息
  bool _teamBotMsg = false; //index 1

  @override
  void initState() {
    super.initState();
    _pages
      // ..add(HomePage())
      ..add(DialoguePage())
      ..add(TeamPage())
      ..add(MinePage());
    _init();
  }

  _init() {
    WidgetsBinding.instance.addObserver(this);
    ChannelManager.getInstance().init();
    WsConnector.connect();
    PushManager.setContext(context);
    if (isIOS()) {
      JPushManager.initPlatformState();
    } else {
      PushManager.initPlatformState();
    }
    _eventInit();
    _checkVersion();
  }

  //事件监听
  _eventInit() {
    // eventBus.on(EVENT_UPDATE_TEAM_JOIN, (arg) {
    //   if (arg == true && _teamBotMsg1 == false) {
    //     if (mounted) {
    //       setState(() {
    //         _teamBotMsg1 = true;
    //       });
    //     }
    //   }
    //   if (arg == false && _teamBotMsg1 == true) {
    //     if (mounted) {
    //       setState(() {
    //         _teamBotMsg1 = false;
    //       });
    //     }
    //   }
    // });
    eventBus.on(EVENT_NEW_CONTACT_APPLY, (arg) {
      if (arg == true && _teamBotMsg == false) {
        if (mounted) {
          setState(() {
            _teamBotMsg = true;
          });
        }
      }
      if (arg == false && _teamBotMsg == true) {
        if (mounted) {
          setState(() {
            _teamBotMsg = false;
          });
        }
      }
    });
    eventBus.on(EVENT_UPDATE_MSG_UNREAD, (arg) {
      if (arg == true && _newMsg == false) {
        if (mounted) {
          setState(() {
            _newMsg = true;
          });
        }
      }
      if (arg == false && _newMsg == true) {
        if (mounted) {
          setState(() {
            _newMsg = false;
          });
        }
      }
    });
  }

  //版本检测
  _checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ClientVersion clientVersion =
        await commonApi.versionCheck(packageInfo.version);
    if (clientVersion != null) {
      if (clientVersion.force == true) {
        showAlert(context,
            canPop: false,
            title: clientVersion.title,
            contentWidget: Html(
              shrinkWrap: true,
              data: clientVersion.content,
            ),
            sureBtn: S.of(context).experienceNow, sureCallBack: () {
          _upgrade(clientVersion.url);
        });
      } else {
        showConfirm(context,
            title: clientVersion.title,
            textAlign: TextAlign.center,
            contentWidget: Html(
              shrinkWrap: true,
              data: clientVersion.content,
            ),
            cancelBtn: S.of(context).afterToTalk,
            sureBtn: S.of(context).experienceNow, sureCallBack: () {
          _upgrade(clientVersion.url);
        });
      }
    }
  }

  _upgrade(String url) async {
    if (Platform.isAndroid) {
      if (await checkPermission()) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return WillPopScope(
                  child: UpgradeDialog(url), onWillPop: () async => false);
            });
      }
    } else if (Platform.isIOS) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch the url';
      }
    } else {
      print('暂无此平台');
    }
  }

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await Permission.storage.request();
      if (permission == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // 从后台模式唤醒
        PushManager.setIsBackstage(false);
        eventBus.emit(EVENT_UPDATE_MSG_STATE, true);
        eventBus.emit(EVENT_WAKE_IN_BACKGROUND, true);
        break;
      case AppLifecycleState.inactive:
        if (isIOS()) {
          JPushManager.jpush.setBadge(0);
        }
        break;
      case AppLifecycleState.paused:
        // APP进入后台模式
        PushManager.setIsBackstage(true);
        //---------同步消息
        ChannelManager.getInstance().syncMsgChannel();
        //---------同步消息
        eventBus.emit(EVENT_ENTER_THE_BACKGROUND, true);
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    eventBus.off(EVENT_UPDATE_MSG_UNREAD);
    eventBus.off(EVENT_NEW_CONTACT_APPLY);
    // eventBus.off(EVENT_UPDATE_TEAM_JOIN);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context, listen: false);

    return WillPopScope(
        onWillPop: () async {
          AndroidBackTop.backDesktop();
          return false;
        },
        child: Scaffold(
          body: IndexedStack(
            children: _pages,
            index: _tabIndex,
          ),
          resizeToAvoidBottomInset: true,
          bottomNavigationBar: Theme(
              data: ThemeData(
                canvasColor: Colors.grey[50],
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: model.currentTheme.lineColor,
                      width: 0.2,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  selectedItemColor: AppColors.mainColor,
                  items: [
                    BottomNavigationBarItem(
                      title: Text(S.of(context).message),
                      icon: _newMsg
                          ? Stack(
                              overflow: Overflow.visible,
                              children: [
                                ImageView(
                                  img: 'assets/images/tabbar_chat_c.png',
                                ),
                                Positioned(right: -5.0, child: buildMessaged())
                              ],
                            )
                          : ImageView(
                              img: 'assets/images/tabbar_chat_c.png',
                            ),
                      activeIcon: _newMsg
                          ? Stack(
                              overflow: Overflow.visible,
                              children: [
                                ImageView(
                                  img: 'assets/images/tabbar_chat_s.png',
                                ),
                                Positioned(right: -5.0, child: buildMessaged())
                              ],
                            )
                          : ImageView(
                              img: 'assets/images/tabbar_chat_s.png',
                            ),
                    ),
                    BottomNavigationBarItem(
                      title: Text(S.of(context).team),
                      icon: ImageView(
                        img: 'assets/images/tabbar_contacts_c.png',
                      ),
                      activeIcon: ImageView(
                        img: 'assets/images/tabbar_contacts_s.png',
                      ),
                    ),
                    BottomNavigationBarItem(
                      title: Text(
                        S.of(context).me,
                      ),
                      icon: _teamBotMsg
                          ? Stack(
                              overflow: Overflow.visible,
                              children: [
                                ImageView(
                                  img: 'assets/images/tabbar_me_c.png',
                                ),
                                Positioned(right: -5.0, child: buildMessaged())
                              ],
                            )
                          : ImageView(
                              img: 'assets/images/tabbar_me_c.png',
                            ),
                      activeIcon: _teamBotMsg
                          ? Stack(
                              overflow: Overflow.visible,
                              children: [
                                ImageView(
                                  img: 'assets/images/tabbar_me_s.png',
                                ),
                                Positioned(right: -5.0, child: buildMessaged())
                              ],
                            )
                          : ImageView(
                              img: 'assets/images/tabbar_me_s.png',
                            ),
                    ),
                  ],
                  currentIndex: _tabIndex,
                  elevation: 20,
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) {
                    if (mounted)
                      setState(() {
                        _tabIndex = index;
                      });
                  },
                ),
              )),
        ));
  }
}
