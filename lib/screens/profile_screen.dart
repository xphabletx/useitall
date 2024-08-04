import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import 'meal_plan_screen.dart';
import 'name_age_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Map<String, dynamic>>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = DatabaseHelper.instance.getProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Profile Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Planner'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MealPlanScreen(userName: '')),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No profiles found.'));
          } else {
            final profiles = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return GestureDetector(
                        onLongPress: () => _showOptionsDialog(context, profile),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              Text(
                                profile['profileIcon'],
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Name: ${profile['name']}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (profile['isMain'] == 1) ...[
                                          const Text(
                                            " - ",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            "Set as main profile",
                                            style: TextStyle(
                                              fontSize: 14, // Smaller font size to avoid overflow
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text("Age Group: ${profile['isOver18'] == 1 ? 'Over 18' : 'Under 18'}"),
                                    const SizedBox(height: 8),
                                    Text("Diet Preferences: ${profile['dietPreferences']}"),
                                    const SizedBox(height: 8),
                                    Text("Allergies: ${profile['allergies']}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MealPlanScreen(
                                userName: profiles.firstWhere((profile) => profile['isMain'] == 1)['name'],
                              ),
                            ),
                          );
                        },
                        child: const Text("Let's plan!"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NameAgeScreen(),
                            ),
                          );
                        },
                        child: const Text('Add Profile'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, Map<String, dynamic> profile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Profile Options"),
          content: const Text("Choose an option:"),
          actions: <Widget>[
            TextButton(
              child: const Text("Set as Main Profile"),
              onPressed: () {
                Navigator.of(context).pop();
                _setMainProfile(profile['id']);
              },
            ),
            TextButton(
              child: const Text("Delete Profile"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProfile(profile['id']);
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setMainProfile(int id) async {
    await DatabaseHelper.instance.setMainProfile(id);
    setState(() {
      _profilesFuture = DatabaseHelper.instance.getProfiles();
    });
  }

  Future<void> _deleteProfile(int id) async {
    await DatabaseHelper.instance.deleteProfile(id);
    setState(() {
      _profilesFuture = DatabaseHelper.instance.getProfiles();
});
}
}