import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_bloc.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_event.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_state.dart';
import 'package:med_just/features/pomodoro/data/task_model.dart';

class TaskListWidget extends StatelessWidget {
  const TaskListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        // Handle initial and loading states
        if (state is PomodoroInitial || state is PomodoroLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (state is PomodoroError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Handle loaded state
        if (state is PomodoroLoaded) {
          final tasks = state.tasks;
          final activeTaskId = state.activeTask?.id;

          // Show empty state with create button
          if (tasks.isEmpty) {
            return _EmptyTasksView(
              onCreateTask: () => _showAddTaskDialog(context),
            );
          }

          // Show task list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final isActive = task.id == activeTaskId;

              return _TaskCard(task: task, isActive: isActive);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    int estimatedPomodoros = 1;
    DateTime? dueDate;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add New Task'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Task Title *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<TaskPriority>(
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.flag),
                          ),
                          items:
                              TaskPriority.values.map((p) {
                                return DropdownMenuItem(
                                  value: p,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getPriorityIcon(p),
                                        color: _getPriorityColor(p),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(p.name.toUpperCase()),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (v) => setState(() => priority = v!),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text('Estimated Pomodoros:'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed:
                                      estimatedPomodoros > 1
                                          ? () => setState(
                                            () => estimatedPomodoros--,
                                          )
                                          : null,
                                ),
                                Text(
                                  '$estimatedPomodoros',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed:
                                      () =>
                                          setState(() => estimatedPomodoros++),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            dueDate == null
                                ? 'Set Due Date (optional)'
                                : 'Due: ${DateFormat('MMM dd, yyyy').format(dueDate!)}',
                          ),
                          trailing:
                              dueDate != null
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        () => setState(() => dueDate = null),
                                  )
                                  : null,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() => dueDate = date);
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a task title'),
                            ),
                          );
                          return;
                        }

                        final task = TaskModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text.trim(),
                          description:
                              descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                          priority: priority,
                          createdAt: DateTime.now(),
                          estimatedPomodoros: estimatedPomodoros,
                          dueDate: dueDate,
                        );

                        context.read<PomodoroBloc>().add(AddTask(task));
                        Navigator.pop(context);
                      },
                      child: const Text('Add Task'),
                    ),
                  ],
                ),
          ),
    );
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.arrow_upward;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.arrow_downward;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}

// Empty state widget with create button
class _EmptyTasksView extends StatelessWidget {
  final VoidCallback onCreateTask;

  const _EmptyTasksView({required this.onCreateTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_outlined,
                      size: 80,
                      color: Colors.blue.shade300,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'No Tasks Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first task to start\ntracking your study time with Pomodoro',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Large create button
            ElevatedButton.icon(
              onPressed: onCreateTask,
              icon: const Icon(Icons.add, size: 28),
              label: const Text(
                'Create Your First Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Info cards
            _buildInfoCard(
              icon: Icons.timer,
              title: 'Focus Sessions',
              description: 'Work in 25-minute focused intervals',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.trending_up,
              title: 'Track Progress',
              description: 'Monitor your completed pomodoros',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.check_circle,
              title: 'Stay Organized',
              description: 'Manage tasks with priorities and due dates',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Task card widget
class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isActive;

  const _TaskCard({required this.task, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Task'),
                content: const Text(
                  'Are you sure you want to delete this task?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        );
      },
      onDismissed: (_) {
        context.read<PomodoroBloc>().add(DeleteTask(task.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                context.read<PomodoroBloc>().add(AddTask(task));
              },
            ),
          ),
        );
      },
      child: Card(
        color: isActive ? Colors.blue.shade50 : null,
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isActive ? 4 : 1,
        child: ListTile(
          onTap: () => _onTaskTap(context, task),
          leading: _buildPriorityIcon(task.priority),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration:
                  task.status == TaskStatus.completed
                      ? TextDecoration.lineThrough
                      : null,
              color: task.status == TaskStatus.completed ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${task.pomodorosCompleted}/${task.estimatedPomodoros} Pomodoros',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color:
                          task.dueDate!.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd').format(task.dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            task.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing:
              task.status != TaskStatus.completed
                  ? IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                    tooltip: 'Mark as complete',
                    onPressed: () {
                      context.read<PomodoroBloc>().add(
                        UpdateTask(task.copyWith(status: TaskStatus.completed)),
                      );
                    },
                  )
                  : const Icon(Icons.check_circle, color: Colors.green),
        ),
      ),
    );
  }

  void _onTaskTap(BuildContext context, TaskModel task) {
    final bloc = context.read<PomodoroBloc>();
    final state = bloc.state;

    if (state is! PomodoroLoaded) return;

    if (state.timerStatus != TimerStatus.idle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stop current timer first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (task.status == TaskStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task is already completed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    bloc.add(StartTimer(task.id));
  }

  Widget _buildPriorityIcon(TaskPriority priority) {
    Color color;
    IconData icon;

    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        icon = Icons.arrow_upward;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case TaskPriority.low:
        color = Colors.green;
        icon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
