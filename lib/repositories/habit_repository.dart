import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_app/models/habit.dart';

class HabitRepository {
  final SharedPreferences _prefs;

  HabitRepository(this._prefs);

  List<Habit> getSelectedHabits() {
    final str = _prefs.getString('selectedHabitsMap');
    if (str == null) return [];
    final Map<String, dynamic> map = jsonDecode(str);
    return map.entries.map((e) => Habit(
      name: e.key,
      colorHex: e.value,
      isCompleted: false,
    )).toList();
  }

  List<Habit> getCompletedHabits() {
    final str = _prefs.getString('completedHabitsMap');
    if (str == null) return [];
    final Map<String, dynamic> map = jsonDecode(str);
    return map.entries.map((e) => Habit(
      name: e.key,
      colorHex: e.value,
      isCompleted: true,
    )).toList();
  }

  Future<void> addHabit(Habit habit) async {
    final habits = _getRawMap('selectedHabitsMap');
    habits[habit.name] = habit.colorHex;
    await _prefs.setString('selectedHabitsMap', jsonEncode(habits));
  }

  Future<void> removeHabit(String name) async {
    final habits = _getRawMap('selectedHabitsMap');
    habits.remove(name);
    await _prefs.setString('selectedHabitsMap', jsonEncode(habits));
  }

  Future<void> markDone(Habit habit) async {
    final done = _getRawMap('completedHabitsMap');
    done[habit.name] = habit.colorHex;
    await _prefs.setString('completedHabitsMap', jsonEncode(done));
    
    // Remove from selected (To Do) list
    await removeHabit(habit.name);
  }

  Future<void> undoDone(Habit habit) async {
    final done = _getRawMap('completedHabitsMap');
    done.remove(habit.name);
    await _prefs.setString('completedHabitsMap', jsonEncode(done));
    
    // Add back to selected (To Do) list
    await addHabit(habit.copyWith(isCompleted: false));
  }

  Map<String, dynamic> _getRawMap(String key) {
    final str = _prefs.getString(key);
    if (str == null) return {};
    return jsonDecode(str);
  }
}
