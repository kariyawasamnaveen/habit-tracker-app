import 'package:flutter/foundation.dart';
import 'package:habit_app/models/user_profile.dart';
import 'package:habit_app/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository;

  late UserProfile _profile;
  bool _isLoggedIn = false;

  UserProvider(this._repository) {
    loadUser();
  }

  UserProfile get profile => _profile;
  bool get isLoggedIn => _isLoggedIn;

  void loadUser() {
    _profile = _repository.getProfile();
    _isLoggedIn = _repository.isLoggedIn();
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    loadUser();
  }

  Future<void> login() async {
    await _repository.setLoggedIn(true);
    loadUser();
  }

  Future<void> logout() async {
    await _repository.logout();
    loadUser();
  }
}
