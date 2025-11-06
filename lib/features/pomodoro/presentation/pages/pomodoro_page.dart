import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/timer_display.dart';
import '../widgets/timer_controls.dart';
import '../widgets/task_list_widget.dart';
import '../controller/poromdo_bloc.dart';
import '../controller/poromdo_event.dart';
import '../controller/poromdo_state.dart';
import '../../data/task_model.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PomodoroBloc()..add(LoadPomodoro()),
      child: const _PomodoroPageContent(),
    );
  }
}

class _PomodoroPageContent extends StatelessWidget {
  const _PomodoroPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TimerDisplay(),
            const SizedBox(height: 20),
            const TimerControls(),
            const SizedBox(height: 20),
            const Expanded(child: TaskListWidget()),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<PomodoroBloc, PomodoroState>(
        builder: (context, state) {
          // Only show FAB when there are tasks
          if (state is PomodoroLoaded && state.tasks.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
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
                                  child: Text(p.name.toUpperCase()),
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

  void _showSettings(BuildContext context) {
    final bloc = context.read<PomodoroBloc>();
    final state = bloc.state;

    if (state is! PomodoroLoaded) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Pomodoro Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Pomodoro Duration: ${state.pomodoroDuration} minutes'),
                Slider(
                  value: state.pomodoroDuration.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${state.pomodoroDuration} min',
                  onChanged: (value) {
                    bloc.add(UpdateDuration(value.toInt()));
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
