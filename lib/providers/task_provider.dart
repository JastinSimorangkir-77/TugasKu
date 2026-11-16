import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/weekly_productivity.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'filter_provider.dart';

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  TaskNotifier() : super([]) {
    _loadInitialTasks();
  }

  void _loadInitialTasks() {
    final tasks = StorageService.loadTasks();
    state = tasks;
    // Reschedule notifications for active upcoming tasks
    for (final task in tasks) {
      if (!task.isCompleted && task.deadline.isAfter(DateTime.now())) {
        NotificationService.scheduleTaskNotifications(task);
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    final updatedList = [task, ...state];
    state = updatedList;
    await StorageService.saveTasks(updatedList);
    await NotificationService.scheduleTaskNotifications(task);
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    // Cancel old notifications first
    final oldTask = state.firstWhere(
      (t) => t.id == updatedTask.id,
      orElse: () => updatedTask,
    );
    await NotificationService.cancelTaskNotifications(oldTask);

    final updatedList = state.map((t) {
      return t.id == updatedTask.id ? updatedTask : t;
    }).toList();

    state = updatedList;
    await StorageService.saveTasks(updatedList);

    if (!updatedTask.isCompleted && updatedTask.deadline.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskNotifications(updatedTask);
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final taskIndex = state.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final currentTask = state[taskIndex];
    final isNowCompleted = !currentTask.isCompleted;

    final updatedTask = currentTask.copyWith(
      isCompleted: isNowCompleted,
      completedAt: isNowCompleted ? DateTime.now() : null,
    );

    final updatedList = List<TaskModel>.from(state);
    updatedList[taskIndex] = updatedTask;
    state = updatedList;

    await StorageService.saveTasks(updatedList);

    if (isNowCompleted) {
      await NotificationService.cancelTaskNotifications(currentTask);
    } else {
      if (updatedTask.deadline.isAfter(DateTime.now())) {
        await NotificationService.scheduleTaskNotifications(updatedTask);
      }
    }
  }

  Future<void> deleteTask(String id) async {
    final taskToDelete = state.firstWhere(
      (t) => t.id == id,
      orElse: () => state.first,
    );
    await NotificationService.cancelTaskNotifications(taskToDelete);

    final updatedList = state.where((t) => t.id != id).toList();
    state = updatedList;
    await StorageService.saveTasks(updatedList);
  }
}

// Global Tasks Provider
final taskListProvider = StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  return TaskNotifier();
});

// Smart Sorted & Filtered Tasks Provider
final filteredSortedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final selectedSubject = ref.watch(selectedSubjectProvider);

  // 1. Filter by subject
  final subjectFiltered = selectedSubject == 'Semua'
      ? tasks
      : tasks.where((t) => t.subject == selectedSubject).toList();

  // 2. Separate pending and completed tasks
  final pending = subjectFiltered.where((t) => !t.isCompleted).toList();
  final completed = subjectFiltered.where((t) => t.isCompleted).toList();

  // 3. Smart Sorting for pending: Urgensi (Mendesak > Sedang > Rendah) + Deadline terdekat
  pending.sort((a, b) {
    final urgencyComp = b.priority.weight.compareTo(a.priority.weight);
    if (urgencyComp != 0) return urgencyComp;
    return a.deadline.compareTo(b.deadline);
  });

  // 4. Sort completed by most recently finished or deadline
  completed.sort((a, b) {
    if (a.completedAt != null && b.completedAt != null) {
      return b.completedAt!.compareTo(a.completedAt!);
    }
    return b.deadline.compareTo(a.deadline);
  });

  // Completed tasks are moved to the bottom
  return [...pending, ...completed];
});

// Live Task Statistics Provider
class TaskStatistics {
  final int total;
  final int completed;
  final int pending;
  final double completionRate;

  const TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.completionRate,
  });
}

final taskStatisticsProvider = Provider<TaskStatistics>((ref) {
  final tasks = ref.watch(taskListProvider);
  final total = tasks.length;
  final completed = tasks.where((t) => t.isCompleted).length;
  final pending = total - completed;
  final rate = total > 0 ? (completed / total) : 0.0;

  return TaskStatistics(
    total: total,
    completed: completed,
    pending: pending,
    completionRate: rate,
  );
});

// Weekly Productivity Chart Data Provider (Mon - Sun)
final weeklyProductivityProvider = Provider<List<DayProductivity>>((ref) {
  final tasks = ref.watch(taskListProvider);
  final now = DateTime.now();

  // Find Monday of the current week (weekday 1 is Monday in Dart)
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  const dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final List<DayProductivity> daysList = [];

  for (int i = 0; i < 7; i++) {
    final currentDay = monday.add(Duration(days: i));
    final nextDay = currentDay.add(const Duration(days: 1));

    // Tasks due or created for this day
    final totalForDay = tasks.where((t) {
      final d = t.deadline;
      return d.isAfter(currentDay.subtract(const Duration(seconds: 1))) &&
          d.isBefore(nextDay);
    }).length;

    // Tasks completed on this day
    final completedForDay = tasks.where((t) {
      if (!t.isCompleted) return false;
      final compDate = t.completedAt ?? t.deadline;
      return compDate.isAfter(currentDay.subtract(const Duration(seconds: 1))) &&
          compDate.isBefore(nextDay);
    }).length;

    // If total is 0 but there is completed task, normalize total
    final adjustedTotal = completedForDay > totalForDay ? completedForDay : totalForDay;

    daysList.add(DayProductivity(
      dayName: dayNames[i],
      completedTasks: completedForDay,
      totalTasks: adjustedTotal,
      date: currentDay,
    ));
  }

  return daysList;
});

