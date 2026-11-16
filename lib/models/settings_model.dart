import 'package:flutter/material.dart';

class AppSettingsModel {
  final ThemeMode themeMode;
  final double soundVolume; // 0.0 - 1.0
  final bool enableSound;
  final bool enableVibration;
  final bool enableDailyReminder;
  final bool enableUrgentReminder;
  final int dailyReminderHour;
  final int dailyReminderMinute;
  final String studentName;
  final String vocationalMajor;

  const AppSettingsModel({
    this.themeMode = ThemeMode.dark,
    this.soundVolume = 0.8,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableDailyReminder = true,
    this.enableUrgentReminder = true,
    this.dailyReminderHour = 8,
    this.dailyReminderMinute = 0,
    this.studentName = 'Siswa SMK Unggul',
    this.vocationalMajor = 'Rekayasa Perangkat Lunak',
  });

  AppSettingsModel copyWith({
    ThemeMode? themeMode,
    double? soundVolume,
    bool? enableSound,
    bool? enableVibration,
    bool? enableDailyReminder,
    bool? enableUrgentReminder,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    String? studentName,
    String? vocationalMajor,
  }) {
    return AppSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      soundVolume: soundVolume ?? this.soundVolume,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableDailyReminder: enableDailyReminder ?? this.enableDailyReminder,
      enableUrgentReminder: enableUrgentReminder ?? this.enableUrgentReminder,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? this.dailyReminderMinute,
      studentName: studentName ?? this.studentName,
      vocationalMajor: vocationalMajor ?? this.vocationalMajor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'soundVolume': soundVolume,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'enableDailyReminder': enableDailyReminder,
      'enableUrgentReminder': enableUrgentReminder,
      'dailyReminderHour': dailyReminderHour,
      'dailyReminderMinute': dailyReminderMinute,
      'studentName': studentName,
      'vocationalMajor': vocationalMajor,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      themeMode: map['themeMode'] == 'light' ? ThemeMode.light : ThemeMode.dark,
      soundVolume: (map['soundVolume'] as num?)?.toDouble() ?? 0.8,
      enableSound: map['enableSound'] as bool? ?? true,
      enableVibration: map['enableVibration'] as bool? ?? true,
      enableDailyReminder: map['enableDailyReminder'] as bool? ?? true,
      enableUrgentReminder: map['enableUrgentReminder'] as bool? ?? true,
      dailyReminderHour: map['dailyReminderHour'] as int? ?? 8,
      dailyReminderMinute: map['dailyReminderMinute'] as int? ?? 0,
      studentName: map['studentName'] as String? ?? 'Siswa SMK Unggul',
      vocationalMajor: map['vocationalMajor'] as String? ?? 'Rekayasa Perangkat Lunak',
    );
  }
}
