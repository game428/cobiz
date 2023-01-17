import 'dart:convert';
import 'dart:typed_data';

import 'package:cobiz_client/provider/global_model.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

String getOnlyId() {
  var uuid = Uuid();
  return uuid.v4(options: {'rng': UuidUtil.cryptoRNG}).replaceAll('-', '');
}

//补 空格
String httpAddSpace(String msg) {
  String m = msg;
  if ((msg.contains('http://') || msg.contains('https://')) &&
      !msg.endsWith(' ')) {
    m = msg + ' ';
  }
  return m;
}

//返回burn时间戳
int getBurnByType(int burnType) {
  switch (burnType) {
    case 0:
      return 0;
    case 1:
      return -1;
    case 2:
      return 60000;
    case 3:
      return 300000;
    case 4:
      return 3600000;
    case 5:
      return 86400000;
    default:
      return 0;
  }
}

List burnSettingList(BuildContext context) {
  return [
    {"value": 0, "text": S.of(context).close},
    {"value": 1, "text": S.of(context).burnedImmediately},
    {"value": 2, "text": S.of(context).m1},
    {"value": 3, "text": S.of(context).m5},
    {"value": 4, "text": S.of(context).h1},
    {"value": 5, "text": S.of(context).h24},
  ];
}

// 返回请假类型列表
typeList(BuildContext context) {
  List types = [
    {
      'value': 1,
      'text': S.of(context).personalLeave,
      'label': S.of(context).leaveByHour,
    },
    {
      'value': 2,
      'text': S.of(context).exchangingHoliday,
      'label': S.of(context).leaveByHour,
    },
    {
      'value': 3,
      'text': S.of(context).sickLeave,
      'label': S.of(context).leaveByHour,
    },
    {
      'value': 4,
      'text': S.of(context).annualLeave,
      'label': S.of(context).leaveByWholeDay,
    },
    {
      'value': 5,
      'text': S.of(context).maternityLeave,
      'label': S.of(context).leaveByWholeDay,
    },
    {
      'value': 6,
      'text': S.of(context).paternityLeave,
      'label': S.of(context).leaveByWholeDay,
    },
    {
      'value': 7,
      'text': S.of(context).marriageHoliday,
      'label': S.of(context).leaveByWholeDay,
    },
    {
      'value': 8,
      'text': S.of(context).periodHoliday,
      'label': S.of(context).leaveByWholeDay,
    },
    {
      'value': 9,
      'text': S.of(context).bereavementLeave,
      'label': S.of(context).leaveByWholeDay,
    },
    {
      'value': 10,
      'text': S.of(context).lactationLeave,
      'label': S.of(context).leaveByHour,
    },
  ];
  return types;
}

//根据请假类型匹配名称
leaveTypeName(int type, BuildContext context) {
  String text = '';
  List types = typeList(context);
  for (var i = 0; i < types.length; i++) {
    if (types[i]['value'] == type) {
      text = types[i]['text'];
      break;
    }
  }
  return text;
}

//消息推送，聊天消息格式化
Map<String, String> formatChat(BuildContext context, dynamic data, int id) {
  String msg = '';
  switch (data.mtype) {
    case 1: // 文本
      if (data.type == 2) {
        msg = jsonDecode(data.msg)['text'] ?? '';
      } else {
        if (strIsJson(data.msg)) {
          msg = jsonDecode(data.msg)['text'] ?? '';
        } else {
          msg = data.msg;
        }
      }
      break;
    case 2: // 语音
      msg = '[${S.of(context).audio}]';
      break;
    case 3: // 图片
      msg = '[${S.of(context).photo}]';
      break;
    case 4: // 视频
      msg = '[${S.of(context).video}]';
      break;
    case 5: // 名片
      msg = '[${S.of(context).contactCard}]';
      break;
    case 8: // 公告
      msg = S.of(context).teamNoticeMsg;
      break;
    case 101:
      msg = S.of(context).whoInvitedThem(
          data.from == id ? S.of(context).me : data.name,
          json.decode(data.msg)['names'].join('、'));
      break;
    case 102:
      msg = S.of(context).leftTheGroup(data.name);
      break;
    case 105:
      msg = S.of(context).groupNoticeMsg;
      break;
    case 108:
      msg = '[${S.of(context).teamInvitation}]';
      break;
    default:
      msg = data.msg;
      if (data.type == 2) {
        msg = S.of(context).groupMsg;
      }
      break;
  }
  String name = data.name;
  if (data.type == 2) {
    name = data.gname;
    if (data.mtype != 8 &&
        data.mtype != 101 &&
        data.mtype != 102 &&
        data.mtype != 105) {
      msg = '${data.name} : $msg';
    }
  }
  Map<String, String> map = {
    "title": name,
    "content": msg,
  };
  return map;
}

//消息推送，通知消息格式化
Map<String, String> formatWork(BuildContext context, dynamic data) {
  String title = data['title'];
  String content = S.of(context).newMsg;

  if (data['mode'] == 1) {
    if (strNoEmpty(data['isRev'])) {
      content =
          '[${S.of(context).approve}] ${S.of(context).someRevAppr(data['isRev'], data['userName'] ?? '')}';
    } else {
      content =
          '[${S.of(context).approve}] ${S.of(context).needU(data['userName'] ?? '')}';
    }
  } else if (data['mode'] == 2) {
    if (strNoEmpty(data['isRev'])) {
      content =
          '[${S.of(context).logging}] ${S.of(context).someRev(data['isRev'], data['userName'] ?? '')}';
    } else {
      content =
          '[${S.of(context).logging}] ${S.of(context).upLog(data['userName'] ?? '')}';
    }
  } else if (data['mode'] == 3) {
    if (strNoEmpty(data['isRev'])) {
      content =
          '[${S.of(context).meeting}] ${S.of(context).someRevMeeting(data['isRev'], data['userName'] ?? '')}';
    } else {
      content =
          '[${S.of(context).meeting}] ${S.of(context).meetingMinTitle(data['userName'] ?? '')}';
    }
  } else if (data['mode'] == 10) {
    //任务
    if (strNoEmpty(data['isRev'])) {
      content =
          '[${S.of(context).task}] ${S.of(context).someRevTask(data['isRev'], data['userName'] ?? '')}';
    } else {
      content =
          '[${S.of(context).task}] ${S.of(context).taskTitle(data['userName'] ?? '')}';
    }
  }
  Map<String, String> map = {
    "title": title ?? 'Cobiz',
    "content": content ?? "",
  };
  return map;
}

//根据团队类型id匹配名称
Future<String> queryTeamTypeName(int type, BuildContext context) async {
  GlobalModel model = Provider.of<GlobalModel>(context, listen: false);
  List<String> codes = model.currentLanguageCode;
  String text = S.of(context).other;
  List teamTypeJson = json.decode(await rootBundle
      .loadString('assets/data/team_types_${codes[0]}_${codes[1]}.json'));
  for (var i = 0; i < teamTypeJson.length; i++) {
    if (teamTypeJson[i]['value'] == type) {
      text = teamTypeJson[i]['text'];
      break;
    }
  }
  return text;
}

// 保存图片
void saveToLocal(BuildContext context, GlobalKey repaintKey) async {
  if (await PermissionManger.photosPermission()) {
    RenderRepaintBoundary boundary =
        repaintKey.currentContext.findRenderObject();
    ui.Image image =
        await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List data = byteData.buffer.asUint8List();
    final result = await ImageGallerySaver.saveImage(data);
    if (result != null) {
      showToast(context, S.of(context).saveSuccess);
    } else {
      showToast(context, S.of(context).saveFailed);
    }
  } else {
    showConfirm(context, title: S.of(context).photosPermission,
        sureCallBack: () async {
      await openAppSettings();
    });
  }
}

// 头像专用
String cuttingAvatar(String path) {
  if (strNoEmpty(path)) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return '$path?imageView2/1/w/80/h/80';
    }
    return path;
  } else {
    return 'assets/images/def_avatar.png';
  }
}

// 聊天图片
String chatThumbnail(String path) {
  if (strNoEmpty(path)) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return '$path?imageView2/2/w/120';
    }
    return path;
  } else {
    return 'assets/images/default.jpg';
  }
}

// 笔记图片
String noteThumbnail(String path) {
  if (strNoEmpty(path)) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return '$path?imageView2/1/w/100/h/100';
    }
    return path;
  } else {
    return 'assets/images/default.jpg';
  }
}

// 笔记视频
String noteVideoThumbnail(String path) {
  if (strNoEmpty(path)) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return '$path?vframe/png/offset/0/w/70/h/70';
    }
    return path;
  } else {
    return 'assets/images/default.jpg';
  }
}

// 获取城市列表
Future<String> getRegion(BuildContext context) {
  GlobalModel model = Provider.of<GlobalModel>(context, listen: false);
  List<String> codes = model.currentLanguageCode;
  return rootBundle
      .loadString('assets/data/region_${codes[0]}_${codes[1]}.json');
}

// 获取对应城市地址
String getPlace(String value, {int area1, int area2, int area3, int type = 1}) {
  List _nations = json.decode(value);
  String place = '';
  var country = _nations.firstWhere((e) => e['id'] == area1);
  if (country == null) return place;
  if ((area1 > 1 || area2 < 1) && country['id'] != 247) {
    place = country['text'];
  }
  if ((area2 ?? 0) > 0 && country['child'].length > 0) {
    var province = country['child'].firstWhere((e) => e['id'] == area2);
    if (province == null) return place;
    if (type == 1) {
      place += '${place.length > 0 ? ' ' : ''}${province['text']}';
    } else if (type == 2) {
      place = province['text'];
    }
    if ((area3 ?? 0) > 0 && province['child'].length > 0) {
      var city = province['child'].firstWhere((e) => e['id'] == area3);
      if (city == null) return place;
      if (type == 1) {
        place += ' ${city['text']}';
      } else if (type == 2) {
        place = city['text'];
      }
    }
  }
  return place;
}
