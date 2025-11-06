import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:med_just/core/shared/widgets/loading_indicator.dart';
import 'package:med_just/features/university_map/presentation/widgets/mapview.dart';

import '../../data/maps_model.dart';
import '../bloc/maps_bloc.dart';
import '../bloc/maps_event.dart';
import '../bloc/maps_state.dart';

class UniversityMapScreen extends StatefulWidget {
  const UniversityMapScreen({super.key});

  @override
  State<UniversityMapScreen> createState() => _UniversityMapScreenState();
}

class _UniversityMapScreenState extends State<UniversityMapScreen> {
  String? _selectedType;
  final List<String> _locationTypes = [
    'الكل',
    'قاعة دراسية',
    'لايات',
    'مدرج',
    'قاعات امتحانات',
    'مطعم',
    'مصلى',
    'أخرى',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خريطة الجامعة')),
      body: BlocConsumer<MapsBloc, MapsState>(
        listener: (context, state) {
          if (state is MapsError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Type filter - Now with dropdown
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع المكان',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedType,
                  hint: const Text('اختر النوع'),
                  items:
                      _locationTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type == 'الكل' ? null : type,
                          child: Text(type),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    if (value == null || value == 'الكل') {
                      context.read<MapsBloc>().add(LoadAllLocations());
                    } else {
                      context.read<MapsBloc>().add(LoadLocationsByType(value));
                    }
                  },
                ),
              ),

              // Map view content
              Expanded(child: _buildMapContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapContent(MapsState state) {
    if (state is MapsLoading) {
      return const Center(child: LoadingIndicator());
    } else if (state is LocationsLoaded) {
      return MapView(
        locations: state.locations,
        onLocationSelected: (id) {
          if (id.isNotEmpty) {
            context.read<MapsBloc>().add(LoadLocationById(id));
          }
        },
      );
    } else if (state is MapsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<MapsBloc>().add(LoadAllLocations()),
              child: const Text('حاول مرة أخرى'),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('اختر مكانًا للعرض'));
  }
}
