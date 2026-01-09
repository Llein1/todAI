import 'package:flutter/foundation.dart';
import '../models/streak_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/notification_templates.dart';

/// Streak Provider for Gamification State Management
/// Manages user activity streaks and daily check-ins
class StreakProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  // State variables
  StreakModel? _streak;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  StreakModel? get streak => _streak;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentStreak => _streak?.currentStreak ?? 0;
  int get longestStreak => _streak?.longestStreak ?? 0;
  int get totalTasksCompleted => _streak?.totalTasksCompleted ?? 0;
  bool get isActiveToday => _streak?.isActiveToday ?? false;

  /// Initialize and check streak (called on app startup)
  Future<void> initializeAndCheckStreak() async {
    await loadStreak();
    await checkAndUpdateStreak();
    
    // Schedule daily reminder at 20:00
    await _notificationService.scheduleDailyStreakReminder();
  }

  /// Load streak from database
  Future<void> loadStreak() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _streak = await _dbHelper.getStreak();
    } catch (e) {
      _errorMessage = 'Failed to load streak: $e';
      _streak = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check and update streak (should be called daily or on app start)
  Future<void> checkAndUpdateStreak() async {
    if (_streak == null) {
      await loadStreak();
    }

    try {
      final currentDate = DateTime.now();
      final updatedStreak = _streak!.updateStreak(currentDate);

      if (updatedStreak != _streak) {
        await _dbHelper.updateStreak(updatedStreak);
        
        final oldStreak = _streak!.currentStreak;
        _streak = updatedStreak;
        
        // Show achievement notification for milestones
        final newStreak = updatedStreak.currentStreak;
        if (newStreak > oldStreak && (newStreak == 7 || newStreak == 30 || newStreak == 100)) {
          await _notificationService.showStreakAchievement(newStreak);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update streak: $e';
      notifyListeners();
    }
  }

  /// Called when a task is completed
  Future<void> onTaskCompleted() async {
    if (_streak == null) {
      await loadStreak();
    }

    try {
      // Update streak with current date
      await checkAndUpdateStreak();

      // Increment task count is handled by TodoProvider
      // but we reload to get updated count
      await loadStreak();
    } catch (e) {
      _errorMessage = 'Failed to process task completion: $e';
      notifyListeners();
    }
  }

  /// Send daily streak reminder if not active
  Future<void> sendStreakReminderIfNeeded() async {
    if (!isActiveToday && currentStreak > 0) {
      await _notificationService.showNotification(
        NotificationService.streakReminderId,
        NotificationTemplates.streakReminderTitle,
        NotificationTemplates.streakReminderBody(currentStreak),
      );
    }
  }

  /// Reset streak (e.g., for testing or user request)
  Future<bool> resetStreak() async {
    if (_streak == null) return false;

    try {
      final resetStreak = _streak!.resetStreak();
      await _dbHelper.updateStreak(resetStreak);
      _streak = resetStreak;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reset streak: $e';
      notifyListeners();
      return false;
    }
  }

  /// Get streak message for UI
  String getStreakMessage() {
    if (_streak == null || currentStreak == 0) {
      return 'Start your streak today! 🔥';
    }

    if (currentStreak == 1) {
      return '1 day streak! Keep going! 🎯';
    }

    if (currentStreak >= longestStreak && currentStreak > 1) {
      return '$currentStreak days - NEW RECORD! 🏆';
    }

    return '$currentStreak days streak! 🔥';
  }

  /// Get motivational message based on streak
  String getMotivationalMessage() {
    if (_streak == null) return 'Let\'s get started!';

    final streak = currentStreak;

    if (streak == 0) {
      return 'Complete a task today to start your streak!';
    } else if (streak < 3) {
      return 'Great start! Keep building that streak!';
    } else if (streak < 7) {
      return 'You\'re on fire! 🔥';
    } else if (streak < 14) {
      return 'Amazing consistency! Keep it up!';
    } else if (streak < 30) {
      return 'You\'re unstoppable! 💪';
    } else {
      return 'Legendary streak! You\'re a productivity master! 👑';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
