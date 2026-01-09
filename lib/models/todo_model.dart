import 'dart:convert';
import 'package:uuid/uuid.dart';

/// Enhanced Todo Model with AI capabilities
/// Supports AI-generated tasks, priorities, deadlines, and sub-tasks
class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final bool isAiGenerated;
  final String priority; // 'low', 'medium', 'high'
  final DateTime? deadline;
  final String? category; // 'work', 'personal', 'urgent'
  final List<String> tags;
  final List<String> subTasks;
  final List<String> completedSubTasks;
  final String? aiSuggestions; // JSON string
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    String? id,
    required this.title,
    this.description,
    this.isDone = false,
    this.isAiGenerated = false,
    this.priority = 'medium',
    this.deadline,
    this.category,
    List<String>? tags,
    List<String>? subTasks,
    List<String>? completedSubTasks,
    this.aiSuggestions,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        subTasks = subTasks ?? [],
        completedSubTasks = completedSubTasks ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convert model to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone ? 1 : 0,
      'isAiGenerated': isAiGenerated ? 1 : 0,
      'priority': priority,
      'deadline': deadline?.millisecondsSinceEpoch,
      'category': category,
      'tags': jsonEncode(tags),
      'subTasks': jsonEncode(subTasks),
      'completedSubTasks': jsonEncode(completedSubTasks),
      'aiSuggestions': aiSuggestions,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Create model from Map (SQLite)
  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      isDone: (map['isDone'] as int) == 1,
      isAiGenerated: (map['isAiGenerated'] as int) == 1,
      priority: map['priority'] as String,
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
          : null,
      category: map['category'] as String?,
      tags: (jsonDecode(map['tags'] as String) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      subTasks: (jsonDecode(map['subTasks'] as String) as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      completedSubTasks:
          (jsonDecode(map['completedSubTasks'] as String) as List<dynamic>)
              .map((e) => e.toString())
              .toList(),
      aiSuggestions: map['aiSuggestions'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isDone': isDone,
      'isAiGenerated': isAiGenerated,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'category': category,
      'tags': tags,
      'subTasks': subTasks,
      'completedSubTasks': completedSubTasks,
      'aiSuggestions': aiSuggestions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isDone: json['isDone'] as bool,
      isAiGenerated: json['isAiGenerated'] as bool,
      priority: json['priority'] as String,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e.toString()).toList(),
      subTasks:
          (json['subTasks'] as List<dynamic>).map((e) => e.toString()).toList(),
      completedSubTasks: (json['completedSubTasks'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      aiSuggestions: json['aiSuggestions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    bool? isAiGenerated,
    String? priority,
    DateTime? deadline,
    String? category,
    List<String>? tags,
    List<String>? subTasks,
    List<String>? completedSubTasks,
    String? aiSuggestions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      subTasks: subTasks ?? this.subTasks,
      completedSubTasks: completedSubTasks ?? this.completedSubTasks,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (deadline == null || isDone) return false;
    return deadline!.isBefore(DateTime.now());
  }

  /// Get completion percentage for sub-tasks
  double get subTasksCompletionPercentage {
    if (subTasks.isEmpty) return 0.0;
    return completedSubTasks.length / subTasks.length;
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, isDone: $isDone, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
