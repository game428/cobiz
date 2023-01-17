import 'package:cobiz_client/tools/utils/file_util.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/user.dart';
import 'package:cobiz_client/http/user.dart' as userApi;
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/pages/common/select_area.dart';
import 'package:cobiz_client/pages/root_page.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/picker/data_picker.dart';
import 'package:cobiz_client/provider/global_model.dart';
import 'package:provider/provider.dart';
import 'package:cobiz_client/ui/view/operate_line_view.dart';

class ImproveDataPage extends StatefulWidget {
  final int from; // 来源: 1.登录 2.我的

  const ImproveDataPage({Key key, this.from}) : super(key: key);

  @override
  _ImproveDataPageState createState() => _ImproveDataPageState();
}

class _ImproveDataPageState extends State<ImproveDataPage> {
  GlobalModel model;
  User _user;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  bool _isShowNameClear = false;
  // ignore: unused_field
  bool _isShowCodeClear = false;

  File _imageFile;

  int _genderId = 0;
  String _genderName = '';

  String _birthdayStr = '';

  String _areaStr = '';
  String _mark = '';
  int _nation = 0;
  int _province = 0;
  int _city = 0;
  bool _isInputFinish = false;

  @override
  void initState() {
    super.initState();
    model = Provider.of<GlobalModel>(context, listen: false);
    _user = API.userInfo;
    _init();
  }

  void _init() {
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isFinishInput();
          _isShowNameClear = _nameController.text.length > 0;
        });
      }
    });
    if (_user != null && _user.invited != true) {
      _codeController.addListener(() {
        if (mounted) {
          setState(() {
            _isShowCodeClear = _codeController.text.length > 0;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _codeController.text = _user.inviteCode;
        });
      }
    }
    if (mounted) {
      setState(() {
        _nameController.text = _user.nickname;
        _genderId = _user.gender;
        _mark = _user.mark;
        _birthdayStr =
            DateUtil.formatSeconds(_user.birthday, format: "yyyy-MM-dd");
      });
    }
    _getPlace();
  }

  void _isFinishInput() {
    _isInputFinish = _nameController.text.length > 0 &&
        (_imageFile != null || widget.from != 1);
  }

  Future _getPhoto() async {
    File result =
        await FileUtil.getInstance().getPhoto(context, isCropper: true);
    if (result == null) return;
    if (mounted) {
      setState(() {
        _imageFile = result;
      });
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  void _selectGender() {
    showDataPicker(
      context,
      DataPicker(
        jsonData: [
          {'value': 1, 'text': S.of(context).male},
          {'value': 2, 'text': S.of(context).female}
        ],
        isArray: true,
        cancelText: S.of(context).cancelText,
        confirmText: S.of(context).confirmTitle,
        onConfirm: (values, selecteds) {
          if (mounted) {
            setState(() {
              _genderId = values[0].value;
            });
            FocusScope.of(context).requestFocus(FocusNode());
          }
        },
      ),
    );
  }

  void _getPlace() async {
    if ((_user.area1 ?? 0) < 1) return;
    await getRegion(context).then((value) {
      String place = getPlace(value,
          area1: _user.area1, area2: _user.area2, area3: _user.area3);
      if (mounted) {
        setState(() {
          _areaStr = place;
        });
      }
    });
  }

  void _selectArea() async {
    final Map result = await routePush(SelectAreaPage(
      nation: _nation,
      province: _province,
      city: _city,
    ));
    if (result == null) return;

    _areaStr = '';
    if (result['nationName'].toString().isNotEmpty && result['nation'] != 247)
      _areaStr = result['nationName'];
    if (result['provinceName'].toString().isNotEmpty)
      _areaStr += ' ' + result['provinceName'];
    if (result['cityName'].toString().isNotEmpty)
      _areaStr += ' ' + result['cityName'];

    _nation = result['nation'];
    _province = result['province'];
    _city = result['city'];

    if (mounted) setState(() {});
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _doSubmit() async {
    String nickname = _nameController.text;
    if (nickname.isEmpty) {
      return showToast(context, S.of(context).enterNickname);
    }
    if (_imageFile == null && widget.from == 1) {
      return showToast(context, S.of(context).enterAvatar);
    }
    Loading.before(context: context);
    String avatar = '';
    String inviteCode = _codeController.text;
    if (_imageFile != null) {
      var result = await commonApi.uploadFileCompress(_imageFile.path,
          bucket: 2, type: MediaType.PICTURE.index + 1);
      if (result == null) return;
      avatar = result;
    }
    // todo  先自己上传头像，获取返回地址
    int code = await userApi.modifyInfo(context, nickname,
        avatar: avatar,
        gender: _genderId,
        birthday: _birthdayStr,
        area1: _nation,
        area2: _province,
        area3: _city,
        mark: _mark,
        inviteCode: inviteCode);
    if (code != 0) {
      Loading.complete();
      return;
    }
    if (widget.from == 1) {
      Loading.complete();
      routePushAndRemove(RootPage());
    } else {
      Loading.complete();
      Navigator.pop(context, true);
    }
  }

  Widget _buildOperate() {
    _genderName = _genderId == 1
        ? S.of(context).male
        : _genderId == 2 ? S.of(context).female : '';

    return Expanded(
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          OperateLineView(
            title: S.of(context).avatar,
            onPressed: _getPhoto,
            rightWidget: Container(
              width: 150.0,
              height: 85.0,
              alignment: Alignment.centerRight,
              child: ClipOval(
                child: ImageView(
                  img: (_imageFile?.path ?? cuttingAvatar(_user?.avatar ?? '')),
                  width: 60.0,
                  height: 60.0,
                  needLoad: true,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          EditLineView(
            title: S.of(context).nickName,
            hintText: S.of(context).enterNickname,
            textController: _nameController,
            isShowClear: _isShowNameClear,
            maxLen: 30,
          ),
          OperateLineView(
            title: S.of(context).gender,
            onPressed: _selectGender,
            rightWidget: Text(
              _genderName,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.textF16T4,
            ),
          ),
          OperateLineView(
            title: S.of(context).region,
            onPressed: _selectArea,
            rightWidget: Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      _areaStr,
                      textAlign: TextAlign.right,
                      style: TextStyles.textF16T4,
                    ))),
          ),

          // EditLineView(
          //   title: S.of(context).gender,
          //   text: _genderName,
          //   haveArrow: true,
          //   onPressed: _selectGender,
          // ),
          // EditLineView(
          //   title: S.of(context).region,
          //   text: _areaStr,
          //   haveArrow: true,
          //   onPressed: _selectArea,
          // ),
          // OperateLineView(
          //   title: S.of(context).signature,
          //   onPressed: () async {
          //     String result =
          //         await routeMaterialPush(ModifySignature(signature: _mark));
          //     if (mounted && result != null) {
          //       setState(() {
          //         _mark = result;
          //       });
          //     }
          //   },
          //   rightWidget: Container(
          //     width: 150,
          //     alignment: Alignment.centerRight,
          //     child: Text(
          //       _mark ?? S.of(context).enterSignature,
          //       maxLines: 1,
          //       overflow: TextOverflow.ellipsis,
          //       style: TextStyles.textF16T4,
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: ComMomBar(
          automaticallyImplyLeading: widget.from == 2,
          elevation: 0.5,
          title: S.of(context).improveData,
          rightDMActions: <Widget>[
            buildSureBtn(
              text: S.of(context).finish,
              textStyle:
                  _isInputFinish ? TextStyles.textF14T2 : TextStyles.textF14T1,
              color: _isInputFinish ? AppColors.mainColor : greyECColor,
              onPressed: _doSubmit,
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            _buildOperate(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
