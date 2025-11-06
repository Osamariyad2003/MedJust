class PomodoroSettingsModel {
  final int workDuration; // in minutes
  final int shortBreakDuration; // in minutes
  final int longBreakDuration; // in minutes
  final int longBreakInterval; // after how many sessions to take a long break

  const PomodoroSettingsModel({
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.longBreakInterval,
  });

  PomodoroSettingsModel copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? longBreakInterval,
  }) {
    return PomodoroSettingsModel(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
    );
  }

  factory PomodoroSettingsModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return PomodoroSettingsModel(
      workDuration: _toInt(json['workDuration']),
      shortBreakDuration: _toInt(json['shortBreakDuration']),
      longBreakDuration: _toInt(json['longBreakDuration']),
      longBreakInterval: _toInt(json['longBreakInterval']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'longBreakInterval': longBreakInterval,
    };
  }
}
