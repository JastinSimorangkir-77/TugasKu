import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../providers/activity_provider.dart';
import '../providers/theme_provider.dart';

class LastActivityCard extends ConsumerWidget {
  const LastActivityCard({super.key});

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return 'Hari ini, ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 2) {
      return 'Kemarin, ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastActivity = ref.watch(lastActivityProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final hasActivity = lastActivity != null;
    final activityColor = hasActivity
        ? lastActivity.color
        : AppColors.primaryEmerald;
    final activityIcon = hasActivity
        ? lastActivity.icon
        : Icons.history_rounded;
    final activityTitle = hasActivity
        ? lastActivity.title
        : 'Sesi Aplikasi Aktif';
    final activityDesc = hasActivity
        ? lastActivity.description
        : 'Data tersimpan otomatis. Tambahkan tugas pertamamu untuk mulai mencatat progres!';
    final activityTime = hasActivity
        ? _formatRelativeTime(lastActivity.timestamp)
        : 'Baru saja dibuka';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activityColor.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              activityIcon,
              size: 20,
              color: activityColor,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktivitas Terakhir',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      activityTime,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: activityColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  activityTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activityDesc,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
