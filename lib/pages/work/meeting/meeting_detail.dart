import 'dart:convert';

import 'package:cobiz_client/http/res/team_model/common_model.dart';
import 'package:cobiz_client/http/res/team_model/meeting_detail.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/chat_common_widget.dart';
import 'package:cobiz_client/pages/work/ui/work_widget.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/view/edit_line_view.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

class MeetingDetailPage extends StatefulWidget {
  final int teamId;
  final int id;
  final int type; // 1 不能编辑，2 可编辑
  final String teamName;

  const MeetingDetailPage(
      {Key key, this.type, this.id, this.teamId, this.teamName})
      : super(key: key);

  @override
  _MeetingDetailPageState createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  TextEditingController _textController = TextEditingController();
  FocusNode _textFocus = FocusNode();
  MeetingDetail _detail;
  bool isComment = false;
  bool _isLoadOk = false;

  Comments curComment;
  Map curMsg = Map();
  bool _isReply = false;

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
    MeetingDetail res =
        await workApi.getMeetingDetail(teamId: widget.teamId, id: widget.id);
    if (res != null) {
      _detail = res;
    }
    if (mounted) {
      setState(() {
        _isLoadOk = true;
      });
    }
  }

  // 主持人
  Widget buildHost() {
    List hostList = _detail?.director;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextTitle(
            S.of(context).host,
          ),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: (hostList != null && hostList.isNotEmpty)
                  ? hostList.map((participant) {
                      return Container(
                        width: 60,
                        child: Column(
                          children: [
                            ImageView(
                                img: cuttingAvatar(participant.avatar),
                                width: 40,
                                height: 40,
                                needLoad: true,
                                isRadius: 20),
                            Container(
                              alignment: Alignment.center,
                              height: 20.0,
                              child: Text(
                                participant.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              participant.state == 1
                                  ? S.of(context).haveRead
                                  : S.of(context).unread,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: participant.state == 1
                                      ? AppColors.mainColor
                                      : null),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      );
                    }).toList()
                  : [],
            ),
          )
        ],
      ),
    );
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
        horizontal: 15.0,
        vertical: 20.0,
      ),
      child: child,
    );
  }

  // 编辑
  // Future _edit() async {}

  Widget _buildColumn() {
    String format = 'yyyy-MM-dd HH:mm';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).meetingTitle,
                  style: TextStyles.textF16T9,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  _detail?.title ?? '',
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
                  S.of(context).meetingDes,
                  style: TextStyles.textF16T9,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  _detail?.content ?? '',
                  style: TextStyles.textF14C2,
                ),
              ],
            ),
            haveBorder: false,
          ),
          Container(height: 8, color: AppColors.specialBgGray),
          buildHost(),
          Container(height: 8, color: AppColors.specialBgGray),
          buildCopyTo(context, _detail?.copyTo ?? null,
              title: S.of(context).participants),
          Container(height: 8, color: AppColors.specialBgGray),
          OperateLineView(
            title: S.of(context).beginTime,
            rightWidget: Text(
                DateUtil.formatSeconds(_detail?.beginAt ?? 0, format: format)),
            isArrow: false,
          ),
          OperateLineView(
            title: S.of(context).endTime,
            rightWidget: Text(
                DateUtil.formatSeconds(_detail?.endAt ?? 0, format: format)),
            isArrow: false,
          ),
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
    bool res = await workApi.replyMeeting(logId: widget.id, content: content);
    Loading.complete();
    if (res == true) {
      _hideQuote();
      _init();
    } else {
      showToast(context, S.of(context).replyFail);
    }
  }

  // 清除引用
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
          title: S.of(context).meeting,
          elevation: 0.5,
          // rightDMActions: <Widget>[
          //   buildSureBtn(
          //     text: S.of(context).edit,
          //     textStyle: TextStyles.textF14T2,
          //     color: AppColors.mainColor,
          //     onPressed: _edit,
          //   ),
          // ],
        ),
        body: _isLoadOk
            ? ScrollConfiguration(
                behavior: MyBehavior(),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: _buildColumn(),
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
    super.dispose();
  }
}
