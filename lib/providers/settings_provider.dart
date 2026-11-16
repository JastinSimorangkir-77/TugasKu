import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../services/storage_service.dart';
import 'theme_provider.dart';

class SettingsNotifier extends StateNotifier<AppSettingsModel> {
  final Ref ref;

  SettingsNotifier(this.ref) : super(StorageService.loadSettings());

  void updateSettings(AppSettingsModel newSettings) {
    state = newSettings;
    StorageService.saveSettings(newSettings);
    // Sinkronkan themeProvider
    ref.read(themeProvider.notifier).setTheme(newSettings.themeMode);
  }

  void setThemeMode(ThemeMode mode) {
    final updated = state.copyWith(themeMode: mode);
    state = updated;
    StorageService.saveSettings(updated);
    ref.read(themeProvider.notifier).setTheme(mode);
  }

  void setSoundVolume(double volume) {
    final updated = state.copyWith(soundVolume: volume);
    state = updated;
    StorageService.saveSettings(updated);
  }

  void toggleSound(bool enabled) {
    final updated = state.copyWith(enableSound: enabled);
    state = updated;
    StorageService.saveSettings(updated);
  }

  void toggleVibration(bool enabled) {
    final updated = state.copyWith(enableVibration: enabled);
    state = updated;
    StorageService.saveSettings(updated);
  }

  void toggleDailyReminder(bool enabled) {
    final updated = state.copyWith(enableDailyReminder: enabled);
    state = updated;
    StorageService.saveSettings(updated);
  }

  void toggleUrgentReminder(bool enabled) {
    final updated = state.copyWith(enableUrgentReminder: enabled);
    state = updated;
    StorageService.saveSettings(updated);
  }

  void setDailyReminderTime(int hour, int minute) {
    final updated = state.copyWith(
      dailyReminderHour: hour,
      dailyReminderMinute: minute,
    );
    state = updated;
    StorageService.saveSettings(updated);
  }

  void updateProfile(String name, String major) {
    final updated = state.copyWith(
      studentName: name,
      vocationalMajor: major,
    );
    state = updated;
    StorageService.saveSettings(updated);
  }

  void setAvatarIndex(int index) {
    final updated = state.copyWith(avatarIndex: index);
    state = updated;
    StorageService.saveSettings(updated);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettingsModel>((ref) {
  return SettingsNotifier(ref);
});
