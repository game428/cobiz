import 'package:cobiz_client/socket/command.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/tools/cobiz.dart';

class NotifySettingsPage extends StatefulWidget {
  NotifySettingsPage();

  @override
  _NotifySettingsPageState createState() => _NotifySettingsPageState();
}

class _NotifySettingsPageState extends State<NotifySettingsPage> {
  bool _newMsg = true; // 信息通知
  bool _msgDetail = true; // 信息详情
  bool _voice = false; // 声音
  bool _vibrate = true; // 振动

  bool _isOpenNotification = true;

  @override
  void initState() {
    super.initState();

    _newMsg = API.userInfo.newNotice;
    _msgDetail = API.userInfo.noticeDetail;
    _voice = API.userInfo.voiceOpen;
    _vibrate = API.userInfo.vibration;

    eventBus.on(EVENT_WAKE_IN_BACKGROUND, _workInBackground);
    _init();
  }

  @override
  void dispose() {
    eventBus.off(EVENT_WAKE_IN_BACKGROUND);
    super.dispose();
  }

  _workInBackground(arg) async {
    if (arg == true) {
      if (_isOpenNotification !=
          await PermissionManger.notificationPermission()) {
        if (mounted) {
          setState(() {
            _isOpenNotification = !_isOpenNotification;
          });
        }
      }
    }
  }

  _init() async {
    if (await PermissionManger.notificationPermission()) {
      _isOpenNotification = true;
    } else {
      if (mounted) {
        setState(() {
          _isOpenNotification = false;
        });
      }
    }
  }

  List<Widget> body() {
    return [
      buildSwitch(S.of(context).receiveNotice, _newMsg, (v) {
        if (mounted) {
          setState(() {
            _newMsg = v;
          });
        }
      }, label: S.of(context).receiveNoticeLabel),
      buildSwitch(S.of(context).showDetails, _msgDetail, (v) {
        if (mounted) {
          setState(() {
            _msgDetail = v;
          });
        }
      }, isLine: false, label: S.of(context).showDetailsLabel),
      _isOpenNotification
          ? Container()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              width: winWidth(context),
              color: greyEAColor,
              child: Text(
                Platform.isIOS
                    ? S.of(context).noNotificationHintIos
                    : S.of(context).noNotificationHintAndroid,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
      buildDivider(height: 8.0, color: greyEAColor),
      buildSwitch(S.of(context).voice, _voice, (v) {
        if (mounted) {
          setState(() {
            _voice = v;
            if (_voice == true) {
              VibrationPhone.play();
            }
          });
        }
      }, label: S.of(context).voiceTip),
      buildSwitch(S.of(context).vibration, _vibrate, (v) {
        if (mounted) {
          setState(() {
            _vibrate = v;
            if (_vibrate == true) {
              VibrationPhone.checkVibrationPhone();
            }
          });
        }
      }, label: S.of(context).vibrationTip),
    ];
  }

  Map _backData() {
    if (_newMsg == API.userInfo.newNotice &&
        _msgDetail == API.userInfo.noticeDetail &&
        _voice == API.userInfo.voiceOpen &&
        _vibrate == API.userInfo.vibration) {
      return null;
    }
    return {
      'newMsg': _newMsg,
      'msgDetail': _msgDetail,
      'voice': _voice,
      'vibrate': _vibrate
    };
  }

  ///通过手机自带物理返回
  Future<bool> _onWillPop() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, _backData());
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // backgroundColor: Colors.white,
        appBar: ComMomBar(
          title: S.of(context).notificationSettings,
          elevation: 0.5,
          backData: _backData(),
        ),
        body: Column(children: body()),
      ),
    );
  }
}
