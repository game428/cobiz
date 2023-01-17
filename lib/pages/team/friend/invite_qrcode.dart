import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteQrcodePage extends StatefulWidget {
  final int type; // 1.邀请好友 2.邀请团队成员
  final String title;
  final String teamCode;
  final int deptId;
  final String name;

  InviteQrcodePage(
      {Key key,
      @required this.type,
      this.title,
      this.deptId,
      this.teamCode,
      this.name})
      : super(key: key);

  @override
  _InviteQrcodePageState createState() => _InviteQrcodePageState();
}

class _InviteQrcodePageState extends State<InviteQrcodePage> {
  GlobalKey repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  String _qrData() {
    String text = '';
    if (widget.type == 1) {
      text = 'cobiz://friend_${API.userInfo.id}';
    } else if (widget.type == 2) {
      if (widget.deptId == null) {
        text = 'cobiz://team_${widget.teamCode}';
      } else {
        text = 'cobiz://dept_${widget.teamCode}_${widget.deptId}';
      }
    }
    text = API.qrPrefix + AESUtils.encrypt(text, isLocal: true);
    return text;
  }

  Widget _buildContent() {
    double qrCodeSize = 200.0;
    if (winWidth(context) < qrCodeSize) {
      qrCodeSize = winWidth(context) - 20;
    }
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            ShadowCardView(
              padding: EdgeInsets.only(bottom: 5.0),
              margin: EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        widget.name ?? API.userInfo.nickname,
                        textAlign: TextAlign.center,
                        style: TextStyles.textF16Bold,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 10.0,
                      ),
                      width: double.infinity,
                      alignment: (widget.type == 1 ? null : Alignment.center),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 0.3,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        widget.type == 1
                            ? S.of(context).qrcodeContactRemark
                            : S.of(context).qrcodeTeamRemark,
                        style: TextStyles.textNum,
                      ),
                      margin: EdgeInsets.only(
                        top: 10.0,
                      ),
                    ),
                    QrImage(
                      data: _qrData(),
                      size: qrCodeSize,
                      embeddedImage: AssetImage('assets/images/cobiz_1.png'),
                      embeddedImageStyle: QrEmbeddedImageStyle(
                        size: Size(30.0, 30.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 50.0,
              child: ImageView(
                img: 'assets/images/cobiz_2.png',
              ),
            ),
          ],
        ),
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ComMomBar(
          title: widget.title ?? S.of(context).teamOperateByQrcode,
          elevation: 0.5,
        ),
        body: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            children: <Widget>[
              // Container(
              //   child: Text(
              //     S.of(context).qrcodeRemark +
              //         (widget.type == 1
              //             ? parseTextFirstLower(S.of(context).friend)
              //             : parseTextFirstLower(S.of(context).member)),
              //     style: TextStyles.textF14C2,
              //   ),
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 5.0,
              //   ),
              // ),
              _buildContent(),
              buildCommonButton(S.of(context).saveToLocal,
                  margin: EdgeInsets.fromLTRB(5, 20, 5, 0), onPressed: () {
                saveToLocal(context, repaintKey);
              }),
            ],
          ),
        ),
        backgroundColor: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
