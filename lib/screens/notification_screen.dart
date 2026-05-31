import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_app/data_manager.dart';
import 'package:habit_app/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _enableNotifications = true;
  Map<String, dynamic> _allHabits = {};
  Set<String> _selectedHabitsForNotification = {};
  
  final List<String> _times = ['Morning', 'Afternoon', 'Evening'];
  String _selectedTime = 'Afternoon';

  @override
  void initState() {
    super.initState();
    final selected = DataManager.selectedHabitsMap;
    final completed = DataManager.completedHabitsMap;
    _allHabits = {...selected, ...completed};
    
    _enableNotifications = DataManager.isNotificationsEnabled;
    _selectedTime = DataManager.notificationTime;
    _selectedHabitsForNotification = DataManager.notificationHabits.toSet();
  }

  Color _parseColor(String hexStr) {
    if (hexStr.length == 6) {
      hexStr = "FF$hexStr";
    }
    return Color(int.parse(hexStr, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1877F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            // Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable Notifications', style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500)),
                CupertinoSwitch(
                  value: _enableNotifications,
                  activeColor: Colors.grey.shade400, // Matching mockup (greyish toggle)
                  trackColor: Colors.grey.shade300,
                  thumbColor: Colors.grey.shade600,
                  onChanged: (val) async {
                    setState(() {
                      _enableNotifications = val;
                    });
                    if (val) {
                      await NotificationService.requestPermissions();
                    }
                  },
                ),
              ],
            ),
            const Divider(color: Colors.black12, height: 30, thickness: 1),
            
            // Select Habits
            const Text('Select Habits for Notification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allHabits.keys.map((habitName) {
                bool isSelected = _selectedHabitsForNotification.contains(habitName);
                Color habitColor = _parseColor(_allHabits[habitName]);
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedHabitsForNotification.remove(habitName);
                      } else {
                        _selectedHabitsForNotification.add(habitName);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? habitColor.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? habitColor : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(Icons.check, color: habitColor, size: 16),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          habitName,
                          style: TextStyle(
                            color: isSelected ? habitColor : Colors.black38,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 30),
            
            // Select Times
            const Text('Select Times for Notification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              children: _times.map((time) {
                bool isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEDE7F6) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF673AB7).withOpacity(0.5) : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check, color: Color(0xFF673AB7), size: 16),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          time,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF673AB7) : Colors.black38,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
                    ], // Close inner Column children
                  ), // Close inner Column
                ), // Close SingleChildScrollView
              ), // Close Expanded
              
              const SizedBox(height: 20),
              
              // Update Button securely anchored to bottom left
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: 250,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      await DataManager.setIsNotificationsEnabled(_enableNotifications);
                      await DataManager.setNotificationHabits(_selectedHabitsForNotification.toList());
                      await DataManager.setNotificationTime(_selectedTime);

                      if (_enableNotifications) {
                        await NotificationService.scheduleDailyNotifications();
                        await NotificationService.showTestNotification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Daily notifications scheduled!')),
                          );
                        }
                      } else {
                        await NotificationService.flutterLocalNotificationsPlugin.cancelAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notifications disabled.')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Update Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ], // Close outer Column children
          ), // Close outer Column
        ), // Close Padding
      ), // Close SafeArea
    ); // Close Scaffold
  }
}
