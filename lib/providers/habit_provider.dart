import 'package:flutter/foundation.dart';
import 'package:habit_app/models/habit.dart';
import 'package:habit_app/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository;

  List<Habit> _selectedHabits = [];
  List<Habit> _completedHabits = [];

  HabitProvider(this._repository) {
    loadHabits();
  }

  List<Habit> get selectedHabits => _selectedHabits;
  List<Habit> get completedHabits => _completedHabits;

  void loadHabits() {
    _selectedHabits = _repository.getSelectedHabits();
    _completedHabits = _repository.getCompletedHabits();
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _repository.addHabit(habit);
    loadHabits();
  }

  Future<void> removeHabit(String name) async {
    await _repository.removeHabit(name);
    loadHabits();
  }

  Future<void> markDone(Habit habit) async {
    await _repository.markDone(habit);
    loadHabits();
  }

  Future<void> undoDone(Habit habit) async {
    await _repository.undoDone(habit);
    loadHabits();
  }
}
