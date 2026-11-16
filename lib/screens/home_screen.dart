import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/filter_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/productivity_chart.dart';
import '../widgets/stat_header.dart';
import '../widgets/subject_filter_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final tasks = ref.watch(filteredSortedTasksProvider);
    final selectedFilter = ref.watch(selectedSubjectProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.assignment_turned_in_rounded,
                color: AppColors.primaryEmerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                children: const [
                  TextSpan(text: 'Tugas'),
                  TextSpan(
                    text: 'Ku',
                    style: TextStyle(color: AppColors.primaryEmerald),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primaryEmerald,
                  size: 14,
                ),
                SizedBox(width: 5),
                Text(
                  'SMK Hebat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryEmerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryEmerald,
          onRefresh: () async {
            // Trigger refresh
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // 1. Stat Header (Profile, Theme switch, Statistics counter)
              const SliverToBoxAdapter(
                child: StatHeader(),
              ),

              // 2. Weekly Productivity Chart
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: ProductivityChart(),
                ),
              ),

              // 3. Subject Horizontal Filters
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SubjectFilterBar(),
                ),
              ),

              // 4. Section Header: Smart Sorted Task List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFilter == 'Semua'
                                ? 'Daftar Tugas Cerdas'
                                : 'Tugas $selectedFilter',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Prioritas: Mendesak > Sedang > Rendah',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          '${tasks.length} Tugas',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Dynamic Task List or Empty State
              if (tasks.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyStateView(currentFilter: selectedFilter),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onEdit: () {
                          TaskFormSheet.show(context, taskToEdit: task);
                        },
                      );
                    },
                    childCount: tasks.length,
                  ),
                ),

              // Bottom padding for FAB space
              const SliverToBoxAdapter(
                child: SizedBox(height: 90),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          TaskFormSheet.show(context);
        },
        backgroundColor: AppColors.primaryEmerald,
        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
        label: const Text(
          'Tambah Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

