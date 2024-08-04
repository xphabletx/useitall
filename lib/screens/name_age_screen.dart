import 'package:flutter/material.dart';

import 'allergies_diet_screen.dart';

class NameAgeScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;

  const NameAgeScreen({super.key, this.profile});

  @override
  _NameAgeScreenState createState() => _NameAgeScreenState();
}

class _NameAgeScreenState extends State<NameAgeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isOver18 = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    if (widget.profile != null) {
      _nameController.text = widget.profile!['name'];
      _isOver18 = widget.profile!['isOver18'] == 'true';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Are you over 18?'),
                  Switch(
                    value: _isOver18,
                    onChanged: (value) {
                      setState(() {
                        _isOver18 = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllergiesDietScreen(
            name: _nameController.text,
            isOver18: _isOver18,
          ),
        ),
      );
    }
  }
}