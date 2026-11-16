import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/task_model.dart';
import '../providers/subject_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class TaskCard extends ConsumerWidget {
  final TaskModel task;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Look up subject color from provider (supports custom subjects)
    final allSubjects = ref.watch(subjectListProvider);
    final matchedSubject = allSubjects
        .where((s) => s.name == task.subject)
        .toList();
    final subjectColor = matchedSubject.isNotEmpty
        ? matchedSubject.first.color
        : SMKSubjects.getSubjectColor(task.subject);
    final subjectIcon = matchedSubject.isNotEmpty
        ? matchedSubject.first.icon
        : SMKSubjects.getSubjectIcon(task.subject);
    final priorityColor = task.priority.color;
    final deadlineFormatted = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(task.deadline);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: task.isCompleted ? 0.65 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: task.isCompleted
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9))
                : (task.priority == TaskPriority.urgent && !task.isCompleted
                    ? AppColors.priorityUrgent.withValues(alpha: 0.4)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            width: task.priority == TaskPriority.urgent && !task.isCompleted ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () {
              ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Badges (Subject & Priority) + Action Menu
                  Row(
                    children: [
                      // Subject Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: subjectColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: subjectColor.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              subjectIcon,
                              size: 13,
                              color: subjectColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              task.subject,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: subjectColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: priorityColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: priorityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              task.priority.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: priorityColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Action Popup Menu
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        onSelected: (action) {
                          if (action == 'edit') {
                            onEdit();
                          } else if (action == 'delete') {
                            _showDeleteDialog(context, ref);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Edit Tugas', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.priorityUrgent),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus Tugas',
                                  style: TextStyle(fontSize: 13, color: AppColors.priorityUrgent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Middle Row: Interactive Checkbox & Title + Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Animated Checkbox
                      GestureDetector(
                        onTap: () {
                          ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(top: 2, right: 12),
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? AppColors.primaryEmerald
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: task.isCompleted
                                  ? AppColors.primaryEmerald
                                  : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                              width: 2,
                            ),
                          ),
                          child: task.isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),

                      // Title & Description with Strike-through Animation
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                    decorationThickness: 2,
                                    color: task.isCompleted
                                        ? (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary)
                                        : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary),
                                  ),
                              child: Text(task.title),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Bottom Row: Deadline & Smart Countdown Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deadlineFormatted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const Spacer(),

                        // Countdown Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? AppColors.primaryEmerald.withValues(alpha: 0.15)
                                : (task.isOverdue
                                    ? AppColors.priorityUrgent.withValues(alpha: 0.15)
                                    : (isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE2E8F0))),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                task.isCompleted
                                    ? Icons.check_circle_outline_rounded
                                    : (task.isOverdue
                                        ? Icons.error_outline_rounded
                                        : Icons.access_time_rounded),
                                size: 11,
                                color: task.isCompleted
                                    ? AppColors.primaryEmerald
                                    : (task.isOverdue
                                        ? AppColors.priorityUrgent
                                        : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary)),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.countdownText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: task.isCompleted
                                      ? AppColors.primaryEmerald
                                      : (task.isOverdue
                                          ? AppColors.priorityUrgent
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Tugas "${task.title}" akan dihapus permanen beserta notifikasinya.'),
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
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(task.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tugas "${task.title}" berhasil dihapus'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

