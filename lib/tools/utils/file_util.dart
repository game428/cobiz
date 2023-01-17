import 'dart:io';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

class FileUtil {
  static FileUtil _instance;

  static FileUtil getInstance() {
    if (_instance == null) {
      _instance = FileUtil._internal();
    }
    return _instance;
  }

  FileUtil._internal();

  Future<String> getTempPath(String endPath) async {
    Directory tempDir = await getTemporaryDirectory();
    String path = tempDir.path + endPath;
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return path;
  }

  Future<String> getDocumentsPath(String endPath) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String path = tempDir.path + endPath;
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return path;
  }

  Future<String> getDownloadPath(String endPath) async {
    Directory tempDir;
    if (isAndroid()) {
      tempDir = await getExternalStorageDirectory();
    } else {
      tempDir = await getApplicationDocumentsDirectory();
    }
    String path = tempDir.path + "/download" + endPath;
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return path;
  }

  bool fileExists(String path) {
    return File(path).existsSync();
  }

  void copyFile(String oldPath, String newPath) {
    File file = File(oldPath);
    if (file.existsSync()) {
      file.copy(newPath);
    }
  }

  Future<List<String>> getDirChildren(String path) async {
    Directory directory = Directory(path);
    final childrenDir = directory.listSync();
    List<String> pathList = [];
    for (var o in childrenDir) {
      final filename = o.path.split("/").last;
      if (filename.contains(".")) {
        pathList.add(o.path);
      }
    }
    return pathList;
  }

  ///[assetPath] 例子 'images/'
  ///[assetName] 例子 '1.jpg'
  ///[filePath] 例子:'/myFile/'
  ///[fileName]  例子 'girl.jpg'
  Future<String> copyAssetToFile(String assetPath, String assetName,
      String filePath, String fileName) async {
    String newPath = await FileUtil.getInstance().getTempPath(filePath);
    String name = fileName;
    bool exists = await new File(newPath + name).exists();
    if (!exists) {
      var data = await rootBundle.load(assetPath + assetName);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(newPath + name).writeAsBytes(bytes);
      return newPath + name;
    } else
      return newPath + name;
  }

  void downloadFile(
      {String url,
      String filePath,
      String fileName,
      Function onComplete}) async {
    // final path = await FileUtil.getInstance().getTempPath(filePath);
    // String name = fileName ?? url.split("/").last;
    // Req
    //     .getInstance()
    //     .client
    //     .download(
    //   url,
    //   path + name,
    //   onReceiveProgress: (int count, int total) {
    //     final downloadProgress = ((count / total) * 100).toInt();
    //     if (downloadProgress == 100) {
    //       if (onComplete != null) onComplete(path + name);
    //     }
    //   },
    //   options: Options(sendTimeout: 15 * 1000, receiveTimeout: 360 * 1000),
    // );
  }

  Future<File> getPhoto(BuildContext context,
      {bool isCropper = false, VoidCallback selectPhone}) async {
    double radius = 15.0;
    double height = 158.0;
    TextStyle textStyle = TextStyle(fontSize: 16.0);
    BorderRadiusGeometry borderRadius = BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
    ShapeBorder shapeBorder = RoundedRectangleBorder(
      borderRadius: borderRadius,
    );

    List<Widget> items = [];
    [
      S.of(context).photograph,
      S.of(context).photoAlbum,
      S.of(context).cancelText
    ].forEach((text) {
      items.add(Container(
        child: Text(
          text,
          style: textStyle,
        ),
        width: double.infinity,
        height: 50.0,
        alignment: Alignment.center,
      ));
    });

    return showModalBottomSheet(
      context: context,
      shape: shapeBorder,
      builder: (BuildContext bct) {
        return Stack(
          children: <Widget>[
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                FlatButton(
                  child: items[0],
                  onPressed: () async {
                    if (await PermissionManger.cameraPermission()) {
                      _pickImage(context, ImageSource.camera, isCropper);
                    } else {
                      showConfirm(context,
                          title: S.of(context).cameraPermission,
                          sureCallBack: () async {
                        await openAppSettings();
                      });
                    }
                  },
                  shape: shapeBorder,
                ),
                Container(
                  height: 0.3,
                  color: Color(0xFFCACACA),
                ),
                FlatButton(
                  child: items[1],
                  onPressed: () async {
                    if (await PermissionManger.photosPermission()) {
                      if (selectPhone != null) {
                        selectPhone();
                      } else {
                        _pickImage(context, ImageSource.gallery, isCropper);
                      }
                    } else {
                      showConfirm(context,
                          title: S.of(context).photosPermission,
                          sureCallBack: () async {
                        await openAppSettings();
                      });
                    }
                  },
                ),
                Container(
                  height: 8.0,
                  color: Color(0xFFECECEC),
                ),
                FlatButton(
                    color: Colors.white,
                    padding:
                        EdgeInsets.only(bottom: ScreenData.bottomSafeHeight),
                    child: items[2],
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ],
        );
      },
    );
  }

  void _pickImage(
      BuildContext context, ImageSource source, bool isCropper) async {
    final pickedFile = await ImagePicker().getImage(source: source);
    File imageFile;
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    if (imageFile != null && isCropper) {
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: 0.5, ratioY: 0.5),
        compressFormat: ImageCompressFormat.png,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: S.of(context).editPhoto,
          toolbarColor: Color(0xFF09C497),
          toolbarWidgetColor: Colors.white,
          showCropGrid: false,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioPickerButtonHidden: true,
          aspectRatioLockEnabled: true,
        ),
      );
      imageFile = croppedFile;
    }
    Navigator.pop(context, imageFile);
  }

  Size calCellPreviewSize(double width, double height) {
    const widthMax = 160.0;
    const heightMax = 200.0;
    if (width < widthMax && height < heightMax) {
      return Size(width, height);
    }

    if (width > height) {
      double retW = widthMax;
      double retH = (retW / width) * height;
      return Size(retW, retH);
    }

    if (width < height) {
      double retH = heightMax;
      double retW = (retH / height) * width;
      return Size(retW, retH);
    }

    return Size(widthMax, heightMax);
  }

  String formatSize(int size) {
    if (size < 1024) {
      return "${size}B";
    }
    if (size < 1024000) {
      return sprintf("%.2fKB", [size / 1024]);
    }
    if (size < 1024000000) {
      return sprintf("%.2fMB", [size / 1024000]);
    }
    return sprintf("%.2fGB", [size / 1024000000]);
  }

  String fileIcon(String mimeType) {
    if (mimeType.indexOf("doc") != -1) return "assets/images/work/docx.png";
    if (mimeType.indexOf("ppt") != -1) return "assets/images/work/pptx.png";
    if (mimeType.indexOf("psd") != -1) return "assets/images/work/psd.png";
    if (mimeType.indexOf("video") != -1) return "assets/images/work/wav.png";
    if (mimeType.indexOf("xls") != -1) return "assets/images/work/xlsx.png";
    if (mimeType.indexOf("zip") != -1) return "assets/images/work/zip.png";
    return "assets/images/work/other_file.png";
  }
}
