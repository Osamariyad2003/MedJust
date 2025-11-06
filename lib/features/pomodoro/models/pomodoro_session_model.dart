class PomodoroSessionModel {
  final int duration; // Duration of the Pomodoro session in seconds
  final bool isActive; // Indicates if the session is currently active
  final DateTime startTime; // Start time of the session
  final DateTime? endTime; // End time of the session, if completed

  PomodoroSessionModel({
    required this.duration,
    required this.isActive,
    required this.startTime,
    this.endTime,
  });

  // Method to calculate remaining time
  int get remainingTime {
    if (!isActive) return 0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (duration - elapsed).clamp(0, duration).toInt();
  }

  // Method to create a copy of the session with updated values
  PomodoroSessionModel copyWith({
    int? duration,
    bool? isActive,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return PomodoroSessionModel(
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  // Serialize to JSON
  Map<String, dynamic> toJson() => {
    'duration': duration,
    'isActive': isActive,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };

  // Deserialize from JSON
  factory PomodoroSessionModel.fromJson(Map<String, dynamic> json) {
    return PomodoroSessionModel(
      duration: json['duration'] as int,
      isActive: json['isActive'] as bool,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime:
          json['endTime'] == null
              ? null
              : DateTime.parse(json['endTime'] as String),
    );
  }
}
