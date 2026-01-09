import 'package:intl/intl.dart';

/// Notification message templates for todAI
class NotificationTemplates {
  // Task reminders
  static String taskReminderTitle(String taskTitle) {
    return '⏰ Reminder: $taskTitle';
  }

  static String taskReminderBody(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());

    if (diff.inMinutes < 60) {
      final minutes = diff.inMinutes;
      return 'Due in $minutes minute${minutes != 1 ? 's' : ''}!';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      return 'Due in $hours hour${hours != 1 ? 's' : ''}!';
    } else {
      return 'Due ${DateFormat('MMM dd, HH:mm').format(deadline)}';
    }
  }

  // Streak reminders
  static const String streakReminderTitle = 'Keep your streak alive! 🔥';

  static String streakReminderBody(int currentStreak) {
    if (currentStreak == 0) {
      return 'Complete a task today to start your streak!';
    } else {
      return 'Don\'t break your $currentStreak day streak! Complete a task today.';
    }
  }

  // Achievement notifications
  static String achievementTitle(int streak) {
    if (streak == 7) return '🎉 One Week Streak!';
    if (streak == 30) return '🏆 One Month Streak!';
    if (streak == 100) return '👑 100 Day Streak - Legendary!';
    if (streak >= 365) return '🌟 One Year Streak - Incredible!';
    return '🔥 $streak Day Streak!';
  }

  static String achievementBody(int streak) {
    if (streak == 7) {
      return 'Amazing! You\'ve completed tasks for 7 days straight!';
    } else if (streak == 30) {
      return 'Incredible! A full month of productivity!';
    } else if (streak == 100) {
      return 'You\'re a productivity legend! 100 days of consistency!';
    } else if (streak >= 365) {
      return 'Unbelievable! You\'ve been consistent for a whole year!';
    } else {
      return 'Keep up the great work! You\'re doing amazing!';
    }
  }

  // Task completion
  static const String taskCompletedTitle = '✅ Task Completed!';

  static String taskCompletedBody(String taskTitle) {
    return 'Great job! You completed: $taskTitle';
  }

  // Daily summary
  static const String dailySummaryTitle = '📊 Your Daily Summary';

  static String dailySummaryBody(int completed, int pending) {
    return 'Completed: $completed tasks • Pending: $pending tasks';
  }
}
