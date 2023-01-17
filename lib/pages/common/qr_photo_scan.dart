import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scan/scan.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class QrPhotoScan extends StatefulWidget {
  QrPhotoScan({Key key}) : super(key: key);

  @override
  _QrPhotoScanState createState() => _QrPhotoScanState();
}

class _QrPhotoScanState extends State<QrPhotoScan> {
  File _file;
  bool _notFind = false;

  @override
  void initState() {
    super.initState();
    _selectPhoto();
  }

  // 相册
  void _selectPhoto() {
    List<AssetEntity> assets = <AssetEntity>[];
    AssetPicker.pickAssets(
      context,
      maxAssets: 1,
      pageSize: 320,
      pathThumbSize: 80,
      gridCount: 4,
      selectedAssets: assets,
      requestType: RequestType.common,
      themeColor: AppColors.mainColor,
      // textDelegate: AssetsPickerTextDelegate,
      routeCurve: Curves.easeIn,
      routeDuration: const Duration(milliseconds: 500),
    ).then((List<AssetEntity> result) async {
      if (result == null || result.length < 1) {
        Navigator.pop(context);
      } else {
        _file = await result[0].file;
        if (mounted) {
          setState(() {});
        }
        Loading.before(context: context, text: S.of(context).identifying);
        final String data = await Scan.parse(_file.path);
        Loading.complete();
        if (data == null || data == '') {
          _notFind = true;
          if (mounted) {
            setState(() {});
          }
        } else {
          Navigator.pop(context, data);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey81Color,
      body: Stack(
        children: [
          Container(
            width: winWidth(context),
            height: winHeight(context),
            child: _file != null
                ? Image.file(_file, fit: BoxFit.fitWidth)
                : Container(),
          ),
          Container(
              color: Color(0x72000000),
              width: winWidth(context),
              height: winHeight(context)),
          InkWell(
            onTap: () {
              if (_notFind) {
                Navigator.pop(context);
              }
            },
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: _notFind
                    ? Container(
                        width: winWidth(context),
                        height: winHeight(context),
                        child: Center(
                            child: Container(
                          // color: Colors.black,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(S.of(context).noQr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text(S.of(context).touchBack,
                                  style: TextStyle(
                                      color: greyDFColor, fontSize: 12))
                            ],
                          ),
                        )),
                      )
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
