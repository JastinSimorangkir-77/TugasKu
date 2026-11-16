class DayProductivity {
  final String dayName;     // 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  final int completedTasks;
  final int totalTasks;
  final DateTime date;

  const DayProductivity({
    required this.dayName,
    required this.completedTasks,
    required this.totalTasks,
    required this.date,
  });

  double get completionRate {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks).clamp(0.0, 1.0);
  }
}

