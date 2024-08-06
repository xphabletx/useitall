import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../utilities/csv_util.dart';
import 'name_age_screen.dart';
import 'profile_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
    _navigateToNextScreen();
  }

  Future<void> _loadData() async {
    try {
      final meals = await loadMealsFromCsv();
      for (var meal in meals) {
        await DatabaseHelper.instance.createMeal(meal);
      }
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    await DatabaseHelper.instance.database; // Ensure database is initialized

    bool hasProfiles = await DatabaseHelper.instance.getProfiles().then((profiles) => profiles.isNotEmpty);

    if (hasProfiles) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NameAgeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Food Usey Tool - a useful app that plans meals, helps you buy food and use it all!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}