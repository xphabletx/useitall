// /screens/suggestions_screen.dart

import 'dart:math';

import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/meal.dart';
import '../models/profile.dart';
import '../utilities/date_wheel.dart';
import '../utilities/image_url.dart';
import '../utilities/meal_data.dart';
import '../utilities/meal_options.dart';
import '../utilities/short_date.dart';

class SuggestionsScreen extends StatefulWidget {
  final String userName;
  final DateTime startDate;
  final DateTime endDate;

  const SuggestionsScreen({
    super.key,
    required this.userName,
    required this.startDate,
    required this.endDate,
  });

  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  late Future<Map<DateTime, Map<String, Meal>>> _suggestionsFuture;
  late DateTime _selectedDate;
  List<Profile> _profiles = [];
  Map<String, bool> _isExpandedMap = {};
  Map<DateTime, Map<String, List<Profile>>> _mealProfiles = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.startDate;
    _suggestionsFuture = _generateSuggestions();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await DatabaseHelper.instance.getProfiles();
    setState(() {
      _profiles = profiles;
    });
  }

  Future<Map<DateTime, Map<String, Meal>>> _generateSuggestions() async {
    final random = Random();
    final mealData = MealData.instance;
    final suggestions = <DateTime, Map<String, Meal>>{};
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
    final courses = ['Breakfast', 'Lunch', 'Dinner'];

    for (var i = 0; i <= widget.endDate.difference(widget.startDate).inDays; i++) {
      final date = widget.startDate.add(Duration(days: i));
      suggestions[date] = {};
      _mealProfiles[date] = {};
      for (var j = 0; j < mealTypes.length; j++) {
        final course = courses[j];
        final meal = await mealData.suggestRandomMeal(course);
        suggestions[date]![mealTypes[j]] = meal;
        _mealProfiles[date]![mealTypes[j]] = _profiles; // All profiles eating initially
      }
    }
    return suggestions;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _updateMealProfiles(DateTime date, String mealType, List<Profile> profiles) {
    setState(() {
      _mealProfiles[date]![mealType] = profiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Meal Suggestions'),
            Text(
              formatShortDateRange(widget.startDate, widget.endDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<DateTime, Map<String, Meal>>>(
        future: _suggestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meal suggestions available.'));
          } else {
            final suggestions = snapshot.data!;
            final meals = suggestions[_selectedDate]!;
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: meals.entries.map((mealEntry) {
                      final mealType = mealEntry.key;
                      final meal = mealEntry.value;
                      final isExpanded = _isExpandedMap[mealType] ?? false;
                      final mealProfiles = _mealProfiles[_selectedDate]![mealType]!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '$mealType: ${meal.name}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: isExpanded ? 150 : 50,
                                  height: isExpanded ? 150 : 50,
                                  child: buildMealImage(meal.imageUrl, isExpanded ? 150 : 50),
                                ),
                              ],
                            ),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _isExpandedMap[mealType] = expanded;
                              });
                            },
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Description: ${meal.description.split('.').first}.'),
                                    Text('Cuisine: ${meal.cuisine}'),
                                    Text('Diet: ${meal.diet}'),
                                    Text('Ingredients Count: ${meal.ingredientsCount}'),
                                    Text('Prep Time: ${meal.prepTime} mins'),
                                    Text('Cook Time: ${meal.cookTime} mins'),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Eating:',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    ...mealProfiles.map((profile) {
                                      return Row(
                                        children: [
                                          Text(profile.name),
                                          const SizedBox(width: 5),
                                          Text(profile.icon),
                                        ],
                                      );
                                    }).toList(),
                                                                        TextButton(
                                      onPressed: () {
                                        showMealOptions(
                                          context,
                                          meal,
                                          _profiles,
                                          setState,
                                          (updatedProfiles) {
                                            _updateMealProfiles(_selectedDate, mealType, updatedProfiles[meal.course]!);
                                          },
                                        );
                                      },
                                      child: const Text('Options'),
                                    ),
                                  ],
                                ),
                              ),
                              if (mealProfiles.length < _profiles.length)
                                TextButton(
                                  onPressed: () async {
                                    final newMeal = await MealData.instance.suggestRandomMeal(meal.course);
                                    setState(() {
                                      final remainingProfiles = _profiles.where((profile) => !mealProfiles.contains(profile)).toList();
                                      _updateMealProfiles(_selectedDate, mealType, mealProfiles);
                                      _updateMealProfiles(_selectedDate, '${mealType}_split', remainingProfiles);
                                      meals['${mealType}_split'] = newMeal;
                                    });
                                  },
                                  child: const Text('Add another meal for remaining profiles'),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                DateWheel(
                  dates: List.generate(
                    widget.endDate.difference(widget.startDate).inDays + 1,
                    (index) => widget.startDate.add(Duration(days: index)),
                  ),
                  focusedDate: _selectedDate,
                  onSelectedItemChanged: (index) {
                    _onDateSelected(
                      widget.startDate.add(Duration(days: index)),
                    );
                  },
                  onDateTap: (date) {
                    _onDateSelected(date);
                  },
                  isHorizontal: true,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}