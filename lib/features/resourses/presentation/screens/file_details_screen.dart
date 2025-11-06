import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';
import 'package:med_just/features/resourses/presentation/widgets/pdf_viewer_screen.dart';
import 'package:med_just/features/resourses/presentation/widgets/file_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/features/resourses/data/resources_repository.dart';
import '../bloc/resources_bloc.dart';
import '../widgets/error_display.dart';

class FileDetailsScreen extends StatelessWidget {
  final String fileId;

  const FileDetailsScreen({Key? key, required this.fileId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ResourcesBloc(repository: di<ResourcesRepository>())
                ..add(LoadFileById(fileId)),
      child: BlocConsumer<ResourcesBloc, ResourcesState>(
        listener: (context, state) {
          if (state is ResourcesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is SingleFileLoaded ? state.file.name : 'File Details',
              ),
              actions: [
                if (state is SingleFileLoaded)
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () => _openFile(context, state.file.url),
                    tooltip: 'Open in browser',
                  ),
              ],
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ResourcesState state) {
    if (state is ResourcesLoading) {
      return const Center(child: LoadingIndicator());
    } else if (state is SingleFileLoaded) {
      final file = state.file;

      // For Google Drive links or non-PDFs, we show file info instead
      if (file.url.contains('drive.google.com') || !_isPdf(file.type)) {
        return _buildFileDetailsView(context, file);
      }

      // For PDFs, show the detailed view with an option to view inline
      return _buildFileDetailsView(context, file);
    } else if (state is ResourcesError) {
      return Center(
        child: ErrorDisplay(
          message: state.message,
          onRetry: () {
            context.read<ResourcesBloc>()..add(LoadFileById(fileId));
          },
        ),
      );
    }

    return const Center(child: LoadingIndicator());
  }

  Widget _buildFileDetailsView(BuildContext context, dynamic file) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              _getFileTypeIcon(file.type),
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            file.name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(context, 'Type', _getFileTypeName(file.type)),
                  _buildInfoRow(context, 'Size', _formatFileSize(file.size)),
                  _buildInfoRow(
                    context,
                    'Uploaded',
                    _formatDate(file.uploadedAt),
                  ),
                  if (file.name.isNotEmpty)
                    _buildInfoRow(context, 'Description', file.name),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              String pdfUrl = file.url;
              if (pdfUrl.contains('drive.google.com')) {
                final directUrl = extractDrivePdfUrl(pdfUrl);
                if (directUrl != null) {
                  pdfUrl = directUrl;
                }
              }
              _openFile(context, pdfUrl);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            icon: Icon(Icons.picture_as_pdf),
            label: Text('View PDF'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _downloadFile(context, file.url),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  bool _isPdf(String fileType) {
    return fileType.toLowerCase() == 'pdf';
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileTypeName(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'ppt':
      case 'pptx':
        return 'PowerPoint Presentation';
      case 'xls':
      case 'xlsx':
        return 'Excel Spreadsheet';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'Image';
      default:
        return fileType.toUpperCase();
    }
  }

  String _formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openFile(
    BuildContext context,
    String url, {
    String? title,
  }) async {
    if (url.contains('drive.google.com')) {
      final directUrl = extractDrivePdfUrl(url);
      if (directUrl != null) url = directUrl;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FileWebViewScreen(url: url, title: title ?? 'File'),
      ),
    );
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // For Google Drive, modify the URL to force download if possible
        String downloadUrl = url;
        if (url.contains('drive.google.com/drive/folders')) {
          // Show message that folder downloads need to be done from Drive app
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Opening folder in Google Drive. Download files individually from there.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        } else if (url.contains('drive.google.com/file/d/')) {
          // Convert viewing URL to direct download URL
          final fileId = _extractDriveFileId(url);
          if (fileId != null) {
            downloadUrl =
                'https://drive.google.com/uc?export=download&id=$fileId';
          }
        }

        // Launch the URL - this was the bug, you were awaiting a string
        await launchUrl(
          Uri.parse(downloadUrl),
          mode: LaunchMode.externalApplication,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File opened successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error downloading file: ${e.toString().substring(0, min(e.toString().length, 50))}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openPdfInApp(BuildContext context, String url, String title) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(url: url, title: title),
      ),
    );

    // If result is true, user wants to open in external app
    if (result == true) {
      _openFile(context, url);
    }
  }

  String? _extractDriveFileId(String url) {
    // Handle URLs like https://drive.google.com/file/d/FILE_ID/view
    RegExp fileRegex = RegExp(r'drive\.google\.com/file/d/([^/]+)');
    Match? fileMatch = fileRegex.firstMatch(url);
    if (fileMatch != null && fileMatch.groupCount >= 1) {
      return fileMatch.group(1);
    }

    // Handle URLs like https://drive.google.com/open?id=FILE_ID
    RegExp idRegex = RegExp(r'id=([^&]+)');
    Match? idMatch = idRegex.firstMatch(url);
    if (idMatch != null && idMatch.groupCount >= 1) {
      return idMatch.group(1);
    }

    return null;
  }

  String? extractDrivePdfUrl(String url) {
    final fileIdRegExp = RegExp(r'drive\.google\.com/file/d/([^/]+)');
    final match = fileIdRegExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    return null;
  }
}
