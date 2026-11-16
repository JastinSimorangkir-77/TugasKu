import 'package:flutter/material.dart';

class SMKAvatarPreset {
  final int id;
  final String label;
  final IconData icon;
  final List<Color> gradient;

  const SMKAvatarPreset({
    required this.id,
    required this.label,
    required this.icon,
    required this.gradient,
  });
}

class SMKAvatars {
  static const List<SMKAvatarPreset> presets = [
    SMKAvatarPreset(
      id: 0,
      label: 'RPL / Informatika',
      icon: Icons.code_rounded,
      gradient: [Color(0xFF10B981), Color(0xFF047857)],
    ),
    SMKAvatarPreset(
      id: 1,
      label: 'TKJ / Jaringan',
      icon: Icons.lan_rounded,
      gradient: [Color(0xFF0284C7), Color(0xFF0369A1)],
    ),
    SMKAvatarPreset(
      id: 2,
      label: 'DKV / Multimedia',
      icon: Icons.palette_rounded,
      gradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    ),
    SMKAvatarPreset(
      id: 3,
      label: 'Teknik Otomotif / Mesin',
      icon: Icons.settings_suggest_rounded,
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
    SMKAvatarPreset(
      id: 4,
      label: 'Teknik Elektro / Listrik',
      icon: Icons.electric_bolt_rounded,
      gradient: [Color(0xFFEAB308), Color(0xFFCA8A04)],
    ),
    SMKAvatarPreset(
      id: 5,
      label: 'Bisnis / Manajemen',
      icon: Icons.trending_up_rounded,
      gradient: [Color(0xFF6366F1), Color(0xFF4338CA)],
    ),
    SMKAvatarPreset(
      id: 6,
      label: 'Kreatif / Broadcasting',
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFFEC4899), Color(0xFFBE185D)],
    ),
    SMKAvatarPreset(
      id: 7,
      label: 'Siswa SMK Juara',
      icon: Icons.school_rounded,
      gradient: [Color(0xFF0D9488), Color(0xFF0F766E)],
    ),
  ];

  static SMKAvatarPreset getPreset(int id) {
    if (id >= 0 && id < presets.length) {
      return presets[id];
    }
    return presets[0];
  }
}

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
  final int avatarIndex;

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
    this.avatarIndex = 0,
  });

  SMKAvatarPreset get avatar => SMKAvatars.getPreset(avatarIndex);

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
    int? avatarIndex,
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
      avatarIndex: avatarIndex ?? this.avatarIndex,
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
      'avatarIndex': avatarIndex,
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
      vocationalMajor:
          map['vocationalMajor'] as String? ?? 'Rekayasa Perangkat Lunak',
      avatarIndex: map['avatarIndex'] as int? ?? 0,
    );
  }
}
