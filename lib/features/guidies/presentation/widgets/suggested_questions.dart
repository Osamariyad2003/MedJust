// lib/features/guidies/presentation/widgets/suggested_questions.dart
import 'package:flutter/material.dart';

class SuggestedQuestions extends StatelessWidget {
  final List<String> questions;
  final Function(String) onQuestionTap;

  const SuggestedQuestions({
    super.key,
    required this.questions,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'أسئلة مقترحة:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              textDirection: TextDirection.rtl,
              children:
                  questions.map((question) {
                    return ActionChip(
                      label: Text(
                        question,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      onPressed: () => onQuestionTap(question),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
