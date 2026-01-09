import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';

/// AI Provider for State Management
/// Manages AI-related state throughout the application

class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  
  // State variables
  bool _isAIThinking = false;
  String _currentSuggestion = '';
  String? _errorMessage;

  // Getters
  bool get isAIThinking => _isAIThinking;
  String get currentSuggestion => _currentSuggestion;
  String? get errorMessage => _errorMessage;

  /// Get sentence completion suggestion
  Future<void> getSuggestion(String partialText) async {
    if (partialText.isEmpty) {
      _currentSuggestion = '';
      notifyListeners();
      return;
    }

    _isAIThinking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSuggestion = await _aiService.completeSentence(partialText);
    } catch (e) {
      _errorMessage = 'AI suggestion failed: $e';
      _currentSuggestion = '';
    } finally {
      _isAIThinking = false;
      notifyListeners();
    }
  }

  /// Extract date from natural language
  Future<DateTime?> extractDate(String text) async {
    try {
      return await _aiService.extractDateTime(text);
    } catch (e) {
      _errorMessage = 'Date extraction failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Get priority suggestion for a task
  Future<String> getPrioritySuggestion(String taskText) async {
    try {
      return await _aiService.suggestPriority(taskText);
    } catch (e) {
      _errorMessage = 'Priority suggestion failed: $e';
      notifyListeners();
      return 'medium';
    }
  }

  /// Clear current suggestion
  void clearSuggestion() {
    _currentSuggestion = '';
    _errorMessage = null;
    notifyListeners();
  }
}
