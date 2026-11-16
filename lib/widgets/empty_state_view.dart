import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import 'task_form_sheet.dart';

class EmptyStateView extends ConsumerWidget {
  final String currentFilter;

  const EmptyStateView({
    super.key,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final allTasks = ref.watch(taskListProvider);
    final isDark = themeMode == ThemeMode.dark;

    final isTotalEmpty = allTasks.isEmpty;
    final isAllCompleted = allTasks.isNotEmpty &&
        allTasks.every((t) => t.isCompleted);

    String title;
    String subtitle;
    IconData icon;
    Color accentColor;

    if (isTotalEmpty) {
      title = 'Belum Ada Tugas Sekolah';
      subtitle =
          'Yuk mulai catat tugas kejuruan, laporan PKL, atau PR teori kamu di sini agar jadwalmu tertata rapi!';
      icon = Icons.edit_calendar_rounded;
      accentColor = AppColors.primaryEmerald;
    } else if (isAllCompleted && currentFilter == 'Semua') {
      title = 'Luar Biasa, Semua Selesai! 🎉';
      subtitle =
          'Kamu sudah menuntaskan seluruh tugas yang terdaftar. Istirahat sejenak atau tambahkan proyek kejuruan baru.';
      icon = Icons.verified_rounded;
      accentColor = AppColors.primaryEmerald;
    } else {
      title = 'Tidak Ada Tugas "$currentFilter"';
      subtitle =
          'Belum ada tugas yang terdaftar di kategori mata pelajaran ini. Ketuk tombol di bawah untuk membuat tugas baru.';
      icon = Icons.filter_alt_off_rounded;
      accentColor = const Color(0xFF6366F1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 34,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => TaskFormSheet.show(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(
              isTotalEmpty ? 'Tambah Tugas Pertama' : 'Buat Tugas Baru',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
