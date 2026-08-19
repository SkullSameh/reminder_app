import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import 'add_edit_reminder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final reminders = provider.filteredReminders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditReminderScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New reminder'),
      ),
      body: Column(
        children: [
          _StatusFilterBar(provider: provider),
          const SizedBox(height: 8),
          _CategoryFilterBar(provider: provider),
          const SizedBox(height: 8),
          Expanded(
            child: reminders.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: reminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return ReminderCard(
                        reminder: reminder,
                        onToggleDone: () => provider.toggleDone(reminder.id),
                        onDelete: () => provider.deleteReminder(reminder.id),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditReminderScreen(existing: reminder),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  final ReminderProvider provider;
  const _StatusFilterBar({required this.provider});

  String _label(ReminderFilter f) {
    switch (f) {
      case ReminderFilter.all:
        return 'All';
      case ReminderFilter.active:
        return 'Active';
      case ReminderFilter.done:
        return 'Done';
      case ReminderFilter.overdue:
        return 'Overdue';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ReminderFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = ReminderFilter.values[index];
          final selected = provider.statusFilter == filter;
          final count = provider.countFor(filter);
          return FilterChip(
            selected: selected,
            onSelected: (_) => provider.setStatusFilter(filter),
            label: Text('${_label(filter)} ($count)'),
          );
        },
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final ReminderProvider provider;
  const _CategoryFilterBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryChip(
            label: 'All categories',
            icon: Icons.apps_rounded,
            color: Theme.of(context).colorScheme.primary,
            selected: provider.categoryFilter == null,
            onTap: () => provider.setCategoryFilter(null),
          ),
          const SizedBox(width: 8),
          ...ReminderCategory.values.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: c.label,
                  icon: c.icon,
                  color: c.color,
                  selected: provider.categoryFilter == c,
                  onTap: () => provider.setCategoryFilter(c),
                ),
              )),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 56, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          Text(
            'No reminders here',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
