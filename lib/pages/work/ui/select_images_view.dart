import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/utils/file_util.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class SelectImagesView extends StatefulWidget {
  final int type; // 1.图片上传 2.附件上传
  final EdgeInsetsGeometry margin;
  final List<File> images;
  final VoidCallback onPressed;
  final bool haveBorder;

  const SelectImagesView(
      {Key key,
      this.type = 1,
      this.margin,
      @required this.images,
      this.onPressed,
      this.haveBorder = false})
      : super(key: key);

  @override
  _SelectImagesViewState createState() => _SelectImagesViewState();
}

class _SelectImagesViewState extends State<SelectImagesView> {
  List<File> _images = List();
  int _imgLength = 6;

  @override
  void initState() {
    super.initState();
    _images = widget.images;
  }

  Future _getPhoto() async {
    if (_images.length >= _imgLength) {
      showToast(context, S.of(context).max6photo);
    } else {
      widget.onPressed();
      var result = await FileUtil.getInstance()
          .getPhoto(context, isCropper: false, selectPhone: selectPhoto);
      if (result == null) return;
      if (mounted) {
        setState(() {
          _images.add(result);
        });
      }
    }
  }

  // 相片
  void selectPhoto() async {
    List<AssetEntity> assets = <AssetEntity>[];
    AssetPicker.pickAssets(
      context,
      maxAssets: _imgLength - _images.length,
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
      Navigator.pop(context);
      if (result == null || result.length < 1) return;
      for (AssetEntity image in result) {
        File file = await image.file;
        if (mounted) {
          setState(() {
            _images.add(file);
          });
        }
      }
    });
  }

  void _deleteImage(File image) {
    if (mounted) {
      setState(() {
        _images.remove(image);
      });
    }
  }

  Widget _buildImageItem(File image, double imgSize) {
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              buildFilletImage(
                image.path,
                imgSize: imgSize,
                margin: EdgeInsets.only(
                  right: 10.0,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0.0,
            top: 0.0,
            child: InkWell(
              child: Icon(
                Icons.cancel,
                size: 18.0,
              ),
              onTap: () => _deleteImage(image),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    double size = 40.0;
    List<Widget> items = _images.map((image) {
      return _buildImageItem(image, size);
    }).toList();
    items.add(InkWell(
      child: Container(
        padding: EdgeInsets.only(
          top: 5.0,
        ),
        child: ImageView(
          img:
              'assets/images/work/${widget.type == 2 ? 'ic_enclosure' : 'ic_picture'}.png',
        ),
      ),
      onTap: () => _getPhoto(),
    ));
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 15.0, right: 15.0),
      padding: (widget.haveBorder
          ? EdgeInsets.only(
              bottom: 5.0,
            )
          : null),
      decoration: (widget.haveBorder
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.4, color: greyDFColor),
              ),
            )
          : null),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 10.0,
        children: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListItemView(
            title: widget.type == 2
                ? S.of(context).updatingFiles
                : S.of(context).uploadPicture,
            haveBorder: false,
          ),
          SizedBox(
            height: 5.0,
          ),
          _buildImageArea(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
