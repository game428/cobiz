import 'dart:convert';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/pages/team/group/select_group_members.dart';
import 'package:cobiz_client/pages/team/team_page/edit_billing_info.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/utils/file_util.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/http/common.dart' as commonApi;

class TeamSettingsPage extends StatefulWidget {
  final int teamId;

  const TeamSettingsPage({Key key, this.teamId}) : super(key: key);

  @override
  _TeamSettingsPageState createState() => _TeamSettingsPageState();
}

class _TeamSettingsPageState extends State<TeamSettingsPage> {
  List teamTypeJson;

  TeamInfo _teamInfo;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _introController = TextEditingController();

  bool _isShowNameClear = false;
  bool _isShowIntroClear = false;
  bool _isInputFinish = false;

  // ignore: unused_field
  int _teamTypeId = 0;
  String _teamTypeName = '';

  File _imageFile;

  String _oldName = '';

  //管理员id
  List<int> _managerId = [];
  //管理员name
  List<String> _managerName = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
    _getData();
  }

  Future _getData() async {
    GlobalModel model = Provider.of<GlobalModel>(context, listen: false);
    List<String> codes = model.currentLanguageCode;
    rootBundle
        .loadString('assets/data/team_types_${codes[0]}_${codes[1]}.json')
        .then((value) {
      teamTypeJson = json.decode(value);
    });
    var res = await teamApi.getSomeoneTeam(teamId: widget.teamId);
    if (res != null) {
      if (mounted) {
        _teamInfo = res;
        _oldName = _teamInfo.name;
        _nameController.text = _teamInfo.name;
        _introController.text = _teamInfo.intro;
        _teamTypeId = _teamInfo.type;
        _teamTypeName = await queryTeamTypeName(_teamInfo.type, context);
        _teamInfo.managers.forEach((key, value) {
          _managerId.add(int.parse(key));
          _managerName.add(value.toString());
        });
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _initController() {
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowNameClear = _nameController.text.length > 0;
          _isFinishInput();
        });
      }
    });
    _introController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowIntroClear = _introController.text.length > 0;
        });
      }
    });
  }

  void _isFinishInput() {
    _isInputFinish = _nameController.text.length > 0;
  }

  Future _dealSubmit() async {
    if (_nameController.text.isEmpty) {
      return;
    }
    Loading.before(context: context);
    String logo;
    if (_imageFile != null) {
      var result = await commonApi.uploadFileCompress(_imageFile.path,
          bucket: 2, type: MediaType.PICTURE.index + 1);
      logo = result;
    }
    bool res = await teamApi.teamSetting(
        teamId: widget.teamId,
        name: _nameController.text,
        icon: logo,
        intro: _introController.text,
        type: _teamTypeId,
        managerIds: _managerId);
    Loading.complete();
    if (res == true) {
      if (_oldName != _nameController.text ||
          !_teamInfo.icon.contains(logo ?? '')) {
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
      }
    } else {
      return showToast(context, S.of(context).saveFailed);
    }
  }

  void _selectType() {
    FocusScope.of(context).requestFocus(FocusNode());
    showDataPicker(
        context,
        DataPicker(
          jsonData: teamTypeJson,
          isArray: true,
          looping: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selecteds) {
            if (mounted) {
              setState(() {
                _teamTypeId = values[0].value;
                _teamTypeName = values[0].text;
              });
            }
          },
        ));
  }

  //选择管理员
  void _selectManager() async {
    var res = await routePush(SelectGroupMembersPage(
      teamId: _teamInfo.id,
      memberList: _managerId,
      showType: 3,
      title: S.of(context).setManager,
    ));
    if (res != null && mounted) {
      _managerName = res['names'];
      _managerId = res['ids'];
      setState(() {});
    }
  }

  void _deleteTeam() async {
    Loading.before(context: context);
    var res = await teamApi.dismissTeam(widget.teamId);
    Loading.complete();
    if (res) {
      Navigator.pop(context, true);
    } else {
      showToast(context, S.of(context).operateFailure);
    }
  }

  Future _getPhoto() async {
    FocusScope.of(context).requestFocus(FocusNode());
    File result =
        await FileUtil.getInstance().getPhoto(context, isCropper: true);
    if (result == null) return;
    if (mounted) {
      setState(() {
        _imageFile = result;
      });
    }
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EditLineView(
          title: S.of(context).teamOrgNameLabel,
          hintText: S.of(context).teamOrgNameHintText,
          maxLen: 30,
          textController: _nameController,
          isShowClear: _isShowNameClear,
        ),
        EditLineView(
          title: S.of(context).teamOrgLogoLabel,
          haveArrow: true,
          top: 10.0,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              buildFilletImage(
                  (_imageFile?.path ??
                      (strNoEmpty((_teamInfo?.icon ?? ''))
                          ? _teamInfo.icon
                          : logoImageG)),
                  margin: EdgeInsets.only(right: 10.0),
                  radius: 20)
            ],
          ),
          onPressed: _getPhoto,
        ),
        EditLineView(
          title: S.of(context).teamOrgIntro,
          hintText: S.of(context).teamOrgIntroHintText,
          maxLen: 100,
          textController: _introController,
          isShowClear: _isShowIntroClear,
        ),
        EditLineView(
          title: S.of(context).teamOrgType,
          text: _teamTypeName,
          haveArrow: true,
          onPressed: _selectType,
        ),
        EditLineView(
          title: S.of(context).billingInformation,
          titleMaxOdds: 0.6,
          haveArrow: true,
          onPressed: () => routePush(EditBillingInfoPage(
            teamId: widget.teamId,
          )),
        ),
        EditLineView(
            title: S.of(context).setManager,
            titleMaxOdds: 0.4,
            text: _managerName.join(','),
            haveArrow: true,
            onPressed: _selectManager),
        EditLineView(
          title: S.of(context).dissolveOrg,
          titleMaxOdds: 0.6,
          haveArrow: true,
          onPressed: () {
            showSureModal(context, S.of(context).dissolveOrg, _deleteTeam,
                promptText: S.of(context).teamDissolveConfirmContent);
          },
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).teamSettings,
        elevation: 0.5,
        rightDMActions: [
          isLoading
              ? Container()
              : buildSureBtn(
                  text: S.of(context).save,
                  textStyle: TextStyles.textF14T2,
                  color: _isInputFinish ? AppColors.mainColor : greyECColor,
                  onPressed: _dealSubmit,
                ),
        ],
      ),
      body: isLoading
          ? buildProgressIndicator()
          : ScrollConfiguration(
              behavior: MyBehavior(),
              child: ListView(
                children: <Widget>[_buildColumn()],
              ),
            ),
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }
}
