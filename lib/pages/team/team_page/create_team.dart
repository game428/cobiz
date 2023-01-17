import 'dart:convert';

import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/domain/storage_domain.dart';
import 'package:cobiz_client/http/res/team_model/team_info.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;
import 'package:cobiz_client/http/common.dart' as commonApi;
import 'package:cobiz_client/pages/team/member/add_member.dart';
import 'package:cobiz_client/provider/channel_manager.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/utils/file_util.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CreateTeamPage extends StatefulWidget {
  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  List teamTypeJson;

  FocusNode _focusNodeName = FocusNode();
  FocusNode _focusNodeIntro = FocusNode();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _introController = TextEditingController();

  bool _isShowNameClear = false;
  bool _isShowIntroClear = false;

  // ignore: unused_field
  int _teamTypeId = 0;
  String _teamTypeName = '';

  bool _isInputFinish = false;

  File _imageFile;

  @override
  void initState() {
    super.initState();
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
          _isFinishInput();
        });
      }
    });

    _getData();
  }

  void _isFinishInput() {
    _isInputFinish = _nameController.text.length > 0;
  }

  void _getData() async {
    GlobalModel model = Provider.of<GlobalModel>(context, listen: false);
    List<String> codes = model.currentLanguageCode;
    rootBundle
        .loadString('assets/data/team_types_${codes[0]}_${codes[1]}.json')
        .then((value) {
      teamTypeJson = json.decode(value);
    });
  }

  void _unfocusField() {
    _focusNodeName.unfocus();
    _focusNodeIntro.unfocus();
  }

  Future _getPhoto() async {
    _unfocusField();

    File result =
        await FileUtil.getInstance().getPhoto(context, isCropper: true);
    if (result == null) return;
    if (mounted) {
      setState(() {
        _imageFile = result;
      });
    }
  }

  void _selectType() {
    _unfocusField();
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

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildTextTitle(
          S.of(context).teamCreateMark,
          fontSize: FontSizes.font_s14,
          top: 0.0,
          left: 15.0,
          right: 15.0,
        ),
        EditLineView(
          title: S.of(context).teamOrgNameLabel,
          hintText: S.of(context).teamOrgNameHintText,
          textController: _nameController,
          maxLen: 30,
          focusNode: _focusNodeName,
          isShowClear: _isShowNameClear,
        ),
        OperateLineView(
          title: S.of(context).teamOrgLogoLabel,
          isArrow: false,
          onPressed: _getPhoto,
          rightWidget: buildFilletImage(
            _imageFile?.path ?? 'assets/images/chat/extend/camera.png',
            // margin: EdgeInsets.only(right: 10.0),
          ),
        ),
        EditLineView(
          title: S.of(context).teamOrgIntro,
          hintText: S.of(context).teamOrgIntroHintText,
          maxLen: 100,
          textController: _introController,
          focusNode: _focusNodeIntro,
          isShowClear: _isShowIntroClear,
        ),
        EditLineView(
          title: S.of(context).teamOrgType,
          text: _teamTypeName,
          haveArrow: true,
          onPressed: _selectType,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocusField(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
          appBar: ComMomBar(
            title: S.of(context).teamCreateTitle,
            elevation: 0.5,
            rightDMActions: <Widget>[
              buildSureBtn(
                text: S.of(context).finish,
                textStyle: _isInputFinish
                    ? TextStyles.textF14T2
                    : TextStyles.textF14T1,
                color: _isInputFinish ? AppColors.mainColor : greyECColor,
                onPressed: _dealSubmit,
              ),
            ],
          ),
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
              children: <Widget>[_buildColumn()],
            ),
          ),
          backgroundColor: Colors.white),
    );
  }

  Future _dealSubmit() async {
    if (!_isInputFinish) {
      return;
    }
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
    var res = await teamApi.createTeam(
        tName: _nameController.text,
        intro: _introController.text,
        type: _teamTypeId,
        icon: logo);
    Loading.complete();
    if (res == 3) return showToast(context, S.of(context).nameDuplicated);
    if (res == null || res == 1 || res == 2 || res == 4)
      return showToast(context, S.of(context).createTeamFailure);
    TeamInfo teamInfo = res;
    await teamApi.switchTeam(teamInfo.id);
    if (teamInfo.chatId != null && teamInfo.chatId != 0) {
      ChannelManager.getInstance().addGroupChat(
          teamInfo.chatId,
          teamInfo.name,
          [teamInfo.icon],
          teamInfo.numB,
          1,
          0,
          false,
          ChatStore(getOnlyId(), ChatType.GROUP.index + 1, API.userInfo.id,
              teamInfo.chatId, 100, '',
              state: 2, time: DateTime.now().millisecondsSinceEpoch));
    }
    routePush(AddTeamMemberPage(
      teamId: teamInfo.id,
      isNewTeam: true,
      isManager: true,
      teamName: teamInfo.name,
      teamCode: teamInfo.code,
    )).then((value) {
      Navigator.pop(context, teamInfo);
    });
  }

  @override
  void dispose() {
    _focusNodeName.dispose();
    _focusNodeIntro.dispose();
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }
}
