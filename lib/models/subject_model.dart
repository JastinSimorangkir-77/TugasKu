import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SubjectCategory {
  static const String produktif = 'Produktif Kejuruan';
  static const String umum = 'Mata Pelajaran Umum';

  static const List<String> all = [produktif, umum];
}

class SubjectModel {
  final String id;
  final String name;
  final String category; // SubjectCategory.produktif or SubjectCategory.umum
  final bool isDefault;
  final int colorIndex;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.category,
    this.isDefault = false,
    this.colorIndex = 0,
  });

  SubjectModel copyWith({
    String? id,
    String? name,
    String? category,
    bool? isDefault,
    int? colorIndex,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isDefault: isDefault ?? this.isDefault,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isDefault': isDefault,
      'colorIndex': colorIndex,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
      colorIndex: map['colorIndex'] as int? ?? 0,
    );
  }

  Color get color => _subjectColors[colorIndex % _subjectColors.length];

  IconData get icon => getIcon(name);

  static const List<Color> _subjectColors = [
    AppColors.subjectProduktif,
    AppColors.subjectMatematika,
    AppColors.subjectBahasaIndonesia,
    AppColors.subjectBahasaInggris,
    AppColors.subjectPkn,
    AppColors.subjectSejarah,
    AppColors.subjectAgama,
    AppColors.subjectLainnya,
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
  ];

  static IconData getIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('matematik') || lower.contains('math')) {
      return Icons.calculate_rounded;
    }
    if (lower.contains('bahasa indo')) return Icons.menu_book_rounded;
    if (lower.contains('bahasa ingg') || lower.contains('english')) {
      return Icons.language_rounded;
    }
    if (lower.contains('pkk') || lower.contains('kewirausahaan')) {
      return Icons.storefront_rounded;
    }
    if (lower.contains('sejarah') || lower.contains('ipas')) {
      return Icons.public_rounded;
    }
    if (lower.contains('agama') || lower.contains('pai')) {
      return Icons.auto_stories_rounded;
    }
    if (lower.contains('olahraga') || lower.contains('pjok')) {
      return Icons.sports_soccer_rounded;
    }
    if (lower.contains('bp') ||
        lower.contains('bk') ||
        lower.contains('bimbing')) {
      return Icons.person_rounded;
    }
    if (lower.contains('ppb') || lower.contains('pembuatan program')) {
      return Icons.terminal_rounded;
    }
    if (lower.contains('pad') || lower.contains('administrasi')) {
      return Icons.admin_panel_settings_rounded;
    }
    if (lower.contains('ui') ||
        lower.contains('ux') ||
        lower.contains('desain')) {
      return Icons.design_services_rounded;
    }
    if (lower.contains('website') || lower.contains('web')) {
      return Icons.web_rounded;
    }
    if (lower.contains('aps') ||
        lower.contains('jaringan') ||
        lower.contains('network')) {
      return Icons.router_rounded;
    }
    if (lower.contains('pkn') ||
        lower.contains('ppkn') ||
        lower.contains('kewarganegaraan')) {
      return Icons.account_balance_rounded;
    }
    if (lower.contains('produktif') || lower.contains('kejuruan')) {
      return Icons.code_rounded;
    }
    return Icons.assignment_rounded;
  }

  // ─── Default Subjects ─────────────────────────────────────────────────────

  static List<SubjectModel> get defaultSubjects => [
        ..._defaultProduktif,
        ..._defaultUmum,
      ];

  static List<SubjectModel> get _defaultProduktif => [
        const SubjectModel(
          id: 'prod_pad',
          name: 'PAD',
          category: SubjectCategory.produktif,
          isDefault: true,
          colorIndex: 0,
        ),
        const SubjectModel(
          id: 'prod_ppb',
          name: 'PPB',
          category: SubjectCategory.produktif,
          isDefault: true,
          colorIndex: 8,
        ),
        const SubjectModel(
          id: 'prod_uiux',
          name: 'UI/UX',
          category: SubjectCategory.produktif,
          isDefault: true,
          colorIndex: 9,
        ),
        const SubjectModel(
          id: 'prod_web',
          name: 'Pembuatan Website',
          category: SubjectCategory.produktif,
          isDefault: true,
          colorIndex: 10,
        ),
        const SubjectModel(
          id: 'prod_aps',
          name: 'APS',
          category: SubjectCategory.produktif,
          isDefault: true,
          colorIndex: 11,
        ),
      ];

  static List<SubjectModel> get _defaultUmum => [
        const SubjectModel(
          id: 'umum_bind',
          name: 'Bahasa Indonesia',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 2,
        ),
        const SubjectModel(
          id: 'umum_mat',
          name: 'Matematika',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 1,
        ),
        const SubjectModel(
          id: 'umum_bing',
          name: 'Bahasa Inggris',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 3,
        ),
        const SubjectModel(
          id: 'umum_sejarah',
          name: 'Sejarah',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 5,
        ),
        const SubjectModel(
          id: 'umum_pkk',
          name: 'PKK',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 11,
        ),
        const SubjectModel(
          id: 'umum_pjok',
          name: 'Olahraga',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 10,
        ),
        const SubjectModel(
          id: 'umum_bpbk',
          name: 'BP/BK',
          category: SubjectCategory.umum,
          isDefault: true,
          colorIndex: 7,
        ),
      ];
}
