import 'package:cobiz_client/domain/azlistview_domain.dart';
import 'package:cobiz_client/pages/common/select_contact.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ChannelMore extends StatefulWidget {
  final bool isInited;
  final bool isMore;
  final FocusNode textFocus;
  final PageController pageController;
  final Function(dynamic) call;

  final int joinFromWhere; // 5: 单聊进入 6：从群聊
  final String name; //群名 人名
  final dynamic avatar; //群头 人头  String List<dynamic>
  final int id; //groupId userId
  final int gtype; //群类型

  const ChannelMore(
      {Key key,
      this.isInited,
      this.isMore,
      this.textFocus,
      this.pageController,
      this.call,
      @required this.joinFromWhere,
      @required this.name,
      @required this.avatar,
      @required this.id,
      @required this.gtype})
      : super(key: key);

  @override
  _ChannelMoreState createState() => _ChannelMoreState();
}

class _ChannelMoreState extends State<ChannelMore> {
  final picker = ImagePicker();
  int _curIndex = 0;

  List _data = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _moreActionHandler(int id) async {
    switch (id) {
      case 1:
        if (await PermissionManger.photosPermission()) {
          _selectPhoto();
        } else {
          showConfirm(context, title: S.of(context).photosPermission,
              sureCallBack: () async {
            await openAppSettings();
          });
        }
        break;
      case 2:
        _pickImage();
        break;
      case 3:
        routeMaterialPush(
            SelctContatPage(joinFromWhere: widget.joinFromWhere, data: {
          'id': widget.id,
          'avatar': widget.avatar,
          'name': widget.name,
          'gtype': widget.gtype
        })).then((value) {
          if (value != null && value is ContactExtendIsSelected) {
            widget.call({MediaType.CARD: value});
          }
        });
        break;
      case 4:
        break;
      case 5:
        break;
      case 6:
        break;
      case 7:
        break;
      case 8:
        break;
    }
  }

  // 拍摄
  void _pickImage() async {
    try {
      if (await PermissionManger.cameraPermission()) {
        final pickedFile = await picker.getImage(source: ImageSource.camera);
        File imageFile;
        if (pickedFile != null) {
          imageFile = File(pickedFile.path);
        }
        if (imageFile != null) {
          widget.call({MediaType.PICTURE: imageFile});
        }
      } else {
        showConfirm(context, title: S.of(context).cameraPermission,
            sureCallBack: () async {
          await openAppSettings();
        });
      }
    } catch (e) {
      // skip
    }
  }

  // 相册
  void _selectPhoto() {
    List<AssetEntity> assets = <AssetEntity>[];
    AssetPicker.pickAssets(
      context,
      maxAssets: 9,
      pageSize: 320,
      pathThumbSize: 80,
      gridCount: 4,
      selectedAssets: assets,
      requestType: RequestType.common,
      themeColor: AppColors.mainColor,
      // textDelegate: AssetsPickerTextDelegate,
      routeCurve: Curves.easeIn,
      routeDuration: const Duration(milliseconds: 500),
    ).then((List<AssetEntity> result) {
      if (result == null || result.length < 1) return;
      widget.call({MediaType.PICTURE: result});
    });
  }

  Widget _buildItem(int id, String title, String icon) {
    double width = (ScreenData.width - 100) / 4 - 0.5;
    double size = width - 10.0;
    if (size > 55) size = 55.0;
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: FlatButton(
              onPressed: () {
                _moreActionHandler(id);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              padding: EdgeInsets.all(0),
              color: Colors.white,
              child: Container(
                width: size,
                child: ImageView(
                  img: icon,
                  width: 25.0,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.textF12T1,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    return List.generate(_data.length, (index) {
      return Container(
        margin: EdgeInsets.all(20.0),
        child: Wrap(
          runSpacing: 10.0,
          spacing: 20.0,
          children: List.generate(_data[index].length, (index2) {
            return _buildItem(_data[index][index2]['id'],
                _data[index][index2]['name'], _data[index][index2]['icon']);
          }),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _data = [
      [
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
      ],
    ];
    if (widget.joinFromWhere != 5 || widget.id != 10) {
      _data[0].add({
        'id': 3,
        'name': S.of(context).contactCard,
        'icon': 'assets/images/chat/extend/user_card.png'
      });
    }
    return widget.isInited
        ? GestureDetector(
            child: Container(
              width: double.infinity,
              height: widget.isMore ? 220.0 : 0.0,
              padding: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
              color: greyEFColor,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  ScrollConfiguration(
                    behavior: MyBehavior(),
                    child: PageView(
                      controller: widget.pageController,
                      onPageChanged: (v) {
                        setState(() => _curIndex = v);
                      },
                      children: _buildContent(),
                    ),
                  ),
                  _data.length > 1
                      ? Container(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_data.length, (index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: buildMessaged(
                                  size: 10.0,
                                  color: _curIndex == index
                                      ? AppColors.mainColor
                                      : Colors.grey.withOpacity(0.3),
                                ),
                              );
                            }),
                          ),
                        )
                      : SizedBox(
                          width: 0.0,
                          height: 0.0,
                        ),
                ],
              ),
            ),
            onTap: () {},
          )
        : SizedBox(
            width: 0.0,
            height: 0.0,
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
