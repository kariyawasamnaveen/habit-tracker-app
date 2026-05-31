import 'package:flutter/material.dart';
import 'package:habit_app/data_manager.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  double _age = 25;
  String _selectedCountry = 'United States';

  final List<String> _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Sri Lanka',
    'India'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = DataManager.name;
    _usernameController.text = DataManager.username;
    _age = DataManager.age.toDouble();
    if (_age < 18) _age = 25;
    _selectedCountry = DataManager.country;
    if (!_countries.contains(_selectedCountry)) {
      _selectedCountry = 'United States';
    }
  }

  void _saveChanges() async {
    await DataManager.setName(_nameController.text);
    await DataManager.setUsername(_usernameController.text);
    await DataManager.setAge(_age.toInt());
    await DataManager.setCountry(_selectedCountry);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal Info Saved!')),
      );
      Navigator.pop(context);
    }
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
        title: const Text('Personal Info', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
                hintText: 'Name',
                hintStyle: const TextStyle(color: Colors.black54),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Username Field
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.alternate_email, color: Colors.blue),
                hintText: 'Username',
                hintStyle: const TextStyle(color: Colors.black54),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black26),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Age Slider
            Text(
              'Age: ${_age.toInt()}',
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Slider(
              value: _age,
              min: 10,
              max: 100,
              activeColor: Colors.blue,
              inactiveColor: Colors.black12,
              onChanged: (value) {
                setState(() {
                  _age = value;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Country Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black26),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountry,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black38),
                  items: _countries.map((String country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country, style: const TextStyle(color: Colors.black54)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCountry = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Save Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
