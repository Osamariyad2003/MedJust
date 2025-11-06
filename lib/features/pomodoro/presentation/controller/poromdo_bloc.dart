import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/features/pomodoro/data/task_model.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_event.dart';
import 'package:med_just/features/pomodoro/presentation/controller/poromdo_state.dart';

import '../../data/pomodoro_repository.dart';

class PomodoroBloc extends Bloc<PomodoroEvent, PomodoroState> {
  final PomodoroRepository _repository;
  Timer? _timer;

  PomodoroBloc({PomodoroRepository? repository})
    : _repository = repository ?? PomodoroRepository(),
      super(PomodoroInitial()) {
    on<LoadPomodoro>(_onLoad);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<StopTimer>(_onStopTimer);
    on<TickTimer>(_onTick);
    on<CompletePomodoro>(_onComplete);
    on<UpdateDuration>(_onUpdateDuration);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadPomodoro event, Emitter<PomodoroState> emit) async {
    emit(PomodoroLoading());
    try {
      final tasks = await _repository.getTasks();
      final duration = await _repository.getPomodoroDuration();
      emit(PomodoroLoaded(tasks: tasks, pomodoroDuration: duration));
    } catch (e) {
      emit(PomodoroError('Failed to load: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<PomodoroState> emit) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    try {
      await _repository.addTask(event.task);
      final tasks = await _repository.getTasks();
      emit(currentState.copyWith(tasks: tasks));
    } catch (e) {
      emit(PomodoroError('Failed to add task: $e'));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    try {
      await _repository.updateTask(event.task);
      final tasks = await _repository.getTasks();
      emit(currentState.copyWith(tasks: tasks));
    } catch (e) {
      emit(PomodoroError('Failed to update task: $e'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    try {
      await _repository.deleteTask(event.taskId);
      final tasks = await _repository.getTasks();
      emit(
        currentState.copyWith(
          tasks: tasks,
          clearActiveTask: currentState.activeTask?.id == event.taskId,
        ),
      );
    } catch (e) {
      emit(PomodoroError('Failed to delete task: $e'));
    }
  }

  Future<void> _onStartTimer(
    StartTimer event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    final task = currentState.tasks.firstWhere((t) => t.id == event.taskId);
    final duration = currentState.pomodoroDuration * 60;

    final updatedTask = task.copyWith(status: TaskStatus.inProgress);
    await _repository.updateTask(updatedTask);
    final tasks = await _repository.getTasks();

    emit(
      currentState.copyWith(
        tasks: tasks,
        timerStatus: TimerStatus.running,
        remainingSeconds: duration,
        totalSeconds: duration,
        activeTask: updatedTask,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(TickTimer());
    });
  }

  Future<void> _onPauseTimer(
    PauseTimer event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    _timer?.cancel();
    emit(currentState.copyWith(timerStatus: TimerStatus.paused));
  }

  Future<void> _onResumeTimer(
    ResumeTimer event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    emit(currentState.copyWith(timerStatus: TimerStatus.running));
    _startTimer();
  }

  Future<void> _onStopTimer(
    StopTimer event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    _timer?.cancel();

    if (currentState.activeTask != null) {
      final updatedTask = currentState.activeTask!.copyWith(
        status: TaskStatus.pending,
      );
      await _repository.updateTask(updatedTask);
      final tasks = await _repository.getTasks();

      emit(
        currentState.copyWith(
          tasks: tasks,
          timerStatus: TimerStatus.idle,
          clearActiveTask: true,
        ),
      );
    }
  }

  Future<void> _onTick(TickTimer event, Emitter<PomodoroState> emit) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    if (currentState.timerStatus != TimerStatus.running) return;

    if (currentState.remainingSeconds > 0) {
      emit(
        currentState.copyWith(
          remainingSeconds: currentState.remainingSeconds - 1,
        ),
      );
    } else {
      add(CompletePomodoro());
    }
  }

  Future<void> _onComplete(
    CompletePomodoro event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    _timer?.cancel();

    if (currentState.activeTask != null) {
      final updatedTask = currentState.activeTask!.copyWith(
        pomodorosCompleted: currentState.activeTask!.pomodorosCompleted + 1,
        totalMinutesSpent:
            currentState.activeTask!.totalMinutesSpent +
            currentState.pomodoroDuration,
        status: TaskStatus.pending,
      );

      await _repository.updateTask(updatedTask);
      final tasks = await _repository.getTasks();

      emit(
        currentState.copyWith(
          tasks: tasks,
          timerStatus: TimerStatus.idle,
          clearActiveTask: true,
        ),
      );
    }
  }

  Future<void> _onUpdateDuration(
    UpdateDuration event,
    Emitter<PomodoroState> emit,
  ) async {
    if (state is! PomodoroLoaded) return;
    final currentState = state as PomodoroLoaded;

    await _repository.setPomodoroDuration(event.minutes);
    emit(currentState.copyWith(pomodoroDuration: event.minutes));
  }
}
