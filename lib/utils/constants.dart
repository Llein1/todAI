import 'package:flutter/material.dart';

/// App-wide constants and configuration

class AppConstants {
  // App Info
  static const String appName = 'todAI';
  static const String appVersion = '1.0.0';
  
  // API Configuration (Placeholder)
  static const String apiKeyPlaceholder = 'YOUR_API_KEY_HERE';
  
  // Animation Durations
  static const Duration normalAnimDuration = Duration(milliseconds: 300);
  static const Duration fastAnimDuration = Duration(milliseconds: 150);
  static const Duration slowAnimDuration = Duration(milliseconds: 500);
  
  // Debounce Duration for AI Suggestions
  static const Duration aiDebounceDelay = Duration(milliseconds: 800);
  
  // Database
  static const String databaseName = 'todai.db';
  static const int databaseVersion = 1;
}

/// Material 3 Color Scheme
class AppColors {
  // Will be defined based on Material 3 theme
  // TODO: Customize colors in Phase 5
  
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color secondaryLight = Color(0xFF625B71);
  
  static const Color primaryDark = Color(0xFFD0BCFF);
  static const Color secondaryDark = Color(0xFFCCC2DC);
}

/// Text Styles
class AppTextStyles {
  // TODO: Define custom text styles in Phase 5
}
