import 'package:cobiz_client/http/work.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';

class IssueNoticePage extends StatefulWidget {
  final int teamId;

  const IssueNoticePage({Key key, this.teamId}) : super(key: key);

  @override
  _IssueNoticePageState createState() => _IssueNoticePageState();
}

class _IssueNoticePageState extends State<IssueNoticePage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _isShowTitleClear = false;
  bool _isShowAuthorClear = false;
  bool _isShowContentClear = false;

  // ignore: unused_field
  bool _isInputFinish = false;

  // String _membersStr = '';
  // String _friendsStr = '';

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _titleController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowTitleClear = _titleController.text.length > 0;
          _isFinishInput();
        });
      }
    });
    _authorController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowAuthorClear = _authorController.text.length > 0;
        });
      }
    });
    _contentController.addListener(() {
      if (mounted) {
        setState(() {
          _isShowContentClear = _contentController.text.length > 0;
        });
      }
    });
  }

  void _isFinishInput() {
    _isInputFinish = _titleController.text.length > 0;
  }

  Future _dealSubmit() async {
    String _title = _titleController.text;
    String _content = _contentController.text;
    if (_title.isEmpty) {
      showToast(context, S.of(context).noticeTitleHint);
    } else if (_content.isEmpty) {
      showToast(context, S.of(context).noticeContentHint);
    } else {
      Loading.before(context: context);
      bool resState = await addNotice(
          teamId: widget.teamId,
          title: _title,
          content: _content,
          author: _authorController.text);
      Loading.complete();
      if (resState) {
        showToast(context, S.of(context).publishingSuccess);
        Navigator.pop(context, true);
      } else {
        showToast(context, S.of(context).publishingFailed);
      }
    }
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        EditLineView(
          title: S.of(context).announcementTitle,
          hintText: S.of(context).pEnterAnnouncementTitle,
          textController: _titleController,
          isShowClear: _isShowTitleClear,
          maxLen: 50,
        ),
        EditLineView(
          title: S.of(context).author,
          hintText: S.of(context).pEnterAuthor,
          textController: _authorController,
          isShowClear: _isShowAuthorClear,
          maxLen: 30,
        ),
        ListItemView(
          title: S.of(context).announcementContent,
          haveBorder: false,
        ),
        EditLineView(
          minHeight: 40.0,
          hintText: S.of(context).pEnterAnnouceContent,
          top: 5.0,
          maxLen: 500,
          textAlign: TextAlign.left,
          textFieldLines: 5,
          textController: _contentController,
          isShowClear: _isShowContentClear,
        ),
        // EditLineView(
        //   title: S.of(context).notifyStaff,
        //   text: _membersStr,
        //   haveArrow: true,
        //   onPressed: () {
        //     FocusScope.of(context).requestFocus(FocusNode());
        //   },
        // ),
        // EditLineView(
        //   title: S.of(context).notifyFriends,
        //   text: _friendsStr,
        //   haveArrow: true,
        //   onPressed: () {
        //     FocusScope.of(context).requestFocus(FocusNode());
        //   },
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: S.of(context).issueTask,
        elevation: 0.5,
        rightDMActions: <Widget>[
          buildSureBtn(
            text: S.of(context).publish,
            textStyle: TextStyles.textF14T2,
            color: AppColors.mainColor,
            onPressed: _dealSubmit,
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: ListView(
          children: <Widget>[
            _buildColumn(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
