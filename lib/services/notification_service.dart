import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';
import 'storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static const String _urgentChannelId = 'tugasku_urgent_channel';
  static const String _urgentChannelName = 'Peringatan Mendesak (H-2 Jam)';
  static const String _dailyChannelId = 'tugasku_daily_channel';
  static const String _dailyChannelName = 'Pengingat Harian Rutin (24 Jam Sekali)';

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _isInitialized = true;
      await requestPermissions();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  static Future<void> requestPermissions() async {
    try {
      // Android 13+ (API 33+) request
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
        await androidPlatform.requestExactAlarmsPermission();
      }

      // iOS request
      final iosPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlatform != null) {
        await iosPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Request permissions error: $e');
    }
  }

  /// Jadwal otomatis pintar berbasis preferensi Pengaturan (Settings):
  /// 1. Jika tenggat masih lama (> 24 jam) dan pengingat harian aktif, jadwalkan pengingat setiap 24 jam sekali.
  /// 2. Jika tenggat sudah dekat dan peringatan darurat aktif, buat notifikasi peringatan di H-2 jam sebelum tenggat.
  static Future<void> scheduleTaskNotifications(TaskModel task) async {
    if (task.isCompleted) {
      await cancelTaskNotifications(task);
      return;
    }

    // Bersihkan jadwal lama terlebih dahulu sebelum menjadwalkan ulang
    await cancelTaskNotifications(task);

    final now = DateTime.now();
    final remainingDuration = task.deadline.difference(now);

    // Jangan jadwalkan jika deadline sudah terlewat
    if (remainingDuration.isNegative) return;

    final settings = StorageService.loadSettings();
    final time2hBefore = task.deadline.subtract(const Duration(hours: 2));

    // -------------------------------------------------------------------------
    // 1. Peringatan Mendesak di H-2 Jam Sebelum Tenggat Pengumpulan
    // -------------------------------------------------------------------------
    if (settings.enableUrgentReminder && time2hBefore.isAfter(now)) {
      await _scheduleSingleNotification(
        id: task.notificationId2h,
        title: '⚠️ Mendesak: Deadline 2 Jam Lagi!',
        body:
            '[${task.subject}] "${task.title}" harus dikumpulkan dalam 2 jam. Pastikan tugas sudah selesai!',
        scheduledDate: time2hBefore,
        payload: task.id,
        isUrgent: true,
        enableSound: settings.enableSound,
        enableVibration: settings.enableVibration,
      );
    }

    // -------------------------------------------------------------------------
    // 2. Pengingat Rutin Harian (Setiap 24 Jam Sekali) Jika Tenggat Masih Lama
    // -------------------------------------------------------------------------
    if (settings.enableDailyReminder && remainingDuration.inHours > 24) {
      final totalDaysAhead = remainingDuration.inDays.clamp(1, 30);

      for (int dayOffset = 1; dayOffset <= totalDaysAhead; dayOffset++) {
        // Interval setiap 24 jam sekali (1 hari, 2 hari, 3 hari, dst.)
        final scheduledTime = now.add(Duration(days: dayOffset));

        // Pengingat harian hanya dikirim selama masih sebelum alarm darurat H-2 jam
        if (scheduledTime.isBefore(time2hBefore)) {
          final hoursUntilDeadline =
              task.deadline.difference(scheduledTime).inHours;
          final daysLeft = (hoursUntilDeadline / 24).ceil();

          await _scheduleSingleNotification(
            id: task.getDailyNotificationId(dayOffset),
            title: '📅 Pengingat Harian Tugas: $daysLeft Hari Lagi',
            body:
                '[${task.subject}] "${task.title}" tersisa $daysLeft hari lagi. Yuk cicil tugasmu agar tidak menumpuk!',
            scheduledDate: scheduledTime,
            payload: task.id,
            isUrgent: false,
            enableSound: settings.enableSound,
            enableVibration: settings.enableVibration,
          );
        }
      }
    }
  }

  static Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    required bool isUrgent,
    required bool enableSound,
    required bool enableVibration,
  }) async {
    try {
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        isUrgent ? _urgentChannelId : _dailyChannelId,
        isUrgent ? _urgentChannelName : _dailyChannelName,
        channelDescription: isUrgent
            ? 'Notifikasi peringatan darurat tepat 2 jam sebelum batas waktu tugas.'
            : 'Notifikasi pengingat berkala setiap 24 jam sekali untuk tugas dengan tenggat lama.',
        importance: isUrgent ? Importance.max : Importance.high,
        priority: isUrgent ? Priority.max : Priority.high,
        showWhen: true,
        playSound: enableSound,
        enableVibration: enableVibration,
        icon: '@mipmap/ic_launcher',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: enableSound,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      debugPrint(
        'Notification scheduled (${isUrgent ? 'URGENT H-2h' : 'DAILY 24h'}, Sound: $enableSound, Vib: $enableVibration) for $tzScheduled (ID: $id)',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelTaskNotifications(TaskModel task) async {
    try {
      // Batalkan notifikasi mendesak H-2 jam
      await _notificationsPlugin.cancel(task.notificationId2h);

      // Batalkan semua notifikasi pengingat harian 24 jam yang mungkin terjadwal
      for (int i = 1; i <= 30; i++) {
        await _notificationsPlugin.cancel(task.getDailyNotificationId(i));
      }
      debugPrint('Cancelled all notifications (daily & 2h) for task: ${task.id}');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancel all notifications: $e');
    }
  }
}
