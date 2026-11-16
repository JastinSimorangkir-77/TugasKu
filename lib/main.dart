import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data format lokal Indonesia (hari & bulan)
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Format lokal error: $e');
  }

  // Inisialisasi Offline Storage (Hive & SharedPreferences)
  await StorageService.init();

  // Inisialisasi Service Notifikasi Lokal
  await NotificationService.init();

  runApp(
    const ProviderScope(
      child: TugasKuApp(),
    ),
  );
}

class TugasKuApp extends ConsumerWidget {
  const TugasKuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'TugasKu - Pengelola Tugas SMK',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
