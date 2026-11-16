import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

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

  static Future<void> scheduleTaskNotifications(TaskModel task) async {
    if (task.isCompleted) {
      await cancelTaskNotifications(task);
      return;
    }

    final now = DateTime.now();

    // 1. Jadwalkan 24 Jam Sebelum Deadline
    final time24hBefore = task.deadline.subtract(const Duration(hours: 24));
    if (time24hBefore.isAfter(now)) {
      await _scheduleSingleNotification(
        id: task.notificationId24h,
        title: 'Pengingat Deadline Tugas Besok (H-1)!',
        body: '[${task.subject}] "${task.title}" tersisa 24 jam lagi. Yuk selesaikan sekarang!',
        scheduledDate: time24hBefore,
        payload: task.id,
      );
    }

    // 2. Jadwalkan 2 Jam Sebelum Deadline
    final time2hBefore = task.deadline.subtract(const Duration(hours: 2));
    if (time2hBefore.isAfter(now)) {
      await _scheduleSingleNotification(
        id: task.notificationId2h,
        title: 'Mendesak: Deadline 2 Jam Lagi!',
        body: '[${task.subject}] "${task.title}" akan segera berakhir. Pastikan tugas sudah di-submit!',
        scheduledDate: time2hBefore,
        payload: task.id,
      );
    }
  }

  static Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    try {
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'tugasku_deadline_channel',
        'Pengingat Deadline TugasKu',
        channelDescription: 'Notifikasi otomatis 24 jam & 2 jam sebelum batas pengumpulan tugas sekolah.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
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
      debugPrint('Notification scheduled for $tzScheduled (ID: $id)');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelTaskNotifications(TaskModel task) async {
    try {
      await _notificationsPlugin.cancel(task.notificationId24h);
      await _notificationsPlugin.cancel(task.notificationId2h);
      debugPrint('Cancelled notifications for task: ${task.id}');
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

