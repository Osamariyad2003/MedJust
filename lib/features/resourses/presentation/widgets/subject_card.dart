import 'package:flutter/material.dart';
import '../../../../core/models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({Key? key, required this.subject, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 140, // Increased height from 100 to 140
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.book,
                    size:
                        48, // Optionally increase icon size for better proportion
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subject.name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // if (subject.resourcesCount != null && subject.resourcesCount! > 0)
              //   Text(
              //     '${subject.resourcesCount} Resources',
              //     style: Theme.of(context).textTheme.bodySmall,
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
