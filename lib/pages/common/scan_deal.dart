import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/http/res/team_model/search_team_info.dart';
import 'package:cobiz_client/pages/common/qr_scanner.dart';
import 'package:cobiz_client/pages/common/scan_result.dart';
import 'package:cobiz_client/pages/dialogue/channel/channel_ui/http_text_page.dart';
import 'package:cobiz_client/pages/dialogue/channel/single_chat/single_info_page.dart';
import 'package:cobiz_client/pages/team/team_page/apply_join.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cobiz_client/http/team.dart' as teamApi;

class Scanner {
  static Future scanDeal(BuildContext context) async {
    String friend = 'cobiz://friend_';
    String team = 'cobiz://team_';
    String dept = 'cobiz://dept_';
    String path = await routePush(QrScannerPage());
    if (path == null) {
      return;
    }
    // 网络地址
    if (isNetWorkImg(path)) {
      if (path.startsWith(API.qrPrefix)) {
        String data =
            path.substring(path.indexOf(API.qrPrefix) + API.qrPrefix.length);
        if (strNoEmpty(data)) {
          String decodeStr = AESUtils.decrypt(data, isLocal: true);
          if (decodeStr == null) {
            routePush(HttpTextPage(path.toString().trim(), null, 2));
          } else {
            // 邀请好友
            if (decodeStr.startsWith(friend)) {
              String id = decodeStr.split(friend)[1];
              if (int.parse(id) == API.userInfo.id) {
                showToast(context, S.of(context).cantAddMine);
              } else {
                routePush(SingleInfoPage(
                  userId: int.parse(id),
                  whereToInfo: 1,
                ));
              }
              return;
            }

            // 邀请进团队
            if (decodeStr.startsWith(team)) {
              String code = '#CB#' + decodeStr.split(team)[1];
              List<SearchTeamInfo> _teamItems = await teamApi.searchTeam(code);
              if (_teamItems != null && _teamItems.isNotEmpty) {
                routePush(ApplyJoinTeamPage(
                  type: 1,
                  team: _teamItems[0],
                ));
              } else {
                showToast(context, S.of(context).teamNotExist);
              }
              return;
            }

            // 邀请进部门
            if (decodeStr.startsWith(dept)) {
              List<String> str = (decodeStr.split(dept)[1]).split('_');
              String code = '#CB#' + str[0];
              List<SearchTeamInfo> _teamItems = await teamApi.searchTeam(code);
              if (_teamItems != null && _teamItems.isNotEmpty) {
                routePush(ApplyJoinTeamPage(
                    type: 1, team: _teamItems[0], deptId: int.parse(str[1])));
              } else {
                showToast(context, S.of(context).teamNotExist);
              }
              return;
            }
          }
        } else {
          routePush(HttpTextPage(path.toString().trim(), null, 2));
        }
      } else {
        routePush(HttpTextPage(path.toString().trim(), null, 2));
      }
      return;
    } else {
      routeMaterialPush(ScanResultPage(path ?? ""));
    }
  }
}
