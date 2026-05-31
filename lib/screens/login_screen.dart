import 'package:flutter/material.dart';
import 'package:habit_app/screens/register_screen.dart';
import 'package:habit_app/screens/home_screen.dart';
import 'package:habit_app/data_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    final savedUsername = DataManager.username;
    final savedPassword = DataManager.password;

    if (savedUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account found. Please register first.')),
      );
      return;
    }

    if (username == savedUsername && password == savedPassword) {
      await DataManager.setIsLoggedIn(true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B5ED7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0), // Reduced from 40 to make fields wider
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Habitt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800, // Thicker, more premium font weight
                    color: Colors.white,
                    letterSpacing: 1.2, // Slight letter spacing for premium look
                  ),
                ),
                const SizedBox(height: 60),
                
                // Premium Username Field
                _buildPremiumTextField(
                  controller: _usernameController,
                  hint: 'manusha@gmail.com',
                  icon: Icons.email,
                ),
                const SizedBox(height: 25),
                
                // Premium Password Field
                _buildPremiumTextField(
                  controller: _passwordController,
                  hint: '........',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                
                // Forgot Password
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Premium Log In Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70.0), // Increased from 50 to keep buttons small relative to wider screen
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3), // Soft shadow for depth
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                    ),
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent, // Shadow handled by container
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16 to make button less tall
                      ),
                      child: const Text('Log In', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // OR text
                const Text(
                  'or',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 30),
                
                // Premium Sign Up Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70.0), // Increased from 50 to keep buttons small relative to wider screen
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16 to make button less tall
                    ),
                    child: const Text('Sign up', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
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
            color: Colors.black.withOpacity(0.25), // Soft, blended shadow
            blurRadius: 35,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Icon(icon, color: const Color(0xFF1877F2), size: 22),
          ),
          border: InputBorder.none, // Removes harsh edges
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0), // Reduced from 18 to make fields less tall
        ),
      ),
    );
  }
}
