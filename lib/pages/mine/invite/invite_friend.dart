import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/pages/mine/invite/invite_history.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;

class InviteFriendPage extends StatefulWidget {
  final String inviteCode;
  InviteFriendPage({Key key, this.inviteCode}) : super(key: key);

  @override
  _InviteFriendPageState createState() => _InviteFriendPageState();
}

class _InviteFriendPageState extends State<InviteFriendPage> {
  GlobalKey repaintKey = GlobalKey();
  String promoteUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isLoading = true;
    String result = await commonApi.getPromoteUrl();
    if (mounted) {
      setState(() {
        promoteUrl = result;
      });
    }
    isLoading = false;
  }

  Widget _mid() {
    double qrcSize = 196.0;
    if (winWidth(context) < qrcSize) {
      qrcSize = winWidth(context) - 20;
    }
    return Container(
      height: 454,
      width: 336,
      margin: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/images/mine/qr_code_bg.png'))),
      child: Column(children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 30.0, bottom: 32.0),
          child: ImageView(
            img: 'assets/images/mine/invite_logo.png',
            isRadius: 0.0,
          ),
        ),
        isLoading == true
            ? Container(
                width: qrcSize,
                height: qrcSize,
                child: Center(
                  child: CupertinoActivityIndicator(),
                ),
              )
            : QrImage(
                data: promoteUrl ?? '',
                size: qrcSize,
                embeddedImage: AssetImage('assets/images/code_logo.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(30.0, 30.0),
                ),
              ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 28.0),
          child: Text("${S.of(context).inviteCode}：${widget.inviteCode}",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: FontSizes.font_s17,
                  fontWeight: FontWeight.w500)),
        )
      ]),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topCenter, //指定未定位或部分定位widget的对齐方式
          overflow: Overflow.visible,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            image: AssetImage('assets/images/mine/top_bg.png'),
                            alignment: Alignment.topCenter,
                            fit: BoxFit.fitWidth)),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 107.0,
                        ),
                        RepaintBoundary(
                          key: repaintKey,
                          child: _mid(),
                        ),
                      ],
                    ),
                  ),
                  Row(children: [
                    buildCommonButton(S.of(context).copyLinkShare,
                        onPressed: () {
                      Clipboard.setData(new ClipboardData(text: promoteUrl))
                          .then((value) =>
                              {showToast(context, S.of(context).copySuccess)});
                    }),
                    Spacer(),
                    buildCommonButton(S.of(context).savePicturesShare,
                        onPressed: () {
                      saveToLocal(context, repaintKey);
                    }),
                  ]),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ComMomBar(
                mainColor: Colors.white,
                title: S.of(context).inviteFriends,
                backgroundColor: Colors.transparent,
                rightDMActions: <Widget>[
                  IconButton(
                    icon: ImageView(
                      img: 'assets/images/mine/record.png',
                      width: 25.0,
                    ),
                    onPressed: () {
                      routePush(InviteHistoryPage());
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
