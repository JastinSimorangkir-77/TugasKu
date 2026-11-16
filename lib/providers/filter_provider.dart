import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Level 1: Selected main category.
/// Values: 'Semua', 'Produktif Kejuruan', 'Mata Pelajaran Umum'
final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');

/// Level 2: Selected specific subject within a category.
/// null = show all subjects in selected category.
final selectedSubjectProvider = StateProvider<String?>((ref) => null);
