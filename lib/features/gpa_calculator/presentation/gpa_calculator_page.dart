import 'package:flutter/material.dart';

class GpaCalculatorPage extends StatefulWidget {
  @override
  State<GpaCalculatorPage> createState() => _GpaCalculatorPageState();
}

class _GpaCalculatorPageState extends State<GpaCalculatorPage> {
  List<TextEditingController> gpaControllers = [];
  List<TextEditingController> hoursControllers = [];
  List<String> selectedGrades = [];
  List<String> options = [
    'A+',
    'A',
    'A-',
    'B+',
    'B',
    'B-',
    'C+',
    'C',
    'C-',
    'D+',
    'D',
    'D-',
    'F',
  ];
  Map<String, double> option = {
    'A+': 4.2,
    'A': 4.0,
    'A-': 3.75,
    'B+': 3.5,
    'B': 3.25,
    'B-': 3.0,
    'C+': 2.75,
    'C': 2.5,
    'C-': 2.25,
    'D+': 2,
    'D': 1.75,
    'D-': 1.5,
    'F': 0.5,
  };

  double? calculatedGpa;

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  void _addRow() {
    setState(() {
      gpaControllers.add(TextEditingController());
      hoursControllers.add(TextEditingController());
      selectedGrades.add(options[0]);
    });
  }

  void _removeRow(int index) {
    setState(() {
      gpaControllers[index].dispose();
      hoursControllers[index].dispose();
      gpaControllers.removeAt(index);
      hoursControllers.removeAt(index);
      selectedGrades.removeAt(index);
    });
  }

  void _calculateGpa() {
    double totalPoints = 0;
    double totalHours = 0;
    for (int i = 0; i < gpaControllers.length; i++) {
      final grade = selectedGrades[i];
      final hours = double.tryParse(hoursControllers[i].text) ?? 0;
      final points = option[grade] ?? 0;
      totalPoints += points * hours;
      totalHours += hours;
    }
    setState(() {
      calculatedGpa = totalHours > 0 ? totalPoints / totalHours : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final fontSize = screenWidth < 600 ? 16.0 : 20.0;

    return Scaffold(
      appBar: AppBar(title: Text('GPA Calculator')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: gpaControllers.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Colors.blue.shade100, width: 1.5),
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: padding * 0.7,
                    horizontal: 2,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(padding + 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: selectedGrades[index],
                            items:
                                options.map((grade) {
                                  return DropdownMenuItem(
                                    value: grade,
                                    child: Text(
                                      grade,
                                      style: TextStyle(fontSize: fontSize),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGrades[index] = value!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Grade',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: padding * 0.7),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: hoursControllers[index],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Hours',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                        SizedBox(width: padding * 0.7),
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed:
                              gpaControllers.length > 1
                                  ? () => _removeRow(index)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: padding),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text(
                    'Add Subject',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  onPressed: _addRow,
                ),
                SizedBox(width: padding),
                ElevatedButton.icon(
                  icon: Icon(Icons.calculate),
                  label: Text(
                    'Calculate GPA',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  onPressed: _calculateGpa,
                ),
              ],
            ),
            SizedBox(height: padding * 2),
            if (calculatedGpa != null)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                color:
                    calculatedGpa! >= 3.5
                        ? Colors.green.shade100
                        : calculatedGpa! >= 2.5
                        ? Colors.orange.shade100
                        : Colors.red.shade100,
                margin: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: padding,
                    horizontal: padding * 1.5,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your GPA',
                        style: TextStyle(
                          fontSize: fontSize + 6,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        calculatedGpa!.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: fontSize + 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        calculatedGpa! >= 3.5
                            ? 'Excellent!'
                            : calculatedGpa! >= 2.5
                            ? 'Good'
                            : 'Needs Improvement',
                        style: TextStyle(
                          fontSize: fontSize + 2,
                          color:
                              calculatedGpa! >= 3.5
                                  ? Colors.green
                                  : calculatedGpa! >= 2.5
                                  ? Colors.orange
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
