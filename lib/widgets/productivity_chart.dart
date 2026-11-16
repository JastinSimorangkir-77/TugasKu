import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';

class ProductivityChart extends ConsumerStatefulWidget {
  const ProductivityChart({super.key});

  @override
  ConsumerState<ProductivityChart> createState() => _ProductivityChartState();
}

class _ProductivityChartState extends ConsumerState<ProductivityChart> {
  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final productivityDays = ref.watch(weeklyProductivityProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Calculate weekly totals
    int totalWeekTasks = 0;
    int completedWeekTasks = 0;
    for (final day in productivityDays) {
      totalWeekTasks += day.totalTasks;
      completedWeekTasks += day.completedTasks;
    }
    final overallRate = totalWeekTasks > 0
        ? ((completedWeekTasks / totalWeekTasks) * 100).toInt()
        : 0;

    // Determine max Y for chart axis
    double maxY = 4;
    for (final d in productivityDays) {
      if (d.totalTasks > maxY) maxY = d.totalTasks.toDouble();
      if (d.completedTasks > maxY) maxY = d.completedTasks.toDouble();
    }
    maxY = maxY + 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title & Performance Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        size: 20,
                        color: AppColors.primaryEmerald,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Produktivitas Mingguan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Senin s/d Minggu • SMK Produktif',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      totalWeekTasks > 0
                          ? '$overallRate% Selesai'
                          : 'Mulai Minggu Ini',
                      style: const TextStyle(
                        color: AppColors.primaryEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Chart Canvas
          SizedBox(
            height: 155,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFF0F172A) : const Color(0xFF334155),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = productivityDays[groupIndex];
                      final isCompletedRod = rodIndex == 1;
                      final type = isCompletedRod ? 'Selesai' : 'Total';
                      final count = rod.toY.toInt();
                      return BarTooltipItem(
                        '${day.dayName}\n$type: $count tugas',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event, barTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        touchedGroupIndex = -1;
                        return;
                      }
                      touchedGroupIndex =
                          barTouchResponse.spot!.touchedBarGroupIndex;
                    });
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (maxY / 3).ceilToDouble().clamp(1.0, 10.0),
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= productivityDays.length) {
                          return const SizedBox.shrink();
                        }
                        final isTouched = index == touchedGroupIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            productivityDays[index].dayName,
                            style: TextStyle(
                              color: isTouched
                                  ? AppColors.primaryEmerald
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              fontWeight: isTouched ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark
                        ? const Color(0xFF334155).withValues(alpha: 0.4)
                        : const Color(0xFFE2E8F0),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                barGroups: List.generate(productivityDays.length, (index) {
                  final day = productivityDays[index];
                  final isCurrentGroupTouched = index == touchedGroupIndex;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      // Rod 1: Total Tasks
                      BarChartRodData(
                        toY: day.totalTasks.toDouble(),
                        color: isCurrentGroupTouched
                            ? (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1))
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        width: 9,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                      // Rod 2: Completed Tasks
                      BarChartRodData(
                        toY: day.completedTasks.toDouble(),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF34D399),
                            AppColors.primaryEmerald,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 9,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: AppColors.primaryEmerald,
                label: 'Tugas Selesai',
                isDark: isDark,
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                label: 'Total Tugas',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

