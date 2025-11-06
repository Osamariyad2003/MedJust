import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_bloc.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_event.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_state.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroBloc, PomodoroState>(
      builder: (context, state) {
        if (state is! PomodoroLoaded || state.activeTask == null) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.timer_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Select a task to start',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        final task = state.activeTask!;
        final minutes = (state.remainingSeconds / 60).floor();
        final seconds = state.remainingSeconds % 60;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: state.progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.timerStatus == TimerStatus.running
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.timerStatus == TimerStatus.running
                              ? 'In Progress'
                              : 'Paused',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.timerStatus == TimerStatus.running)
                      ElevatedButton.icon(
                        onPressed:
                            () =>
                                context.read<PomodoroBloc>().add(PauseTimer()),
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed:
                            () =>
                                context.read<PomodoroBloc>().add(ResumeTimer()),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed:
                          () => context.read<PomodoroBloc>().add(StopTimer()),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
