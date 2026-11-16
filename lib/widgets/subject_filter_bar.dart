import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../models/subject_model.dart';
import '../providers/filter_provider.dart';
import '../providers/subject_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class SubjectFilterBar extends ConsumerWidget {
  const SubjectFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubject = ref.watch(selectedSubjectProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final produktifCount = ref.watch(produktifPendingCountProvider);
    final umumCount = ref.watch(umumPendingCountProvider);
    final allTasks = ref.watch(taskListProvider);
    final totalPending = allTasks.where((t) => !t.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Level 1: Category Chips ─────────────────────────────────────
        SizedBox(
          height: 46,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: [
              // "Semua" chip
              _CategoryChip(
                label: 'Semua',
                badgeCount: totalPending,
                isSelected: selectedCategory == 'Semua',
                accentColor: AppColors.primaryEmerald,
                isDark: isDark,
                icon: Icons.apps_rounded,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = 'Semua';
                  ref.read(selectedSubjectProvider.notifier).state = null;
                },
              ),
              const SizedBox(width: 10),

              // "Produktif Kejuruan" chip
              _CategoryChip(
                label: 'Produktif',
                badgeCount: produktifCount,
                isSelected: selectedCategory == SubjectCategory.produktif,
                accentColor: AppColors.subjectProduktif,
                isDark: isDark,
                icon: Icons.code_rounded,
                onTap: () {
                  if (selectedCategory == SubjectCategory.produktif) {
                    // Toggle off → back to Semua
                    ref.read(selectedCategoryProvider.notifier).state = 'Semua';
                    ref.read(selectedSubjectProvider.notifier).state = null;
                  } else {
                    ref.read(selectedCategoryProvider.notifier).state =
                        SubjectCategory.produktif;
                    ref.read(selectedSubjectProvider.notifier).state = null;
                  }
                },
              ),
              const SizedBox(width: 10),

              // "Mata Pelajaran Umum" chip
              _CategoryChip(
                label: 'Umum',
                badgeCount: umumCount,
                isSelected: selectedCategory == SubjectCategory.umum,
                accentColor: const Color(0xFF8B5CF6),
                isDark: isDark,
                icon: Icons.school_rounded,
                onTap: () {
                  if (selectedCategory == SubjectCategory.umum) {
                    ref.read(selectedCategoryProvider.notifier).state = 'Semua';
                    ref.read(selectedSubjectProvider.notifier).state = null;
                  } else {
                    ref.read(selectedCategoryProvider.notifier).state =
                        SubjectCategory.umum;
                    ref.read(selectedSubjectProvider.notifier).state = null;
                  }
                },
              ),
            ],
          ),
        ),

        // ─── Level 2: Sub-subject chips (animated) ───────────────────────
        if (selectedCategory != 'Semua')
          _SubjectChipRow(
            category: selectedCategory,
            selectedSubject: selectedSubject,
            isDark: isDark,
            ref: ref,
          )
              .animate()
              .fadeIn(duration: 220.ms, curve: Curves.easeOut)
              .slideY(begin: -0.15, end: 0, duration: 220.ms, curve: Curves.easeOut),
      ],
    );
  }
}

// ─── Level 1 Category Chip ────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final int badgeCount;
  final bool isSelected;
  final Color accentColor;
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.badgeCount,
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? accentColor.withValues(alpha: 0.2)
                  : accentColor)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (isDark ? accentColor : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.white)
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 7),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? accentColor.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.28))
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? (isDark ? accentColor : Colors.white)
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Level 2 Subject Sub-chips Row ───────────────────────────────────────────

class _SubjectChipRow extends ConsumerWidget {
  final String category;
  final String? selectedSubject;
  final bool isDark;
  final WidgetRef ref;

  const _SubjectChipRow({
    required this.category,
    required this.selectedSubject,
    required this.isDark,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    final subjects = category == SubjectCategory.produktif
        ? watchRef.watch(produktifSubjectsProvider)
        : watchRef.watch(umumSubjectsProvider);

    final allTasks = watchRef.watch(taskListProvider);

    if (subjects.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final subject = subjects[i];
            final isSelected = selectedSubject == subject.name;

            // Count pending tasks for this subject
            final pendingCount = allTasks
                .where((t) => !t.isCompleted && t.subject == subject.name)
                .length;

            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  ref.read(selectedSubjectProvider.notifier).state = null;
                } else {
                  ref.read(selectedSubjectProvider.notifier).state = subject.name;
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? subject.color.withValues(alpha: isDark ? 0.22 : 0.12)
                      : (isDark
                          ? AppColors.darkSurfaceElevated
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? subject.color
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: isSelected ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: subject.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? subject.color
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    ),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: subject.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: subject.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
