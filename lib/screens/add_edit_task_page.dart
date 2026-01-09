import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../providers/ai_provider.dart';
import '../utils/constants.dart';

/// Add/Edit Task Page
/// AI-powered task creation and editing
class AddEditTaskPage extends StatefulWidget {
  final TodoModel? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _deadline;
  String _priority = 'medium';
  String? _category;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _deadline = task?.deadline;
    _priority = task?.priority ?? 'medium';
    _category = task?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _extractDateFromAI() async {
    final aiProvider = context.read<AIProvider>();
    final text = _titleController.text + ' ' + _descriptionController.text;

    await aiProvider.parseAndExtractDate(text);

    if (aiProvider.extractedDateTime != null) {
      setState(() {
        _deadline = aiProvider.extractedDateTime;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date extracted by AI! 🤖')),
        );
      }
    }
  }

  Future<void> _suggestPriorityFromAI() async {
    final aiProvider = context.read<AIProvider>();
    final text = _titleController.text + ' ' + _descriptionController.text;

    await aiProvider.detectPriority(text);

    if (aiProvider.detectedPriority != null) {
      setState(() {
        _priority = aiProvider.detectedPriority!;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Priority set to ${_priority.toUpperCase()} by AI! 🤖')),
        );
      }
    }
  }

  Future<void> _detectCategoryFromAI() async {
    final aiProvider = context.read<AIProvider>();
    final text = _titleController.text + ' ' + _descriptionController.text;

    await aiProvider.detectCategory(text);

    if (aiProvider.detectedCategory != null) {
      setState(() {
        _category = aiProvider.detectedCategory;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Category set to ${_category?.toUpperCase()} by AI! 🤖')),
        );
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final todoProvider = context.read<TodoProvider>();
    final task = TodoModel(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      deadline: _deadline,
      priority: _priority,
      category: _category,
      isDone: widget.task?.isDone ?? false,
    );

    final success = widget.task == null
        ? await todoProvider.addTodo(task)
        : await todoProvider.updateTodo(task);

    setState(() => _isLoading = false);

    if (mounted && success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.task == null
              ? 'Task created! ✅'
              : 'Task updated! ✅'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveTask,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Add details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            // AI Suggestion Chips
            Wrap(
              spacing: UIConstants.paddingSmall,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Extract Date'),
                  onPressed: _extractDateFromAI,
                ),
                ActionChip(
                  avatar: const Icon(Icons.priority_high, size: 18),
                  label: const Text('Suggest Priority'),
                  onPressed: _suggestPriorityFromAI,
                ),
                ActionChip(
                  avatar: const Icon(Icons.category, size: 18),
                  label: const Text('Detect Category'),
                  onPressed: _detectCategoryFromAI,
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            // Deadline
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Deadline'),
                subtitle: Text(_deadline == null
                    ? 'No deadline set'
                    : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year} ${_deadline!.hour}:${_deadline!.minute.toString().padLeft(2, '0')}'),
                trailing: _deadline != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _deadline = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );

                  if (date != null && mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          _deadline ?? DateTime.now()),
                    );

                    if (time != null) {
                      setState(() {
                        _deadline = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            // Priority
            Card(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: UIConstants.paddingSmall),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'low', label: Text('Low')),
                        ButtonSegment(value: 'medium', label: Text('Medium')),
                        ButtonSegment(value: 'high', label: Text('High')),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _priority = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            // Category
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingMedium,
                ),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('No category')),
                    DropdownMenuItem(value: 'work', child: Text('Work')),
                    DropdownMenuItem(value: 'personal', child: Text('Personal')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          : Hero(
              tag: 'add_task_fab',
              child: FloatingActionButton.extended(
                onPressed: _saveTask,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? 'Update' : 'Create'),
              ),
            ),
    );
  }
}
