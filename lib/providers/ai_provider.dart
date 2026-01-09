import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import '../utils/debouncer.dart';
import '../utils/constants.dart';

/// AI Provider for State Management
/// Manages AI-related state throughout the application

class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  final Debouncer _debouncer = Debouncer(
    milliseconds: AppConstants.aiDebounceDelay.inMilliseconds,
  );

  // State variables
  bool _isAIThinking = false;
  String _currentSuggestion = '';
  List<String> _suggestions = [];
  String? _selectedSuggestion;
  bool _showSuggestions = false;
  String? _errorMessage;
  DateTime? _extractedDateTime;
  String? _detectedPriority;
  String? _detectedCategory;

  // Getters
  bool get isAIThinking => _isAIThinking;
  String get currentSuggestion => _currentSuggestion;
  List<String> get suggestions => _suggestions;
  String? get selectedSuggestion => _selectedSuggestion;
  bool get showSuggestions => _showSuggestions;
  String? get errorMessage => _errorMessage;
  DateTime? get extractedDateTime => _extractedDateTime;
  String? get detectedPriority => _detectedPriority;
  String? get detectedCategory => _detectedCategory;

  /// Get sentence completion suggestion with debouncing
  void getSuggestionsDebounced(String partialText) {
    if (partialText.trim().isEmpty || partialText.trim().length < 3) {
      _currentSuggestion = '';
      _showSuggestions = false;
      notifyListeners();
      return;
    }

    _debouncer.run(() {
      getSuggestion(partialText);
    });
  }

  /// Get sentence completion suggestion
  Future<void> getSuggestion(String partialText) async {
    if (partialText.trim().isEmpty) {
      _currentSuggestion = '';
      _showSuggestions = false;
      notifyListeners();
      return;
    }

    _isAIThinking = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSuggestion = await _aiService.completeSentence(partialText);
      _showSuggestions = _currentSuggestion.isNotEmpty;
    } catch (e) {
      _errorMessage = 'AI suggestion failed: $e';
      _currentSuggestion = '';
      _showSuggestions = false;
    } finally {
      _isAIThinking = false;
      notifyListeners();
    }
  }

  /// Parse text and extract date/time
  Future<void> parseAndExtractDate(String text) async {
    try {
      _extractedDateTime = await _aiService.extractDateTime(text);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Date extraction failed: $e';
      _extractedDateTime = null;
      notifyListeners();
    }
  }

  /// Detect priority from text
  Future<void> detectPriority(String text) async {
    try {
      _detectedPriority = await _aiService.suggestPriority(text);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Priority detection failed: $e';
      _detectedPriority = null;
      notifyListeners();
    }
  }

  /// Detect category from text
  Future<void> detectCategory(String text) async {
    try {
      _detectedCategory = await _aiService.categorizeTask(text);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Category detection failed: $e';
      _detectedCategory = null;
      notifyListeners();
    }
  }

  /// Generate sub-tasks
  Future<List<String>> generateSubTasks(String mainTask) async {
    try {
      return await _aiService.generateSubTasks(mainTask);
    } catch (e) {
      _errorMessage = 'Sub-task generation failed: $e';
      return [];
    }
  }

  /// Select a suggestion
  void selectSuggestion(String suggestion) {
    _selectedSuggestion = suggestion;
    _showSuggestions = false;
    notifyListeners();
  }

  /// Clear all suggestions
  void clearSuggestions() {
    _currentSuggestion = '';
    _suggestions = [];
    _selectedSuggestion = null;
    _showSuggestions = false;
    _errorMessage = null;
    _extractedDateTime = null;
    _detectedPriority = null;
    _detectedCategory = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Dispose
  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }
}
