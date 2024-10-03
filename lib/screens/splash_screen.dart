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
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    await DatabaseHelper.instance.database; // Ensure database is initialized

    bool hasProfiles = await DatabaseHelper.instance.getProfiles().then((profiles) => profiles.isNotEmpty);
    bool hasMeals = await DatabaseHelper.instance.getMealsCount().then((count) => count >= 1177);

    if (!hasMeals) {
      await _loadData(); // Load data if no meals are present
    }

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

  Future<void> _loadData() async {
    try {
      final meals = await loadMealsFromCsv();  // Directly call the CSV utility function
      final db = await DatabaseHelper.instance.database;
      for (var meal in meals) {
        await db.insert('meals', meal.toMap());
      }
      print('Loaded ${meals.length} meals into the database.');

      final macros = await loadIngredientMacrosFromCsv();  // Load macros from CSV
      for (var macro in macros) {
        await db.insert('ingredient_macros', macro);
      }
      print('Loaded ${macros.length} ingredient macros into the database.');
    } catch (e) {
      print('Error loading data: $e');
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