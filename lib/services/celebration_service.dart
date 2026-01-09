import 'package:flutter/material.dart';
import '../widgets/celebration_overlay.dart';

/// Celebration Service
/// Manages celebration triggers throughout the app
class CelebrationService {
  // Singleton pattern
  static final CelebrationService _instance = CelebrationService._internal();
  factory CelebrationService() => _instance;
  CelebrationService._internal();

  /// Show task completion celebration
  Future<void> showTaskComplete(BuildContext context) async {
    await CelebrationOverlay.show(
      context,
      message: 'Task Completed! 🎉',
      icon: Icons.check_circle,
      duration: const Duration(seconds: 2),
    );
  }

  /// Show streak milestone celebration
  Future<void> showStreakMilestone(BuildContext context, int streak) async {
    String message;
    IconData icon;

    if (streak == 7) {
      message = 'One Week Streak! 🔥';
      icon = Icons.local_fire_department;
    } else if (streak == 30) {
      message = 'One Month Streak! 🏆';
      icon = Icons.emoji_events;
    } else if (streak == 100) {
      message = '100 Day Streak! 👑';
      icon = Icons.military_tech;
    } else if (streak == 365) {
      message = 'One Year Streak! 🌟';
      icon = Icons.stars;
    } else {
      message = '$streak Day Streak! 🔥';
      icon = Icons.local_fire_department;
    }

    await CelebrationOverlay.show(
      context,
      message: message,
      icon: icon,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show generic celebration
  Future<void> showGenericCelebration(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) async {
    await CelebrationOverlay.show(
      context,
      message: message,
      icon: icon,
      duration: duration,
    );
  }

  /// Show first task celebration
  Future<void> showFirstTask(BuildContext context) async {
    await CelebrationOverlay.show(
      context,
      message: 'First Task! Great Start! 🚀',
      icon: Icons.celebration,
      duration: const Duration(seconds: 2),
    );
  }

  /// Show all tasks complete celebration
  Future<void> showAllTasksComplete(BuildContext context) async {
    await CelebrationOverlay.show(
      context,
      message: 'All Tasks Done! Amazing! ✨',
      icon: Icons.workspace_premium,
      duration: const Duration(seconds: 2),
    );
  }
}
