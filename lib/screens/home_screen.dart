import 'package:flutter/material.dart';
import 'package:habit_app/data_manager.dart';
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
  Map<String, dynamic> _habits = {};
  Map<String, dynamic> _completedHabits = {};
  
  String? _quoteText;
  String? _quoteAuthor;
  bool _isLoadingQuote = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _fetchQuoteOfDay();
  }

  Future<void> _fetchQuoteOfDay() async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/today'));
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

  void _loadHabits() {
    setState(() {
      _habits = DataManager.selectedHabitsMap;
      _completedHabits = DataManager.completedHabitsMap;
    });
  }

  Color _parseColor(String hexStr) {
    if (hexStr.length == 6) {
      hexStr = "FF$hexStr";
    }
    return Color(int.parse(hexStr, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final userName = DataManager.name.isNotEmpty ? DataManager.name : 'Test User';

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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigureHabitScreen())).then((_) => _loadHabits());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: const Text('Personal Info', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen())).then((_) => _loadHabits());
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
                await DataManager.logout();
                if (mounted) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2575FC).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isLoadingQuote
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.format_quote, color: Colors.white70, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Quote of the Day',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"$_quoteText"',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '- $_quoteAuthor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
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
              _habits.isEmpty
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
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        String habitName = _habits.keys.elementAt(index);
                        String colorHex = _habits[habitName];
                        Color cardColor = _parseColor(colorHex);

                        return Dismissible(
                          key: Key(habitName),
                          direction: DismissDirection.endToStart, // Swipe right to left
                          onDismissed: (direction) async {
                            await DataManager.markHabitDone(habitName, colorHex);
                            _loadHabits();
                            if (mounted) {
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
                                  color: Colors.black.withOpacity(0.08),
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
                    
                    if (_completedHabits.isEmpty)
                      const Text(
                        'Swipe left on an activity to mark as done.',
                        style: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _completedHabits.length,
                        itemBuilder: (context, index) {
                          String habitName = _completedHabits.keys.elementAt(index);
                          String colorHex = _completedHabits[habitName];
                          Color cardColor = _parseColor(colorHex);

                          return Dismissible(
                            key: Key('done_$habitName'),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) async {
                              await DataManager.undoHabitDone(habitName, colorHex);
                              _loadHabits();
                              if (mounted) {
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
                                  color: Colors.black.withOpacity(0.05),
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
          _loadHabits();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
