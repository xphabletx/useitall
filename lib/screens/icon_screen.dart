import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/profile.dart';
import 'profile_screen.dart';

class IconScreen extends StatefulWidget {
  final String name;
  final String ageGroup;
  final List<String> allergies;
  final List<String> dietPreferences;
  final bool isMain;

  const IconScreen({
    super.key,
    required this.name,
    required this.ageGroup,
    required this.allergies,
    required this.dietPreferences,
    required this.isMain,
  });

  @override
  _IconScreenState createState() => _IconScreenState();
}

class _IconScreenState extends State<IconScreen> {
  late String _profileIcon = '🍏'; // Default emoji

  final List<String> _foodEmojis = [
    '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦', '🥬', '🥒', '🌶', '🫑', '🌽', '🥕', '🫒', '🧄', '🧅', '🥔', '🍠', '🥐', '🥯', '🍞', '🥖', '🥨', '🧀', '🥚', '🍳', '🧈', '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🦴', '🌭', '🍔', '🍟', '🍕', '🌮', '🌯', '🫔', '🥙', '🧆', '🥚', '🍳', '🧀', '🥗', '🍿', '🥫', '🍱', '🍲', '🍜', '🍝', '🍛', '🍣', '🍤', '🍙', '🍚', '🍘', '🍥', '🥟', '🥠', '🥡', '🍢', '🍧', '🍨', '🍦', '🥧', '🧁', '🍰', '🎂', '🍮', '🍬', '🍭', '🍫', '🍿', '🍩', '🍪', '🍺', '🍻', '🥂', '🍷', '🥃', '🍸', '🍹', '🍾', '🍶', '🍵', '🫖', '☕', '🧃', '🥤', '🧋', '🧉', '🍽', '🍴', '🥄'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile Icon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Select Profile Icon',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                children: _foodEmojis.map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _profileIcon = emoji;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _profileIcon == emoji
                              ? Colors.grey[800]!
                              : Colors.transparent,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(
                            fontSize: 36.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Welcome ${widget.name} $_profileIcon. Let\'s get started!'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    final profile = Profile(
      name: widget.name,
      ageGroup: widget.ageGroup,
      icon: _profileIcon,
      dietPreferences: widget.dietPreferences,
      allergies: widget.allergies,
      isMain: widget.isMain, // Correctly using the isMain parameter
    );

    await DatabaseHelper.instance.createProfile(profile);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Created')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }
}