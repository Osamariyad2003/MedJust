import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/local/secure_helper.dart';
import 'package:med_just/core/models/user_model.dart';
import 'package:med_just/core/models/year_model.dart';
import 'package:med_just/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:med_just/features/profile/presentation/bloc/profile_event.dart';
import 'package:med_just/features/profile/presentation/bloc/profile_state.dart';
import 'package:med_just/features/profile/data/profile_repo.dart';
import 'package:med_just/core/di/di.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Year>> _yearsFuture;
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _yearsFuture = fetchAllYears();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await _secureStorage.isLoggedIn();
    if (!isLoggedIn && mounted) {
      // Navigate to login screen if not authenticated
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<List<Year>> fetchAllYears() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('years').get();
      return snapshot.docs
          .map((doc) => Year.fromJson({'id': doc.id, ...doc.data()!}))
          .toList();
    } catch (e) {
      debugPrint('Error fetching years: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ProfileBloc(
            repository: di<ProfileRepository>(),
            secureStorage: _secureStorage,
          )..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                context.read<ProfileBloc>().add(SaveProfile());
              },
            ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileSaving) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري الحفظ...'),
                  ],
                ),
              );
            } else if (state is ProfileLoaded) {
              final profile = state.profile;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(LoadProfile());
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProfileHeader(profile),
                    const SizedBox(height: 24),
                    _buildProfileForm(profile, context),
                  ],
                ),
              );
            } else if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(LoadProfile());
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.15),
          child: Text(
            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          profile.email,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileForm(UserModel profile, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        FutureBuilder<List<Year>>(
          future: _yearsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('فشل في تحميل السنوات الدراسية'),
              );
            }

            final years = snapshot.data ?? [];
            if (years.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('لا توجد سنوات دراسية متاحة'),
              );
            }

            String? selectedYearId;
            final dynamic yearField = profile.yearId;
            if (yearField is String) {
              selectedYearId = yearField;
            } else if (yearField is Map && yearField['id'] is String) {
              selectedYearId = yearField['id'] as String;
            } else if (yearField is Year) {
              selectedYearId = yearField.id;
            }

            return DropdownButtonFormField<String>(
              value: selectedYearId,
              items:
                  years
                      .map(
                        (year) => DropdownMenuItem<String>(
                          value: year.id,
                          child: Text(year.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<ProfileBloc>().add(UpdateYearId(value));
                }
              },
              decoration: const InputDecoration(
                labelText: 'السنة الدراسية',
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: profile.address,
          decoration: const InputDecoration(
            labelText: 'العنوان',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            context.read<ProfileBloc>().add(UpdateAddress(value));
          },
        ),
      ],
    );
  }
}
