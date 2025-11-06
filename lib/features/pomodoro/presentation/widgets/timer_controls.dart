import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/features/pomodoro/data/task_model.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_bloc.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_state.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        if (state is! PomodoroLoaded) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      'Tasks',
                      '${state.tasks.length}',
                      Icons.task_alt,
                      Colors.blue,
                    ),
                    _buildStat(
                      'Completed',
                      '${state.tasks.where((t) => t.status == TaskStatus.completed).length}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStat(
                      'Pomodoros',
                      '${state.tasks.fold<int>(0, (sum, t) => sum + t.pomodorosCompleted)}',
                      Icons.timer,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Pomodoro Duration: ${state.pomodoroDuration} minutes',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
