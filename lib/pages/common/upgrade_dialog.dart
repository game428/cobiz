import 'package:cobiz_client/tools/cobiz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';

class UpgradeDialog extends StatefulWidget {
  final String url;
  UpgradeDialog(this.url, {Key key}) : super(key: key);

  @override
  _UpgradeDialogState createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<UpgradeDialog> {
  double _downloadProgress = 0.0;
  String _progressText = '';

  @override
  void initState() {
    super.initState();
    _installApk(widget.url);
  }

  _installApk(String url) async {
    File _apkFile = await downloadAndroid(url);
    if (_apkFile == null) {
      Navigator.pop(context);
      showToast(context, S.of(context).tryAgainLater);
      return;
    }
    String _apkFilePath = _apkFile.path;

    if (_apkFilePath.isEmpty) {
      return;
    }
    InstallPlugin.installApk(_apkFilePath, 'io.cobiz.client').then((value) {
      Navigator.pop(context);
    }).catchError((error) {
      Navigator.pop(context);
    });
  }

  /// 下载安卓更新包
  Future<File> downloadAndroid(String url) async {
    /// 创建存储文件
    Directory storageDir = await getExternalStorageDirectory();
    String storagePath = storageDir.path;
    File file =
        new File('$storagePath/${GlobalModel.getInstance().appName}v1.0.1.apk');

    if (!file.existsSync()) {
      file.createSync();
    }

    try {
      /// 发起下载请求
      Response response = await Dio().get(url,
          onReceiveProgress: showDownloadProgress,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ));
      file.writeAsBytesSync(response.data);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// 展示下载进度
  void showDownloadProgress(num received, num total) {
    if (total != -1) {
      double _progress =
          double.parse('${(received / total).toStringAsFixed(2)}');
      _downloadProgress = _progress;
      if (_progress == 1.0) {
        _progressText = S.of(context).installApp;
      } else {
        _progressText = S.of(context).downloading((_downloadProgress * 100)
            .toString()
            .substring(
                0, (_downloadProgress * 100).toString().indexOf('.') + 2));
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          width: winWidth(context) - 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                  value: _downloadProgress,
                ),
              ),
              Text(_progressText)
            ],
          ),
        ),
      ),
    );
  }
}
