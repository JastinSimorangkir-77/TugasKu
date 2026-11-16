import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum TaskPriority {
  urgent('Mendesak', 3, AppColors.priorityUrgent),
  medium('Sedang', 2, AppColors.priorityMedium),
  low('Rendah', 1, AppColors.priorityLow);

  final String label;
  final int weight;
  final Color color;

  const TaskPriority(this.label, this.weight, this.color);

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name.toLowerCase() == value.toLowerCase() || p.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

class SMKSubjects {
  static const List<String> subjects = [
    'Produktif Kejuruan',
    'Matematika',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    'PPKN',
    'Sejarah & IPAS',
    'Pendidikan Agama',
    'Lainnya',
  ];

  static Color getSubjectColor(String subject) {
    switch (subject) {
      case 'Produktif Kejuruan':
        return AppColors.subjectProduktif;
      case 'Matematika':
        return AppColors.subjectMatematika;
      case 'Bahasa Indonesia':
        return AppColors.subjectBahasaIndonesia;
      case 'Bahasa Inggris':
        return AppColors.subjectBahasaInggris;
      case 'PPKN':
        return AppColors.subjectPkn;
      case 'Sejarah & IPAS':
        return AppColors.subjectSejarah;
      case 'Pendidikan Agama':
        return AppColors.subjectAgama;
      default:
        return AppColors.subjectLainnya;
    }
  }

  static IconData getSubjectIcon(String subject) {
    switch (subject) {
      case 'Produktif Kejuruan':
        return Icons.code_rounded;
      case 'Matematika':
        return Icons.calculate_rounded;
      case 'Bahasa Indonesia':
        return Icons.menu_book_rounded;
      case 'Bahasa Inggris':
        return Icons.language_rounded;
      case 'PPKN':
        return Icons.account_balance_rounded;
      case 'Sejarah & IPAS':
        return Icons.public_rounded;
      case 'Pendidikan Agama':
        return Icons.auto_stories_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime deadline;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.deadline,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  // Unique notification IDs based on task ID hash
  int get notificationId2h => (id.hashCode.abs() % 1000000) * 100;

  // Daily notification IDs for long deadlines (up to 30 days ahead)
  int getDailyNotificationId(int dayOffset) =>
      ((id.hashCode.abs() % 1000000) * 100) + (dayOffset % 99) + 1;

  // Countdown badge string generator
  String get countdownText {
    if (isCompleted) return 'Selesai';
    
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      final daysLate = difference.inDays.abs();
      if (daysLate == 0) {
        return 'Terlewat hari ini';
      }
      return 'Terlambat ${daysLate}h';
    }

    final days = difference.inDays;
    final hours = difference.inHours;

    if (days == 0) {
      if (hours <= 0) {
        final minutes = difference.inMinutes;
        return minutes > 0 ? '$minutes mnt lagi' : 'Batas Waktu Tiba';
      }
      return 'Hari Ini ($hours jam lagi)';
    } else if (days == 1) {
      return 'H-1 Besok';
    } else if (days == 2) {
      return 'H-2';
    } else {
      return 'H-$days';
    }
  }

  bool get isOverdue {
    if (isCompleted) return false;
    return deadline.isBefore(DateTime.now());
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    DateTime? deadline,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'deadline': deadline.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      subject: map['subject'] as String? ?? 'Produktif Kejuruan',
      deadline: DateTime.parse(map['deadline'] as String),
      priority: TaskPriority.fromString(map['priority'] as String? ?? 'medium'),
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }
}

