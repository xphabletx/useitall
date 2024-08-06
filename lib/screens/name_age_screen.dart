import 'package:flutter/material.dart';

import 'allergies_diet_screen.dart';

class NameAgeScreen extends StatefulWidget {
  const NameAgeScreen({super.key});

  @override
  _NameAgeScreenState createState() => _NameAgeScreenState();
}

class _NameAgeScreenState extends State<NameAgeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedAgeGroup;

  final List<String> _ageGroups = [
    'Under 18',
    '18 and above',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile - Step 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedAgeGroup,
                decoration: const InputDecoration(labelText: 'Age Group'),
                items: _ageGroups.map((ageGroup) {
                  return DropdownMenuItem(
                    value: ageGroup,
                    child: Text(ageGroup),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an age group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllergiesDietScreen(
                          name: _nameController.text,
                          ageGroup: _selectedAgeGroup!,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}