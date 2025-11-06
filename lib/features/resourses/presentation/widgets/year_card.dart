import 'package:flutter/material.dart';
import 'package:med_just/core/shared/themes/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/year_model.dart';

class YearCard extends StatelessWidget {
  final Year year;
  final VoidCallback onTap;

  const YearCard({Key? key, required this.year, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = (screenWidth * 0.28).clamp(220.0, 420.0);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(context, imageHeight),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    year.batch_name != null && year.batch_name.isNotEmpty
                        ? year.batch_name
                        : year.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _showYearInfoDialog(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Check if there's any information to display
        final hasAcademicSupervisor =
            year.academicSupervisor != null &&
            year.academicSupervisor!.isNotEmpty;
        final hasActor = year.actor != null && year.actor!.isNotEmpty;
        final hasGroupUrl = year.groupurl != null && year.groupurl!.isNotEmpty;
        final hasAnyInfo = hasAcademicSupervisor || hasActor || hasGroupUrl;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.school,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (year.batch_name != null && year.batch_name.isNotEmpty)
                      ? year.batch_name
                      : year.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hasAnyInfo)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No additional information available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                if (hasAcademicSupervisor)
                  _buildInfoRow(
                    Icons.person_outline,
                    'Academic Guide (مرشد اكاديمي)',
                    year.academicSupervisor!,
                    Theme.of(context).primaryColor,
                  ),

                if (hasActor)
                  _buildInfoRow(
                    Icons.person,
                    'CR (ممثل الدفعة)',
                    year.actor!,
                    Colors.orange,
                  ),

                if (hasGroupUrl)
                  _buildClickableInfoRow(
                    context,
                    Icons.group_outlined,
                    'CR Group Link (قروب الدفعة)',
                    'Join Group',
                    year.groupurl!,
                    Colors.green,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasGroupUrl)
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchURL(year.groupurl ?? "");
                },
                child: const Text('Join Group'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String buttonText,
    String url,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _launchURL(url),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(buttonText),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: avoid_print
      print('Could not launch $url');
    }
  }

  Widget _buildImage(BuildContext context, double height) {
    final raw = (year.imageUrl ?? '').trim();

    if (raw.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        child: Center(
          child: Icon(
            Icons.school,
            color: Theme.of(context).colorScheme.primary,
            size: 72,
          ),
        ),
      );
    }

    final url = _normalizeDriveUrl(raw);

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.black54,
            ),
          ),
        );
      },
    );
  }

  String _normalizeDriveUrl(String raw) {
    final r = raw.trim();

    if (r.startsWith('http')) {
      final driveViewMatch = RegExp(
        r'drive\.google\.com/(file/d/|open\?id=|uc\?id=)([^/?&]+)',
        caseSensitive: false,
      ).firstMatch(r);
      if (driveViewMatch != null) {
        final id = driveViewMatch.group(2);
        return 'https://drive.google.com/uc?export=view&id=$id';
      }
      return r;
    }

    final driveIdMatch =
        RegExp(r'/d/([^/]+)').firstMatch(r) ??
        RegExp(r'id=([^&]+)').firstMatch(r);
    if (driveIdMatch != null) {
      final id = driveIdMatch.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    }

    return r;
  }
}
