import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/nlp_helper.dart';

/// AI Service for todAI Application
/// Handles all AI-related operations including:
/// - Sentence completion
/// - Date/time extraction from natural language
/// - Task prioritization suggestions
/// - Smart task suggestions

class AIService {
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Get API key from environment variables
  String? get _apiKey {
    final provider = dotenv.env['AI_PROVIDER'] ?? 'gemini';
    if (provider == 'gemini') {
      return dotenv.env['GEMINI_API_KEY'];
    } else if (provider == 'openai') {
      return dotenv.env['OPENAI_API_KEY'];
    }
    return null;
  }

  /// Get AI provider type
  String get _provider => dotenv.env['AI_PROVIDER'] ?? 'gemini';

  /// Check if API is configured
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty && !_apiKey!.contains('your_');

  /// Complete user's sentence based on context
  /// Returns AI-generated completion suggestion
  Future<String> completeSentence(String partialText) async {
    if (!isConfigured) {
      return 'AI not configured. Check .env file';
    }

    if (partialText.trim().isEmpty || partialText.trim().length < 3) {
      return '';
    }

    try {
      if (_provider == 'gemini') {
        return await _callGeminiAPI(
          AIConstants.sentenceCompletionPrompt + partialText,
        );
      } else {
        return await _callOpenAIAPI(
          AIConstants.sentenceCompletionPrompt + partialText,
        );
      }
    } catch (e) {
      return ''; // Silently fail for UX
    }
  }

  /// Extract date and time from natural language input
  /// Example: "tomorrow at 5pm" -> DateTime object
  Future<DateTime?> extractDateTime(String text) async {
    // First try offline NLP helper (fast, no API cost)
    final offlineResult = NLPHelper.combineDateTime(text);
    if (offlineResult != null) {
      return offlineResult;
    }

    // If offline fails and AI is configured, try AI
    if (!isConfigured) {
      return null;
    }

    try {
      if (_provider == 'gemini') {
        final response = await _callGeminiAPI(
          AIConstants.dateExtractionPrompt + text,
        );

// Parse AI response - expecting "YYYY-MM-DD HH:MM" or "none"
        if (response.toLowerCase().contains('none')) {
          return null;
        }

        final dateTimePattern = RegExp(r'(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})');
        final match = dateTimePattern.firstMatch(response);
        if (match != null) {
          return DateTime(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
            int.parse(match.group(4)!),
            int.parse(match.group(5)!),
          );
        }
      }
    } catch (e) {
      // Fall back to null
    }

    return null;
  }

  /// Analyze task and suggest priority level
  /// Returns priority: 'high', 'medium', 'low'
  Future<String> suggestPriority(String taskText) async {
    // First try offline detection
    final offlineResult = NLPHelper.detectPriority(taskText);
    if (offlineResult != null) {
      return offlineResult;
    }

    if (!isConfigured) {
      return 'medium';
    }

    try {
      if (_provider == 'gemini') {
        final response = await _callGeminiAPI(
          AIConstants.priorityPrompt + taskText,
        );

        final lowerResponse = response.toLowerCase().trim();
        if (lowerResponse.contains('high')) return 'high';
        if (lowerResponse.contains('low')) return 'low';
        return 'medium';
      }
    } catch (e) {
      // Fall back to medium
    }

    return 'medium';
  }

  /// Generate sub-tasks for a given main task
  Future<List<String>> generateSubTasks(String mainTask) async {
    if (!isConfigured) {
      return [];
    }

    try {
      if (_provider == 'gemini') {
        final response = await _callGeminiAPI(
          AIConstants.subTasksPrompt + mainTask,
        );

        // Parse response - expecting a list
        final lines = response.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) {
              // Remove bullets, numbers, etc.
              return line.replaceAll(RegExp(r'^[\d\-\*\•\.]+\s*'), '').trim();
            })
            .where((line) => line.isNotEmpty)
            .take(5)
            .toList();

        return lines;
      }
    } catch (e) {
      // Return empty list
    }

    return [];
  }

  /// Categorize task
  Future<String?> categorizeTask(String taskText) async {
    // First try offline detection
    final offlineResult = NLPHelper.detectCategory(taskText);
    if (offlineResult != null) {
      return offlineResult;
    }

    if (!isConfigured) {
      return null;
    }

    try {
      if (_provider == 'gemini') {
        final response = await _callGeminiAPI(
          AIConstants.categoryPrompt + taskText,
        );

        final lowerResponse = response.toLowerCase().trim();
        if (lowerResponse.contains('work')) return 'work';
        if (lowerResponse.contains('personal')) return 'personal';
        if (lowerResponse.contains('urgent')) return 'urgent';
      }
    } catch (e) {
      // Return null
    }

    return null;
  }

  /// Call Gemini API
  Future<String> _callGeminiAPI(String prompt) async {
    final url = Uri.parse('${AIConstants.geminiEndpoint}?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 100,
        }
      }),
    ).timeout(AIConstants.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text?.toString().trim() ?? '';
    } else {
      throw Exception('Gemini API error: ${response.statusCode}');
    }
  }

  /// Call OpenAI API (alternative)
  Future<String> _callOpenAIAPI(String prompt) async {
    final url = Uri.parse(AIConstants.openAIEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    ).timeout(AIConstants.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices']?[0]?['message']?['content'];
      return text?.toString().trim() ?? '';
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }
}
