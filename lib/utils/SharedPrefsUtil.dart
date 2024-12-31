import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsUtil {
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      return json.decode(userData);
    }
    return {};
  }

  static Future<Map<String, dynamic>> getAllData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    Map<String, dynamic> allData = {};
    for (String key in keys) {
      allData[key] = prefs.get(key);
    }
    return allData;
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}