import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/models/professor_model.dart';
import 'package:med_just/features/professors/data/professor_repo.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_bloc.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_event.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_state.dart';
import 'package:med_just/features/professors/presentation/screens/professor_details_screen.dart';
import 'package:med_just/features/professors/presentation/widgets/professor_list_item.dart';
import 'package:med_just/features/resourses/presentation/widgets/error_display.dart';
import '../../../../core/shared/widgets/loading_indicator.dart';

class ProfessorsListScreen extends StatefulWidget {
  const ProfessorsListScreen({super.key});

  @override
  State<ProfessorsListScreen> createState() => _ProfessorsListScreenState();
}

class _ProfessorsListScreenState extends State<ProfessorsListScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> _departments = ['Loading...'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ProfessorsBloc(repository: di<ProfessorsRepository>())
                ..add(LoadAllProfessors()),
      child: BlocConsumer<ProfessorsBloc, ProfessorsState>(
        listener: (context, state) {
          if (state is AllProfessorsLoaded) {
            // Update departments and tab controller when data loads
            final departments = _getDepartments(state.professors);
            setState(() {
              _departments = departments;
              // Recreate the controller with the new length
              _tabController?.dispose();
              _tabController = TabController(
                length: departments.length,
                vsync: this,
              );
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Faculty Members'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child:
                    _tabController != null
                        ? TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabs:
                              _departments
                                  .map((dept) => Tab(text: dept))
                                  .toList(),
                          indicatorSize: TabBarIndicatorSize.tab,
                        )
                        : const SizedBox(),
              ),
            ),
            body:
                state is ProfessorsLoading
                    ? const Center(child: LoadingIndicator())
                    : state is AllProfessorsLoaded
                    ? _buildTabBarView(state.professors)
                    : state is ProfessorsError
                    ? ErrorDisplay(
                      message: state.message,
                      onRetry:
                          () => context.read<ProfessorsBloc>().add(
                            LoadAllProfessors(),
                          ),
                    )
                    : const Center(
                      child: Text('Select a department to view professors'),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildTabBarView(List<Professor> professors) {
    // Group professors by department
    final departmentGroups = _groupProfessorsByDepartment(professors);

    // Only build TabBarView if controller exists and has correct length
    if (_tabController == null ||
        _tabController!.length != _departments.length) {
      return const Center(child: Text('Loading departments...'));
    }

    return TabBarView(
      controller: _tabController,
      children:
          _departments.map((department) {
            final departmentProfessors = departmentGroups[department] ?? [];
            return _buildDepartmentProfessorsList(
              context,
              departmentProfessors,
            );
          }).toList(),
    );
  }

  List<String> _getDepartments(List<Professor> professors) {
    final departments = professors.map((p) => p.department).toSet().toList();
    departments.sort(); // Sort alphabetically
    return departments;
  }

  Map<String, List<Professor>> _groupProfessorsByDepartment(
    List<Professor> professors,
  ) {
    final Map<String, List<Professor>> departmentGroups = {};

    for (var professor in professors) {
      if (!departmentGroups.containsKey(professor.department)) {
        departmentGroups[professor.department] = [];
      }
      departmentGroups[professor.department]!.add(professor);
    }

    return departmentGroups;
  }

  Widget _buildDepartmentProfessorsList(
    BuildContext context,
    List<Professor> professors,
  ) {
    if (professors.isEmpty) {
      return const Center(child: Text('No professors found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: professors.length,
      itemBuilder: (context, index) {
        final professor = professors[index];
        return ProfessorCard(
          professor: professor,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProfessorDetailsScreen(professorId: professor.id),
                ),
              ),
        );
      },
    );
  }
}
