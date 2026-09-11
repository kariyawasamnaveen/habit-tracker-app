import 'package:flutter/material.dart';
import 'package:habit_app/utils/color_utils.dart';
import 'package:habit_app/utils/constants.dart';
import 'package:habit_app/widgets/quote_card.dart';
import 'package:provider/provider.dart';
import 'package:habit_app/providers/habit_provider.dart';
import 'package:habit_app/providers/user_provider.dart';
import 'package:habit_app/screens/configure_habit_screen.dart';
import 'package:habit_app/screens/login_screen.dart';
import 'package:habit_app/screens/personal_info_screen.dart';
import 'package:habit_app/screens/report_screen.dart';
import 'package:habit_app/screens/notification_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _quoteText;
  String? _quoteAuthor;
  bool _isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    _fetchQuoteOfDay();
  }

  Future<void> _fetchQuoteOfDay() async {
    try {
      final response = await http.get(Uri.parse(Constants.zenQuotesApiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _quoteText = data[0]['q'];
            _quoteAuthor = data[0]['a'];
            _isLoadingQuote = false;
          });
        }
      } else {
        setState(() {
          _quoteText = "Believe you can and you're halfway there.";
          _quoteAuthor = "Theodore Roosevelt";
          _isLoadingQuote = false;
        });
      }
    } catch (e) {
      setState(() {
        _quoteText = "Success is not final, failure is not fatal: it is the courage to continue that counts.";
        _quoteAuthor = "Winston Churchill";
        _isLoadingQuote = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final habitProvider = Provider.of<HabitProvider>(context);

    final Map<String, dynamic> habitsMap = {
      for (var h in habitProvider.selectedHabits) h.name: h.colorHex
    };
    final Map<String, dynamic> completedHabitsMap = {
      for (var h in habitProvider.completedHabits) h.name: h.colorHex
    };

    final userName = userProvider.profile.name.isNotEmpty ? userProvider.profile.name : 'Test User';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1877F2)),
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black87),
              title: const Text('Configure', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigureHabitScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: const Text('Personal Info', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.black87),
              title: const Text('Reports', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.black87),
              title: const Text('Notifications', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black87),
              title: const Text('Sign Out', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              onTap: () async {
                await userProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              // --- Quote of the Day Section ---
              QuoteCard(
                isLoading: _isLoadingQuote,
                quoteText: _quoteText,
                quoteAuthor: _quoteAuthor,
              ),
              const SizedBox(height: 15),

              // "To Do 📝" Title
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'To Do ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    '📝',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Habit List
              habitsMap.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Use the + button to create some habits!',
                        style: TextStyle(color: Colors.black38, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: habitsMap.length,
                      itemBuilder: (context, index) {
                        String habitName = habitsMap.keys.elementAt(index);
                        String colorHex = habitsMap[habitName];
                        Color cardColor = ColorUtils.parseColor(colorHex);

                        return Dismissible(
                          key: Key(habitName),
                          direction: DismissDirection.endToStart, // Swipe right to left
                          onDismissed: (direction) async {
                            final targetHabit = habitProvider.selectedHabits.firstWhere((h) => h.name == habitName);
                            await habitProvider.markDone(targetHabit);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$habitName marked as done!')),
                              );
                            }
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50), // Green swipe background
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Swipe to Complete',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.check, color: Colors.white),
                              ],
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 25),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              habitName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              
              // Bottom Area (Done section)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 120), // Increased top margin significantly to push it down
                padding: const EdgeInsets.only(top: 15, bottom: 25),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black12, width: 1.5)),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Done ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Icon(Icons.check_box, color: Colors.black87, size: 20),
                        SizedBox(width: 4),
                        Text('🎉', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    if (completedHabitsMap.isEmpty)
                      const Text(
                        'Swipe left on an activity to mark as done.',
                        style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: completedHabitsMap.length,
                        itemBuilder: (context, index) {
                          String habitName = completedHabitsMap.keys.elementAt(index);
                          String colorHex = completedHabitsMap[habitName];
                          Color cardColor = ColorUtils.parseColor(colorHex);

                          return Dismissible(
                            key: Key('done_$habitName'),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) async {
                              final targetHabit = habitProvider.completedHabits.firstWhere((h) => h.name == habitName);
                              await habitProvider.undoDone(targetHabit);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$habitName marked as To Do!')),
                                );
                              }
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF44336), // Red color
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.undo, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Swipe to Undo',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 25),
                              decoration: BoxDecoration(
                                color: cardColor, 
                                borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    habitName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF4CAF50), // Green check circle
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80), // Spacing for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1877F2),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConfigureHabitScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
