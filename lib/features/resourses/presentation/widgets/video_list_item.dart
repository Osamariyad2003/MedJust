import 'package:flutter/material.dart';
import '../../../../core/models/video_model.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoCard({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail with play overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        video.thumbnailUrl != null &&
                                video.thumbnailUrl!.isNotEmpty
                            ? Image.network(
                              video.thumbnailUrl!,
                              width: 100,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      _buildPlaceholder(cs),
                            )
                            : _buildPlaceholder(cs),
                  ),

                  // Play button overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // Duration indicator (if available)
                  if (video.duration != null)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(video.duration.inHours!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Video details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    if (video.description != null &&
                        video.description!.isNotEmpty)
                      Text(
                        video.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // Additional metadata row
                    Row(
                      children: [
                        // Video source/platform indicator if available
                        if (_getVideoSource(video.url) != null) ...[
                          Icon(
                            _getVideoSourceIcon(video.url),
                            size: 14,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getVideoSource(video.url) ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Date if available
                        if (video.uploadedAt != null) ...[
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: cs.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(video.uploadedAt!),
                            style: TextStyle(fontSize: 12, color: cs.outline),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron or custom action
              Icon(Icons.chevron_right_rounded, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme cs) {
    return Container(
      width: 100,
      height: 70,
      color: cs.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.video_library_rounded,
          color: cs.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String? _getVideoSource(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'YouTube';
    } else if (url.contains('vimeo.com')) {
      return 'Vimeo';
    }
    return null;
  }

  IconData _getVideoSourceIcon(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return Icons.play_circle_filled;
    } else if (url.contains('vimeo.com')) {
      return Icons.videocam;
    }
    return Icons.video_library;
  }
}
