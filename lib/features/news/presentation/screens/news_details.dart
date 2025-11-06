import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/news_model.dart';

class NewsDetailsScreen extends StatelessWidget {
  final News news;

  const NewsDetailsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.4; // 40% of screen height
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Content with image and scrolling text
          CustomScrollView(
            slivers: [
              // Image at top
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Hero image
                    SizedBox(
                      width: double.infinity,
                      height: imageHeight,
                      child:
                          news.imageUrl.isNotEmpty
                              ? Image.network(
                                news.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      color: cs.surfaceVariant,
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                              )
                              : Container(
                                color: cs.surfaceVariant,
                                child: Icon(
                                  Icons.newspaper,
                                  size: 80,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                    ),

                    // Gradient overlay for better text visibility
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Category pill on image
                    if (news.category != null)
                      Positioned(
                        top: 16 + MediaQuery.of(context).padding.top,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            news.category!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),

                    // Title on image
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Text(
                        news.title,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacing to avoid content being too close to the image
              SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Content details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date and time
                      Text(
                        _formatDateTime(news.publishedAt),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Divider
                      const Divider(),

                      // News content
                      Text(news.content, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }
}
