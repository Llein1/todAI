import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/constants.dart';

/// Streak Card Widget
/// Displays current streak with fire theme and motivational message
class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final String message;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = longestStreak > 0 ? currentStreak / longestStreak : 0.0;

    return Card(
      elevation: UIConstants.elevationMedium,
      margin: const EdgeInsets.all(UIConstants.paddingMedium),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: GradientColors.streakGradient,
          borderRadius: BorderRadius.circular(UIConstants.radiusLarge),
        ),
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          children: [
            // Fire Animation & Streak Number
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Lottie.network(
                    AnimationConstants.streakFire,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('🔥', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Column(
                  children: [
                    Text(
                      '$currentStreak',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentStreak == 1 ? 'DAY' : 'DAYS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Lottie.network(
                    AnimationConstants.streakFire,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('🔥', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            // Motivational Message
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            // Progress Bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      'Record: $longestStreak days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
