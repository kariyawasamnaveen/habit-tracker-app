import 'package:flutter/material.dart';
import 'package:habit_app/data_manager.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> _habitNames = [];

  @override
  void initState() {
    super.initState();
    // Combine all habits just for display in report
    final Map<String, dynamic> selected = DataManager.selectedHabitsMap;
    final Map<String, dynamic> completed = DataManager.completedHabitsMap;
    _habitNames = [...selected.keys, ...completed.keys];
    
    // Add dummy ones if completely empty just to show the table properly
    if (_habitNames.isEmpty) {
      _habitNames = ['Practice typing', 'Walk 100 steps', 'Meditate'];
    }
  }

  // Dummy logic to generate random check/cross based on habit name and day length
  bool _isDoneDummy(String habit, String day) {
    int hash = habit.hashCode + day.hashCode;
    return hash % 3 != 0; // Roughly 66% true for visual variety
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
        title: const Text('Weekly Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.withOpacity(0.05)),
            columnSpacing: 25,
            columns: [
              const DataColumn(label: Text('Habit', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))),
              ..._days.map((day) => DataColumn(
                label: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              )),
            ],
            rows: _habitNames.map((habitName) {
              return DataRow(
                cells: [
                  DataCell(Text(habitName, style: const TextStyle(color: Colors.black54))),
                  ..._days.map((day) {
                    bool isDone = _isDoneDummy(habitName, day);
                    return DataCell(
                      Icon(
                        isDone ? Icons.check_circle : Icons.cancel,
                        color: isDone ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
