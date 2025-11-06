import 'package:flutter/material.dart';
import '../../../../core/models/file_model.dart';

class FileCard extends StatelessWidget {
  final FileModel file;
  final VoidCallback onTap;
  final VoidCallback? onDownload;

  const FileCard({
    super.key,
    required this.file,
    required this.onTap,
    this.onDownload,
  });

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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // File type icon with container
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _getFileTypeColor(file.type).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getFileTypeIcon(file.type),
                    color: _getFileTypeColor(file.type),
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // File details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getFileTypeColor(
                              file.type,
                            ).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            file.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getFileTypeColor(file.type),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.straighten, size: 12, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          _formatFileSize(file.size),
                          style: TextStyle(fontSize: 12, color: cs.outline),
                        ),
                        if (file.uploadedAt != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: cs.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(file.uploadedAt!),
                            style: TextStyle(fontSize: 12, color: cs.outline),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Download button if provided
              if (onDownload != null)
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  tooltip: 'Download',
                  color: cs.primary,
                  onPressed: onDownload,
                )
              else
                Icon(Icons.chevron_right_rounded, color: cs.outline, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for better display
  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_rounded;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatFileSize(int kilobytes) {
    if (kilobytes < 1024) {
      return '$kilobytes KB';
    } else {
      final megabytes = (kilobytes / 1024).toStringAsFixed(1);
      return '$megabytes MB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
