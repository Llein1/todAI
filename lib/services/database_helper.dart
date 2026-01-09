/// Database Helper for SQLite Operations
/// Manages local database for tasks and streaks
library;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';
import '../models/streak_model.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Database configuration
  static const String _databaseName = 'todai.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _todosTable = 'todos';
  static const String _streaksTable = 'streaks';

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    // Create todos table
    await db.execute('''
      CREATE TABLE $_todosTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isDone INTEGER NOT NULL DEFAULT 0,
        isAiGenerated INTEGER NOT NULL DEFAULT 0,
        priority TEXT NOT NULL DEFAULT 'medium',
        deadline INTEGER,
        category TEXT,
        tags TEXT NOT NULL DEFAULT '[]',
        subTasks TEXT NOT NULL DEFAULT '[]',
        completedSubTasks TEXT NOT NULL DEFAULT '[]',
        aiSuggestions TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create streaks table
    await db.execute('''
      CREATE TABLE $_streaksTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        currentStreak INTEGER NOT NULL DEFAULT 0,
        longestStreak INTEGER NOT NULL DEFAULT 0,
        lastActiveDate INTEGER NOT NULL,
        totalTasksCompleted INTEGER NOT NULL DEFAULT 0,
        streakStartDate INTEGER
      )
    ''');

    // Initialize default streak
    await db.insert(_streaksTable, StreakModel().toMap());
  }

  /// Handle database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO: Implement migration logic when schema changes
  }

  // ==================== TODO CRUD OPERATIONS ====================

  /// Insert a new todo
  Future<int> insertTodo(TodoModel todo) async {
    final db = await database;
    return await db.insert(
      _todosTable,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing todo
  Future<int> updateTodo(TodoModel todo) async {
    final db = await database;
    return await db.update(
      _todosTable,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  /// Delete a todo
  Future<int> deleteTodo(String id) async {
    final db = await database;
    return await db.delete(
      _todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a todo by ID
  Future<TodoModel?> getTodo(String id) async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TodoModel.fromMap(maps.first);
  }

  /// Get all todos
  Future<List<TodoModel>> getAllTodos() async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Get todos by category
  Future<List<TodoModel>> getTodosByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Get todos by priority
  Future<List<TodoModel>> getTodosByPriority(String priority) async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      where: 'priority = ?',
      whereArgs: [priority],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Get completed todos
  Future<List<TodoModel>> getCompletedTodos() async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      where: 'isDone = ?',
      whereArgs: [1],
      orderBy: 'updatedAt DESC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Get pending todos
  Future<List<TodoModel>> getPendingTodos() async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      where: 'isDone = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Search todos by title or description
  Future<List<TodoModel>> searchTodos(String query) async {
    final db = await database;
    final maps = await db.query(
      _todosTable,
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Get todos with upcoming deadlines
  Future<List<TodoModel>> getUpcomingTodos() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final maps = await db.query(
      _todosTable,
      where: 'isDone = ? AND deadline > ?',
      whereArgs: [0, now],
      orderBy: 'deadline ASC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  /// Get overdue todos
  Future<List<TodoModel>> getOverdueTodos() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final maps = await db.query(
      _todosTable,
      where: 'isDone = ? AND deadline < ?',
      whereArgs: [0, now],
      orderBy: 'deadline ASC',
    );

    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  // ==================== STREAK CRUD OPERATIONS ====================

  /// Get current streak
  Future<StreakModel> getStreak() async {
    final db = await database;
    final maps = await db.query(
      _streaksTable,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) {
      // Initialize if not exists
      final defaultStreak = StreakModel();
      await db.insert(_streaksTable, defaultStreak.toMap());
      return defaultStreak;
    }

    return StreakModel.fromMap(maps.first);
  }

  /// Update streak
  Future<int> updateStreak(StreakModel streak) async {
    final db = await database;
    return await db.update(
      _streaksTable,
      streak.toMap(),
      where: 'id = ?',
      whereArgs: [streak.id],
    );
  }

  /// Increment task completed count
  Future<void> incrementTaskCount() async {
    final streak = await getStreak();
    final updatedStreak = streak.incrementTaskCount();
    await updateStreak(updatedStreak);
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete all todos (for testing/reset)
  Future<void> deleteAllTodos() async {
    final db = await database;
    await db.delete(_todosTable);
  }

  /// Get database statistics
  Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_todosTable'),
    );

    final completedCount = Sqflite.firstIntValue(
      await db.rawQuery(
          'SELECT COUNT(*) FROM $_todosTable WHERE isDone = 1'),
    );

    final pendingCount = Sqflite.firstIntValue(
      await db.rawQuery(
          'SELECT COUNT(*) FROM $_todosTable WHERE isDone = 0'),
    );

    return {
      'total': totalCount ?? 0,
      'completed': completedCount ?? 0,
      'pending': pendingCount ?? 0,
    };
  }
}
