import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/utils/user_utils.dart';
import 'package:med_just/core/utils/year_mapping.dart';
import 'package:med_just/features/news/data/news_repository.dart';
import 'package:med_just/features/news/presentation/screens/news_details.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../../data/news_model.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              NewsBloc(repository: di<NewsRepository>())..add(LoadAllNews()),
      child: Scaffold(
        body: BlocConsumer<NewsBloc, NewsState>(
          listener: (context, state) {
            if (state is NewsError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is NewsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NewsLoaded) {
              if (state.newsList.isEmpty) {
                return const Center(child: Text('No news available.'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  final newsBloc = context.read<NewsBloc>();
                  newsBloc.add(LoadAllNews());
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use grid for wide screens, list for narrow screens
                    if (constraints.maxWidth > 600) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 24,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: state.newsList.length,
                        itemBuilder: (context, index) {
                          final news = state.newsList[index];
                          return NewsCard(news: news);
                        },
                      );
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.newsList.length,
                        itemBuilder: (context, index) {
                          final news = state.newsList[index];
                          return NewsCard(news: news);
                        },
                      );
                    }
                  },
                ),
              );
            } else if (state is NewsError) {
              return const Center(child: Text('No news available.'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: isWide ? 8 : 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.3), width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(news: news),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(isWide ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (news.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          news.category!,
                          style: TextStyle(
                            fontSize: isWide ? 13 : 11,
                            fontWeight: FontWeight.w500,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                    SizedBox(height: isWide ? 12 : 8),
                    Text(
                      news.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isWide ? 20 : 17,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isWide ? 10 : 8),
                    Text(
                      news.summary ?? news.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: isWide ? 15 : 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isWide ? 16 : 12),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: isWide ? 16 : 14,
                          color: cs.outline,
                        ),
                        const SizedBox(width: 6),

                        SizedBox(width: isWide ? 16 : 12),
                        Icon(
                          Icons.calendar_today,
                          size: isWide ? 16 : 14,
                          color: cs.outline,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${news.publishedAt.day}/${news.publishedAt.month}/${news.publishedAt.year}",
                          style: TextStyle(
                            fontSize: isWide ? 13 : 12,
                            color: cs.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (news.imageUrl.isNotEmpty) ...[
                SizedBox(width: isWide ? 20 : 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: isWide ? 140 : 100,
                    height: isWide ? 140 : 100,
                    child: Image.network(
                      news.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: cs.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: cs.onSurfaceVariant,
                              size: isWide ? 40 : 30,
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
