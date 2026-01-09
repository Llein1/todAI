import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/streak_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/streak_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/task_card.dart';
import '../utils/constants.dart';

/// Home Page - Dashboard
/// Displays streak, stats, and upcoming tasks
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize on app startup
    Future.microtask(() {
      context.read<StreakProvider>().initializeAndCheckStreak();
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TodoProvider>().loadTodos();
          await context.read<StreakProvider>().loadStreak();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: UIConstants.paddingMedium),
              // Streak Card
              Consumer<StreakProvider>(
                builder: (context, streakProvider, child) {
                  return StreakCard(
                    currentStreak: streakProvider.currentStreak,
                    longestStreak: streakProvider.longestStreak,
                    message: streakProvider.getStreakMessage(),
                  );
                },
              ),
              const SizedBox(height: UIConstants.paddingLarge),
              // Stats Row
              Consumer<TodoProvider>(
                builder: (context, todoProvider, child) {
                  final total = todoProvider.totalTodos;
                  final completed = todoProvider.completedTodos;
                  final pending = todoProvider.pendingTodos;
                  final rate = total > 0 ? (completed / total) * 100 : 0.0;

                  return StatsRow(
                    totalTasks: total,
                    completedTasks: completed,
                    pendingTasks: pending,
                    completionRate: rate,
                  );
                },
              ),
              const SizedBox(height: UIConstants.paddingLarge),
              // Upcoming Tasks
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingMedium,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Tasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/tasks');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UIConstants.paddingSmall),
              // Upcoming Tasks List
              Consumer<TodoProvider>(
                builder: (context, todoProvider, child) {
                  if (todoProvider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(UIConstants.paddingLarge),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final upcomingTasks = todoProvider.todos
                      .where((t) => !t.isDone)
                      .take(3)
                      .toList();

                  if (upcomingTasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(UIConstants.paddingLarge),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: theme.primaryColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: UIConstants.paddingMedium),
                            Text(
                              'No pending tasks!',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.paddingSmall),
                            Text(
                              'Tap + to add a new task',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingTasks.length,
                    itemBuilder: (context, index) {
                      final task = upcomingTasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          // TODO: Navigate to task detail
                        },
                        onToggle: (value) async {
                          await todoProvider.toggleTodoStatus(task.id);
                          if (value) {
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
                  );
                },
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-task');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
