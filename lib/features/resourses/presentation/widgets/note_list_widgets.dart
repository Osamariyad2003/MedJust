import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_bloc.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';
import 'package:med_just/core/models/notes_model.dart';

class NotesListWidget extends StatefulWidget {
  final String videoId;
  final Function(Duration)? onTimestampTap; // Callback to seek video

  const NotesListWidget({Key? key, required this.videoId, this.onTimestampTap})
    : super(key: key);

  @override
  State<NotesListWidget> createState() => _NotesListWidgetState();
}

class _NotesListWidgetState extends State<NotesListWidget> {
  @override
  void initState() {
    super.initState();
    // load after first frame so context.read is safe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResourcesBloc>().add(LoadVideoNotes(widget.videoId));
    });
  }

  Future<void> _onDelete(String noteId) async {
    // Dispatch delete event handled by ResourcesBloc
    context.read<ResourcesBloc>().add(DeleteVideoNote(widget.videoId, noteId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResourcesBloc, ResourcesState>(
      builder: (context, state) {
        if (state is ResourcesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ResourcesError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is VideoNotesLoaded) {
          final notes = state.notes;
          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add notes while watching the video',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return _NoteCard(
                note: note,
                onDelete: () => _onDelete(note.id),
                onTimestampTap:
                    widget.onTimestampTap != null &&
                            note.timestampDuration != null
                        ? () => widget.onTimestampTap!(note.timestampDuration!)
                        : null,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final VideoNote note;
  final VoidCallback onDelete;
  final VoidCallback? onTimestampTap;

  const _NoteCard({
    required this.note,
    required this.onDelete,
    this.onTimestampTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (note.timestamp != null) ...[
                  InkWell(
                    onTap: onTimestampTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            note.timestamp!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          if (onTimestampTap != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.play_arrow,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(note.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Note'),
                            content: const Text(
                              'Are you sure you want to delete this note?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) onDelete();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.content, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
