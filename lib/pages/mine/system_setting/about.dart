import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/res/client_version.dart';
import 'package:cobiz_client/pages/common/upgrade_dialog.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<AboutPage> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(title: S.of(context).aboutUs, elevation: 0.5),
      body: SafeArea(
          child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            SizedBox(
              width: 84,
              height: 84,
              child: Image.asset(logoImage),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              S.of(context).currentVersion(_appVersion),
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              S.of(context).isTheLatestVersion,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Spacer(),
            buildCommonButton(
              S.of(context).cheackUpdate,
              paddingH: 6.0,
              margin: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 70.0,
              ),
              onPressed: () async {
                Loading.before(
                    context: context, text: S.of(context).checkingTheVersion);
                ClientVersion clientVersion =
                    await commonApi.versionCheck(_appVersion);
                Loading.complete();
                if (clientVersion == null) {
                  showToast(context, S.of(context).currentlyTheLatestVersion);
                } else {
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
              },
            )
          ],
        ),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
