import 'package:flutter/material.dart';

enum ReminderCategory { medicine, work, exam, other }

extension ReminderCategoryX on ReminderCategory {
  String get label {
    switch (this) {
      case ReminderCategory.medicine:
        return 'Medicine';
      case ReminderCategory.work:
        return 'Work';
      case ReminderCategory.exam:
        return 'Exam';
      case ReminderCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ReminderCategory.medicine:
        return Icons.medication_rounded;
      case ReminderCategory.work:
        return Icons.work_rounded;
      case ReminderCategory.exam:
        return Icons.school_rounded;
      case ReminderCategory.other:
        return Icons.notifications_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReminderCategory.medicine:
        return const Color(0xFFE85D75);
      case ReminderCategory.work:
        return const Color(0xFF4C7DF0);
      case ReminderCategory.exam:
        return const Color(0xFF9B6BF2);
      case ReminderCategory.other:
        return const Color(0xFFF2A93B);
    }
  }
}

class Reminder {
  final String id;
  String title;
  String description;
  ReminderCategory category;
  DateTime dateTime;
  bool isDone;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateTime,
    this.isDone = false,
  });

  bool get isOverdue => !isDone && dateTime.isBefore(DateTime.now());

  Reminder copyWith({
    String? title,
    String? description,
    ReminderCategory? category,
    DateTime? dateTime,
    bool? isDone,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'dateTime': dateTime.toIso8601String(),
        'isDone': isDone,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: ReminderCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ReminderCategory.other,
        ),
        dateTime: DateTime.parse(json['dateTime'] as String),
        isDone: json['isDone'] as bool? ?? false,
      );
}
