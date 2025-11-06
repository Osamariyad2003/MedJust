import 'package:flutter/material.dart';
import '../../../../core/models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final VoidCallback? onFinish;

  const QuizScreen({Key? key, required this.quiz, this.onFinish})
    : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  List<int?> _selectedAnswers = [];
  int _score = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List<int?>.filled(widget.quiz.questions.length, null);
  }

  void _nextQuestion() {
    if (_currentQuestion < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_selectedAnswers[i] == widget.quiz.questions[i].correctAnswer) {
        score++;
      }
    }
    setState(() {
      _score = score;
      _finished = true;
    });
    if (widget.onFinish != null) widget.onFinish!();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_currentQuestion];
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child:
            _finished
                ? _buildResult(context)
                : _buildQuestion(context, question),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${_currentQuestion + 1} of ${widget.quiz.questions.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(question.question, style: Theme.of(context).textTheme.titleLarge),
        if (question.imageUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Image.network(question.imageUrl, height: 120),
          ),
        const SizedBox(height: 24),
        ...List.generate(question.options.length, (index) {
          return RadioListTile<int>(
            value: index,
            groupValue: _selectedAnswers[_currentQuestion],
            title: Text(question.options[index]),
            onChanged: (value) {
              setState(() {
                _selectedAnswers[_currentQuestion] = value;
              });
            },
          );
        }),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _selectedAnswers[_currentQuestion] != null
                    ? _nextQuestion
                    : null,
            child: Text(
              _currentQuestion < widget.quiz.questions.length - 1
                  ? 'Next'
                  : 'Finish',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = widget.quiz.questions.length;
    final percent = (_score / total * 100).toStringAsFixed(1);
    final passed = _score >= (widget.quiz.passRate / 100 * total);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Quiz Finished!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Score: $_score / $total',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'Percentage: $percent%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            passed ? 'You Passed!' : 'You Did Not Pass',
            style: TextStyle(
              color: passed ? Colors.green : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
