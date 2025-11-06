class Quiz {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final int timeLimit;
  final DateTime createdAt;
  final double passRate;
  final String blink;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimit,
    required this.createdAt,
    required this.passRate,
    required this.blink,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],

      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
      timeLimit: json['timeLimit'],
      createdAt: DateTime.parse(json['createdAt']),
      passRate: json['passRate'] ?? 70,
      blink: json['blink'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'createdAt': createdAt.toIso8601String(),
      'passRate': passRate,
      'blink': blink,
    };
  }
}

class Question {
  final String id;
  final String text;
  final String imageUrl;
  final String question;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    required this.question,
    required this.imageUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      question: json['question'],
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'question': question,
      'imageUrl': imageUrl,
    };
  }
}
