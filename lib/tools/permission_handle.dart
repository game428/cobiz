import 'package:cobiz_client/tools/cobiz.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionManger {
  //通知
  static Future<bool> notificationPermission() async {
    PermissionStatus permission = await Permission.notification.request();
    return _permissionDeal(permission);
  }

  //联系人权限
  static Future<bool> contactsPermission() async {
    PermissionStatus permission = await Permission.contacts.request();
    return _permissionDeal(permission);
  }

  //相机权限
  static Future<bool> cameraPermission() async {
    PermissionStatus permission = await Permission.camera.request();
    return _permissionDeal(permission);
  }

  //相册 存储权限
  static Future<bool> photosPermission() async {
    if (Platform.isIOS) {
      PermissionStatus permission = await Permission.photos.request();
      return _permissionDeal(permission);
    } else if (Platform.isAndroid) {
      PermissionStatus permission = await Permission.storage.request();
      return _permissionDeal(permission);
    } else {
      return false;
    }
  }

  //麦克风权限
  static Future<bool> microphonePermission() async {
    PermissionStatus permission = await Permission.microphone.request();
    return _permissionDeal(permission);
  }

  static bool _permissionDeal(PermissionStatus permission) {
    if (permission == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
