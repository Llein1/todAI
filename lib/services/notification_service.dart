import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/todo_model.dart';
import '../utils/notification_templates.dart';

/// Notification Service for todAI
/// Handles all notification operations including task reminders and streak notifications
class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs
  static const int streakReminderId = 999;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navigate to specific task or screen based on payload
    // This will be implemented in Phase 5 (UI/UX)
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // Android 13+
    final android = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS
    final ios = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return android ?? ios ?? false;
  }

  /// Show immediate notification
  Future<void> showNotification(
    int id,
    String title,
    String body, {
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'todai_default',
      'Default Notifications',
      channelDescription: 'General notifications from todAI',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule notification for specific time
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate, {
    String? payload,
  }) async {
    // Don't schedule if date is in the past
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'todai_reminders',
      'Task Reminders',
      channelDescription: 'Reminders for your tasks',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Schedule task reminder (1 hour before deadline)
  Future<void> scheduleTaskReminder(TodoModel task) async {
    if (task.deadline == null || task.isDone) {
      return;
    }

    // Schedule notification 1 hour before deadline
    final reminderTime = task.deadline!.subtract(const Duration(hours: 1));

    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      final title = NotificationTemplates.taskReminderTitle(task.title);
      final body = NotificationTemplates.taskReminderBody(task.deadline!);

      await scheduleNotification(
        task.id.hashCode,
        title,
        body,
        reminderTime,
        payload: task.id,
      );
    }
  }

  /// Schedule daily streak reminder (default: 20:00)
  Future<void> scheduleDailyStreakReminder({int hour = 20}) async {
    // Cancel existing
    await cancelNotification(streakReminderId);

    // Calculate next reminder time
    final now = DateTime.now();
    var reminderTime = DateTime(now.year, now.month, now.day, hour, 0);

    // If today's time has passed, schedule for tomorrow
    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      streakReminderId,
      NotificationTemplates.streakReminderTitle,
      'Complete a task today to keep your streak alive!',
      reminderTime,
    );
  }

  /// Show streak achievement notification
  Future<void> showStreakAchievement(int streak) async {
    final title = NotificationTemplates.achievementTitle(streak);
    final body = 'You\'ve maintained a $streak day streak! Amazing! 🎉';

    await showNotification(
      streakReminderId + 1,
      title,
      body,
    );
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
