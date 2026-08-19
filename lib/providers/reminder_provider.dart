import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';

enum ReminderFilter { all, active, done, overdue }

class ReminderProvider extends ChangeNotifier {
  static const _storageKey = 'reminders_v1';
  final _uuid = const Uuid();

  final List<Reminder> _reminders = [];
  ReminderFilter _statusFilter = ReminderFilter.all;
  ReminderCategory? _categoryFilter;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  ReminderFilter get statusFilter => _statusFilter;
  ReminderCategory? get categoryFilter => _categoryFilter;

  List<Reminder> get filteredReminders {
    var list = _reminders.where((r) {
      if (_categoryFilter != null && r.category != _categoryFilter) {
        return false;
      }
      switch (_statusFilter) {
        case ReminderFilter.all:
          return true;
        case ReminderFilter.active:
          return !r.isDone;
        case ReminderFilter.done:
          return r.isDone;
        case ReminderFilter.overdue:
          return r.isOverdue;
      }
    }).toList();

    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return a.dateTime.compareTo(b.dateTime);
    });
    return list;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _reminders.clear();
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _reminders.addAll(
        decoded.map((e) => Reminder.fromJson(e as Map<String, dynamic>)),
      );
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> addReminder({
    required String title,
    required String description,
    required ReminderCategory category,
    required DateTime dateTime,
  }) async {
    _reminders.add(Reminder(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      dateTime: dateTime,
    ));
    notifyListeners();
    await _save();
  }

  Future<void> updateReminder(Reminder updated) async {
    final index = _reminders.indexWhere((r) => r.id == updated.id);
    if (index == -1) return;
    _reminders[index] = updated;
    notifyListeners();
    await _save();
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> toggleDone(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _reminders[index] = _reminders[index].copyWith(
      isDone: !_reminders[index].isDone,
    );
    notifyListeners();
    await _save();
  }

  void setStatusFilter(ReminderFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(ReminderCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  int countFor(ReminderFilter filter) {
    switch (filter) {
      case ReminderFilter.all:
        return _reminders.length;
      case ReminderFilter.active:
        return _reminders.where((r) => !r.isDone).length;
      case ReminderFilter.done:
        return _reminders.where((r) => r.isDone).length;
      case ReminderFilter.overdue:
        return _reminders.where((r) => r.isOverdue).length;
    }
  }
}
