import 'package:flutter/material.dart';

enum ActivityType {
  created,
  completed,
  uncompleted,
  updated,
  deleted,
  session,
}

class UserActivity {
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  const UserActivity({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.created:
        return Icons.add_task_rounded;
      case ActivityType.completed:
        return Icons.check_circle_outline_rounded;
      case ActivityType.uncompleted:
        return Icons.replay_rounded;
      case ActivityType.updated:
        return Icons.edit_note_rounded;
      case ActivityType.deleted:
        return Icons.delete_outline_rounded;
      case ActivityType.session:
        return Icons.access_time_rounded;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.created:
        return const Color(0xFF6366F1);
      case ActivityType.completed:
        return const Color(0xFF10B981);
      case ActivityType.uncompleted:
        return const Color(0xFFF59E0B);
      case ActivityType.updated:
        return const Color(0xFF0284C7);
      case ActivityType.deleted:
        return const Color(0xFFEF4444);
      case ActivityType.session:
        return const Color(0xFF10B981);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  factory UserActivity.fromMap(Map<String, dynamic> map) {
    return UserActivity(
      title: map['title'] as String? ?? 'Aktivitas',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      type: ActivityType.values.firstWhere(
        (t) => t.name == (map['type'] as String? ?? 'session'),
        orElse: () => ActivityType.session,
      ),
    );
  }
}
