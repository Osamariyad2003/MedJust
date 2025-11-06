import 'package:equatable/equatable.dart';
import 'package:med_just/features/pomodoro/data/task_model.dart';

enum TimerStatus { idle, running, paused }

abstract class PomodoroState extends Equatable {
  const PomodoroState();
  @override
  List<Object?> get props => [];
}

class PomodoroInitial extends PomodoroState {}

class PomodoroLoading extends PomodoroState {}

class PomodoroLoaded extends PomodoroState {
  final List<TaskModel> tasks;
  final TimerStatus timerStatus;
  final int remainingSeconds;
  final int totalSeconds;
  final TaskModel? activeTask;
  final int pomodoroDuration;

  const PomodoroLoaded({
    required this.tasks,
    this.timerStatus = TimerStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.activeTask,
    this.pomodoroDuration = 25,
  });

  PomodoroLoaded copyWith({
    List<TaskModel>? tasks,
    TimerStatus? timerStatus,
    int? remainingSeconds,
    int? totalSeconds,
    TaskModel? activeTask,
    bool clearActiveTask = false,
    int? pomodoroDuration,
  }) {
    return PomodoroLoaded(
      tasks: tasks ?? this.tasks,
      timerStatus: timerStatus ?? this.timerStatus,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      activeTask: clearActiveTask ? null : (activeTask ?? this.activeTask),
      pomodoroDuration: pomodoroDuration ?? this.pomodoroDuration,
    );
  }

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0;

  @override
  List<Object?> get props => [
    tasks,
    timerStatus,
    remainingSeconds,
    totalSeconds,
    activeTask,
    pomodoroDuration,
  ];
}

class PomodoroError extends PomodoroState {
  final String message;
  const PomodoroError(this.message);
  @override
  List<Object?> get props => [message];
}
