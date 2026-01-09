import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_helper.dart';

/// Todo Provider for State Management
/// Manages todo list state and database operations
class TodoProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // State variables
  List<TodoModel> _todos = [];
  List<TodoModel> _filteredTodos = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentFilter = 'all'; // 'all', 'pending', 'completed'
  String? _currentCategory;
  String? _searchQuery;

  // Getters
  List<TodoModel> get todos => _filteredTodos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;
  String? get currentCategory => _currentCategory;
  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((t) => t.isDone).length;
  int get pendingTodos => _todos.where((t) => !t.isDone).length;

  /// Load all todos from database
  Future<void> loadTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todos = await _dbHelper.getAllTodos();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load todos: $e';
      _todos = [];
      _filteredTodos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new todo
  Future<bool> addTodo(TodoModel todo) async {
    try {
      await _dbHelper.insertTodo(todo);
      _todos.insert(0, todo);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add todo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update an existing todo
  Future<bool> updateTodo(TodoModel todo) async {
    try {
      await _dbHelper.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update todo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a todo
  Future<bool> deleteTodo(String id) async {
    try {
      await _dbHelper.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete todo: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggle todo completion status
  Future<bool> toggleTodoStatus(String id) async {
    try {
      final index = _todos.indexWhere((t) => t.id == id);
      if (index == -1) return false;

      final updatedTodo = _todos[index].copyWith(
        isDone: !_todos[index].isDone,
      );

      await _dbHelper.updateTodo(updatedTodo);
      _todos[index] = updatedTodo;

      // Update streak if task completed
      if (updatedTodo.isDone) {
        await _dbHelper.incrementTaskCount();
      }

      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to toggle todo status: $e';
      notifyListeners();
      return false;
    }
  }

  /// Filter todos by status
  void filterTodos(String filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(String? category) {
    _currentCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Search todos
  void searchTodos(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _currentFilter = 'all';
    _currentCategory = null;
    _searchQuery = null;
    _applyFilters();
    notifyListeners();
  }

  /// Apply current filters
  void _applyFilters() {
    _filteredTodos = List.from(_todos);

    // Apply status filter
    if (_currentFilter == 'pending') {
      _filteredTodos = _filteredTodos.where((t) => !t.isDone).toList();
    } else if (_currentFilter == 'completed') {
      _filteredTodos = _filteredTodos.where((t) => t.isDone).toList();
    }

    // Apply category filter
    if (_currentCategory != null) {
      _filteredTodos =
          _filteredTodos.where((t) => t.category == _currentCategory).toList();
    }

    // Apply search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      _filteredTodos = _filteredTodos.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// Get todos by priority
  Future<List<TodoModel>> getTodosByPriority(String priority) async {
    try {
      return await _dbHelper.getTodosByPriority(priority);
    } catch (e) {
      _errorMessage = 'Failed to get todos by priority: $e';
      return [];
    }
  }

  /// Get upcoming todos (with deadlines)
  Future<List<TodoModel>> getUpcomingTodos() async {
    try {
      return await _dbHelper.getUpcomingTodos();
    } catch (e) {
      _errorMessage = 'Failed to get upcoming todos: $e';
      return [];
    }
  }

  /// Get overdue todos
  Future<List<TodoModel>> getOverdueTodos() async {
    try {
      return await _dbHelper.getOverdueTodos();
    } catch (e) {
      _errorMessage = 'Failed to get overdue todos: $e';
      return [];
    }
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      return await _dbHelper.getStatistics();
    } catch (e) {
      _errorMessage = 'Failed to get statistics: $e';
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
