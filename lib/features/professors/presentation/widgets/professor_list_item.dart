import 'package:flutter/material.dart';
import '../../../../core/models/professor_model.dart';

class ProfessorCard extends StatelessWidget {
  final Professor professor;
  final VoidCallback onTap;

  const ProfessorCard({Key? key, required this.professor, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  image:
                      professor.imageUrl != null
                          ? DecorationImage(
                            image: NetworkImage(professor.imageUrl!),
                            fit: BoxFit.cover,
                          )
                          : null,
                  color: Colors.grey.shade200,
                ),
                child:
                    professor.imageUrl == null
                        ? Icon(Icons.person, size: 32, color: Colors.grey)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professor.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      professor.department ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
