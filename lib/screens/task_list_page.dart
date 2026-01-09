import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/streak_provider.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';

/// Task List Page
/// Displays all tasks with filters and search
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  todoProvider.searchTodos(value);
                },
              )
            : const Text('All Tasks'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  todoProvider.searchTodos('');
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
              vertical: UIConstants.paddingSmall,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: todoProvider.currentFilter == 'all',
                  onTap: () => todoProvider.filterTodos('all'),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                _FilterChip(
                  label: 'Pending',
                  isSelected: todoProvider.currentFilter == 'pending',
                  onTap: () => todoProvider.filterTodos('pending'),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                _FilterChip(
                  label: 'Completed',
                  isSelected: todoProvider.currentFilter == 'completed',
                  onTap: () => todoProvider.filterTodos('completed'),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                _FilterChip(
                  label: 'Work',
                  isSelected: todoProvider.currentCategory == 'work',
                  onTap: () => todoProvider.filterByCategory(
                    todoProvider.currentCategory == 'work' ? null : 'work',
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                _FilterChip(
                  label: 'Personal',
                  isSelected: todoProvider.currentCategory == 'personal',
                  onTap: () => todoProvider.filterByCategory(
                    todoProvider.currentCategory == 'personal'
                        ? null
                        : 'personal',
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                _FilterChip(
                  label: 'Urgent',
                  isSelected: todoProvider.currentCategory == 'urgent',
                  onTap: () => todoProvider.filterByCategory(
                    todoProvider.currentCategory == 'urgent' ? null : 'urgent',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Task List
          Expanded(
            child: todoProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : todoProvider.todos.isEmpty
                    ? _EmptyState(theme: theme)
                    : RefreshIndicator(
                        onRefresh: () => todoProvider.loadTodos(),
                        child: ListView.builder(
                          itemCount: todoProvider.todos.length,
                          itemBuilder: (context, index) {
                            final task = todoProvider.todos[index];
                            return TaskCard(
                              task: task,
                              onTap: () {
                                // TODO: Navigate to task detail
                              },
                              onToggle: (value) async {
                                await todoProvider.toggleTodoStatus(task.id);
                                if (value && context.mounted) {
                                  context
                                      .read<StreakProvider>()
                                      .onTaskCompleted();
                                }
                              },
                              onDelete: () {
                                todoProvider.deleteTodo(task.id);
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: theme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            Text(
              'No tasks found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              'Tap + to create your first task',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
