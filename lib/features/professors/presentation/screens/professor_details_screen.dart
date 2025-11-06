import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/di/di.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/features/professors/data/professor_repo.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_bloc.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_event.dart';
import 'package:med_just/features/professors/presentation/bloc/professor_state.dart';
import 'package:med_just/features/resourses/presentation/widgets/error_display.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessorDetailsScreen extends StatelessWidget {
  final String professorId;

  const ProfessorDetailsScreen({Key? key, required this.professorId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ProfessorsBloc(repository: di<ProfessorsRepository>())
                ..add(LoadProfessorDetails(professorId)),
      child: BlocConsumer<ProfessorsBloc, ProfessorsState>(
        listener: (context, state) {
          if (state is ProfessorsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is ProfessorDetailsLoaded
                    ? state.professor.name
                    : 'Professor Details',
              ),
            ),
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfessorsState state) {
    if (state is ProfessorsLoading) {
      return const Center(child: LoadingIndicator());
    } else if (state is ProfessorDetailsLoaded) {
      final professor = state.professor;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professor image
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage:
                    professor.imageUrl != null
                        ? NetworkImage(professor.imageUrl!)
                        : null,
                child:
                    professor.imageUrl == null
                        ? const Icon(Icons.person, size: 80)
                        : null,
              ),
            ),
            const SizedBox(height: 24),

            // Professor name
            Text(
              professor.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Department
            _buildInfoRow(context, 'Department', professor.department),

            // Office location
            if (professor.department != null &&
                professor.department!.isNotEmpty)
              _buildInfoRow(context, 'Office', professor.department!),

            // Email
            if (professor.email != null && professor.email!.isNotEmpty)
              _buildInfoRow(
                context,
                'Email',
                professor.email!,
                onTap: () => _launchEmail(professor.email!),
              ),

            // Bio
            if (professor.bio != null && professor.bio!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                professor.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Subject list
            if (professor.subjectIds.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Teaches', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              // Note: In a real app, you would fetch the actual subject names
              ...professor.subjectIds
                  .map(
                    (subjectId) => ListTile(
                      leading: const Icon(Icons.book),
                      title: Text('Subject ID: $subjectId'),
                      onTap: () {
                        // Navigate to subject details
                      },
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      );
    } else if (state is ProfessorsError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          context.read<ProfessorsBloc>().add(LoadProfessorDetails(professorId));
        },
      );
    }

    return const Center(child: Text('No professor information available'));
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:
                onTap != null
                    ? GestureDetector(
                      onTap: onTap,
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                    : Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
