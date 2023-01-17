import 'dart:convert';

import 'package:cobiz_client/http/res/client_version.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:sy_flutter_qiniu_storage/sy_flutter_qiniu_storage.dart';
import 'package:cobiz_client/config/api.dart';
import 'package:cobiz_client/socket/command.dart';
import 'package:cobiz_client/tools/cobiz.dart';
import 'package:cobiz_client/tools/aes_util.dart';
import 'package:cobiz_client/domain/storage_domain.dart';

import 'req.dart';
import 'res/res.dart';

// import 'res/client_version.dart';
final SyFlutterQiniuStorage _syStorage = new SyFlutterQiniuStorage();

/// 交换密钥
Future<String> swapCipher(String pubKey) async {
  var str = await Req.post(API.swapCipherUrl,
      params: {'pubKey': pubKey}, headers: API.tokenHeader(isJson: true));
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return res.data['pubKey'];
}

/// 检查客户端版本信息
/// type: 1.用户协议 2.隐私协议
Future<String> getAgreementUrl(int type, String language) async {
  var str = await Req.post(API.getAgreementUrl,
      params: {'type': type, 'language': language, 'source': 1},
      headers: API.jsonHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return res.data['url'];
}

/// 获取推广地址
Future<String> getPromoteUrl() async {
  var str = await Req.post(API.getPromoteUrl, headers: API.tokenHeader());
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return res.data['url'];
}

/// 检查客户端版本信息
Future<ClientVersion> versionCheck(String version) async {
  var str = await Req.post(API.versionCheckUrl,
      params: {
        'platform': isAndroid() ? 1 : (isIOS() ? 2 : 0),
        'version': version,
        'source': 1
      },
      headers: API.tokenHeader(isJson: true));
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code != 0) {
    return null;
  }
  return ClientVersion.fromJsonMap(res.data);
}

// 压缩图片
Future<File> singleCompressFile(File file) async {
  try {
    File result = await FlutterNativeImage.compressImage(file.absolute.path,
        quality: 80, percentage: 50);
    return result;
  } catch (e) {
    return null;
  }
}

// 压缩视频
Future<File> singleCompressVideo(File file) async {
  try {
    final result = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
    );
    return result.file;
  } catch (e) {
    return null;
  }
}

/// bucket: 1.聊天 2.头像 3.笔记 4.投诉/反馈 5.工作
Future<Map<String, dynamic>> qiniuToken({int bucket}) async {
  var str = await Req.post(API.qiniuTokenUrl,
      params: {'bucket': bucket ?? 1}, headers: API.tokenHeader(isJson: true));
  if (!strNoEmpty(str)) {
    return null;
  }
  var res = Res.fromJsonMap(json.decode(str));
  if (res.code == 0) {
    if (res.data.toString().startsWith('{') &&
        res.data.toString().endsWith('}'))
      return res.data;
    else
      return json.decode(AESUtils.decrypt(res.data));
  }
  return null;
}

String getFileKey(String path) {
  return '${API.userInfo.id}-' +
      DateTime.now().millisecondsSinceEpoch.toString() +
      '.' +
      path.split('.').last;
}

// /// 批量上传文件, 返回一个键值对数据
// /// paths 文件原路径
// /// 返回: key是原文件路径, value是新文件路径
// Future<Map<String, String>> uploadFilesToMap(Set<String> paths) async {
//   if (paths == null || paths.length < 1) return Map();

//   Map<String, dynamic> qiniuInfo = await qiniuToken();
//   if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
//   String token = qiniuInfo['token'];
//   if (!strNoEmpty(token)) throw 'Qiniu token is empty';
//   String prefix = qiniuInfo['prefix'];
//   if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';

//   Map<String, String> images = Map();
//   for (String path in paths) {
//     if (path.startsWith(prefix)) {
//       images[path] = path.replaceAll(prefix, '');
//     } else {
//       UploadResult _upRs =
//           await _syStorage.upload(path, token, getFileKey(path));
//       if (_upRs == null || !_upRs.success) {
//         throw 'Qiniu upload is error';
//       }
//       images[path] = _upRs.key;
//     }
//   }
//   return images;
// }

// Future<Map<String, String>> uploadFilesByChats(List<ChatStore> chats,
//     {bool backFullPath = false}) async {
//   if (chats == null || chats.length < 1) return Map();
//   Map<String, dynamic> qiniuInfo = await qiniuToken();
//   if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
//   String token = qiniuInfo['token'];
//   if (!strNoEmpty(token)) throw 'Qiniu token is empty';
//   String prefix = qiniuInfo['prefix'];
//   if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';
//   Map<String, String> images = Map();
//   for (ChatStore chat in chats) {
//     if (chat.mtype != MediaType.PICTURE.index + 1 &&
//         chat.mtype != MediaType.VIDEO.index + 1) continue;
//     if (chat.msg.startsWith(prefix)) {
//       images[chat.id] =
//           backFullPath ? chat.msg : chat.msg.replaceAll(prefix, '');
//     } else {
//       UploadResult _upRs =
//           await _syStorage.upload(chat.msg, token, getFileKey(chat.msg));
//       if (_upRs == null || !_upRs.success) {
//         throw 'Qiniu upload is error';
//       }
//       images[chat.id] = backFullPath ? '$prefix${_upRs.key}' : _upRs.key;
//     }
//   }
//   return images;
// }

// /// 批量上传文件, 返回图片最新路径
// /// paths 文件原路径
// Future<List<String>> uploadFilesToList(Set<String> paths,
//     {bool backFullPath = false}) async {
//   if (paths == null || paths.length < 1) return List();

//   Map<String, dynamic> qiniuInfo = await qiniuToken();
//   if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
//   String token = qiniuInfo['token'];
//   if (!strNoEmpty(token)) throw 'Qiniu token is empty';
//   String prefix = qiniuInfo['prefix'];
//   if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';

//   List<String> images = List();
//   for (String path in paths) {
//     if (path.startsWith(prefix)) {
//       images.add(backFullPath ? path : path.replaceAll(prefix, ''));
//     } else {
//       UploadResult _upRs =
//           await _syStorage.upload(path, token, getFileKey(path));
//       if (_upRs == null || !_upRs.success) {
//         throw 'Qiniu upload is error';
//       }
//       images.add(backFullPath ? '$prefix${_upRs.key}' : _upRs.key);
//     }
//   }
//   return images;
// }

/// 上传单文件
Future<String> uploadFile(String path,
    {int bucket = 1, bool backFullPath = false}) async {
  if (!strNoEmpty(path)) return null;
  Map<String, dynamic> qiniuInfo = await qiniuToken(bucket: bucket);
  if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
  String token = qiniuInfo['token'];
  if (!strNoEmpty(token)) throw 'Qiniu token is empty';
  String prefix = qiniuInfo['prefix'];
  if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';

  if (path.startsWith(prefix)) {
    return backFullPath ? path : path.replaceAll(prefix, '');
  } else {
    UploadResult _upRs = await _syStorage.upload(path, token, getFileKey(path));
    if (_upRs == null || !_upRs.success) {
      throw 'Qiniu upload is error';
    }
    return backFullPath ? '$prefix${_upRs.key}' : _upRs.key;
  }
}

// 上传单文件并压缩
Future<String> uploadFileCompress(String path,
    {int bucket = 1, bool backFullPath = false, int type}) async {
  if (!strNoEmpty(path)) return null;
  Map<String, dynamic> qiniuInfo = await qiniuToken(bucket: bucket);
  if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
  String token = qiniuInfo['token'];
  if (!strNoEmpty(token)) throw 'Qiniu token is empty';
  String prefix = qiniuInfo['prefix'];
  if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';

  if (path.startsWith(prefix)) {
    return backFullPath ? path : path.replaceAll(prefix, '');
  } else {
    String rosultPath = path;
    if (type == MediaType.PICTURE.index + 1) {
      File flie = File(path);
      File result = await singleCompressFile(flie);
      rosultPath = result.path;
    } else if (type == MediaType.VIDEO.index + 1) {
      File flie = File(path);
      File result = await singleCompressVideo(flie);
      rosultPath = result.path;
    }
    UploadResult _upRs =
        await _syStorage.upload(rosultPath, token, getFileKey(rosultPath));
    if (_upRs == null || !_upRs.success) {
      throw 'Qiniu upload is error';
    }
    return backFullPath ? '$prefix${_upRs.key}' : _upRs.key;
  }
  // return null;
}

// 批量上传文件并压缩
Future<Map<String, String>> uploadFilesCompress(List<ChatStore> chats,
    {int bucket = 1, bool backFullPath = false}) async {
  if (chats == null || chats.length < 1) return Map();
  Map<String, dynamic> qiniuInfo = await qiniuToken(bucket: bucket);
  if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
  String token = qiniuInfo['token'];
  if (!strNoEmpty(token)) throw 'Qiniu token is empty';
  String prefix = qiniuInfo['prefix'];
  if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';
  Map<String, String> images = Map();
  for (ChatStore chat in chats) {
    if (chat.mtype != MediaType.PICTURE.index + 1 &&
        chat.mtype != MediaType.VIDEO.index + 1) continue;
    if (chat.msg.startsWith(prefix)) {
      images[chat.id] =
          backFullPath ? chat.msg : chat.msg.replaceAll(prefix, '');
    } else {
      String rosultPath = chat.msg;
      if (chat.mtype == MediaType.PICTURE.index + 1) {
        File flie = File(chat.msg);
        File result = await singleCompressFile(flie);
        rosultPath = result.path;
      } else if (chat.mtype == MediaType.VIDEO.index + 1) {
        File flie = File(chat.msg);
        File result = await singleCompressVideo(flie);
        rosultPath = result.path;
      }
      UploadResult _upRs =
          await _syStorage.upload(rosultPath, token, getFileKey(rosultPath));
      if (_upRs == null || !_upRs.success) {
        throw 'Qiniu upload is error';
      }
      images[chat.id] = backFullPath ? '$prefix${_upRs.key}' : _upRs.key;
    }
  }
  return images;
}

// /// 批量上传文件并压缩, 返回一个键值对数据
// /// paths 文件原路径
// /// 返回: key是原文件路径, value是新文件路径
Future<Map<String, String>> uploadFilesCompressMap(Set<String> paths,
    {int bucket = 1, bool backFullPath = false}) async {
  if (paths == null || paths.length < 1) return Map();

  Map<String, dynamic> qiniuInfo = await qiniuToken(bucket: bucket);
  if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
  String token = qiniuInfo['token'];
  if (!strNoEmpty(token)) throw 'Qiniu token is empty';
  String prefix = qiniuInfo['prefix'];
  if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';

  Map<String, String> images = Map();
  for (String path in paths) {
    if (path.startsWith(prefix)) {
      images[path] = backFullPath ? path : path.replaceAll(prefix, '');
    } else {
      File flie = File(path);
      File result = await singleCompressFile(flie);
      UploadResult _upRs =
          await _syStorage.upload(path, token, getFileKey(result.path));
      if (_upRs == null || !_upRs.success) {
        throw 'Qiniu upload is error';
      }
      images[path] = backFullPath ? '$prefix${_upRs.key}' : _upRs.key;
    }
  }
  return images;
}

// /// 批量上传文件并压缩, 返回一个键值对数据
// /// paths 文件原路径
// /// 返回: key是原文件路径, value是新文件路径
// Future<Map<String, String>> uploadAllFilesCompressMap(List<dynamic> paths,
//     {int bucket = 1, bool backFullPath = false}) async {
//   if (paths == null || paths.length < 1) return Map();

//   Map<String, dynamic> qiniuInfo = await qiniuToken(bucket: bucket);
//   if (qiniuInfo == null || qiniuInfo.length < 1) throw 'Qiniu info is null';
//   String token = qiniuInfo['token'];
//   if (!strNoEmpty(token)) throw 'Qiniu token is empty';
//   String prefix = qiniuInfo['prefix'];
//   if (!strNoEmpty(prefix)) throw 'Qiniu prefix is empty';

//   Map<String, String> images = Map();
//   images['__prefix'] = prefix;
//   for (dynamic item in paths) {
//     if (item['path'].startsWith(prefix)) {
//       images[item['path']] =
//           backFullPath ? item['path'] : item['path'].replaceAll(prefix, '');
//     } else {
//       String rosultPath = item['path'];
//       if (item['type'] == 'img') {
//         File flie = File(item['path']);
//         File result = await singleCompressFile(flie);
//         rosultPath = result.path;
//       } else if (item['type'] == 'video') {
//         File flie = File(item['path']);
//         File result = await singleCompressVideo(flie);
//         rosultPath = result.path;
//       }
//       UploadResult _upRs =
//           await _syStorage.upload(item['path'], token, getFileKey(rosultPath));
//       if (_upRs == null || !_upRs.success) {
//         throw 'Qiniu upload is error';
//       }
//       images[item['path']] = backFullPath ? '$prefix${_upRs.key}' : _upRs.key;
//     }
//   }
//   return images;
// }
