import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataManager {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  // --- Profile Data ---
  static String get name => prefs.getString('name') ?? '';
  static Future<void> setName(String val) => prefs.setString('name', val);

  static String get username => prefs.getString('username') ?? '';
  static Future<void> setUsername(String val) => prefs.setString('username', val);

  static String get password => prefs.getString('password') ?? '';
  static Future<void> setPassword(String val) => prefs.setString('password', val);

  static bool get isLoggedIn => prefs.getBool('isLoggedIn') ?? false;
  static Future<void> setIsLoggedIn(bool val) => prefs.setBool('isLoggedIn', val);

  static Future<void> logout() async {
    await setIsLoggedIn(false);
  }

  static int get age => prefs.getInt('age') ?? 18;
  static Future<void> setAge(int val) => prefs.setInt('age', val);

  static String get country => prefs.getString('country') ?? 'United States';
  static Future<void> setCountry(String val) => prefs.setString('country', val);

  // --- Habit Data ---
  static Map<String, dynamic> get selectedHabitsMap {
    final str = prefs.getString('selectedHabitsMap');
    if (str == null) return {};
    return jsonDecode(str);
  }

  static Future<void> addHabit(String name, String colorHex) async {
    final habits = selectedHabitsMap;
    habits[name] = colorHex;
    await prefs.setString('selectedHabitsMap', jsonEncode(habits));
  }

  static Future<void> removeHabit(String name) async {
    final habits = selectedHabitsMap;
    habits.remove(name);
    await prefs.setString('selectedHabitsMap', jsonEncode(habits));
  }

  static Map<String, dynamic> get completedHabitsMap {
    final str = prefs.getString('completedHabitsMap');
    if (str == null) return {};
    return jsonDecode(str);
  }

  static Future<void> markHabitDone(String name, String colorHex) async {
    final done = completedHabitsMap;
    done[name] = colorHex;
    await prefs.setString('completedHabitsMap', jsonEncode(done));
    
    // Remove from selected (To Do) list
    await removeHabit(name);
  }

  static Future<void> undoHabitDone(String name, String colorHex) async {
    final done = completedHabitsMap;
    done.remove(name);
    await prefs.setString('completedHabitsMap', jsonEncode(done));
    
    // Add back to selected (To Do) list
    await addHabit(name, colorHex);
  }

  // --- Notification Data ---
  static bool get isNotificationsEnabled => prefs.getBool('isNotificationsEnabled') ?? false;
  static Future<void> setIsNotificationsEnabled(bool val) => prefs.setBool('isNotificationsEnabled', val);

  static List<String> get notificationHabits => prefs.getStringList('notificationHabits') ?? [];
  static Future<void> setNotificationHabits(List<String> val) => prefs.setStringList('notificationHabits', val);

  static String get notificationTime => prefs.getString('notificationTime') ?? 'Morning';
  static Future<void> setNotificationTime(String val) => prefs.setString('notificationTime', val);
}
