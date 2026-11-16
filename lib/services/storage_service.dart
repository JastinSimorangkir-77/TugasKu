import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class StorageService {
  static const String _boxName = 'tugasku_box';
  static const String _tasksKey = 'tasks_data';
  static const String _themeKey = 'app_theme_mode';

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
  }

  // Tasks Storage
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

    // Default SMK dummy tasks for first launch demo
    return _getInitialSampleTasks();
  }

  // Theme Storage
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

    if (value == 'dark') return ThemeMode.dark;
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Default to sleek Dark Theme for vocational students
  }

  static List<TaskModel> _getInitialSampleTasks() {
    final now = DateTime.now();

    return [
      TaskModel(
        id: 'task-smk-01',
        title: 'Project Akhir: CRUD API Backend & Mobile',
        description: 'Implementasi endpoint REST API dengan autentikasi JWT dan konsumsi data ke aplikasi Flutter.',
        subject: 'Produktif Kejuruan',
        deadline: now.add(const Duration(hours: 5)),
        priority: TaskPriority.urgent,
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: 'task-smk-02',
        title: 'Laporan PKL (Praktik Kerja Lapangan) Bab 2',
        description: 'Menyusun tinjauan umum perusahaan mitra dan analisis alur kerja sistem jaringan.',
        subject: 'Bahasa Indonesia',
        deadline: now.add(const Duration(days: 1, hours: 2)),
        priority: TaskPriority.urgent,
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: 'task-smk-03',
        title: 'Kuis Logika Matematika & Aljabar Boolean',
        description: 'Kerjakan 20 soal gerbang logika dan konversi bilangan biner ke heksadesimal di buku tugas.',
        subject: 'Matematika',
        deadline: now.add(const Duration(days: 2)),
        priority: TaskPriority.medium,
        isCompleted: false,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      TaskModel(
        id: 'task-smk-04',
        title: 'Presentasi Teknis: Technical Job Interview',
        description: 'Membuat slide pitch deck 5 menit dalam Bahasa Inggris mengenai portofolio proyek kejuruan.',
        subject: 'Bahasa Inggris',
        deadline: now.add(const Duration(days: 3, hours: 6)),
        priority: TaskPriority.medium,
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      TaskModel(
        id: 'task-smk-05',
        title: 'Rangkuman UUD 1945 & Norma Ketenagakerjaan',
        description: 'Ringkasan hak-hak tenaga kerja muda dan keselamatan kerja (K3) di industri.',
        subject: 'PPKN',
        deadline: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.low,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 4)),
        completedAt: now.subtract(const Duration(hours: 6)),
      ),
      TaskModel(
        id: 'task-smk-06',
        title: 'Latihan Soal Dinamika Sejarah Industri Indonesia',
        description: 'Analisis pengaruh revolusi industri 4.0 terhadap lapangan kerja modern.',
        subject: 'Sejarah & IPAS',
        deadline: now.subtract(const Duration(hours: 14)),
        priority: TaskPriority.low,
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }
}

