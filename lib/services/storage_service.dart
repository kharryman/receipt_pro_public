import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveReceipt(Map<String, dynamic> data) async {
    // Save to Hive/Isar/local storage
  }

  // To save data
  Future<void> setData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  // To read data
  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
