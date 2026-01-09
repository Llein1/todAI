/// Streak Model for gamification
/// Tracks user activity and daily streaks
class StreakModel {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final int totalTasksCompleted;
  final DateTime? streakStartDate;

  StreakModel({
    this.id = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastActiveDate,
    this.totalTasksCompleted = 0,
    this.streakStartDate,
  }) : lastActiveDate = lastActiveDate ?? 
       DateTime.now().subtract(const Duration(days: 2)); // 2 days ago so first task starts streak

  /// Convert model to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate.millisecondsSinceEpoch,
      'totalTasksCompleted': totalTasksCompleted,
      'streakStartDate': streakStartDate?.millisecondsSinceEpoch,
    };
  }

  /// Create model from Map (SQLite)
  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      id: map['id'] as int,
      currentStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      lastActiveDate:
          DateTime.fromMillisecondsSinceEpoch(map['lastActiveDate'] as int),
      totalTasksCompleted: map['totalTasksCompleted'] as int,
      streakStartDate: map['streakStartDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['streakStartDate'] as int)
          : null,
    );
  }

  /// Update streak based on current date
  StreakModel updateStreak(DateTime currentDate) {
    final lastDate =
        DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    final difference = today.difference(lastDate).inDays;

    if (difference == 0) {
      // Same day - no change
      return this;
    } else if (difference == 1) {
      // Next day - increment streak
      final newStreak = currentStreak + 1;
      return copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
        lastActiveDate: currentDate,
        streakStartDate: streakStartDate ?? currentDate,
      );
    } else {
      // Streak broken - reset
      return copyWith(
        currentStreak: 1,
        lastActiveDate: currentDate,
        streakStartDate: currentDate,
      );
    }
  }

  /// Reset streak
  StreakModel resetStreak() {
    return copyWith(
      currentStreak: 0,
      streakStartDate: null,
    );
  }

  /// Increment total tasks completed
  StreakModel incrementTaskCount() {
    return copyWith(
      totalTasksCompleted: totalTasksCompleted + 1,
    );
  }

  /// Create a copy with updated fields
  StreakModel copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    int? totalTasksCompleted,
    DateTime? streakStartDate,
  }) {
    return StreakModel(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      streakStartDate: streakStartDate ?? this.streakStartDate,
    );
  }

  /// Check if streak is active today
  bool get isActiveToday {
    final today = DateTime.now();
    final lastDate =
        DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return lastDate.isAtSameMomentAs(todayDate) ||
        todayDate.difference(lastDate).inDays <= 1;
  }

  @override
  String toString() {
    return 'StreakModel(currentStreak: $currentStreak, longestStreak: $longestStreak, totalTasks: $totalTasksCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is StreakModel &&
        other.id == id &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastActiveDate.millisecondsSinceEpoch == lastActiveDate.millisecondsSinceEpoch &&
        other.totalTasksCompleted == totalTasksCompleted &&
        other.streakStartDate?.millisecondsSinceEpoch == streakStartDate?.millisecondsSinceEpoch;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        currentStreak.hashCode ^
        longestStreak.hashCode ^
        lastActiveDate.hashCode ^
        totalTasksCompleted.hashCode ^
        streakStartDate.hashCode;
  }
}
