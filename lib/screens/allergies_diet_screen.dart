import 'package:flutter/material.dart';

import 'icon_screen.dart';

class AllergiesDietScreen extends StatefulWidget {
  final String name;
  final String ageGroup;

  const AllergiesDietScreen({super.key, required this.name, required this.ageGroup});

  @override
  AllergiesDietScreenState createState() => AllergiesDietScreenState();
}

class AllergiesDietScreenState extends State<AllergiesDietScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _allergies = [];
  final List<String> _dietPreferences = [];

  final List<String> _allergyOptions = [
    'Peanuts', 'Tree Nuts', 'Milk', 'Eggs', 'Wheat', 'Soy', 'Fish', 'Shellfish', 'Sesame', 'Mustard', 'Celery', 'Lupin'
  ];

  final List<String> _dietOptions = [
    'Vegan', 'Vegetarian', 'Non Vegetarian', 'High Protein Vegetarian', 'High Protein Non Vegetarian', 'Eggetarian'
  ];

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile - Step 2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_currentStep == 0) ...[
                const Text(
                  'Allergies',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _allergyOptions.map((allergy) {
                      return CheckboxListTile(
                        title: Text(allergy),
                        value: _allergies.contains(allergy),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _allergies.add(allergy);
                            } else {
                              _allergies.remove(allergy);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                ),
              ],
              if (_currentStep == 1) ...[
                const Text(
                  'Diet Preferences',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: _dietOptions.map((diet) {
                      return CheckboxListTile(
                        title: Text(diet),
                        value: _dietPreferences.contains(diet),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _dietPreferences.add(diet);
                            } else {
                              _dietPreferences.remove(diet);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IconScreen(
                          name: widget.name,
                          ageGroup: widget.ageGroup,
                          allergies: _allergies,
                          dietPreferences: _dietPreferences,
                          isMain: false, // Default to false when creating a new profile
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}