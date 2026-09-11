import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/models/user_profile.dart';

class UserRepository {
  final SharedPreferences _prefs;

  UserRepository(this._prefs);

  UserProfile getProfile() {
    return UserProfile(
      name: _prefs.getString('name') ?? '',
      username: _prefs.getString('username') ?? '',
      age: _prefs.getInt('age') ?? 18,
      country: _prefs.getString('country') ?? 'United States',
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString('name', profile.name);
    await _prefs.setString('username', profile.username);
    await _prefs.setInt('age', profile.age);
    await _prefs.setString('country', profile.country);
  }

  bool isLoggedIn() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('isLoggedIn', value);
  }

  Future<void> logout() async {
    await setLoggedIn(false);
  }
}
