import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../utils/constants.dart';
import '../utils/nlp_helper.dart';

/// Task Card Widget
/// Displays a task with checkbox, title, deadline, and priority indicator
class TaskCard extends StatelessWidget {
  final TodoModel task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isDone;

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: UIConstants.paddingLarge),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: UIConstants.paddingLarge),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        } else {
          // Complete
          onToggle?.call(!isDone);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: Card(
        elevation: UIConstants.elevationLow,
        margin: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: UIConstants.paddingSmall,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: _getPriorityColor(),
                  width: 4,
                ),
              ),
              borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            ),
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: isDone,
                  onChanged: (value) => onToggle?.call(value ?? false),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color:
                              isDone ? theme.disabledColor : theme.primaryColor,
                        ),
                      ),
                      // Description
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Deadline & AI Badge
                      if (task.deadline != null || task.isAiGenerated) ...[
                        const SizedBox(height: UIConstants.paddingSmall),
                        Row(
                          children: [
                            if (task.deadline != null) ...[
                              Icon(
                                Icons.access_time,
                                size: UIConstants.iconSmall,
                                color: task.isOverdue
                                    ? Colors.red
                                    : theme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                NLPHelper.formatDateTime(task.deadline),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: task.isOverdue
                                      ? Colors.red
                                      : theme.primaryColor,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (task.isAiGenerated)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 12,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'AI',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.primaryColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
