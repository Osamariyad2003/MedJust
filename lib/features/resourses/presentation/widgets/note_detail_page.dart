// Add this new page to your project:

import 'package:flutter/material.dart';

class NoteDetailPage extends StatefulWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const NoteDetailPage({
    Key? key,
    required this.initialText,
    required this.onSave,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              minLines: 6,
              maxLines: 12,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit your note...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSave(_controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
