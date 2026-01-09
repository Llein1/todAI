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

/// AI-related Constants
class AIConstants {
  // Gemini API
  static const String geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // OpenAI API (alternative)
  static const String openAIEndpoint =
      'https://api.openai.com/v1/chat/completions';

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 2;

  // Prompts
  static const String sentenceCompletionPrompt =
      'Complete this task description in a concise way (max 10 words): ';

  static const String priorityPrompt =
      'Analyze this task and suggest only the priority level as a single word (low/medium/high): ';

  static const String subTasksPrompt =
      'Break this task into 3-5 actionable sub-tasks. Return only a simple list: ';

  static const String categoryPrompt =
      'Categorize this task as one word (work/personal/urgent): ';

  static const String dateExtractionPrompt =
      'Extract date and time from this text. Return in format "YYYY-MM-DD HH:MM" or "none": ';
}

