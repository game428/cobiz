import 'package:cobiz_client/tools/cobiz.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TemporaryCache {
  ///加载缓存
  static Future<String> loadCache() async {
    try {
      var _tempDir = await getTemporaryDirectory();
      // _tempDir.list(followLinks: false, recursive: true).listen((file) {
      //   //打印每个缓存文件的路径
      //   print(file.path);
      // });
      double value = await _getTotalSizeOfFilesInDir(_tempDir);
      return _renderSize(value);
    } catch (err) {
      debugPrint(err);
      return '0.00B';
    }
  }

  ///清除缓存
  static Future<bool> clearCache() async {
    try {
      var _tempDir = await getTemporaryDirectory();
      double value = await _getTotalSizeOfFilesInDir(_tempDir);

      if (value > 0) {
        await _delDir(_tempDir);
      }
      return true;
    } catch (e) {
      debugPrint(e);
      return false;
    }
  }

  ///递归方式删除目录
  static Future<Null> _delDir(FileSystemEntity file) async {
    try {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await _delDir(child);
        }
      }
      await file.delete();
    } catch (e) {
      debugPrint(e);
    }
  }

  ///格式化文件大小
  static String _renderSize(double value) {
    if (null == value) {
      return '0.00B';
    }
    List<String> unitArr = List()..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  /// 递归方式 计算文件的大小
  static Future<double> _getTotalSizeOfFilesInDir(
      final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        if (children != null)
          for (final FileSystemEntity child in children)
            total += await _getTotalSizeOfFilesInDir(child);
        return total;
      }
      return 0;
    } catch (e) {
      debugPrint(e);
      return 0;
    }
  }
}
