import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/meal.dart';
import '../models/profile.dart';
import '../utilities/change_profile_meal.dart'; // Import the new utility
import '../utilities/date_wheel.dart';
import '../utilities/meal_data.dart';
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
  late Future<Map<DateTime, Map<String, List<Meal>>>> _suggestionsFuture;
  late DateTime _selectedDate;
  List<Profile> _profiles = [];
  final Map<int, bool> _expandedTiles = {};

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

Future<Map<DateTime, Map<String, List<Meal>>>> _generateSuggestions() async {
  final mealData = MealData.instance;
  final suggestions = <DateTime, Map<String, List<Meal>>>{};
  final mealTypes = ['Breakfast', 'Lunch', 'Dinner'];

  for (var i = 0; i <= widget.endDate.difference(widget.startDate).inDays; i++) {
    final date = widget.startDate.add(Duration(days: i));
    suggestions[date] = {};
    for (var mealType in mealTypes) {
      final meal = await mealData.suggestRandomMeal(mealType);
      suggestions[date]![mealType] = [meal]; // Wrap the meal in a List<Meal>
    }
  }
  return suggestions;
}

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _updateMealProfiles(DateTime date, String mealType, List<Meal> updatedMeals) {
    setState(() {
      _suggestionsFuture.then((suggestions) {
        if (suggestions.containsKey(date)) {
          suggestions[date]![mealType] = updatedMeals;
        }
      });
    });
  }

  String _getFirstSentence(String description) {
    return '${description.split('.').first}.';
  }

  Widget _buildMealImage(String imageUrl, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? 200 : 50,
      height: isExpanded ? 200 : 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.broken_image,
              size: isExpanded ? 200 : 50,
              color: Colors.grey,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return SizedBox(
                width: isExpanded ? 200 : 50,
                height: isExpanded ? 200 : 50,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Suggestions for ${formatShortDateRange(widget.startDate, widget.endDate)}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: FutureBuilder<Map<DateTime, Map<String, List<Meal>>>>(
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
                  child: ListView.builder(
                    itemCount: meals.keys.length,
                    itemBuilder: (context, index) {
                      final mealType = meals.keys.elementAt(index);
                      final mealList = meals[mealType]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: mealList.asMap().entries.map((entry) {
                          final i = entry.key;
                          final meal = entry.value;
                          final isExpanded = _expandedTiles[index * 10 + i] ?? false;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                        padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ExpansionTile(
                              key: PageStorageKey('${mealType}_${meal.name}_$i'),
                              initiallyExpanded: isExpanded,
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${i == 0 ? "1st" : "${i + 1}th"} $mealType: ${meal.name}',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  if (meal.imageUrl.isNotEmpty)
                                    _buildMealImage(meal.imageUrl, isExpanded),
                                ],
                              ),
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _expandedTiles[index * 10 + i] = expanded;
                                });
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text('Description: ${_getFirstSentence(meal.description)}'),
                                      Text('Cuisine: ${meal.cuisine}'),
                                      Text('Diet: ${meal.diet}'),
                                      Text('Ingredients Count: ${meal.ingredientsCount}'),
                                      Text('Prep Time: ${meal.prepTime} mins'),
                                      Text('Cook Time: ${meal.cookTime} mins'),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Eating:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      ...meal.profiles?.map((profile) {
                                        return Row(
                                          children: [
                                            Text(profile.name),
                                            const SizedBox(width: 5),
                                            Text(profile.icon),
                                          ],
                                        );
                                      }).toList() ?? [],
                                      TextButton(
                                        onPressed: () {
                                          showChangeMealForProfile(
                                            context,
                                            meal,
                                            _profiles,
                                            setState,
                                            (originalMeal, newMeals) {
                                              _updateMealProfiles(_selectedDate, mealType, newMeals);
                                            },
                                          );
                                        },
                                        child: const Text('Options'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
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
                ),
              ],
            );
          }
        },
      ),
    );
  }
}