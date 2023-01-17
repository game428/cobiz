import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/common_model.dart';
import 'package:cobiz_client/http/res/team_model/work_common_detail.dart';
import 'package:cobiz_client/pages/work/ui/work_widget.dart';
import 'package:cobiz_client/pages/work/work_common.dart';
import 'package:cobiz_client/pages/work/workbench/agree_refues.dart';
import 'package:cobiz_client/pages/work/workbench/agree_refues_show.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:cobiz_client/ui/view/list_row_view.dart';
import 'package:cobiz_client/ui/view/shadow_card_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/work.dart' as workApi;

import 'task_reply.dart';

//四个页面 通用审批详情
class GeneralApprovalDetails extends StatefulWidget {
  final int id;
  final int teamId;
  final Function(Map) updateState;

  GeneralApprovalDetails(
      {Key key, @required this.id, @required this.teamId, this.updateState})
      : super(key: key);

  @override
  _GeneralApprovalDetailsState createState() => _GeneralApprovalDetailsState();
}

class _GeneralApprovalDetailsState extends State<GeneralApprovalDetails> {
  ApprovalDetail approvalDetail;
  bool _isLoadinOk = false;

  @override
  void initState() {
    super.initState();
    _getDetail();
  }

  _getDetail() async {
    approvalDetail =
        await workApi.getApprovalDetail(teamId: widget.teamId, id: widget.id);
    if (approvalDetail == null) {
      showToast(context, S.of(context).tryAgainLater);
      Navigator.pop(context);
    } else {
      if (_isLoadinOk == false) {
        _isLoadinOk = true;
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildTop() {
    return Container(
      foregroundDecoration:
          listBuildBadge(approvalDetail.state, approvalDetail.type, context),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ShadowCardView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            ListRowView(
              paddingLeft: 0,
              haveBorder: false,
              iconRt: 15.0,
              iconWidget: Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(40.0),
                    side: BorderSide(color: Colors.grey, width: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: ImageView(
                    img: cuttingAvatar(approvalDetail.avatar),
                    needLoad: true,
                    width: 42,
                    height: 42,
                  ),
                ),
              ),
              title: nameTile(),
              label: approverState(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _bodyShow(),
            )
          ],
        ),
      ),
    );
  }

  ///body展示
  List<Widget> _bodyShow() {
    List<Widget> list = [];
    switch (approvalDetail.type) {
      case 1: // 通用
        list = [
          buildAnnotation(S.of(context).applyContent, approvalDetail.title,
              maxLines: 100),
          buildAnnotation(S.of(context).applyDetail, approvalDetail.content,
              maxLines: 100),
        ];
        if (approvalDetail.images != null && approvalDetail.images.isNotEmpty) {
          list.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: approvalDetail.images.map((image) {
                return imgView(approvalDetail.images, image);
              }).toList(),
            ),
          ));
        }
        break;
      case 2: // 请假
        String format;
        if ([1, 2, 3, 10].contains(approvalDetail.leaveType)) {
          format = 'yyyy-MM-dd HH:mm';
        } else {
          format = 'yyyy-MM-dd';
        }
        list = [
          buildAnnotation(S.of(context).typeOfLeave,
              leaveTypeName(approvalDetail.leaveType, context),
              maxLines: 1),
          buildAnnotation(S.of(context).beginTime,
              DateUtil.formatSeconds(approvalDetail.beginAt, format: format),
              maxLines: 1),
          buildAnnotation(S.of(context).endTime,
              DateUtil.formatSeconds(approvalDetail.endAt, format: format),
              maxLines: 1),
          buildAnnotation(S.of(context).reasonForLeave, approvalDetail.reason,
              maxLines: 100),
        ];
        if (approvalDetail.images != null && approvalDetail.images.isNotEmpty) {
          list.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: approvalDetail.images.map((image) {
                return imgView(approvalDetail.images, image);
              }).toList(),
            ),
          ));
        }
        break;
      case 3: // 报销
        list = [
          buildAnnotation(S.of(context).expenseTotal,
              approvalDetail.money.toString() + '(${approvalDetail.unit})',
              maxLines: 1),
          buildAnnotation(S.of(context).expenseType, approvalDetail.title,
              maxLines: 100),
          buildAnnotation(S.of(context).expenseDetail, approvalDetail.content,
              maxLines: 100),
        ];
        if (approvalDetail.images != null && approvalDetail.images.isNotEmpty) {
          list.add(Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: approvalDetail.images.map((image) {
                return imgView(approvalDetail.images, image);
              }).toList(),
            ),
          ));
        }
        break;
      case 4: // 任务
        list = [
          buildAnnotation(S.of(context).taskName, approvalDetail.title,
              maxLines: 100),
          buildAnnotation(S.of(context).taskDetail, approvalDetail.content,
              maxLines: 100),
          buildAnnotation(
              S.of(context).finishTime,
              DateUtil.formatSeconds(approvalDetail.endAt,
                  format: 'yyyy-MM-dd HH:mm'),
              maxLines: 1),
        ];
        break;
    }
    return list;
  }

  ///审批状态
  String approverState() {
    switch (approvalDetail.state) {
      case 0: // 未处理
        return S.of(context).processing;
        break;
      case 1: // 已同意/已完成
        if (approvalDetail.type == 4) {
          return S.of(context).completed;
        } else {
          return S.of(context).passed;
        }
        break;
      case 2: // 已拒绝
        return S.of(context).rejected;
        break;
      case 3: // 已撤销
        return S.of(context).revoked;
        break;
      default:
        return '';
    }
  }

  ///名字+类型
  String nameTile() {
    switch (approvalDetail.type) {
      case 1:
      case 3:
      case 4:
        return approvalDetail.name ?? '' + '-' + approvalDetail.title ?? '';
        break;
      case 2:
        return approvalDetail.name ??
            '' + '-' + leaveTypeName(approvalDetail.leaveType, context);
        break;
      default:
        return approvalDetail.name;
    }
  }

  ///审批过程
  List<Widget> _list() {
    List<Widget> list = [];

    if (approvalDetail.type == 1 ||
        approvalDetail.type == 2 ||
        approvalDetail.type == 3) {
      ///审批人
      list.add(_approversList());

      ///抄送人
      if (approvalDetail.copyToList.isNotEmpty) {
        list.add(Container(height: 8, color: AppColors.specialBgGray));
        list.add(buildCopyTo(context, approvalDetail.copyToList));
      }
    } else if (approvalDetail.type == 4) {
      ///执行人
      if (approvalDetail.executorList.isNotEmpty) {
        list.add(_executorList());
      }

      ///抄送人
      if (approvalDetail.copyToList.isNotEmpty) {
        list.add(Container(height: 8, color: AppColors.specialBgGray));
        list.add(buildCopyTo(context, approvalDetail.copyToList));
      }
    }

    /// 评论
    list.add(Container(height: 8, color: AppColors.specialBgGray));
    list.add(
        buildReply(context, approvalDetail.comments, commentCall: commentCall));
    return list;
  }

  // 审批人
  Widget _approversList() {
    List<Widget> list = [
      buildTextTitle(S.of(context).approvalWorkflow),
      SizedBox(height: 15),
    ];
    int len = approvalDetail.approvers.length + 1;
    list.add(_buildBot(null, 0, 1, len));

    ///审批者
    if (approvalDetail.approvers.isNotEmpty) {
      for (var i = 0; i < approvalDetail.approvers.length; i++) {
        if (approvalDetail.state == 3 &&
            approvalDetail.approvers[i].state == 0) {
          list.add(_buildBot(null, i + 1, 3, len));
          break;
        }
        list.add(_buildBot(approvalDetail.approvers[i], i + 1, 2, len));
      }
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }

  void commentCall(Comments comment, Map msg) {
    routePush(TaskReply(
      teamId: widget.teamId,
      id: widget.id,
      curComment: comment,
      curMsg: msg,
    )).then((value) {
      if (value == true) {
        _getDetail();
      }
    });
  }

  // 执行人
  Widget _executorList() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTextTitle(S.of(context).executor),
          SizedBox(height: 15),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.spaceAround,
              children: approvalDetail.executorList.map((executor) {
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (executor?.msg != null && executor?.msg != '') {
                      routePush(AgreeRefuesShow(
                        content: executor?.msg ?? "",
                        time: executor?.time ?? 0,
                      ));
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 60,
                        child: Column(
                          children: [
                            ImageView(
                              img: cuttingAvatar(executor.avatar),
                              width: 40,
                              height: 40,
                              needLoad: true,
                              isRadius: 20,
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 20.0,
                              child: Text(
                                executor.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              executor.state == 0
                                  ? executor.userId != API.userInfo.id
                                      ? S.of(context).unread
                                      : S.of(context).haveRead
                                  : executor.state == 1
                                      ? S.of(context).haveRead
                                      : executor?.msg ??
                                          S.of(context).completed,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: (executor.state == 1 ||
                                          (executor.state == 0 &&
                                              executor.userId ==
                                                  API.userInfo.id))
                                      ? AppColors.mainColor
                                      : null),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Icon(
                          Icons.done,
                          size: 14,
                          color: executor?.state == 2
                              ? themeColor
                              : Colors.transparent,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  //审批人
  Widget _buildBot(ApproversAndExecutor data, int index, int type, int len) {
    List<Widget> dots = [
      buildMessaged(
        color: type == 1
            ? Color(0xFF3E80CA)
            : (type == 3 || approvalDetail.approver == data.userId)
                ? Color(0xFFD87675)
                : Color(0xFF3E80CA),
        size: 6.0,
      ),
      SizedBox(
        height: 6.0,
      ),
    ];
    for (var i = 0; i < 2; i++) {
      dots.insert(
          0,
          SizedBox(
            height: type == 1 ? 6.0 : 4.0,
          ));
      dots.insert(
          0,
          buildMessaged(
            color: type == 1
                ? Color(0xFFD2D2D2).withOpacity(0)
                : Color(0xFFD2D2D2),
            size: 4.0,
          ));
    }
    for (int i = 0; i < 7; i++) {
      dots.add(buildMessaged(
        color: index + 1 == len
            ? Color(0xFFD2D2D2).withOpacity(0)
            : Color(0xFFD2D2D2),
        size: 4.0,
      ));
      dots.add(SizedBox(
        height: index + 1 == len ? 0 : 4.0,
      ));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Column(
            children: dots,
          ),
        ),
        Expanded(
          child: _buildPickBox(data, type),
        ),
      ],
    );
  }

  //审批人
  Widget _buildPickBox(ApproversAndExecutor data, int type) {
    return Container(
        padding: EdgeInsets.only(
          left: 10.0,
        ),
        child: InkWell(
          child: Row(
            children: <Widget>[
              ImageView(
                img: cuttingAvatar((type == 1 || type == 3)
                    ? approvalDetail?.avatar
                    : data?.avatar),
                needLoad: true,
                width: 40,
                height: 40,
                isRadius: 20,
              ),
              SizedBox(width: 10),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    type == 1
                        ? S.of(context).initiateApplication
                        : type == 3 ? approvalDetail?.name : data?.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    type == 1 ? approvalDetail?.name : data?.msg ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: FontSizes.font_s14),
                  ),
                ],
              )),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  type != 3
                      ? Text(
                          DateUtil.formatSeconds(
                              type == 1
                                  ? approvalDetail?.time
                                  : (approvalDetail?.approver != data?.userId
                                      ? data?.state != 0 ? data?.time : 0
                                      : data?.time),
                              format: 'MM-dd HH:mm'),
                          maxLines: 1,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.textF12C4,
                        )
                      : Container(),
                  Text(
                    type == 2
                        ? approversState(data?.state, data?.userId)
                        : type == 3 ? S.of(context).revoked : '',
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: FontSizes.font_s16,
                        color: data?.state == 2
                            ? red68Color
                            : type == 3 ? grey81Color : AppColors.mainColor),
                  ),
                ],
              )),
            ],
          ),
          onTap: () {
            if (type == 2 &&
                data != null &&
                data?.msg != null &&
                data?.msg != '') {
              routePush(AgreeRefuesShow(
                content: data?.msg ?? "",
                time: data?.time ?? 0,
              ));
            }
          },
        ));
  }

  ///审批人状态
  String approversState(int state, int userId) {
    switch (state) {
      case 0:
        if (userId == approvalDetail?.approver) {
          return S.of(context).review;
        } else {
          return '';
        }
        break;
      case 1:
        return S.of(context).agreed;
      case 2:
        return S.of(context).rejected;
      default:
        return '';
    }
  }

  ///底部按钮
  Widget _buildBottomSheet() {
    List<Widget> buttons = List();
    double btnHeight = 40.0;
    // 评论按钮
    buttons.add(Expanded(
      child: buildCommonButton(
        S.of(context).comment,
        margin: EdgeInsets.only(right: 15.0),
        fontSize: FontSizes.font_s16,
        minHeight: btnHeight,
        backgroundColor: AppColors.mainColor,
        onPressed: () {
          routePush(TaskReply(teamId: widget.teamId, id: widget.id))
              .then((value) {
            if (value == true) {
              _getDetail();
            }
          });
        },
      ),
    ));
    if (approvalDetail.executorList.isNotEmpty &&
        approvalDetail.type == 4 &&
        approvalDetail.state == 0) {
      approvalDetail.executorList.forEach((executor) {
        if (executor.userId == API.userInfo.id && executor.state != 2) {
          // 完成按钮
          buttons.add(Expanded(
            child: buildCommonButton(
              S.of(context).finish,
              margin: EdgeInsets.only(right: 15.0),
              fontSize: FontSizes.font_s16,
              minHeight: btnHeight,
              backgroundColor: themeColor,
              sizeColor: Colors.white,
              onPressed: () {
                routePush(AgreeRefues(4, approvalDetail.id, widget.teamId))
                    .then((state) async {
                  if (state == true) {
                    _getDetail();
                    if (widget.updateState != null) {
                      widget.updateState({"type": 4, "state": approvalDetail.state});
                    }
                  }
                });
              },
            ),
          ));
          return;
        }
      });
    }
    if (approvalDetail.approvers.isNotEmpty && approvalDetail.state == 0) {
      approvalDetail.approvers.forEach((approver) {
        if (approver.userId == API.userInfo.id) {
          if (approver.state == 0) {
            if (approvalDetail.type != 4) {
              // 同意按钮
              buttons.add(Expanded(
                child: buildCommonButton(
                  S.of(context).agree,
                  margin: EdgeInsets.only(right: 15.0),
                  fontSize: FontSizes.font_s16,
                  minHeight: btnHeight,
                  backgroundColor: AppColors.mainColor,
                  onPressed: () {
                    routePush(AgreeRefues(1, approvalDetail.id, widget.teamId))
                        .then((state) async {
                      if (state == true) {
                        _getDetail();
                        if (widget.updateState != null) {
                          widget.updateState({"type": 1, "state": approvalDetail.state});
                        }
                      }
                    });
                  },
                ),
              ));
              // 拒绝按钮
              buttons.add(Expanded(
                child: buildCommonButton(
                  S.of(context).refuse,
                  margin: EdgeInsets.only(right: 15.0),
                  fontSize: FontSizes.font_s16,
                  minHeight: btnHeight,
                  backgroundColor: red68Color,
                  onPressed: () {
                    routePush(AgreeRefues(2, approvalDetail.id, widget.teamId))
                        .then((state) async {
                      if (state == true) {
                        _getDetail();
                        if (widget.updateState != null) {
                          widget.updateState({"type": 2, "state": approvalDetail.state});
                        }
                      }
                    });
                  },
                ),
              ));
            }
          }
          return;
        }
      });
    }

    if (approvalDetail.issuer == API.userInfo.id && approvalDetail.state == 0) {
      // 撤销按钮
      buttons.add(Expanded(
        child: buildCommonButton(
          S.of(context).revoke,
          margin: EdgeInsets.only(right: 15.0),
          fontSize: FontSizes.font_s16,
          backgroundColor: red68Color,
          minHeight: btnHeight,
          onPressed: () {
            showSureModal(context, S.of(context).confirmCancellation, () async {
              Loading.before(context: context);
              bool modifyRes = await workApi.modifyApprovalState(
                id: approvalDetail.id,
                teamId: widget.teamId,
                type: 3,
              );
              Loading.complete();
              if (modifyRes == true) {
                _getDetail();
                if (widget.updateState != null) {
                  widget
                      .updateState({"type": 3, "state": approvalDetail.state});
                }
              } else {
                showToast(context, S.of(context).tryAgainLater);
              }
            }, promptText: S.of(context).revokeHint);
          },
        ),
      ));
    }
    if (buttons.length > 0) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
        child: Row(children: buttons),
      );
    } else {
      return Container();
    }
  }

  String pageTitle() {
    switch (approvalDetail?.type ?? 0) {
      case 1:
        return S.of(context).generalDetails;
        break;
      case 2:
        return S.of(context).leaveDetail;
        break;
      case 3:
        return S.of(context).reimbursementDetails;
        break;
      case 4:
        return S.of(context).taskDetail;
        break;
      default:
        return S.of(context).detail;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComMomBar(
        title: pageTitle(),
        elevation: 0.5,
      ),
      body: _isLoadinOk
          ? ScrollConfiguration(
              behavior: MyBehavior(),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildTop(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _list(),
                          ),
                          SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomSheet(),
                ],
              ),
            )
          : buildProgressIndicator(),
    );
  }
}
