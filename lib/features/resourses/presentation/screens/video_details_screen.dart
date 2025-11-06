import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/models/notes_model.dart';
import 'package:med_just/features/resourses/data/resources_repository.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';
import 'package:med_just/features/resourses/presentation/widgets/notes_input_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:med_just/core/local/notes_helper.dart';

import '../bloc/resources_bloc.dart';
import '../widgets/error_display.dart';

class VideoDetailsScreen extends StatefulWidget {
  final String videoId;

  const VideoDetailsScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoDetailsScreen> createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final headlineFontSize = screenWidth * 0.025;
    final bodyFontSize = screenWidth * 0.045;

    return BlocProvider(
      create: (context) =>
          ResourcesBloc(repository: di.get<ResourcesRepository>())
            ..add(LoadVideoById(widget.videoId)),
      child: BlocConsumer<ResourcesBloc, ResourcesState>(
        listener: (context, state) {
          if (state is SingleVideoLoaded) {
            _initializeYoutubePlayer(state.video.url);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is SingleVideoLoaded
                    ? state.video.title
                    : 'Video Details',
                style: TextStyle(fontSize: headlineFontSize),
              ),
            ),
            body: _buildBody(
              context,
              state,
              screenWidth,
              verticalPadding,
              bodyFontSize,
            ),
          );
        },
      ),
    );
  }

  void _initializeYoutubePlayer(String url) {
    final youtubeId = _extractYoutubeId(url);
    if (youtubeId != null) {
      setState(() {
        _youtubeController = YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
          ),
        );
      });
    }
  }

  String? _extractYoutubeId(String url) {
    try {
      return YoutubePlayer.convertUrlToId(url);
    } catch (e) {
      print('Error extracting YouTube ID: $e');
      return null;
    }
  }

  Widget _buildBody(
    BuildContext context,
    ResourcesState state,
    double screenWidth,
    double verticalPadding,
    double bodyFontSize,
  ) {
    if (state is ResourcesLoading) {
      return const Center(child: LoadingIndicator());
    } else if (state is SingleVideoLoaded) {
      final video = state.video;
      final isYoutubeVideo = _youtubeController != null;

      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video player
              if (isYoutubeVideo)
                YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                )
              else
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.5,
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library, size: screenWidth * 0.12),
                        SizedBox(height: verticalPadding),
                        Text(
                          'External Video',
                          style: TextStyle(fontSize: bodyFontSize),
                        ),
                        SizedBox(height: verticalPadding),
                        ElevatedButton(
                          onPressed: () => _launchUrl(video.url),
                          child: Text(
                            'Open Video',
                            style: TextStyle(fontSize: bodyFontSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Video details
              SizedBox(height: verticalPadding),
              Text(
                video.title,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 23),
              ),
              SizedBox(height: verticalPadding / 2),
              if (video.description != null &&
                  video.description!.isNotEmpty) ...[
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: bodyFontSize,
                  ),
                ),
                SizedBox(height: verticalPadding / 2),
                Text(
                  video.description!,
                  style: TextStyle(fontSize: bodyFontSize),
                ),
              ],
              SizedBox(height: verticalPadding),

              SizedBox(height: verticalPadding * 2),
              Text(
                'Your Notes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: bodyFontSize,
                ),
              ),
              SizedBox(height: verticalPadding),

              // Make the input field bigger and notes appear under it
              NoteInputWidget(
                videoId: widget.videoId,
                onNoteSaved: () => setState(() {}),
              ),
              SizedBox(height: verticalPadding),

              FutureBuilder<List<VideoNote>>(
                future: VideoNotesHelper.getNotes(widget.videoId),
                builder: (context, snapshot) {
                  final notes = snapshot.data ?? [];
                  if (notes.isEmpty) {
                    return const Text('No notes yet.');
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < notes.length; i++)
                        Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.97),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notes[i].content,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit',
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NoteDetailPage(
                                              initialText: notes[i].content,
                                              onSave: (newText) async {
                                                await VideoNotesHelper.updateNote(
                                                    widget.videoId, i, newText);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        await VideoNotesHelper.deleteNote(
                                          widget.videoId,
                                          i,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Added: ${notes[i].createdAt.toLocal().toString().substring(0, 16)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else if (state is ResourcesError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          context.read<ResourcesBloc>()..add(LoadVideoById(widget.videoId));
        },
      );
    }

    return const Center(child: LoadingIndicator());
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }
}

class NoteDetailPage extends StatelessWidget {
  final String initialText;
  final ValueChanged<String> onSave;

  const NoteDetailPage({
    Key? key,
    required this.initialText,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: initialText);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          TextButton(
            onPressed: () {
              onSave(_controller.text);
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Edit your note...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
