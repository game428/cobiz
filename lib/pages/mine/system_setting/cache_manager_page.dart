import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/config/config.dart';
import 'package:cobiz_client/provider/theme_model.dart';
import 'package:cobiz_client/tools/utils/file_util.dart';
import 'package:cobiz_client/ui/picker/data_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CacheManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CacheManagerPage();
  }
}

class _CacheManagerPage extends State<CacheManagerPage> {
  DataKeepTpe _dataKeep = DataKeepTpe.forever;
  int _cacheSize = 0;
  int _dataSize = 0;

  @override
  void initState() {
    super.initState();
    _dataKeep = Config.instance.dataKeep;
  }

  void calCacheSize() async {
    var dir = await FileUtil.getInstance().getTempPath("");
    var list = Directory(dir).list(recursive: true);
    int fSize = 0;
    list.forEach((element) {
      fSize += element.statSync().size;
    });
    _cacheSize = fSize;
  }

  void calDataSize() async {
    var dir = await FileUtil.getInstance().getDocumentsPath("");
    var list = Directory(dir).list(recursive: true);
    int fSize = 0;
    list.forEach((element) {
      fSize += element.statSync().size;
    });
    _dataSize = fSize;
  }

  void clearCache() async {
    var dir = await FileUtil.getInstance().getTempPath("");
    Directory(dir).deleteSync(recursive: true);
  }

  void clearData() async {
    var dir = await FileUtil.getInstance().getDocumentsPath("");
    Directory(dir).deleteSync(recursive: true);
  }

  Widget buildChoiceItem(CustomThemeData theme, String title, String valueName,
      bool isLine, VoidCallback onPressed) {
    return ListItemView(
      title: title,
      haveBorder: isLine,
      widgetRt1: new SizedBox(
        height: 20.0,
        child: new Text(
          valueName,
          style:
              TextStyle(fontSize: 14, color: theme.primaryTheme.primaryColor),
        ),
      ),
      onPressed: onPressed,
    );
  }

  void showPicker() {
    showDataPicker(
        context,
        DataPicker(
          jsonData: [
            {'text': S.of(context).threeDays, 'value': DataKeepTpe.threeDays},
            {'text': S.of(context).oneWeek, 'value': DataKeepTpe.oneWeek},
            {'text': S.of(context).oneMonth, 'value': DataKeepTpe.oneMonth},
            {'text': S.of(context).keepForever, 'value': DataKeepTpe.forever},
          ],
          isArray: true,
          cancelText: S.of(context).cancelText,
          confirmText: S.of(context).confirmTitle,
          onConfirm: (values, selected) {
            if (mounted) {
              setState(() {
                _dataKeep = values[0].value;
                Config.instance.dataKeep = _dataKeep;
                Config.instance.save();
              });
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<GlobalModel>(context, listen: false).currentTheme;

    Map<DataKeepTpe, String> _dataKeepTips = {
      DataKeepTpe.threeDays: S.of(context).threeDays,
      DataKeepTpe.oneWeek: S.of(context).oneWeek,
      DataKeepTpe.oneMonth: S.of(context).oneMonth,
      DataKeepTpe.forever: S.of(context).keepForever
    };

    return Scaffold(
      appBar: new ComMomBar(
        title: S.of(context).dataUsage,
        elevation: 0.5,
        mainColor: theme.textColorDark,
        backgroundColor: theme.primaryTheme.backgroundColor,
      ),
      body: Container(
        child: Column(
          children: [
            buildChoiceItem(theme, S.of(context).mediaRetentionTime,
                _dataKeepTips[_dataKeep], true, showPicker),
            Container(
              padding:
                  EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
              margin: EdgeInsets.only(bottom: 10),
              color: theme.primaryTheme.backgroundColor,
              child: Row(
                children: [
                  Text(
                    "* ",
                    style: TextStyle(color: Colors.red),
                  ),
                  Text(S.of(context).dataUsageTip,
                      style: TextStyle(color: Colors.grey))
                ],
              ),
            ),
            buildChoiceItem(
              theme,
              S.of(context).clearCache,
              FileUtil.getInstance().formatSize(_cacheSize),
              true,
              clearCache,
            ),
            buildChoiceItem(
              theme,
              S.of(context).localDatabase,
              FileUtil.getInstance().formatSize(_dataSize),
              true,
              clearData,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
