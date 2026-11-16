import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/subject_model.dart';
import '../services/storage_service.dart';

class SubjectNotifier extends StateNotifier<List<SubjectModel>> {
  SubjectNotifier() : super([]) {
    _loadSubjects();
  }

  void _loadSubjects() {
    state = StorageService.loadSubjects();
  }

  Future<void> addCustomSubject(String name, String category) async {
    // Check for duplicates (case-insensitive)
    final exists = state.any(
      (s) => s.name.toLowerCase() == name.trim().toLowerCase() && s.category == category,
    );
    if (exists) return;

    // Choose a color index based on how many custom subjects exist
    final customCount = state.where((s) => !s.isDefault).length;

    final newSubject = SubjectModel(
      id: const Uuid().v4(),
      name: name.trim(),
      category: category,
      isDefault: false,
      colorIndex: (customCount + 4) % 12,
    );

    final updated = [...state, newSubject];
    state = updated;
    await StorageService.saveSubjects(updated);
  }

  Future<void> deleteCustomSubject(String id) async {
    final updated = state.where((s) => s.id != id || s.isDefault).toList();
    state = updated;
    await StorageService.saveSubjects(updated);
  }

  List<SubjectModel> getByCategory(String category) {
    return state.where((s) => s.category == category).toList();
  }
}

final subjectListProvider =
    StateNotifierProvider<SubjectNotifier, List<SubjectModel>>(
  (ref) => SubjectNotifier(),
);

/// Subjects for Produktif Kejuruan
final produktifSubjectsProvider = Provider<List<SubjectModel>>((ref) {
  final subjects = ref.watch(subjectListProvider);
  return subjects
      .where((s) => s.category == SubjectCategory.produktif)
      .toList();
});

/// Subjects for Mata Pelajaran Umum
final umumSubjectsProvider = Provider<List<SubjectModel>>((ref) {
  final subjects = ref.watch(subjectListProvider);
  return subjects
      .where((s) => s.category == SubjectCategory.umum)
      .toList();
});
