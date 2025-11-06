import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/features/resourses/data/resources_repository.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../bloc/resources_bloc.dart';
import '../widgets/error_display.dart';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const PdfViewerScreen({Key? key, required this.url, required this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => Navigator.pop(context, true),
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  url.startsWith('http') || url.startsWith('https')
                      ? SfPdfViewer.network(
                        url,
                        onDocumentLoadFailed: (details) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to load PDF: ${details.description}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      )
                      : const Center(
                        child: Text('Cannot display local PDF files'),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
