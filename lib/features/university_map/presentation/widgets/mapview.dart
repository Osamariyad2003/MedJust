import 'package:flutter/material.dart';
import 'package:med_just/features/university_map/data/maps_model.dart';
import 'package:med_just/features/university_map/presentation/widgets/map_video_detail.dart';

class MapView extends StatelessWidget {
  final List<LocationModel> locations;
  final Function(String) onLocationSelected;

  const MapView({
    super.key,
    required this.locations,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const Center(child: Text('No locations available'));
    }

    // Calculate screen dimensions to fit exactly 6 cards
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

    // Choose layout based on orientation
    final crossAxisCount =
        isPortrait ? 2 : 3; // 2 columns portrait, 3 landscape
    final childAspectRatio = isPortrait ? 0.85 : 1.2; // Adjust card shape

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      appBar: AppBar(title: Text(location.name)),
                      body: MapVideoDetail(
                        location: location,
                        onBackPressed: () => Navigator.pop(context),
                      ),
                    ),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail with priority for video thumbnail
                if (location.videoUrl != null && location.videoUrl!.isNotEmpty)
                  _buildVideoThumbnail(location.videoUrl!)
                else if (location.imageUrl != null &&
                    location.imageUrl!.isNotEmpty)
                  Image.network(
                    location.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            _buildPlaceholderImage(context, location),
                  )
                else
                  _buildPlaceholderImage(context, location),

                // Video indicator (smaller and more subtle)
                if (location.videoUrl != null && location.videoUrl!.isNotEmpty)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),

                // Location name banner
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    color: Colors.black54,
                    child: Text(
                      location.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(String videoUrl) {
    // Extract YouTube video ID
    final youtubeId = _extractYoutubeId(videoUrl);

    if (youtubeId != null) {
      // Use YouTube thumbnail URL format
      final thumbnailUrl = 'https://img.youtube.com/vi/$youtubeId/0.jpg';
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.video_library, size: 36, color: Colors.grey),
              ),
            ),
      );
    } else {
      // Fallback for non-YouTube videos
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.video_file, size: 36, color: Colors.grey),
        ),
      );
    }
  }

  String? _extractYoutubeId(String url) {
    // Simple extraction for standard YouTube URLs
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Widget _buildPlaceholderImage(BuildContext context, LocationModel location) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.2),
      child: Center(
        child: Icon(
          _getIconForLocationType(location.type),
          size: 32,
          color: Theme.of(context).primaryColor,
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
}
