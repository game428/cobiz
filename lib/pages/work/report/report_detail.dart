import 'dart:convert';

import 'package:cobiz_client/http/res/team_model/common_model.dart';
import 'package:cobiz_client/http/res/team_model/log_detail.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_widget.dart';
import 'package:cobiz_client/pages/work/ui/work_widget.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

class ReportDetailPage extends StatefulWidget {
  final int teamId;
  final int id;

  const ReportDetailPage({Key key, @required this.teamId, @required this.id})
      : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  TextEditingController _textController = TextEditingController();
  FocusNode _textFocus = FocusNode();
  LogDetail _detail;
  bool isComment = false;
  Comments curComment;
  Map curMsg = Map();
  bool _isReply = false;
  bool _isLoadOk = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          isComment = _textController.text.length > 0;
        });
      }
    });
    _init();
  }

  void _init() async {
    _textController.text = '';
    LogDetail res =
        await workApi.getLogDetail(teamId: widget.teamId, id: widget.id);
    if (res != null) {
      _detail = res;
    }
    if (mounted) {
      setState(() {
        _isLoadOk = true;
      });
    }
  }

  Widget _buildBox(Widget child, {bool haveBorder = true}) {
    return Container(
      decoration: (haveBorder
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 0.4, color: greyCAColor),
              ),
            )
          : null),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 20.0,
      ),
      child: child,
    );
  }

  Widget _buildTop() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).workDone,
                  style: TextStyles.textF14Tl,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  _detail?.finished ?? '',
                  style: TextStyles.textF14C2,
                ),
              ],
            ),
          ),
          _buildBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).unfinishedWork,
                  style: TextStyles.textF14Tl,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  _detail?.pending ?? '',
                  style: TextStyles.textF14C2,
                ),
              ],
            ),
          ),
          _buildBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).coordinate,
                  style: TextStyles.textF14Tl,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  _detail?.needed ?? '',
                  style: TextStyles.textF14C2,
                ),
              ],
            ),
          ),
          (_detail?.images ?? null) != null && _detail.images.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: _detail.images.map((image) {
                      return imgView(_detail.images, image);
                    }).toList(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTop(),
          Container(height: 8, color: AppColors.specialBgGray),
          buildCopyTo(context, _detail?.copyTo ?? null),
          Container(height: 8, color: AppColors.specialBgGray),
          buildReply(context, _detail?.comments ?? null,
              commentCall: commentCall),
        ],
      ),
    );
  }

  void commentCall(Comments comment, Map msg) {
    FocusScope.of(context).requestFocus(_textFocus);
    if (mounted) {
      setState(() {
        curComment = comment;
        curMsg = msg;
        _isReply = true;
      });
    }
  }

  void _reply() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Loading.before(context: context);
    String content;
    if (_isReply) {
      content = json.encode({
        "msg": _textController.text,
        "commentName": curComment.name,
        "commentMsg": curMsg['msg'],
        "commentUserId": curComment.userId,
      });
    } else {
      content = json.encode({"msg": _textController.text});
    }
    bool res = await workApi.replyLog(logId: widget.id, content: content);
    Loading.complete();
    if (res == true) {
      _hideQuote();
      _init();
    } else {
      showToast(context, S.of(context).replyFail);
    }
  }

  void _hideQuote() {
    if (mounted) {
      setState(() {
        curComment = null;
        curMsg = Map();
        _isReply = false;
      });
    }
  }

  Widget _buildBottomSheet() {
    return Column(
      children: [
        ChatCommonWidget.quoteShow(
          _isReply,
          '${curComment?.name ?? ""}：${curMsg['msg'] ?? ""}',
          _hideQuote,
          bgColor: greyF6Color,
        ),
        Container(
          padding: EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 0.4, color: greyCAColor))),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.4, color: greyCAColor),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: EditLineView(
                    minHeight: 40.0,
                    hintText: S.of(context).entReply,
                    top: 5.0,
                    focusNode: _textFocus,
                    textAlign: TextAlign.left,
                    textController: _textController,
                    isShowClear: isComment,
                    maxLen: 300,
                  ),
                ),
              ),
              Container(
                height: 60,
                child: buildSureBtn(
                  text: S.of(context).comment,
                  textStyle:
                      isComment ? TextStyles.textF14T2 : TextStyles.textF14T1,
                  color: isComment ? AppColors.mainColor : greyECColor,
                  onPressed: isComment ? _reply : null,
                ),
              ),
            ],
          ),
        ),
      ],
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
          title:
              '[${(_detail?.type ?? 0) == 1 ? S.of(context).daily : (_detail?.type ?? 0) == 2 ? S.of(context).weekly : S.of(context).monthlyReport}] '
              '${S.of(context).logTitle(_detail?.name ?? "")}',
          elevation: 0.5,
        ),
        body: _isLoadOk
            ? ScrollConfiguration(
                behavior: MyBehavior(),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: _buildContent(),
                    ),
                    _buildBottomSheet(),
                  ],
                ),
              )
            : buildProgressIndicator(),
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocus.dispose();
    super.dispose();
  }
}
