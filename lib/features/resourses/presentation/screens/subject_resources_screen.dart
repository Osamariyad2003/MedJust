import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/features/resourses/data/resources_repository.dart';
import 'package:med_just/features/resourses/data/year_data_source.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';

import '../bloc/resources_bloc.dart';
import '../widgets/error_display.dart';
import '../widgets/lecture_list_item.dart';
import '../widgets/resources_summary_card.dart';
import 'lecture_details_screen.dart';

class SubjectResourcesScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const SubjectResourcesScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final headlineFontSize = screenWidth * 0.025;
    final buttonFontSize = screenWidth * 0.045;

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName, style: TextStyle(fontSize: headlineFontSize)),
      ),
      body: BlocProvider(
        create:
            (context) =>
                ResourcesBloc(repository: di.get<ResourcesRepository>())
                  ..add(LoadLecturesBySubject(subjectId)),
        child: BlocListener<ResourcesBloc, ResourcesState>(
          listener: (context, state) {
            if (state is ResourcesError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<ResourcesBloc, ResourcesState>(
            builder: (context, state) {
              if (state is ResourcesLoading) {
                return const LoadingIndicator();
              } else if (state is SubjectResourcesSummaryLoaded) {
                final recentLectures =
                    state.summary['recentLectures'] as List<dynamic>;
                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResourcesSummaryCard(
                          totalLectures: state.summary['totalLectures'],
                          totalFiles: state.summary['totalFiles'],
                          totalVideos: state.summary['totalVideos'],
                          lecturesCount: null,
                          filesCount: null,
                          videosCount: null,
                        ),
                        SizedBox(height: verticalPadding),
                        Text(
                          'Recent Lectures',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontSize: headlineFontSize),
                        ),
                        SizedBox(height: verticalPadding / 2),
                        if (recentLectures.isEmpty)
                          Center(
                            child: Text(
                              'No lectures available for this subject',
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recentLectures.length,
                            separatorBuilder:
                                (context, index) =>
                                    Divider(height: verticalPadding / 2),
                            itemBuilder: (context, index) {
                              final lecture = recentLectures[index];
                              return LectureListItem(
                                lecture: lecture,
                                onTap: () {
                                  context.read<ResourcesBloc>().add(
                                    LoadLectureById(lecture.id),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => LectureDetailsScreen(
                                            lectureId: lecture.id,
                                            subjectName: subjectName,
                                          ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        SizedBox(height: verticalPadding),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<ResourcesBloc>()
                                ..add(LoadLecturesBySubject(subjectId));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                double.infinity,
                                screenHeight * 0.07,
                              ),
                            ),
                            child: Text(
                              'View All Lectures',
                              style: TextStyle(fontSize: buttonFontSize),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is LecturesLoaded) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              context.read<ResourcesBloc>()
                                ..add(LoadSubjectResourcesSummary(subjectId));
                            },
                          ),
                          Text(
                            'All Lectures',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontSize: headlineFontSize),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalPadding / 2),
                      Expanded(
                        child:
                            state.lectures.isEmpty
                                ? Center(
                                  child: Text(
                                    'No lectures available for this subject',
                                    style: TextStyle(fontSize: buttonFontSize),
                                  ),
                                )
                                : ListView.separated(
                                  itemCount: state.lectures.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          Divider(height: verticalPadding / 2),
                                  itemBuilder: (context, index) {
                                    final lecture = state.lectures[index];
                                    return LectureListItem(
                                      lecture: lecture,
                                      onTap: () {
                                        context.read<ResourcesBloc>().add(
                                          LoadLectureById(lecture.id),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => LectureDetailsScreen(
                                                  lectureId: lecture.id,
                                                  subjectName: subjectName,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                );
              } else if (state is ResourcesError) {
                return ErrorDisplay(
                  message: state.message,
                  onRetry: () {
                    context.read<ResourcesBloc>()
                      ..add(LoadSubjectResourcesSummary(subjectId));
                  },
                );
              }
              return const LoadingIndicator();
            },
          ),
        ),
      ),
    );
  }
}
