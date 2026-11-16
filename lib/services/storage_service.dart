import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';
import '../models/settings_model.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _boxName = 'tugasku_box';
  static const String _tasksKey = 'tasks_data';
  static const String _themeKey = 'app_theme_mode';
  static const String _lastActivityKey = 'last_user_activity';
  static const String _lastSessionKey = 'last_session_time';
  static const String _settingsKey = 'app_user_settings';

  static Box? _box;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('Hive init error: $e. Fallback to SharedPreferences.');
    }
    _prefs = await SharedPreferences.getInstance();

    // Catat waktu sesi saat aplikasi dibuka
    await recordSessionLaunch();
  }

  // --- Task Storage ---
  static Future<void> saveTasks(List<TaskModel> tasks) async {
    final listJson = tasks.map((t) => t.toMap()).toList();
    final encoded = jsonEncode(listJson);

    if (_box != null && _box!.isOpen) {
      await _box!.put(_tasksKey, encoded);
    }
    await _prefs?.setString(_tasksKey, encoded);
  }

  static List<TaskModel> loadTasks() {
    String? rawData;
    if (_box != null && _box!.isOpen) {
      rawData = _box!.get(_tasksKey) as String?;
    }
    rawData ??= _prefs?.getString(_tasksKey);

    if (rawData != null && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData) as List<dynamic>;
        return decoded
            .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item as Map)))
            .toList();
      } catch (e) {
        debugPrint('Error decoding saved tasks: $e');
      }
    }

    // Default kosong murni: tidak ada tugas sampai user sendiri yang menambahkannya
    return [];
  }

  // --- Settings Storage ---
  static Future<void> saveSettings(AppSettingsModel settings) async {
    final encoded = jsonEncode(settings.toMap());
    if (_box != null && _box!.isOpen) {
      await _box!.put(_settingsKey, encoded);
    }
    await _prefs?.setString(_settingsKey, encoded);

    // Sinkronisasi tema
    await saveThemeMode(settings.themeMode);
  }

  static AppSettingsModel loadSettings() {
    String? rawData;
    if (_box != null && _box!.isOpen) {
      rawData = _box!.get(_settingsKey) as String?;
    }
    rawData ??= _prefs?.getString(_settingsKey);

    if (rawData != null && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData) as Map<String, dynamic>;
        return AppSettingsModel.fromMap(decoded);
      } catch (e) {
        debugPrint('Error decoding settings: $e');
      }
    }

    return AppSettingsModel(themeMode: loadThemeMode());
  }

  // --- Activity Log Storage ---
  static Future<void> saveLastActivity(UserActivity activity) async {
    final encoded = jsonEncode(activity.toMap());
    if (_box != null && _box!.isOpen) {
      await _box!.put(_lastActivityKey, encoded);
    }
    await _prefs?.setString(_lastActivityKey, encoded);
  }

  static UserActivity? loadLastActivity() {
    String? rawData;
    if (_box != null && _box!.isOpen) {
      rawData = _box!.get(_lastActivityKey) as String?;
    }
    rawData ??= _prefs?.getString(_lastActivityKey);

    if (rawData != null && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData) as Map<String, dynamic>;
        return UserActivity.fromMap(decoded);
      } catch (e) {
        debugPrint('Error decoding last activity: $e');
      }
    }
    return null;
  }

  // --- Session Tracking ---
  static Future<void> recordSessionLaunch() async {
    final now = DateTime.now().toIso8601String();
    if (_box != null && _box!.isOpen) {
      await _box!.put(_lastSessionKey, now);
    }
    await _prefs?.setString(_lastSessionKey, now);
  }

  static DateTime? loadLastSession() {
    String? raw;
    if (_box != null && _box!.isOpen) {
      raw = _box!.get(_lastSessionKey) as String?;
    }
    raw ??= _prefs?.getString(_lastSessionKey);
    if (raw != null) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  // --- Theme Storage ---
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final value = mode.name;
    if (_box != null && _box!.isOpen) {
      await _box!.put(_themeKey, value);
    }
    await _prefs?.setString(_themeKey, value);
  }

  static ThemeMode loadThemeMode() {
    String? value;
    if (_box != null && _box!.isOpen) {
      value = _box!.get(_themeKey) as String?;
    }
    value ??= _prefs?.getString(_themeKey);

    if (value == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Default mode gelap profesional
  }

  // --- Data Reset & Cleanup ---
  static Future<void> resetAllData() async {
    if (_box != null && _box!.isOpen) {
      await _box!.clear();
    }
    await _prefs?.clear();
  }
}
