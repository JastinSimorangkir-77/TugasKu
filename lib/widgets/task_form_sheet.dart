import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../models/subject_model.dart';
import '../models/task_model.dart';
import '../providers/subject_provider.dart';
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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _customSubjectController = TextEditingController();

  late String _selectedCategory;
  String? _selectedSubjectName;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _showCustomSubjectInput = false;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final editTask = widget.taskToEdit;

    _titleController.text = editTask?.title ?? '';
    _descController.text = editTask?.description ?? '';

    _selectedCategory = editTask?.category ?? SubjectCategory.produktif;
    _selectedSubjectName = editTask?.subject;
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
    _customSubjectController.dispose();
    super.dispose();
  }

  List<SubjectModel> _currentSubjects(List<SubjectModel> all) {
    return all.where((s) => s.category == _selectedCategory).toList();
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
          picked.year, picked.month, picked.day,
          _selectedTime.hour, _selectedTime.minute,
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
          _selectedDate.year, _selectedDate.month, _selectedDate.day,
          picked.hour, picked.minute,
        );
      });
    }
  }

  Future<void> _saveCustomSubjectAndSelect() async {
    final name = _customSubjectController.text.trim();
    if (name.isEmpty) return;
    await ref
        .read(subjectListProvider.notifier)
        .addCustomSubject(name, _selectedCategory);
    setState(() {
      _selectedSubjectName = name;
      _showCustomSubjectInput = false;
      _customSubjectController.clear();
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mata pelajaran terlebih dahulu')),
      );
      return;
    }

    final finalDeadline = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (isEditing) {
      final updated = widget.taskToEdit!.copyWith(
        title: title,
        description: description,
        subject: _selectedSubjectName,
        category: _selectedCategory,
        priority: _selectedPriority,
        deadline: finalDeadline,
      );
      ref.read(taskListProvider.notifier).updateTask(updated);
    } else {
      final newTask = TaskModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        subject: _selectedSubjectName!,
        category: _selectedCategory,
        deadline: finalDeadline,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
      );
      ref.read(taskListProvider.notifier).addTask(newTask);
    }

    Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Tugas berhasil diperbarui & alarm notifikasi disinkronkan!'
                : 'Tugas baru berhasil disimpan & pengingat otomatis aktif!',
          ),
          backgroundColor: AppColors.primaryEmerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSubjects = ref.watch(subjectListProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final subjects = _currentSubjects(allSubjects);

    // If selected subject is not in new category, reset it
    final subjectNames = subjects.map((s) => s.name).toList();
    if (_selectedSubjectName != null &&
        !subjectNames.contains(_selectedSubjectName)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedSubjectName = null);
      });
    }

    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final dateFormatted = DateFormat('dd MMM yyyy', 'id').format(_selectedDate);
    final timeFormatted = _selectedTime.format(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_task_rounded,
                          color: AppColors.primaryEmerald, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Tugas' : 'Tugas Baru',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Judul Tugas
                _SectionLabel(label: 'Judul Tugas', isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: 'Contoh: Laporan Praktikum UI/UX',
                    icon: Icons.title_rounded,
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    if (v.trim().length < 3) return 'Minimal 3 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Kategori (Level 1)
                _SectionLabel(label: 'Kategori', isDark: isDark),
                const SizedBox(height: 8),
                _CategorySelector(
                  selected: _selectedCategory,
                  isDark: isDark,
                  onChanged: (cat) {
                    setState(() {
                      _selectedCategory = cat;
                      _selectedSubjectName = null;
                      _showCustomSubjectInput = false;
                      _customSubjectController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // ── Mata Pelajaran (Level 2)
                _SectionLabel(label: 'Mata Pelajaran', isDark: isDark),
                const SizedBox(height: 8),
                if (subjects.isEmpty)
                  _EmptySubjectHint(isDark: isDark)
                else
                  _SubjectGrid(
                    subjects: subjects,
                    selectedName: _selectedSubjectName,
                    isDark: isDark,
                    onSelect: (name) {
                      setState(() {
                        _selectedSubjectName = name;
                        _showCustomSubjectInput = false;
                      });
                    },
                  ),

                // ── Tambah Mapel Baru button
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showCustomSubjectInput = !_showCustomSubjectInput;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _showCustomSubjectInput
                            ? Icons.remove_circle_outline_rounded
                            : Icons.add_circle_outline_rounded,
                        size: 16,
                        color: AppColors.primaryEmerald,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showCustomSubjectInput
                            ? 'Batal tambah mapel'
                            : 'Tambah Mapel Baru',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryEmerald,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Custom subject input (expandable)
                if (_showCustomSubjectInput) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _customSubjectController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _inputDecoration(
                            hint: 'Nama mapel baru…',
                            icon: Icons.school_rounded,
                            isDark: isDark,
                            cardColor: cardColor,
                            borderColor: borderColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _saveCustomSubjectAndSelect,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryEmerald,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // ── Deskripsi
                _SectionLabel(label: 'Deskripsi (opsional)', isDark: isDark),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: 'Catatan tambahan, referensi, atau detail tugas…',
                    icon: Icons.notes_rounded,
                    isDark: isDark,
                    cardColor: cardColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Prioritas
                _SectionLabel(label: 'Prioritas', isDark: isDark),
                const SizedBox(height: 8),
                _PrioritySelector(
                  selected: _selectedPriority,
                  isDark: isDark,
                  onChanged: (p) => setState(() => _selectedPriority = p),
                ),
                const SizedBox(height: 16),

                // ── Deadline
                _SectionLabel(label: 'Batas Waktu (Deadline)', isDark: isDark),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: _DeadlineButton(
                          icon: Icons.event_rounded,
                          text: dateFormatted,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: _DeadlineButton(
                          icon: Icons.access_time_rounded,
                          text: timeFormatted,
                          isDark: isDark,
                          cardColor: cardColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Notif info box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: 16, color: AppColors.primaryEmerald),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifikasi pintar: pengingat rutin setiap 24 jam, '
                          'dan peringatan darurat H-2 jam sebelum deadline.',
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

                // ── Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryEmerald,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEditing
                              ? Icons.save_rounded
                              : Icons.add_task_rounded,
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
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    required Color borderColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark
            ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
            : AppColors.lightTextSecondary.withValues(alpha: 0.6),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, size: 18, color: AppColors.primaryEmerald),
      filled: true,
      fillColor: cardColor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primaryEmerald, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.priorityUrgent, width: 1.5),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final void Function(String) onChanged;

  const _CategorySelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CatChip(
          label: 'Produktif Kejuruan',
          icon: Icons.code_rounded,
          color: AppColors.subjectProduktif,
          isSelected: selected == SubjectCategory.produktif,
          isDark: isDark,
          onTap: () => onChanged(SubjectCategory.produktif),
        ),
        const SizedBox(width: 10),
        _CatChip(
          label: 'Mata Pelajaran Umum',
          icon: Icons.school_rounded,
          color: const Color(0xFF8B5CF6),
          isSelected: selected == SubjectCategory.umum,
          isDark: isDark,
          onTap: () => onChanged(SubjectCategory.umum),
        ),
      ],
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: isDark ? 0.2 : 0.1)
                : (isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected
                      ? color
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? color
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
  }
}

class _SubjectGrid extends StatelessWidget {
  final List<SubjectModel> subjects;
  final String? selectedName;
  final bool isDark;
  final void Function(String) onSelect;

  const _SubjectGrid({
    required this.subjects,
    required this.selectedName,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subjects.map((subject) {
        final isSelected = selectedName == subject.name;
        return GestureDetector(
          onTap: () => onSelect(subject.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Icon(subject.icon,
                    size: 14,
                    color: isSelected
                        ? subject.color
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
                const SizedBox(width: 6),
                Text(
                  subject.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? subject.color
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptySubjectHint extends StatelessWidget {
  final bool isDark;
  const _EmptySubjectHint({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
          const SizedBox(width: 8),
          Text(
            'Belum ada mapel. Tambahkan mapel baru di bawah.',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final TaskPriority selected;
  final bool isDark;
  final void Function(TaskPriority) onChanged;

  const _PrioritySelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((p) {
        final isSelected = selected == p;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: p != TaskPriority.low ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? p.color.withValues(alpha: 0.15)
                      : (isDark
                          ? AppColors.darkSurface
                          : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? p.color
                        : (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? p.color
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DeadlineButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final Color cardColor;
  final Color borderColor;

  const _DeadlineButton({
    required this.icon,
    required this.text,
    required this.isDark,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryEmerald),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
