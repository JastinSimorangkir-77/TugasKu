import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/settings_model.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // 1. Profil Siswa SMK
          _buildSectionHeader(context, title: 'Profil Siswa SMK', icon: Icons.person_rounded),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'TK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.studentName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.vocationalMajor,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryEmerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditProfileDialog(context, ref, settings),
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.primaryEmerald,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 2. Tampilan Aplikasi (Theme Mode)
          _buildSectionHeader(context, title: 'Tampilan Aplikasi', icon: Icons.palette_rounded),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Tema Layar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeOptionCard(
                        context,
                        ref: ref,
                        title: 'Mode Gelap',
                        subtitle: 'Deep Slate (#0F172A)',
                        icon: Icons.nightlight_round,
                        isSelected: settings.themeMode == ThemeMode.dark,
                        targetMode: ThemeMode.dark,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildThemeOptionCard(
                        context,
                        ref: ref,
                        title: 'Mode Terang',
                        subtitle: 'Off-White (#F8FAFC)',
                        icon: Icons.wb_sunny_rounded,
                        isSelected: settings.themeMode == ThemeMode.light,
                        targetMode: ThemeMode.light,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 3. Suara & Notifikasi Peringatan Tugas
          _buildSectionHeader(
            context,
            title: 'Suara & Notifikasi Tugas',
            icon: Icons.volume_up_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slider Kekuatan Suara
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          settings.soundVolume == 0 || !settings.enableSound
                              ? Icons.volume_off_rounded
                              : (settings.soundVolume < 0.5
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_up_rounded),
                          size: 20,
                          color: AppColors.primaryEmerald,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Kekuatan Suara Notifikasi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(settings.soundVolume * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primaryEmerald,
                    inactiveTrackColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    thumbColor: AppColors.primaryEmerald,
                    overlayColor: AppColors.primaryEmerald.withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: settings.soundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setSoundVolume(val);
                      if (val > 0 && !settings.enableSound) {
                        ref.read(settingsProvider.notifier).toggleSound(true);
                      }
                    },
                  ),
                ),

                const Divider(height: 24),

                // Toggle Bunyi Suara
                _buildSwitchTile(
                  title: 'Bunyikan Alarm Suara',
                  subtitle: 'Mainkan nada dering saat notifikasi tugas muncul',
                  value: settings.enableSound,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleSound(val);
                  },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),

                const SizedBox(height: 12),

                // Toggle Getar
                _buildSwitchTile(
                  title: 'Getar Saat Notifikasi',
                  subtitle: 'Getarkan perangkat ketika batas deadline tiba',
                  value: settings.enableVibration,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleVibration(val);
                  },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),

                const Divider(height: 24),

                // Toggle Notifikasi Harian 24 Jam
                _buildSwitchTile(
                  title: 'Pengingat Harian (Setiap 24 Jam)',
                  subtitle: 'Kirim notifikasi rutin berkala jika tenggat masih lama',
                  value: settings.enableDailyReminder,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleDailyReminder(val);
                  },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),

                const SizedBox(height: 12),

                // Jam Pengingat Harian
                InkWell(
                  onTap: () => _pickDailyReminderTime(context, ref, settings),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: AppColors.primaryEmerald,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Jam Pengingat Harian',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${settings.dailyReminderHour.toString().padLeft(2, '0')}:${settings.dailyReminderMinute.toString().padLeft(2, '0')} WIB',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Toggle Peringatan Mendesak H-2 Jam
                _buildSwitchTile(
                  title: 'Peringatan Darurat (H-2 Jam)',
                  subtitle: 'Alarm darurat dengan prioritas tinggi sebelum pengumpulan',
                  value: settings.enableUrgentReminder,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleUrgentReminder(val);
                  },
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 4. Manajemen Data & Pemeliharaan
          _buildSectionHeader(
            context,
            title: 'Data & Pemeliharaan',
            icon: Icons.storage_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.cleaning_services_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Hapus Tugas yang Sudah Selesai',
                  subtitle: 'Bersihkan riwayat tugas yang telah selesai dikerjakan',
                  onTap: () => _showClearCompletedDialog(context, ref),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const Divider(height: 20),
                _buildActionTile(
                  icon: Icons.refresh_rounded,
                  iconColor: AppColors.priorityUrgent,
                  title: 'Reset Seluruh Data Aplikasi',
                  subtitle: 'Hapus seluruh data tugas, log aktivitas, dan pengaturan',
                  onTap: () => _showResetAllDialog(context, ref),
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // 5. Tentang Aplikasi
          Center(
            child: Column(
              children: [
                Text(
                  'TugasKu Mobile • Versi 1.2.0 (SMK Edition)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Penyimpanan Lokal Offline-First (Hive & SQLite)',
                  style: TextStyle(
                    fontSize: 10,
                    color: textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryEmerald),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionCard(
    BuildContext context, {
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required ThemeMode targetMode,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        ref.read(settingsProvider.notifier).setThemeMode(targetMode);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEmerald.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.primaryEmerald
                  : (isDark ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryEmerald
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.primaryEmerald,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDailyReminderTime(
    BuildContext context,
    WidgetRef ref,
    AppSettingsModel settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.dailyReminderHour,
        minute: settings.dailyReminderMinute,
      ),
      helpText: 'Pilih Waktu Pengingat Harian',
      cancelText: 'Batal',
      confirmText: 'Simpan',
    );

    if (picked != null) {
      ref
          .read(settingsProvider.notifier)
          .setDailyReminderTime(picked.hour, picked.minute);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Waktu pengingat harian diatur ke ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')} WIB',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    AppSettingsModel settings,
  ) {
    final nameController = TextEditingController(text: settings.studentName);
    final majorController = TextEditingController(text: settings.vocationalMajor);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit Profil Siswa SMK'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap Siswa',
                prefixIcon: Icon(Icons.badge_rounded, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: majorController,
              decoration: const InputDecoration(
                labelText: 'Program Keahlian / Jurusan',
                prefixIcon: Icon(Icons.school_rounded, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newName = nameController.text.trim();
              final newMajor = majorController.text.trim();
              if (newName.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateProfile(
                      newName,
                      newMajor.isNotEmpty ? newMajor : settings.vocationalMajor,
                    );
              }
              Navigator.pop(dialogCtx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Bersihkan Tugas Selesai?'),
        content: const Text(
          'Semua tugas yang telah Anda tandai selesai akan dihapus permanen untuk merapikan daftar tugas.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(taskListProvider.notifier).clearCompletedTasks();

              if (!dialogCtx.mounted) return;
              Navigator.pop(dialogCtx);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tugas yang selesai berhasil dibersihkan!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }

  void _showResetAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Seluruh Data?'),
        content: const Text(
          'Perhatian: Seluruh data tugas, jadwal notifikasi, dan pengaturan akan dihapus dan dikembalikan ke kondisi awal.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.priorityUrgent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await NotificationService.cancelAllNotifications();
              await StorageService.resetAllData();
              await ref.read(taskListProvider.notifier).resetAllTasks();
              ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);

              if (context.mounted) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seluruh data berhasil di-reset ke kondisi awal.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
