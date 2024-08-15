import 'dart:convert'; // For processing the CSV file

import 'package:flutter/services.dart'; // For loading assets

import '../helpers/database_helper.dart'; // Database helper to interact with the SQLite database
import '../models/meal.dart'; // Meal model to handle meal data

class MealData {
  static final MealData instance = MealData._init();
  late Map<String, int> _ingredientMacroWeights;

  MealData._init() {
    _loadIngredientMacros();
  }

  // Loads ingredient macros from a CSV file and stores them in a map
  Future<void> _loadIngredientMacros() async {
    final csvString = await rootBundle.loadString('assets/ingredient_category_macros.csv');
    final lines = LineSplitter.split(csvString).toList();

    _ingredientMacroWeights = {};

    for (var line in lines.skip(1)) {
      final values = line.split(',');
      if (values.length >= 5) {
        final ingredientName = values[1].trim().toLowerCase(); // Normalize ingredient name
        final categoryMacro = values[4].trim();

        int weight = _getMacroWeight(categoryMacro);
        _ingredientMacroWeights[ingredientName] = weight;
      }
    }
  }

  // Returns a weight based on the macro category of the ingredient
  int _getMacroWeight(String categoryMacro) {
    switch (categoryMacro) {
      case 'Additive':
        return 3;
      case 'Beverage':
        return 1;
      case 'Beverage Alcoholic':
        return 2;
      case 'Carbohydrate':
        return 6;
      case 'Cereal':
        return 5;
      case 'Condiment':
        return 1;
      case 'Dairy':
        return 8;
      case 'Fat':
        return 7;
      case 'Fruit':
        return 6;
      case 'Fungus':
        return 8;
      case 'Herb':
        return 4;
      case 'High Sugar':
        return 1;
      case 'Oil':
        return 1;
      case 'Protein':
        return 10;
      case 'Sauce':
        return 1;
      case 'Spice':
        return 2;
      case 'Vegetable':
        return 9;
      default:
        return 0;
    }
  }

  // Calculates the total macro score for a given list of ingredients
  int calculateMacroScore(List<String> ingredients) {
    int totalScore = 0;

    for (var ingredient in ingredients) {
      final normalizedIngredient = ingredient.trim().toLowerCase();
      final weight = _ingredientMacroWeights[normalizedIngredient] ?? 0;
      totalScore += weight;
    }

    return totalScore;
  }

  // Retrieves all meals from the database
  Future<List<Meal>> getMeals() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('meals');
    return result.map((json) => Meal.fromMap(json)).toList();
  }

  // Retrieves meals from the database based on the course type (e.g., Breakfast, Lunch, Dinner)
  Future<List<Meal>> getMealsByCourse(String course) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('meals', where: 'course = ?', whereArgs: [course]);
    return result.map((json) => Meal.fromMap(json)).toList();
  }

  // Selects a random meal from the list of available meals for a given course
  Future<Meal> suggestRandomMeal(String course) async {
    final meals = await getMealsByCourse(course);
    if (meals.isEmpty) {
      return Meal(
        name: 'No meal',
        description: 'No meal planned',
        cuisine: 'Unknown cuisine',
        diet: 'Any',
        ingredientsCount: 0,
        prepTime: 0,
        cookTime: 0,
        imageUrl: '',
        course: course,
        ingredients: <String>[],
      );
    }

    meals.shuffle();
    return meals.first;
  }

  // Suggests a meal with the highest overlap in ingredients with previously chosen meals
  Future<Meal> suggestMealWithOverlap(String course, List<String> previousIngredients, int day) async {
    final possibleMeals = await getMealsByCourse(course);

    Meal? bestMeal;
    int bestScore = -1;

    for (Meal meal in possibleMeals) {
      int currentScore = calculateOverlapScore(meal.ingredients, previousIngredients);

      // Debug: Show overlap and score calculation
      List<String> overlappingIngredients = meal.ingredients.where((ingredient) => previousIngredients.contains(ingredient)).toList();
      print("Day $day $course - Checking meal: ${meal.name}");
      print("Overlapping ingredients: $overlappingIngredients");
      print("Calculated Score: $currentScore");

      if (currentScore > bestScore) {
        bestScore = currentScore;
        bestMeal = meal;
      }
    }

    print("Day $day $course - Selected meal: ${bestMeal?.name ?? 'None found'} with score: $bestScore");
    return bestMeal ?? await suggestRandomMeal(course); // Fallback to random if no good match
  }

  // Calculates the overlap score between a meal's ingredients and previously selected ingredients
  int calculateOverlapScore(List<String> mealIngredients, List<String> previousIngredients) {
    int score = 0;

    for (var ingredient in mealIngredients) {
      if (previousIngredients.contains(ingredient)) {
        score += _ingredientMacroWeights[ingredient] ?? 0;
      }
    }

    return score;
  }

  // Generates a meal plan for the selected number of days
  Future<void> generateMealPlan(int numberOfDays, bool includeBreakfast, bool includeLunch, bool includeDinner) async {
    List<String> previousIngredients = [];

    for (int day = 1; day <= numberOfDays; day++) {
      print("Generating meal plan for Day $day...");

      if (includeBreakfast) {
        var breakfast = day == 1
            ? await suggestRandomMeal('Breakfast')
            : await suggestMealWithOverlap('Breakfast', previousIngredients, day);
        previousIngredients.addAll(breakfast.ingredients);
        print("Day $day Breakfast - Selected meal: ${breakfast.name}");
      }

      if (includeLunch) {
        var lunch = day == 1
            ? await suggestRandomMeal('Lunch')
            : await suggestMealWithOverlap('Lunch', previousIngredients, day);
        previousIngredients.addAll(lunch.ingredients);
        print("Day $day Lunch - Selected meal: ${lunch.name}");
      }

      if (includeDinner) {
        var dinner = day == 1
            ? await suggestRandomMeal('Dinner')
            : await suggestMealWithOverlap('Dinner', previousIngredients, day);
        previousIngredients.addAll(dinner.ingredients);
        print("Day $day Dinner - Selected meal: ${dinner.name}");
      }
    }
  }
}