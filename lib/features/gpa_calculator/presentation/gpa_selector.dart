import 'package:flutter/material.dart';
import 'package:med_just/features/gpa_calculator/presentation/gpa_calculator_page.dart';
import 'gpa_cum.dart';
// import 'gpa_normal.dart'; // Uncomment and create this if you have a normal GPA page

class GpaSelectorPage extends StatelessWidget {
  const GpaSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate),
                label: const Text('Normal GPA'),
                onPressed: () {
                  // TODO: Navigate to normal GPA page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GpaCalculatorPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.functions),
                label: const Text('Cumulative GPA'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GpaCumulativePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
