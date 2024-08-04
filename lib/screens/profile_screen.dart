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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
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
            Map<String, dynamic>? mainProfile;
            try {
              mainProfile = profiles.firstWhere((profile) => profile['isMain'] == 1);
            } catch (e) {
              // Handle case where no main profile is found
            }
            return Column(
              children: [
                if (mainProfile != null)
                  Card(
                    color: Colors.grey[200],
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        mainProfile['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('is the main profile'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Edit main profile
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return Card(
                        color: profile['isMain'] == 1 ? Colors.grey[300] : null,
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(profile['name']),
                          subtitle: Text(
                            'Allergies: ${profile['allergies']} | Diet: ${profile['dietPreferences']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (profile['isMain'] != 1)
                                IconButton(
                                  icon: const Icon(Icons.star_border),
                                  onPressed: () {
                                    setState(() {
                                      _setMainProfile(profile['id']);
                                    });
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _deleteProfile(profile['id']);
                                  });
                                },
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
                                userName: mainProfile?['name'] ?? 'User',
                              ),
                            ),
                          );
                        },
                        child: Text('Let\'s plan some noms ${mainProfile?['name'] ?? 'User'}'),
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
                        child: const Text('I gotta cook for more people'),
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