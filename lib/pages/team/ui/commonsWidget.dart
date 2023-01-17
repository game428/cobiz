import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cobiz_client/ui/view/text_radius_view.dart';

List<Widget> identity(BuildContext context, int manager, int leader) {
  List<Widget> roleWidget = List();
  //是否是管理员 主管理员
  if (manager == 1) {
    roleWidget.add(TextRadiusView(
      text: S.of(context).manager,
      margin: EdgeInsets.only(
        top: 2.0,
        right: 5.0,
      ),
    ));
  } else if (manager == 2) {
    roleWidget.add(TextRadiusView(
      text: S.of(context).administrator,
      margin: EdgeInsets.only(
        top: 2.0,
        right: 5.0,
      ),
    ));
  }
  //部门主管
  if (leader == 1) {
    roleWidget.add(TextRadiusView(
      text: S.of(context).departmentHead,
      margin: EdgeInsets.only(
        top: 2.0,
        right: 5.0,
      ),
    ));
  }
  // 成员
  if (roleWidget.length == 0) {
    roleWidget.add(TextRadiusView(
      text: S.of(context).member,
      margin: EdgeInsets.only(
        top: 2.0,
        right: 5.0,
      ),
    ));
  }
  //自己
  // if (teamMember.id == API.userInfo.id) {
  //   roleWidget.add(TextRadiusView(
  //     text: '自己',
  //     margin: EdgeInsets.only(
  //       top: 2.0,
  //       right: 5.0,
  //     ),
  //   ));
  // }
  return roleWidget;
}

Widget arrowText(String text, {bool type = false}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      Padding(
        padding: EdgeInsets.only(bottom: 2),
        child: Text(
          text,
          style: type ? TextStyles.textF16C1 : TextStyles.textF16,
        ),
      )
    ],
  );
}
