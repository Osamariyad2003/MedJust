import 'package:flutter/material.dart';
import 'package:med_just/features/university_map/data/maps_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapVideoDetail extends StatefulWidget {
  final LocationModel location;
  final VoidCallback onBackPressed;

  const MapVideoDetail({
    super.key,
    required this.location,
    required this.onBackPressed,
  });

  @override
  State<MapVideoDetail> createState() => _MapVideoDetailState();
}

class _MapVideoDetailState extends State<MapVideoDetail> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initializeYoutubePlayer();
  }

  @override
  void didUpdateWidget(MapVideoDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location.id != oldWidget.location.id) {
      _initializeYoutubePlayer();
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initializeYoutubePlayer() {
    if (widget.location.videoUrl != null &&
        widget.location.videoUrl!.isNotEmpty) {
      final videoId = _extractYoutubeId(widget.location.videoUrl!);
      if (videoId != null) {
        _youtubeController?.dispose();
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final verticalPadding = screenHeight * 0.02;
    final isYoutubeVideo = _youtubeController != null;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title at the top
            Text(
              widget.location.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: verticalPadding),

            // Video player centered
            if (isYoutubeVideo)
              Container(
                width: screenWidth * 0.9,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                ),
              )
            else if (widget.location.videoUrl != null &&
                widget.location.videoUrl!.isNotEmpty)
              Container(
                width: screenWidth * 0.9,
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.video_library, size: 48),
                      const SizedBox(height: 16),
                      const Text('External Video'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _launchUrl(widget.location.videoUrl!),
                        child: const Text('Open Video'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: screenWidth * 0.9,
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForLocationType(widget.location.type),
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('No video available for this location'),
                    ],
                  ),
                ),
              ),

            SizedBox(height: verticalPadding * 2),

            // Type and location info
            Text(
              '${widget.location.type} • ${widget.location.location}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: verticalPadding * 2),

            // Back button at the bottom
            ElevatedButton.icon(
              onPressed: () {
                _youtubeController?.pause();
                widget.onBackPressed();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Map'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLocationType(String type) {
    switch (type.toLowerCase()) {
      case 'قاعات امتحانية':
        return Icons.event_seat;
      case 'مختبرات':
        return Icons.science;
      case 'مكاتب':
        return Icons.business;
      case 'كافتيريات':
        return Icons.restaurant;
      default:
        return Icons.location_on;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }
}
