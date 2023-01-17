import 'package:cobiz_client/pages/common/qr_photo_scan.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cobiz_client/tools/cobiz.dart';

class QrScannerPage extends StatefulWidget {
  @override
  _QrScannerPageState createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  QRViewController _qrController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  String _qrText;
  bool _lightOn = false;
  bool _isLoading = false;

  void _onQRViewCreated(QRViewController controller) {
    this._qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_qrText != null && _qrText.isNotEmpty) return;
      _qrText = scanData;
      _dealScan();
    });
  }

  void _dealScan() async {
    Navigator.pop(context, _qrText);
  }

  void _switchLight() {
    if (_qrController != null) {
      _qrController.toggleFlash();
      if (mounted) {
        setState(() {
          _lightOn = !_lightOn;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 5.0,
              borderLength: 10.0,
              borderWidth: 5.0,
            ),
          ),
          InkWell(
            child: Container(
              margin: EdgeInsets.only(
                  top: 20.0 + ScreenData.topSafeHeight, left: 15),
              child: ImageView(
                img: 'assets/images/ic_round_close.png',
                width: 50.0,
                height: 50.0,
              ),
            ),
            onTap: () {
              if (_lightOn && _qrController != null) {
                _qrController.toggleFlash();
                _lightOn = false;
              }
              Navigator.pop(context);
            },
          ),
          Positioned(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: _switchLight,
                  child: Column(
                    children: <Widget>[
                      ImageView(
                        img: _lightOn
                            ? 'assets/images/light_on.png'
                            : 'assets/images/light_off.png',
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        _lightOn
                            ? S.of(context).tapToTurnOff
                            : S.of(context).tapToTurnOn,
                        style:
                            TextStyle(color: Color(0xFFBCBCBC), fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    if (await PermissionManger.photosPermission()) {
                      if (_qrController != null) {
                        _qrController.pauseCamera();
                        if (_lightOn) {
                          _switchLight();
                        }
                      }
                      routeMaterialPush(QrPhotoScan()).then((value) {
                        if (value == null || value == '') {
                          if (_qrController != null) {
                            _qrController.resumeCamera();
                          }
                        } else {
                          _qrText = value;
                          _dealScan();
                        }
                      });
                    } else {
                      showConfirm(context,
                          title: S.of(context).photosPermission,
                          sureCallBack: () async {
                        await openAppSettings();
                      });
                    }
                  },
                  child: Column(
                    children: [
                      ImageView(img: 'assets/images/qr_photo.png'),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        S.of(context).photo,
                        style:
                            TextStyle(color: Color(0xFFBCBCBC), fontSize: 14.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
            bottom: 50.0,
            left: 20.0,
            right: 20.0,
          ),
          Center(
            child: Opacity(
              opacity: _isLoading ? 1.0 : 0.0,
              child: SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (Platform.isIOS && _qrController != null && _lightOn) {
      _qrController.toggleFlash();
      _lightOn = false;
    }
    _qrController.dispose();
    super.dispose();
  }
}
