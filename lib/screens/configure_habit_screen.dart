import 'package:flutter/material.dart';
import 'package:habit_app/data_manager.dart';

class ConfigureHabitScreen extends StatefulWidget {
  const ConfigureHabitScreen({super.key});

  @override
  State<ConfigureHabitScreen> createState() => _ConfigureHabitScreenState();
}

class _ConfigureHabitScreenState extends State<ConfigureHabitScreen> {
  final _nameController = TextEditingController();
  
  // Color predefined options matching the screenshot exactly
  final Map<String, String> _colorOptions = {
    'Amber': 'FFffc107',
    'Red Accent': 'FFff5252',
    'Light Blue': 'FF03a9f4',
    'Light Green': 'FF8bc34a',
    'Purple Accent': 'FFe040fb',
    'Orange': 'FFff9800',
    'Teal': 'FF009688',
    'Deep Purple': 'FF673ab7',
  };
  
  String _selectedColorName = 'Amber';
  Map<String, dynamic> _habits = {};

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    setState(() {
      _habits = DataManager.selectedHabitsMap;
    });
  }

  Color _parseColor(String hexStr) {
    if (hexStr.length == 6) {
      hexStr = "FF$hexStr";
    }
    return Color(int.parse(hexStr, radix: 16));
  }

  void _addHabit() async {
    if (_nameController.text.isNotEmpty) {
      await DataManager.addHabit(
        _nameController.text, 
        _colorOptions[_selectedColorName]!
      );
      _nameController.clear(); // Clear field after adding
      _loadHabits(); // Refresh list
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
    }
  }

  void _deleteHabit(String habitName) async {
    await DataManager.removeHabit(habitName);
    _loadHabits(); // Refresh list after deleting
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
        title: const Text('Configure Habits', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Habit Name Field matching the screenshot
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Habit Name',
                labelStyle: const TextStyle(color: Colors.black54),
                hintText: 'Run 5k',
                hintStyle: const TextStyle(color: Colors.black38),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
              ),
            ),
            const SizedBox(height: 25),
            
            // Color Selector
            const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 10),
            
            // Dropdown matching closed state in new screenshot
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black12), // Grey border
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedColorName,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  menuMaxHeight: 400,
                  items: _colorOptions.keys.map((String colorName) {
                    return DropdownMenuItem<String>(
                      value: colorName,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _parseColor(_colorOptions[colorName]!),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            colorName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedColorName = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Add Habit Button
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _addHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                ),
                child: const Text('Add Habit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // List of existing habits
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habitName = _habits.keys.elementAt(index);
                final colorHex = _habits[habitName];
                final color = _parseColor(colorHex);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    children: [
                      // Large colored circle
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // Habit Name
                      Expanded(
                        child: Text(
                          habitName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // Delete Icon
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 28),
                        onPressed: () => _deleteHabit(habitName),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
