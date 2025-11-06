import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:med_just/core/local/notes_helper.dart';

class NoteInputWidget extends StatefulWidget {
  final String videoId;
  final Duration? currentPosition; // Current video position
  final VoidCallback? onNoteSaved;

  const NoteInputWidget({
    Key? key,
    required this.videoId,
    this.currentPosition,
    this.onNoteSaved,
  }) : super(key: key);

  @override
  State<NoteInputWidget> createState() => _NoteInputWidgetState();
}

class _NoteInputWidgetState extends State<NoteInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _includeTimestamp = true;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveNote() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    String noteContent = value;

    // Add timestamp if enabled and position is available
    if (_includeTimestamp && widget.currentPosition != null) {
      final timestamp = _formatDuration(widget.currentPosition!);
      noteContent = '[$timestamp] $value';
    }

    await VideoNotesHelper.addNote(widget.videoId, noteContent);
    _controller.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _includeTimestamp && widget.currentPosition != null
                ? 'Note saved with timestamp'
                : 'Note saved',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (widget.onNoteSaved != null) widget.onNoteSaved!();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bodyFontSize = screenWidth * 0.015;
    final hasTimestamp = widget.currentPosition != null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with timestamp toggle
            Row(
              children: [
                Icon(
                  Icons.note_add,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Note',
                  style: TextStyle(
                    fontSize: bodyFontSize * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (hasTimestamp) ...[
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(widget.currentPosition!),
                    style: TextStyle(
                      fontSize: bodyFontSize,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Note input field
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText:
                    hasTimestamp
                        ? 'Write your observation at ${_formatDuration(widget.currentPosition!)}...'
                        : 'Add a note...',
                hintStyle: TextStyle(fontSize: bodyFontSize * 0.9),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: TextStyle(fontSize: bodyFontSize),
              onSubmitted: (_) => _saveNote(),
            ),
            const SizedBox(height: 12),

            // Actions row
            Row(
              children: [
                // Timestamp toggle
                if (hasTimestamp)
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: _includeTimestamp,
                          onChanged: (value) {
                            setState(() => _includeTimestamp = value ?? true);
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Expanded(
                          child: Text(
                            'Include timestamp',
                            style: TextStyle(fontSize: bodyFontSize * 0.9),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),

                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        _controller.clear();
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(fontSize: bodyFontSize),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.save, size: 18),
                      label: Text(
                        'Save Note',
                        style: TextStyle(fontSize: bodyFontSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
