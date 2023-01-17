import 'package:cobiz_client/pages/mine/ui/titled_box.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/ui/view/switch_line_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cache_manager_page.dart';

class StoreSettingsPage extends StatefulWidget {
  StoreSettingsPage();

  @override
  _StoreSettingsPageState createState() => _StoreSettingsPageState();
}

class _StoreSettingsPageState extends State<StoreSettingsPage> {
  bool aplGit = false;
  bool aplVideo = false;
  bool whenUsedCellular = false;
  bool whenUsedWifi = false;

  // 存储
  List<Widget> buidStorageItems(GlobalModel model) {
    List<Widget> list = [
      OperateLineView(
        title: S.of(context).storageUsage,
        onPressed: () {
          routePush(CacheManagerPage());
        },
      ),
      OperateLineView(
        title: S.of(context).cellularDataUsage,
        onPressed: () {},
      ),
    ];

    return list;
  }

  // 下载
  List<Widget> buidDownloadItems(GlobalModel model) {
    List<Widget> list = [
      SwitchLineView(
        title: S.of(context).whenUsedCellular,
        value: whenUsedCellular,
        isArrow: true,
        onPressed: () {
        },
        onChanged: (value) {
          if (mounted) {
            setState(() {
              whenUsedCellular = value;
            });
          }
        },
      ),
      SwitchLineView(
        title: S.of(context).whenUsedWifi,
        value: whenUsedWifi,
        isArrow: true,
        onPressed: () {
        },
        onChanged: (value) {
          if (mounted) {
            setState(() {
              whenUsedWifi = value;
            });
          }
        },
      ),
    ];

    return list;
  }

  // 播放
  List<Widget> buidPlayItems(GlobalModel model) {
    List<Widget> list = [
      SwitchLineView(
        title: S.of(context).gitPicture,
        value: aplGit,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              aplGit = value;
            });
          }
        },
      ),
      SwitchLineView(
        title: S.of(context).video,
        value: aplVideo,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              aplVideo = value;
            });
          }
        },
      ),
    ];

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context, listen: false);

    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).dataStore,
        elevation: 0.5,
      ),
      body: Container(
        color: model.currentTheme.primaryTheme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TitledBox(
                title: S.of(context).storageAndNetworkUsage,
                children: buidStorageItems(model),
              ),
              TitledBox(
                title: S.of(context).downloadMediaAutomatically,
                margin: EdgeInsets.only(top: 10),
                children: buidDownloadItems(model),
              ),
              TitledBox(
                title: S.of(context).autoPlay,
                margin: EdgeInsets.only(top: 10),
                children: buidPlayItems(model),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
