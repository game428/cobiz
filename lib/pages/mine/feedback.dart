import 'dart:convert';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/http/user.dart' as feebackApi;
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/special_text/my_special_text_builder.dart';

class FeedBackPage extends StatefulWidget {
  final int id;

  const FeedBackPage({Key key, this.id}) : super(key: key);

  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  List pathList = List();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocus = FocusNode();
  final GlobalKey _key = GlobalKey();
  // List<AssetEntity> assets = <AssetEntity>[];

  @override
  void initState() {
    super.initState();
  }

  _sub() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_textController.text.isEmpty)
      return showToast(context, S.of(context).pleaseInputFeedback);
    Loading.before(context: context);
    List strPath = [];
    if (pathList.length > 0) {
      Set<String> paths = Set();
      pathList.forEach((element) {
        paths.add(element);
      });
      Map<String, String> result =
          await commonApi.uploadFilesCompressMap(paths, bucket: 4);
      if (result == null || result.length < 1) return;
      result.forEach((key, value) {
        strPath.add(value);
      });
      var res = await feebackApi.subFeedback(
          _textController.text, jsonEncode(strPath));
      Loading.complete();
      if (res != false) {
        showToast(context, S.of(context).feedbackSuccess);
        Navigator.pop(context);
      } else {
        showToast(context, S.of(context).tryAgainLater);
      }
    } else {
      var res = await feebackApi.subFeedback(
          _textController.text, jsonEncode(strPath));
      Loading.complete();
      if (res != false) {
        showToast(context, S.of(context).feedbackSuccess);
        Navigator.pop(context);
      } else {
        showToast(context, S.of(context).tryAgainLater);
      }
    }
  }

  Future<void> _actionHandler(int id) async {
    if (id == 1) {
      if (pathList.length < 8) {
        if (await PermissionManger.photosPermission()) {
          AssetPicker.pickAssets(
            context,
            maxAssets: 8 - pathList.length,
            pageSize: 320,
            pathThumbSize: 80,
            gridCount: 4,
            // selectedAssets: assets,
            requestType: RequestType.image,
            themeColor: Colors.blue,
            // textDelegate: AssetsPickerTextDelegate,
            routeCurve: Curves.easeIn,
            routeDuration: const Duration(milliseconds: 500),
          ).then((List<AssetEntity> result) {
            if (result == null || result.length < 1) return;
            // assets = result;
            result.forEach((element) async {
              var ii = await element.file;
              pathList.add(ii.path);
            });
            if (mounted) {
              setState(() {});
            }
          });
        } else {
          showConfirm(context, title: S.of(context).photosPermission,
              sureCallBack: () async {
            await openAppSettings();
          });
        }
      } else {
        showToast(context, S.of(context).max8photo);
      }
    } else {
      if (pathList.length < 8) {
        if (await PermissionManger.cameraPermission()) {
          // ignore: deprecated_member_use
          File file = await ImagePicker.pickImage(source: ImageSource.camera);
          if (file == null) return;
          if (mounted) {
            setState(() {
              pathList.add(file.path);
            });
          }
        } else {
          showConfirm(context, title: S.of(context).cameraPermission,
              sureCallBack: () async {
            await openAppSettings();
          });
        }
      } else {
        showToast(context, S.of(context).max8photo);
      }
    }
  }

  Widget _buildBtn(int id, String image) {
    double size = 50.0;
    return Container(
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: FlatButton(
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          _actionHandler(id);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        padding: EdgeInsets.all(0),
        child: Container(
          width: size,
          child: ImageView(
            img: image,
            width: 30.0,
          ),
        ),
      ),
    );
  }

  ///选择的图片
  Widget get selectedAssetsListView => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
              width: winWidth(context),
              height: 70,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pathList.length,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: EdgeInsets.all(3),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: ImageView(
                                img: pathList[index],
                                fit: BoxFit.cover,
                                width: 70,
                              ),
                            ),
                            Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    if (mounted) {
                                      setState(() {
                                        pathList.removeAt(index);
                                      });
                                    }
                                  },
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.grey,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  })),
          Positioned(
              right: 0,
              child: pathList.length >= 5
                  ? Icon(Icons.keyboard_arrow_right)
                  : Container()),
          Positioned(
              left: 0,
              child: pathList.length >= 5
                  ? Icon(Icons.keyboard_arrow_left)
                  : Container())
        ],
      );

  Widget _buildOperateLine() {
    List _data = [
      {
        'id': 1,
        'name': S.of(context).photo,
        'icon': 'assets/images/chat/extend/pic.png'
      },
      {
        'id': 2,
        'name': S.of(context).camera,
        'icon': 'assets/images/chat/extend/camera.png'
      },
    ];
    return Column(
      children: <Widget>[
        selectedAssetsListView,
        InkWell(
          child: Container(
            height: 50.0,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              color: greyF7Color,
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _data.map((e) {
                return _buildBtn(e['id'], e['icon']);
              }).toList(),
            ),
          ),
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
        Container(
          height: ScreenData.bottomSafeHeight,
          color: greyF7Color,
        )
      ],
    );
  }

  Widget _buildContent() {
    return Container(
      height: 200.0,
      child: ExtendedTextField(
        key: _key,
        autofocus: true,
        minLines: 3,
        maxLines: null,
        focusNode: _textFocus,
        controller: _textController,
        style: TextStyles.textF16,
        keyboardType: TextInputType.multiline,
        maxLength: 200,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 16.0),
          hintText: S.of(context).opinionHintext,
          isDense: true,
          contentPadding: EdgeInsets.all(5.0),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        specialTextSpanBuilder: MySpecialTextSpanBuilder(
          showAtBackground: true,
        ),
        scrollPhysics: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 5.0,
      ),
    );
  }

  void insertText(String text) {
    final TextEditingValue value = _textController.value;
    final int start = value.selection.baseOffset;
    int end = value.selection.extentOffset;
    if (value.selection.isValid) {
      String newText = '';
      if (value.selection.isCollapsed) {
        if (end > 0) {
          newText += value.text.substring(0, end);
        }
        newText += text;
        if (value.text.length > end) {
          newText += value.text.substring(end, value.text.length);
        }
      } else {
        newText = value.text.replaceRange(start, end, text);
        end = start;
      }

      _textController.value = value.copyWith(
          text: newText,
          selection: value.selection.copyWith(
              baseOffset: end + text.length, extentOffset: end + text.length));
    } else {
      _textController.value = TextEditingValue(
        text: text,
        selection:
            TextSelection.fromPosition(TextPosition(offset: text.length)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        elevation: 0.5,
        title: S.of(context).feedback,
        rightDMActions: <Widget>[
          buildSureBtn(
            text: S.of(context).send,
            textStyle: TextStyles.textF14T2,
            color: AppColors.mainColor,
            onPressed: () {
              _sub();
            },
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topCenter, //指定未定位或部分定位widget的对齐方式
          overflow: Overflow.visible,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildContent(),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildOperateLine(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    pathList.clear();
    super.dispose();
  }
}
