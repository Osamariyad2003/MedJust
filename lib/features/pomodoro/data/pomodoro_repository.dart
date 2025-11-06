import 'package:med_just/features/pomodoro/data/task_model.dart';

import 'pomodoro_data_source.dart';

class PomodoroRepository {
  final PomodoroDataSource _dataSource;

  PomodoroRepository({PomodoroDataSource? dataSource})
    : _dataSource = dataSource ?? PomodoroDataSource();

  Future<List<TaskModel>> getTasks() async {
    return await _dataSource.loadTasks();
  }

  Future<void> addTask(TaskModel task) async {
    final tasks = await getTasks();
    tasks.insert(0, task);
    await _dataSource.saveTasks(tasks);
  }

  Future<void> updateTask(TaskModel task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _dataSource.saveTasks(tasks);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _dataSource.saveTasks(tasks);
  }

  Future<int> getPomodoroDuration() async {
    return await _dataSource.getPomodoroDuration();
  }

  Future<void> setPomodoroDuration(int minutes) async {
    await _dataSource.setPomodoroDuration(minutes);
  }
}
