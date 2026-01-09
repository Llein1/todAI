import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility for delaying function execution
/// Useful for search inputs, AI suggestions, etc.
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Run the action after debounce delay
  /// Cancels previous timer if called again
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Clean up resources
  void dispose() {
    _timer?.cancel();
  }

  /// Check if there's a pending action
  bool get isActive => _timer?.isActive ?? false;
}
