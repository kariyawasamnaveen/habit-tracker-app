import 'package:flutter/material.dart';
import 'package:habit_app/data_manager.dart';
import 'package:habit_app/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  double _age = 25;
  String _country = 'United States';
  
  final List<Map<String, String>> _prebuiltHabits = [
    {'name': 'Wake Up Early', 'color': 'FF6f42c1'},
    {'name': 'Workout', 'color': 'FFd63384'},
    {'name': 'Drink Water', 'color': 'FFfd7e14'},
    {'name': 'Meditate', 'color': 'FF82c91e'},
    {'name': 'Read a Book', 'color': 'FFffc107'},
    {'name': 'Practice Gratitude', 'color': 'FF20c997'},
    {'name': 'Sleep 8 Hours', 'color': 'FF6f42c1'},
    {'name': 'Eat Healthy', 'color': 'FF0052cc'},
  ];

  final Set<String> _selectedHabits = {};

  void _register() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a username and password')));
      return;
    }
    
    await DataManager.setName(_nameController.text.trim());
    await DataManager.setUsername(_usernameController.text.trim());
    await DataManager.setPassword(_passwordController.text.trim());
    await DataManager.setIsLoggedIn(true);
    await DataManager.setAge(_age.toInt());
    await DataManager.setCountry(_country);
    
    for (var habitName in _selectedHabits) {
      final habit = _prebuiltHabits.firstWhere((h) => h['name'] == habitName);
      await DataManager.addHabit(habitName, habit['color']!);
    }

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background to exactly match the client UI
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2188FF), 
              Color(0xFF0B5ED7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 35), // Pushed down further as requested
              // Clean minimal AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Register', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30, letterSpacing: 0.5)), // Increased font size
                centerTitle: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 15),
                      
                      _buildPremiumTextField(
                        controller: _nameController,
                        hint: 'john smith',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      
                      _buildPremiumTextField(
                        controller: _usernameController,
                        hint: '@ jsmith',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 15),
                      
                      _buildPremiumTextField(
                        controller: _passwordController,
                        hint: 'Create a password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 25),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text('Age: ${_age.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF1877F2),
                          inactiveTrackColor: Colors.white.withOpacity(0.3), // Changed to visible white track
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.2),
                          trackHeight: 3.0, // Slimmer track
                        ),
                        child: Slider(
                          value: _age,
                          min: 10,
                          max: 100,
                          onChanged: (val) {
                            setState(() {
                              _age = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Premium subtle shadow Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12), // Increased to give faded edge look
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _country,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1877F2)),
                            items: <String>['United States', 'United Kingdom', 'Canada', 'Australia', 'Sri Lanka']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _country = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 35),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text('Select Your Habits', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 12,
                        children: _prebuiltHabits.map((habit) {
                          final isSelected = _selectedHabits.contains(habit['name']);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedHabits.remove(habit['name']);
                                } else {
                                  _selectedHabits.add(habit['name']!);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1877F2) : Colors.white,
                                borderRadius: BorderRadius.circular(20), // More perfectly rounded pills
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12), // Increased to give faded edge look
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                habit['name']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF0B5ED7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12, // Smaller, elegant font
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 25), // Reduced to move button up
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0), // Narrow button
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15), // Soft faded shadow
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1877F2),
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14), // Reverted to original height
                            ),
                            child: const Text('Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12), // Increased to give faded edge look
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 18, right: 10),
            child: Icon(icon, color: const Color(0xFF1877F2), size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }
}
