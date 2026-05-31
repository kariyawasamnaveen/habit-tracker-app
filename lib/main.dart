import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:habit_app/data_manager.dart';
import 'package:habit_app/screens/login_screen.dart';
import 'package:habit_app/screens/home_screen.dart';
import 'package:habit_app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager.init(); // Initialize SharedPreferences
  await NotificationService.init();
  
  // Wrap the app with DevicePreview
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Enables preview only in debug mode
      builder: (context) => const HabittApp(),
    ),
  );
}

class HabittApp extends StatelessWidget {
  const HabittApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Essential configurations for DevicePreview to work properly
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      title: 'Habitt Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0052cc),
      ),
      home: DataManager.isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
