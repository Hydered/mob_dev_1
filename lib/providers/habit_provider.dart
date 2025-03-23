import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class HabitProvider with ChangeNotifier {
  final List<Habit> _habits;
  final SharedPreferences _prefs;

  HabitProvider(this._habits, this._prefs);

  List<Habit> get habits => _habits;

  Future<void> _saveHabits() async {
    final String encodedData = jsonEncode(_habits.map((habit) => habit.toJson()).toList());
    await _prefs.setString('habits', encodedData);
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void deleteHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    _saveHabits();
    notifyListeners();
  }

  void addNote(String habitId, Note note) {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final updatedNotes = [...habit.notes, note];
      _habits[index] = habit.copyWith(notes: updatedNotes);
      _saveHabits();
      notifyListeners();
    }
  }

  void recordRelapse(String habitId) {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final now = DateTime.now();
      final currentStreak = calculateStreak(habit);
      final newLongestStreak = currentStreak > habit.longestStreak 
          ? currentStreak 
          : habit.longestStreak;
      
      final updatedRelapses = [...habit.relapses, now];
      _habits[index] = habit.copyWith(
        lastRelapse: now,
        relapses: updatedRelapses,
        longestStreak: newLongestStreak,
      );
      
      _saveHabits();
      notifyListeners();
    }
  }

  int calculateStreak(Habit habit) {
    final lastRelapse = habit.lastRelapse;
    final startDate = habit.startDate;
    final now = DateTime.now();
    
    if (lastRelapse == null) {
      return now.difference(startDate).inDays;
    } else {
      return now.difference(lastRelapse).inDays;
    }
  }
}
