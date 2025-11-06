import 'package:flutter/material.dart';

enum ResourceType { lecture, file, video, quiz, other }

class ResourcesSummaryCard extends StatelessWidget {
  final int? lecturesCount;
  final int? filesCount;
  final int? videosCount;
  final int? quizzesCount;
  final ResourceType currentResourceType;
  final VoidCallback? onLecturesTap;
  final VoidCallback? onFilesTap;
  final VoidCallback? onVideosTap;
  final VoidCallback? onQuizzesTap;

  const ResourcesSummaryCard({
    Key? key,
    this.lecturesCount,
    this.filesCount,
    this.videosCount,
    this.quizzesCount,
    this.currentResourceType = ResourceType.other,
    this.onLecturesTap,
    this.onFilesTap,
    this.onVideosTap,
    this.onQuizzesTap,
    required int totalLectures,
    required totalVideos,
    required totalFiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getHeaderText(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (lecturesCount != null ||
                    currentResourceType == ResourceType.lecture)
                  _buildCountItem(
                    context,
                    Icons.menu_book,
                    lecturesCount?.toString() ?? '0',
                    'Lectures',
                    Colors.blue,
                    currentResourceType == ResourceType.lecture,
                    onLecturesTap,
                  ),
                if (filesCount != null ||
                    currentResourceType == ResourceType.file)
                  _buildCountItem(
                    context,
                    Icons.insert_drive_file,
                    filesCount?.toString() ?? '0',
                    'Files',
                    Colors.green,
                    currentResourceType == ResourceType.file,
                    onFilesTap,
                  ),
                if (videosCount != null ||
                    currentResourceType == ResourceType.video)
                  _buildCountItem(
                    context,
                    Icons.video_library,
                    videosCount?.toString() ?? '0',
                    'Videos',
                    Colors.orange,
                    currentResourceType == ResourceType.video,
                    onVideosTap,
                  ),
                if (quizzesCount != null ||
                    currentResourceType == ResourceType.quiz)
                  _buildCountItem(
                    context,
                    Icons.quiz,
                    quizzesCount?.toString() ?? '0',
                    'Quizzes',
                    Colors.purple,
                    currentResourceType == ResourceType.quiz,
                    onQuizzesTap,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getHeaderText() {
    switch (currentResourceType) {
      case ResourceType.lecture:
        return 'Lecture Resources';
      case ResourceType.file:
        return 'Related Resources';
      case ResourceType.video:
        return 'Video Resources';
      case ResourceType.quiz:
        return 'Quiz Resources';
      case ResourceType.other:
      default:
        return 'Available Resources';
    }
  }

  Widget _buildCountItem(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    Color color,
    bool isActive,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  isActive
                      ? Border.all(color: color.withOpacity(0.7), width: 2)
                      : null,
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Icon(icon, color: isActive ? Colors.white : color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive ? color : null,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: isActive ? color : null),
          ),
        ],
      ),
    );
  }
}
