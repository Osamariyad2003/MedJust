import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/models/video_model.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/features/resourses/data/resources_repository.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';
import 'package:med_just/features/resourses/presentation/widgets/quiz_screen.dart';

import '../bloc/resources_bloc.dart';
import '../widgets/error_display.dart';
import '../widgets/file_list_item.dart';
import '../widgets/video_list_item.dart';
import 'file_details_screen.dart';
import 'video_details_screen.dart';

class LectureDetailsScreen extends StatefulWidget {
  final String lectureId;
  final String subjectName;

  const LectureDetailsScreen({
    Key? key,
    required this.lectureId,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<LectureDetailsScreen> createState() => _LectureDetailsScreenState();
}

class _LectureDetailsScreenState extends State<LectureDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final tabFontSize = screenWidth * 0.025;

    return SafeArea(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ResourcesBloc>(
            create:
                (context) =>
                    ResourcesBloc(repository: di<ResourcesRepository>())
                      ..add(LoadLectureById(widget.lectureId)),
          ),
        ],
        child: BlocConsumer<ResourcesBloc, ResourcesState>(
          listener: (context, state) {
            if (state is ResourcesError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  state is SingleLectureLoaded
                      ? state.lecture.title
                      : 'Lecture Details',
                  style: TextStyle(fontSize: tabFontSize + 2),
                ),
                bottom:
                    state is SingleLectureLoaded
                        ? TabBar(
                          controller: _tabController,

                          labelStyle: TextStyle(
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          tabs: const [
                            Tab(text: 'Files'),
                            Tab(text: 'Videos'),
                            Tab(text: 'Quizzes'),
                          ],
                        )
                        : null,
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: _buildBody(context, state, screenWidth, screenHeight),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ResourcesState state,
    double screenWidth,
    double screenHeight,
  ) {
    if (state is ResourcesLoading) {
      return const Center(child: LoadingIndicator());
    } else if (state is SingleLectureLoaded) {
      return TabBarView(
        controller: _tabController,
        children: [
          _buildFilesTab(context, state, screenWidth),
          _buildVideosTab(context, state, screenWidth),
          _buildQuizzesTab(context, state, screenWidth),
        ],
      );
    } else if (state is ResourcesError) {
      return Center(
        child: ErrorDisplay(
          message: state.message,
          onRetry: () {
            context.read<ResourcesBloc>().add(
              LoadLectureById(widget.lectureId),
            );
          },
        ),
      );
    }
    return const Center(child: LoadingIndicator());
  }

  Widget _buildFilesTab(
    BuildContext context,
    SingleLectureLoaded state,
    double screenWidth,
  ) {
    if (state.files.isEmpty) {
      return Center(
        child: Text(
          'No files available',
          style: TextStyle(fontSize: screenWidth * 0.045),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      itemCount: state.files.length,
      itemBuilder: (context, index) {
        final file = state.files[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
          child: FileCard(
            file: file,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileDetailsScreen(fileId: file.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideosTab(
    BuildContext context,
    SingleLectureLoaded state,
    double screenWidth,
  ) {
    if (state.videos.isEmpty) {
      return Center(
        child: Text(
          'No videos available',
          style: TextStyle(fontSize: screenWidth * 0.045),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      itemCount: state.videos.length,
      itemBuilder: (context, index) {
        final video = state.videos[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
          child: VideoCard(
            video: video,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoDetailsScreen(videoId: video.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuizzesTab(
    BuildContext context,
    SingleLectureLoaded state,
    double screenWidth,
  ) {
    if (state.quizzes == null || state.quizzes.isEmpty) {
      return Center(
        child: Text(
          'No quizzes available',
          style: TextStyle(fontSize: screenWidth * 0.045),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      itemCount: state.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = state.quizzes[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.quiz, size: screenWidth * 0.06),
              radius: screenWidth * 0.06,
            ),
            title: Text(
              'Quiz ${quiz.title}',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
            subtitle: Text('${quiz.timeLimit ?? 0} mins •'),
            trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.045),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)),
              );
              // Navigate to quiz screen
            },
          ),
        );
      },
    );
  }
}
