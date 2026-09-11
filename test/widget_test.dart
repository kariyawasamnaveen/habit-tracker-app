import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/data_manager.dart';
import 'package:habit_app/main.dart';
import 'package:habit_app/repositories/habit_repository.dart';
import 'package:habit_app/repositories/user_repository.dart';
import 'package:habit_app/providers/habit_provider.dart';
import 'package:habit_app/providers/user_provider.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await DataManager.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => HabitProvider(HabitRepository(prefs)),
          ),
          ChangeNotifierProvider(
            create: (_) => UserProvider(UserRepository(prefs)),
          ),
        ],
        child: const HabittApp(),
      ),
    );

    // Verify app renders something (like the login screen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
