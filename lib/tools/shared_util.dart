export 'package:cobiz_client/config/keys.dart';
import 'package:cobiz_client/config/storage_manager.dart';

class SharedUtil {
  factory SharedUtil() => _getInstance();

  static SharedUtil get instance => _getInstance();
  static SharedUtil _instance;

  SharedUtil._internal() {
    //初始化
    //init
  }

  static SharedUtil _getInstance() {
    if (_instance == null) {
      _instance = new SharedUtil._internal();
    }
    return _instance;
  }

  bool hasKey(String key) {
    Set keys = StorageManager.sp.getKeys();
    return keys.contains(key);
  }

  /// save
  Future saveString(String key, String value) async {
    await StorageManager.sp.setString(key, value);
  }

  Future saveInt(String key, int value) async {
    await StorageManager.sp.setInt(key, value);
  }

  Future saveDouble(String key, double value) async {
    await StorageManager.sp.setDouble(key, value);
  }

  Future saveBoolean(String key, bool value) async {
    await StorageManager.sp.setBool(key, value);
  }

  Future saveStringList(String key, List<String> list) async {
    await StorageManager.sp.setStringList(key, list);
  }

  Future<bool> readAndSaveList(String key, String data) async {
    List<String> strings = StorageManager.sp.getStringList(key) ?? [];
    if (strings.length >= 10) return false;
    strings.add(data);
    await StorageManager.sp.setStringList(key, strings);
    return true;
  }

  void readAndExchangeList(String key, String data, int index) async {
    List<String> strings = StorageManager.sp.getStringList(key) ?? [];
    strings[index] = data;
    await StorageManager.sp.setStringList(key, strings);
  }

  void readAndRemoveList(String key, int index) async {
    List<String> strings = StorageManager.sp.getStringList(key) ?? [];
    strings.removeAt(index);
    await StorageManager.sp.setStringList(key, strings);
  }

  Future<bool> remove(String key) async {
    return StorageManager.sp.remove(key);
  }

  /// get
  Future<String> getString(String key) async {
    return StorageManager.sp.getString(key);
  }

  Future<int> getInt(String key) async {
    return StorageManager.sp.getInt(key);
  }

  Future<double> getDouble(String key) async {
    return StorageManager.sp.getDouble(key);
  }

  Future<bool> getBoolean(String key) async {
    return StorageManager.sp.getBool(key) ?? false;
  }

  Future<List<String>> getStringList(String key) async {
    return StorageManager.sp.getStringList(key);
  }

  Future<List<String>> readList(String key) async {
    List<String> strings = StorageManager.sp.getStringList(key) ?? [];
    return strings;
  }
}
