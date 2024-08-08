// /utilities/meal_options.dart

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../models/profile.dart';
import '../utilities/meal_data.dart';

void showMealOptions(
  BuildContext context,
  Meal meal,
  List<Profile> profiles,
  Function setStateCallback,
  Function(Map<String, List<Profile>>) updateMealProfilesCallback,
) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh meal'),
            onTap: () async {
              final newMeal = await MealData.instance.suggestRandomMeal(meal.course);
              setStateCallback(() {
                meal = newMeal;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Remove meal'),
            onTap: () {
              setStateCallback(() {
                // Implement logic to remove the meal
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Change meal for profile'),
            onTap: () {
              Navigator.pop(context);
              showChangeMealForProfile(context, meal, profiles, setStateCallback, updateMealProfilesCallback);
            },
          ),
        ],
      );
    },
  );
}

void showChangeMealForProfile(
  BuildContext context,
  Meal meal,
  List<Profile> profiles,
  Function setStateCallback,
  Function(Map<String, List<Profile>>) updateMealProfilesCallback,
) {
  showDialog(
    context: context,
    builder: (context) {
      final selectedProfiles = <Profile>[];
      return AlertDialog(
        title: const Text('Change meal for profile'),
        content: StatefulBuilder(
          builder: (context, dialogSetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: profiles.map((profile) {
                return CheckboxListTile(
                  title: Text(profile.name),
                  value: selectedProfiles.contains(profile),
                  onChanged: (bool? value) {
                    dialogSetState(() {
                      if (value == true) {
                        selectedProfiles.add(profile);
                      } else {
                        selectedProfiles.remove(profile);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedProfiles.isNotEmpty) {
                final newMeal = await MealData.instance.suggestRandomMeal(meal.course);
                updateMealProfilesCallback({
                  meal.course: selectedProfiles,
                });
                setStateCallback(() {
                  // Implement the state change logic
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Change'),
          ),
        ],
      );
    },
  );
}