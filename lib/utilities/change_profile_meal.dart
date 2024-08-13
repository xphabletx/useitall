import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/profile.dart';
import '../utilities/meal_data.dart';

void showChangeMealForProfile(
  BuildContext context,
  Meal originalMeal,
  List<Profile> profiles,
  Function setState,
  Function(Meal, List<Meal>) updateMealProfilesCallback,
) {
  final Map<String, bool> profileSelections = {for (var profile in profiles) profile.name: false};

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select Profiles'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: profiles.map((profile) {
                return SwitchListTile(
                  title: Text(profile.name),
                  secondary: Text(profile.icon),
                  value: profileSelections[profile.name]!,
                  onChanged: (bool value) {
                    setDialogState(() {
                      profileSelections[profile.name] = value;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  final selectedProfiles = profiles.where((profile) => profileSelections[profile.name]!).toList();
                  final remainingProfiles = profiles.where((profile) => !profileSelections[profile.name]!).toList();

                  if (selectedProfiles.isNotEmpty) {
                    MealData.instance.suggestRandomMeal(originalMeal.course).then((newMeal) {
                      newMeal.profiles = selectedProfiles;
                      List<Meal> newMeals = [];
                      setState(() {
                        originalMeal.profiles = remainingProfiles;
                        if (remainingProfiles.isEmpty) {
                          newMeals.add(newMeal);
                        } else {
                          newMeals.add(originalMeal);
                          newMeals.add(newMeal);
                        }
                      });
                      updateMealProfilesCallback(originalMeal, newMeals);
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}