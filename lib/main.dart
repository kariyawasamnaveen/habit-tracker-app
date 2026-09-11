import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/data_manager.dart'; // Temporarily keep for old dependencies
import 'package:habit_app/screens/login_screen.dart';
import 'package:habit_app/screens/home_screen.dart';
import 'package:habit_app/services/notification_service.dart';

import 'package:habit_app/repositories/habit_repository.dart';
import 'package:habit_app/repositories/user_repository.dart';
import 'package:habit_app/providers/habit_provider.dart';
import 'package:habit_app/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Keep DataManager.init() for now until all screens are updated
  await DataManager.init(); 
  await NotificationService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HabitProvider(HabitRepository(prefs)),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(UserRepository(prefs)),
        ),
      ],
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const HabittApp(),
      ),
    ),
  );
}

class HabittApp extends StatelessWidget {
  const HabittApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Habitt Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0052cc),
      ),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return userProvider.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
