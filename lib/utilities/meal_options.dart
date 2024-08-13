import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/profile.dart';
import '../utilities/meal_data.dart';

void showMealOptions(
  BuildContext context,
  Meal meal,
  List<Profile> profiles,
  Function setState,
  Function(Meal) updateMealProfilesCallback,
) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh meal'),
            onTap: () {
              Navigator.pop(context);
              MealData.instance.suggestRandomMeal(meal.course).then((newMeal) {
                setState(() {
                  meal.name = newMeal.name;
                  meal.description = newMeal.description;
                  meal.cuisine = newMeal.cuisine;
                  meal.diet = newMeal.diet;
                  meal.ingredientsCount = newMeal.ingredientsCount;
                  meal.prepTime = newMeal.prepTime;
                  meal.cookTime = newMeal.cookTime;
                  meal.imageUrl = newMeal.imageUrl;
                });
                updateMealProfilesCallback(meal);
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Remove meal'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                meal.profiles = [];
              });
              updateMealProfilesCallback(meal);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Change meal for profile'),
            onTap: () {
              Navigator.pop(context);
              // Remove the following line since it's now handled in change_profile_meal.dart
              // showChangeMealForProfile(context, meal, profiles, setState, updateMealProfilesCallback);
            },
          ),
        ],
      );
    },
  );
}