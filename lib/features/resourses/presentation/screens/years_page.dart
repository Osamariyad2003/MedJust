import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_event.dart';
import 'package:med_just/features/resourses/presentation/bloc/resources_state.dart';
import '../../../../core/shared/themes/app_colors.dart';
import '../../../../core/shared/widgets/loading_indicator.dart';

import '../../../../core/models/year_model.dart';
import '../../../../core/models/subject_model.dart';
import '../widgets/year_card.dart';
import '../widgets/subject_card.dart';
import 'subject_resources_screen.dart';
import '../bloc/resources_bloc.dart'; // Import ResourcesBloc
import '../../../../features/resourses/data/resources_repository.dart';

class YearsPage extends StatefulWidget {
  const YearsPage({Key? key}) : super(key: key);

  @override
  State<YearsPage> createState() => _YearsPageState();
}

class _YearsPageState extends State<YearsPage> {
  String? selectedYearId;
  String? selectedYearName;
  String? selectedYearImageUrl;

  List<Year> years = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchYears();
  }

  Future<void> _fetchYears() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final repo = ResourcesRepository();
      final fetchedYears = await repo.getYears();
      fetchedYears.map((year) => print(year.imageUrl)).toList();
      setState(() {
        years = fetchedYears;
        isLoading = false;
      });
      print(years.map((year) => year.imageUrl).toList());
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load years';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final headlineFontSize = (screenWidth * 0.025).clamp(18.0, 32.0);
    final iconSize = screenWidth * 0.02;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child:
              selectedYearId == null
                  ? _buildYearsList(screenWidth, iconSize)
                  : _buildSubjectsList(screenWidth, iconSize),
        ),
      ),
    );
  }

  Widget _buildYearsList(double screenWidth, double iconSize) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return _buildErrorView(context, errorMessage!);
    }
    if (years.isEmpty) {
      return _buildEmptyState(
        context,
        'No academic years found',
        'Years will be displayed here once available.',
        iconSize,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        return YearCard(
          year: year,
          onTap: () {
            setState(() {
              selectedYearId = year.id;
              selectedYearName = year.name;
              selectedYearImageUrl = year.imageUrl;
            });
            // You can fetch subjects here if needed
          },
        );
      },
    );
  }

  Widget _buildSubjectsList(double screenWidth, double iconSize) {
    return BlocBuilder<ResourcesBloc, ResourcesState>(
      builder: (context, state) {
        print('Current state: $state, selectedYearId: $selectedYearId');

        if (state is ResourcesInitial ||
            (state is YearsLoaded && selectedYearId != null)) {
          print('Loading subjects for year: $selectedYearId');
          context.read<ResourcesBloc>().add(
            LoadSubjectsByYear(selectedYearId!),
          );
          return const LoadingIndicator();
        } else if (state is ResourcesLoading) {
          return const LoadingIndicator();
        } else if (state is ResourcesError) {
          print('Error loading subjects: ${state.message}');
          return _buildErrorView(context, state.message);
        } else if (state is SubjectsLoaded) {
          print('Subjects loaded: ${state.subjects.length}');
          if (state.subjects.isEmpty) {
            print('No subjects found for yearId: $selectedYearId');
          }
          return _buildSubjectsGrid(
            context,
            state.subjects,
            screenWidth,
            iconSize,
          );
        }
        print('Unhandled state: $state');
        return const Center(child: Text('No subjects found'));
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _fetchYears, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsGrid(
    BuildContext context,
    List<Subject> subjects,
    double screenWidth,
    double iconSize,
  ) {
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final childAspectRatio = screenWidth > 600 ? 1.1 : 0.8;
    if (subjects.isEmpty) {
      return _buildEmptyState(
        context,
        'No subjects found',
        'Subjects for this year will appear here once available.',
        iconSize,
      );
    } else {
      return GridView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: screenWidth * 0.04,
          mainAxisSpacing: screenWidth * 0.04,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return SubjectCard(
            subject: subject,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => SubjectResourcesScreen(
                        subjectId: subject.id,
                        subjectName: subject.name,
                      ),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String message,
    double iconSize,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(iconSize * 0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: iconSize,
              color: Colors.grey[400],
            ),
            SizedBox(height: iconSize * 0.3),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: iconSize * 0.15),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
