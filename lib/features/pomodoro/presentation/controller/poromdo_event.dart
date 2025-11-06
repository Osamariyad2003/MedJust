import 'package:equatable/equatable.dart';
import 'package:med_just/features/pomodoro/data/task_model.dart';

abstract class PomodoroEvent extends Equatable {
  const PomodoroEvent();
  @override
  List<Object?> get props => [];
}

class LoadPomodoro extends PomodoroEvent {}

class AddTask extends PomodoroEvent {
  final TaskModel task;
  const AddTask(this.task);
  @override
  List<Object?> get props => [task];
}

class UpdateTask extends PomodoroEvent {
  final TaskModel task;
  const UpdateTask(this.task);
  @override
  List<Object?> get props => [task];
}

class DeleteTask extends PomodoroEvent {
  final String taskId;
  const DeleteTask(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class StartTimer extends PomodoroEvent {
  final String taskId;
  const StartTimer(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class PauseTimer extends PomodoroEvent {}

class ResumeTimer extends PomodoroEvent {}

class StopTimer extends PomodoroEvent {}

class TickTimer extends PomodoroEvent {}

class CompletePomodoro extends PomodoroEvent {}

class ToggleTaskCompletion extends PomodoroEvent {}

class UpdateDuration extends PomodoroEvent {
  final int minutes;
  const UpdateDuration(this.minutes);
  @override
  List<Object?> get props => [minutes];
}
