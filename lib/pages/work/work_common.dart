import 'package:cobiz_client/http/res/team_model/work_common_list.dart';
import 'package:cobiz_client/pages/work/ui/badge_decoration_view.dart';
import 'package:cobiz_client/pages/work/workbench/agree_refues.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//工作的操作按钮
Widget buildBtn(bool isCircular, String text, VoidCallback callback) {
  return CupertinoButton(
    child: Text(
      text,
      style: TextStyles.textF14C3,
    ),
    color: isCircular ? AppColors.mainColor : red68Color,
    minSize: 30.0,
    pressedOpacity: 0.8,
    padding: EdgeInsets.symmetric(
      horizontal: 15.0,
    ),
    borderRadius: BorderRadius.circular(5.0),
    onPressed: callback,
  );
}

///根据 类型: 1.通用 2.请假 3.报销 4.任务 以及状态 显示右上角标识
listBuildBadge(int status, int type, BuildContext context) {
  BadgeDecoration badge;
  switch (status) {
    case 0: //未处理 进行中
      badge = BadgeDecoration(
        badgeColor: radiusBgColor,
        textSpan: TextSpan(
          text: S.of(context).processing,
          style: TextStyles.textF12C5,
        ),
      );
      break;
    case 1:
      if (type == 4) {
        //已完成
        badge = BadgeDecoration(
          badgeColor: themeColor,
          text: S.of(context).completed,
        );
      } else {
        //已通过
        badge = BadgeDecoration(
          badgeColor: themeColor,
          text: S.of(context).passed,
        );
      }
      break;
    case 2: //已拒绝
      badge = BadgeDecoration(
        badgeColor: red68Color,
        text: S.of(context).rejected,
      );
      break;
    case 3: //已撤销
      badge = BadgeDecoration(
        badgeColor: grey81Color,
        text: S.of(context).revoked,
      );
      break;
  }
  return badge;
}

//这个不删
Widget buildAnnotation(String title, String content,
    {bool isExpanded = true, int maxLines = 1}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment:
        maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: <Widget>[
      Container(
        constraints: BoxConstraints(maxWidth: ScreenData.width / 3),
        child: Text('$title : ', style: TextStyles.textF12C4),
      ),
      (isExpanded
          ? Expanded(
              child: Text(
                content,
                style: TextStyles.textF12C5,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : Text(
              content,
              style: TextStyles.textF12C5,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            )),
    ],
  );
}

Widget buildLine({double height, Color color}) {
  return Container(
    height: height ?? 0.4,
    color: color ?? greyCAColor,
  );
}

Widget buildTitle(WorkCommonListItem workCommonListItem, BuildContext context) {
  String title = '';
  switch (workCommonListItem.type) {
    case 1:
      title = S.of(context).universalTitle(workCommonListItem.issuer);
      break;
    case 2:
      title = S.of(context).leaveTitle(workCommonListItem.issuer);
      break;
    case 3:
      title = S.of(context).reimbursementTitle(workCommonListItem.issuer);
      break;
    case 4:
      title = S.of(context).taskTitle(workCommonListItem.issuer);
      break;
  }
  return Row(
    children: <Widget>[
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.textF16C3,
        ),
      )
    ],
  );
}

///类型: 1.通用 2.请假 3.报销 4.任务
List<Widget> switchAnnotation(
    WorkCommonListItem workCommonListItem, BuildContext context) {
  List<Widget> list = [
    // buildAnnotation(S.of(context).sponsor, workCommonListItem.issuer ?? ''),
  ];
  switch (workCommonListItem.type) {
    case 1:
      list.add(buildAnnotation(
          S.of(context).applyContent, workCommonListItem.title ?? ''));
      list.add(buildAnnotation(
          S.of(context).applyDetail, workCommonListItem.content ?? ''));
      break;
    case 2:
      list.add(buildAnnotation(S.of(context).typeOfLeave,
          leaveTypeName(workCommonListItem.leaveType, context)));
      if ([1, 2, 3, 10].contains(workCommonListItem.leaveType)) {
        list.add(buildAnnotation(
            S.of(context).beginTime,
            DateUtil.formatSeconds(workCommonListItem.beginAt,
                format: 'yyyy-MM-dd HH:mm')));
        list.add(buildAnnotation(
            S.of(context).endTime,
            DateUtil.formatSeconds(workCommonListItem.endAt,
                format: 'yyyy-MM-dd HH:mm')));
      } else {
        list.add(buildAnnotation(
            S.of(context).beginTime,
            DateUtil.formatSeconds(workCommonListItem.beginAt,
                format: 'yyyy-MM-dd')));
        list.add(buildAnnotation(
            S.of(context).endTime,
            DateUtil.formatSeconds(workCommonListItem.endAt,
                format: 'yyyy-MM-dd')));
      }
      break;
    case 3:
      list.add(buildAnnotation(
          S.of(context).expenseType, workCommonListItem.title ?? ''));
      list.add(buildAnnotation(S.of(context).expenseTotal,
          '${workCommonListItem.money.toString()} (${workCommonListItem.unit})'));
      list.add(buildAnnotation(
          S.of(context).expenseDetail, workCommonListItem.content ?? ''));
      break;
    case 4:
      list.add(buildAnnotation(
          S.of(context).taskName, workCommonListItem.title ?? ''));
      list.add(buildAnnotation(
          S.of(context).taskDetail, workCommonListItem.content ?? ''));
      list.add(buildAnnotation(
          S.of(context).finishTime,
          DateUtil.formatSeconds(workCommonListItem.endAt,
              format: 'yyyy-MM-dd HH:mm')));
      break;
  }
  return list;
}

///通过页面分配按钮 pageType 1:待处理 2：已处理 3：已发起 4：抄送我
Widget switchDealBtn(WorkCommonListItem workCommonListItem,
    BuildContext context, int teamId, int pageType,
    {VoidCallback onPressed, VoidCallback onRevoke}) {
  List<Widget> btnList = [
    Container(
      constraints: BoxConstraints(maxWidth: winWidth(context) / 2 - 50),
      child: Padding(
        padding: EdgeInsets.only(left: 15.0, right: 10.0),
        child: Text(
            DateUtil.formatSeconds(workCommonListItem.time,
                format: 'yyyy-MM-dd HH:mm'),
            style: TextStyles.textF12C4),
      ),
    ),
    Spacer(),
  ];
  switch (pageType) {
    case 1:
      // type：1.通用 2.请假 3.报销 4.任务
      if (workCommonListItem.type == 4) {
        btnList.add(Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: buildBtn(true, S.of(context).finish, () {
            routePush(AgreeRefues(4, workCommonListItem.id, teamId))
                .then((state) {
              if (state == true) {
                onPressed();
              }
            });
          }),
        ));
      } else if (workCommonListItem.type == 1 ||
          workCommonListItem.type == 2 ||
          workCommonListItem.type == 3) {
        btnList.add(buildBtn(false, S.of(context).refuse, () {
          routePush(AgreeRefues(2, workCommonListItem.id, teamId))
              .then((state) {
            if (state == true) {
              onPressed();
            }
          });
        }));
        btnList.add(Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: buildBtn(true, S.of(context).agree, () {
            routePush(AgreeRefues(1, workCommonListItem.id, teamId))
                .then((state) {
              if (state == true) {
                onPressed();
              }
            });
          }),
        ));
      }
      break;
    case 2: //已处理 没有按钮
      break;
    case 3: //已发起
      if (workCommonListItem.state == 0) {
        btnList.add(Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: buildBtn(false, S.of(context).revoke, onRevoke),
        ));
      }
      break;
    case 4: //抄送我 没有按钮
      btnList.add(Padding(
        padding: EdgeInsets.only(left: 15.0, right: 15.0),
        child: workCommonListItem.read == 1
            ? Text(S.of(context).haveRead, style: TextStyles.textF12C4)
            : Text(S.of(context).unread, style: TextStyles.textF12C3),
      ));
      break;
    default:
      btnList.add(Container());
      break;
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: btnList,
  );
}
