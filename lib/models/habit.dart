import 'package:flutter/material.dart';

enum Mood { great, good, neutral, bad, terrible }

class Note {
  final String id;
  final DateTime date;
  final String content;
  final Mood mood;

  Note({
    required this.id, 
    required this.date, 
    required this.content, 
    required this.mood
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String,
      mood: Mood.values.firstWhere(
        (e) => e.toString() == 'Mood.${json['mood']}',
        orElse: () => Mood.neutral,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'content': content,
      'mood': mood.toString().split('.').last,
    };
  }
}

class Habit {
  final String id;
  final String name;
  final String category;
  final DateTime startDate;
  final DateTime? lastRelapse;
  final List<Note> notes;
  final List<DateTime> relapses;
  final int goalDays;
  final int longestStreak;
  final bool active;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.startDate,
    this.lastRelapse,
    required this.notes,
    required this.relapses,
    required this.goalDays,
    required this.longestStreak,
    required this.active,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      lastRelapse: json['lastRelapse'] != null 
          ? DateTime.parse(json['lastRelapse'] as String) 
          : null,
      notes: (json['notes'] as List)
          .map((noteJson) => Note.fromJson(noteJson as Map<String, dynamic>))
          .toList(),
      relapses: (json['relapses'] as List)
          .map((date) => DateTime.parse(date as String))
          .toList(),
      goalDays: json['goalDays'] as int,
      longestStreak: json['longestStreak'] as int,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'lastRelapse': lastRelapse?.toIso8601String(),
      'notes': notes.map((note) => note.toJson()).toList(),
      'relapses': relapses.map((date) => date.toIso8601String()).toList(),
      'goalDays': goalDays,
      'longestStreak': longestStreak,
      'active': active,
    };
  }

  Habit copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? startDate,
    DateTime? lastRelapse,
    List<Note>? notes,
    List<DateTime>? relapses,
    int? goalDays,
    int? longestStreak,
    bool? active,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      lastRelapse: lastRelapse ?? this.lastRelapse,
      notes: notes ?? this.notes,
      relapses: relapses ?? this.relapses,
      goalDays: goalDays ?? this.goalDays,
      longestStreak: longestStreak ?? this.longestStreak,
      active: active ?? this.active,
    );
  }
}

class Category {
  final String id;
  final String name;
  final IconData icon;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
  });
}

final List<Category> defaultCategories = [
  const Category(id: 'smoking', name: 'Курение', icon: Icons.local_fire_department),
  const Category(id: 'alcohol', name: 'Алкоголь', icon: Icons.sports_bar),
  const Category(id: 'media', name: 'Социальные сети', icon: Icons.public),
  const Category(id: 'gaming', name: 'Видеоигры', icon: Icons.sports_esports),
  const Category(id: 'other', name: 'Другое', icon: Icons.category),
];
