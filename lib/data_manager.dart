import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  // --- Auth Data (Only kept for password validation/storage as requested) ---
  static String get username => prefs.getString('username') ?? '';
  static String get password => prefs.getString('password') ?? '';
  static Future<void> setPassword(String val) async {
    final bytes = utf8.encode(val);
    final hash = sha256.convert(bytes).toString();
    await prefs.setString('password', hash);
  }

  // --- Notification Data ---
  static bool get isNotificationsEnabled => prefs.getBool('isNotificationsEnabled') ?? false;
  static Future<void> setIsNotificationsEnabled(bool val) => prefs.setBool('isNotificationsEnabled', val);

  static List<String> get notificationHabits => prefs.getStringList('notificationHabits') ?? [];
  static Future<void> setNotificationHabits(List<String> val) => prefs.setStringList('notificationHabits', val);

  static String get notificationTime => prefs.getString('notificationTime') ?? 'Morning';
  static Future<void> setNotificationTime(String val) => prefs.setString('notificationTime', val);
}
