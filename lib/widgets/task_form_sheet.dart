import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;

  const TaskFormSheet({
    super.key,
    this.taskToEdit,
  });

  static Future<void> show(BuildContext context, {TaskModel? taskToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormSheet(taskToEdit: taskToEdit),
    );
  }

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _selectedSubject;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final editTask = widget.taskToEdit;

    _titleController = TextEditingController(text: editTask?.title ?? '');
    _descController = TextEditingController(text: editTask?.description ?? '');
    _selectedSubject = editTask?.subject ?? SMKSubjects.subjects.first;
    _selectedPriority = editTask?.priority ?? TaskPriority.medium;

    if (editTask != null) {
      _selectedDate = editTask.deadline;
      _selectedTime = TimeOfDay.fromDateTime(editTask.deadline);
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59);
      _selectedTime = const TimeOfDay(hour: 23, minute: 59);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih Batas Waktu Tugas',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Pilih Jam Batas Waktu',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final finalDeadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: title,
        description: description,
        subject: _selectedSubject,
        priority: _selectedPriority,
        deadline: finalDeadline,
      );
      ref.read(taskListProvider.notifier).updateTask(updated);
    } else {
      final newTask = TaskModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        subject: _selectedSubject,
        deadline: finalDeadline,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
      );
      ref.read(taskListProvider.notifier).addTask(newTask);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Tugas berhasil diperbarui & alarm notifikasi disinkronkan!'
              : 'Tugas baru berhasil disimpan & pengingat otomatis aktif!',
        ),
        backgroundColor: AppColors.primaryEmeraldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final dateFormatted = DateFormat('EEE, d MMM yyyy', 'id_ID').format(_selectedDate);
    final timeFormatted = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Tugas SMK' : 'Tambah Tugas Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Input: Judul Tugas
              Text(
                'Judul Tugas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Laporan Praktikum Web API Laravel',
                  prefixIcon: Icon(Icons.title_rounded, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul tugas wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input: Mata Pelajaran SMK
              Text(
                'Mata Pelajaran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_rounded, size: 20),
                ),
                dropdownColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                items: SMKSubjects.subjects.map((subj) {
                  return DropdownMenuItem(
                    value: subj,
                    child: Row(
                      children: [
                        Icon(
                          SMKSubjects.getSubjectIcon(subj),
                          size: 16,
                          color: SMKSubjects.getSubjectColor(subj),
                        ),
                        const SizedBox(width: 10),
                        Text(subj, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSubject = val);
                },
              ),
              const SizedBox(height: 16),

              // Input: Deskripsi / Catatan Tugas
              Text(
                'Deskripsi / Catatan (Opsional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Instruksi guru, kriteria penilaian, atau catatan penting...',
                  prefixIcon: Icon(Icons.notes_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Choice Chips: Prioritas Tugas (Urgensi)
              Text(
                'Tingkat Urgensi / Prioritas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  final pColor = priority.color;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? pColor.withValues(alpha: 0.18)
                              : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? pColor : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: pColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              priority.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected
                                    ? pColor
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Deadline: Tanggal & Waktu Pickers
              Text(
                'Batas Waktu Pengumpulan (Deadline)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Date Picker Button
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_rounded, size: 18, color: AppColors.primaryEmerald),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateFormatted,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Time Picker Button
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primaryEmerald),
                            const SizedBox(width: 8),
                            Text(
                              timeFormatted,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Notification Auto-schedule reminder notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      size: 16,
                      color: AppColors.primaryEmerald,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notifikasi otomatis pintar: Pengingat rutin setiap 24 jam sekali jika tenggat masih lama, dan peringatan darurat di H-2 jam sebelum batas waktu.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryEmerald,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing ? Icons.save_rounded : Icons.add_task_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Simpan Perubahan' : 'Tambahkan Tugas',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

