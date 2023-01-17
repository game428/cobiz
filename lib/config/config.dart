import 'dart:convert';
import 'package:cobiz_client/tools/cobiz.dart';

enum DataKeepTpe { threeDays, oneWeek, oneMonth, forever }

class Config {
  bool adlOnCellular = false; //蜂窝网络时自动下载媒体
  bool adlOnWifi = true; //wifi时自动下载媒体
  bool aplGit = true; //自动播放git
  bool aplVideo = true; //自动播放视频
  DataKeepTpe dataKeep = DataKeepTpe.forever;

  static Config _instance = Config();

  static void init() async {
    var data = await SharedUtil.instance.getString("_config");
    if (data == null) {
      return;
    }
    var obj = json.decode(data);
    _instance = Config.fromJsonMap(obj);
  }

  // ignore: unused_element
  Config._internal();

  Config();

  static Config get instance => _instance;

  void save() async {
    var obj = toJson();
    var data = json.encode(obj);
    await SharedUtil.instance.saveString("_config", data);
  }

  Config.fromJsonMap(Map<String, dynamic> map)
      : adlOnCellular = map["adlOnCellular"] ?? false,
        adlOnWifi = map["adlOnWifi"] ?? true,
        aplGit = map["aplGit"] ?? true,
        aplVideo = map["aplVideo"] ?? true,
        dataKeep = map["dataKeep"] == null
            ? DataKeepTpe.forever
            : DataKeepTpe.values[map["dataKeep"]];

  Map<String, dynamic> toJson() {
    return {
      "adlOnCellular": adlOnCellular,
      "adlOnWifi": adlOnWifi,
      "aplGit": aplGit,
      "aplVideo": aplVideo,
      "dataKeep": dataKeep.index,
    };
  }
}
