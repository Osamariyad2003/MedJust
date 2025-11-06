import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FileWebViewScreen extends StatelessWidget {
  final String url;
  final String title;

  const FileWebViewScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url)),
      ),
    );
  }
}