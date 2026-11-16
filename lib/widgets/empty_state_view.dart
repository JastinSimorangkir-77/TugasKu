import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
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
    final isDark = themeMode == ThemeMode.dark;

    final isAllCategory = currentFilter == 'Semua';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              size: 38,
              color: AppColors.primaryEmerald,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAllCategory
                ? 'Semua Tugas Selesai! 🎉'
                : 'Tidak Ada Tugas "$currentFilter"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isAllCategory
                ? 'Hebat! Kamu telah menuntaskan seluruh tugas sekolahmu. Istirahat sejenak atau tambahkan tugas proyek baru.'
                : 'Belum ada tugas yang terdaftar untuk mata pelajaran ini. Ketuk tombol di bawah untuk membuat tugas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => TaskFormSheet.show(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Buat Tugas Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

