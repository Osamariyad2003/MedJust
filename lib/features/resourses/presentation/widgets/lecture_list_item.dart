import 'package:flutter/material.dart';
import '../../../../core/models/lecture_model.dart';

class LectureListItem extends StatelessWidget {
  final Lecture lecture;
  final VoidCallback onTap;

  const LectureListItem({Key? key, required this.lecture, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.14; // Match YearCard image size

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    (lecture.imageUrl != null && lecture.imageUrl!.isNotEmpty)
                        ? Image.network(
                          lecture.imageUrl!,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: imageSize,
                                height: imageSize,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                ),
                              ),
                        )
                        : Container(
                          width: imageSize,
                          height: imageSize,
                          color: accentColor.withOpacity(0.15),
                          child: Icon(
                            Icons.menu_book,
                            color: accentColor,
                            size: 32,
                          ),
                        ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lecture.description != null &&
                        lecture.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        lecture.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Created: ${_formatDate(lecture.createdAt as DateTime)}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
