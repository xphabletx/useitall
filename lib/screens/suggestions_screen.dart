import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../utilities/meal_data.dart';

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
  late Future<List<Meal>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = MealData.instance.getMeals();
  }

  String _getFirstSentence(String description) {
    return '${description.split('.').first}.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Suggestions for ${widget.userName}'),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meal suggestions available.'));
          } else {
            final meals = snapshot.data!;
            return ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return ListTile(
                  title: Text(meal.name),
                  subtitle: Text(_getFirstSentence(meal.description)),
                  onTap: () {
                    // Expand to show more details
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(meal.name),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Cuisine: ${meal.cuisine}'),
                              Text('Diet: ${meal.diet}'),
                              Text('Ingredients Count: ${meal.ingredientsCount}'),
                              Text('Prep Time: ${meal.prepTime} mins'),
                              Text('Cook Time: ${meal.cookTime} mins'),
                              if (meal.imageUrl.isNotEmpty)
                                Image.network(meal.imageUrl),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}