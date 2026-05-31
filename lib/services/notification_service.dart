import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:habit_app/data_manager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> scheduleDailyNotifications() async {
    print('--- Notification Scheduling Started ---');
    await flutterLocalNotificationsPlugin.cancelAll();
    print('Canceled previous notifications.');

    if (!DataManager.isNotificationsEnabled) {
      print('Notifications are disabled. Stopping.');
      return;
    }

    final habits = DataManager.notificationHabits;
    if (habits.isEmpty) {
      print('No habits selected. Stopping.');
      return;
    }

    final timeStr = DataManager.notificationTime;
    int hour = 8;
    int minute = 0;

    if (timeStr == 'Afternoon') {
      hour = 13;
    } else if (timeStr == 'Evening') {
      hour = 20;
    }

    print('Selected Time: $timeStr ($hour:$minute)');
    print('Selected Habits: ${habits.join(", ")}');

    final scheduledDate = _nextInstanceOfTime(hour, minute);
    print('Scheduled Exact Date/Time: $scheduledDate');

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'daily_habit_channel',
      'Daily Habit Reminders',
      channelDescription: 'Daily reminders for your selected habits',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1,
      title: 'Habit Reminder',
      body: 'Time for your habits: ${habits.join(", ")}',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    print('--- Notification Successfully Scheduled! ---');
  }

  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'habit_channel_id',
      'Habit Notifications',
      channelDescription: 'Notifications for your habits',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'Habit Reminder',
      body: 'This is a test notification for your habit!',
      notificationDetails: notificationDetails,
    );
  }
}
