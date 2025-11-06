import 'package:flutter/material.dart';

class GpaCumulativePage extends StatefulWidget {
  const GpaCumulativePage({super.key});

  @override
  State<GpaCumulativePage> createState() => _GpaCumulativePageState();
}

class _GpaCumulativePageState extends State<GpaCumulativePage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  double? _result;

  void _calculateGpa() {
    if (_formKey.currentState?.validate() ?? false) {
      final first = double.parse(_controllers[0].text);
      final second = double.parse(_controllers[1].text);
      final third = double.parse(_controllers[2].text);
      final fourth = double.parse(_controllers[3].text);
      final fifth = double.parse(_controllers[4].text);
      final sixth = double.parse(_controllers[5].text);

      final gpa =
          (first * 0.14) +
          (second * 0.14) +
          (third * 0.14) +
          (fourth * 0.14) +
          (fifth * 0.14) +
          (sixth * 0.30);

      setState(() {
        _result = gpa;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cumulative GPA Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              for (int i = 0; i < 6; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _controllers[i],
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Semester ${i + 1} GPA',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter GPA';
                      final v = double.tryParse(value);
                      if (v == null || v < 0 || v > 4)
                        return 'Enter valid GPA (0-4)';
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateGpa,
                child: const Text('Calculate'),
              ),
              if (_result != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Cumulative GPA: ${_result!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
