import '../helpers/database_helper.dart';
import '../models/meal.dart';

class MealData {
  static final MealData instance = MealData._init();

  MealData._init();

  Map<String, List<String>> day1Ingredients = {};
  Map<String, List<String>> ingredientToSynonyms = {}; // Map to store ingredient-to-synonym mappings
  Set<String> usedMeals = {}; // To track used meal names to avoid duplicates

  // Load ingredient synonyms from the database
  Future<void> loadIngredientSynonyms() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> results = await db.query('ingredient_macros');

    for (var row in results) {
      String ingredient = row['ingredient_name'];
      String? synonymsString = row['synonyms'];

      if (synonymsString != null && synonymsString.isNotEmpty) {
        List<String> synonymsList = synonymsString.split(';').map((synonym) => synonym.trim()).toList();
        ingredientToSynonyms[ingredient] = synonymsList;
      } else {
        ingredientToSynonyms[ingredient] = [];
      }
    }

    print('Loaded ${ingredientToSynonyms.length} ingredient synonyms.');
  }

  // Suggest a random meal for Day 1
  Future<Meal> suggestRandomMeal(String course) async {
    final meals = await DatabaseHelper.instance.getMealsByCourse(course);
    if (meals.isEmpty) {
      return Meal(
        name: 'No meal',
        description: 'No meal planned',
        cuisine: 'Unknown',
        diet: 'Any',
        ingredientsCount: 0,
        prepTime: 0,
        cookTime: 0,
        imageUrl: '',
        course: course,
        ingredients: [],
        ingredientsString: '',
      );
    }
    meals.shuffle();
    return meals.first;
  }

  // Normalize ingredient by removing hyphens, converting to lowercase, and handling word order
  String _normalizeIngredient(String ingredient) {
    ingredient = ingredient.toLowerCase().replaceAll('-', ' ').trim();
    return ingredient.split(' ').reversed.join(' ');
  }

  // Match ingredients considering synonyms
  bool _matchIngredient(String baseIngredient, String ingredientToCheck) {
    String normalizedBase = _normalizeIngredient(baseIngredient);
    String normalizedToCheck = _normalizeIngredient(ingredientToCheck);

    // Direct match
    if (normalizedBase == normalizedToCheck) {
      return true;
    }

    // Check synonyms
    if (ingredientToSynonyms.containsKey(baseIngredient)) {
      for (var synonym in ingredientToSynonyms[baseIngredient]!) {
        if (_normalizeIngredient(synonym) == normalizedToCheck) {
          return true;
        }
      }
    }

    return false;
  }

  // Generate meal plan for specified number of days
  Future<void> generateMealPlan(int numberOfDays, bool includeBreakfast, bool includeLunch, bool includeDinner) async {
    // Ensure ingredient synonyms are loaded before generating the meal plan
    await loadIngredientSynonyms();

    for (int day = 1; day <= numberOfDays; day++) {
      print("\nGenerating meal plan for Day $day...");

      if (includeBreakfast) {
        if (day == 1) {
          Meal breakfast = await suggestRandomMeal('Breakfast');
          _processMeal('Breakfast', breakfast, day);
        } else {
          Meal breakfast = await suggestTopMeal('Breakfast', day);
          _processMeal('Breakfast', breakfast, day);
        }
      }

      if (includeLunch) {
        if (day == 1) {
          Meal lunch = await suggestRandomMeal('Lunch');
          _processMeal('Lunch', lunch, day);
        } else {
          Meal lunch = await suggestTopMeal('Lunch', day);
          _processMeal('Lunch', lunch, day);
        }
      }

      if (includeDinner) {
        if (day == 1) {
          Meal dinner = await suggestRandomMeal('Dinner');
          _processMeal('Dinner', dinner, day);
        } else {
          Meal dinner = await suggestTopMeal('Dinner', day);
          _processMeal('Dinner', dinner, day);
        }
      }
    }
  }

  // Process the meal and calculate the ingredient overlaps and scores
  void _processMeal(String course, Meal meal, int day) async {
    print("$course for Day $day: ${meal.name}");
    print("Ingredient count: ${meal.ingredientsCount}");
    print("Ingredients: ${meal.ingredients.join(', ')}");

    if (day == 1) {
      day1Ingredients[course] = meal.ingredients; // Store Day 1 ingredients for comparison
      usedMeals.add(meal.name); // Mark this meal as used
    } else {
      // Compare with Day 1 ingredients for the same course
      final day1CourseIngredients = day1Ingredients[course] ?? [];
      final matchingIngredients = meal.ingredients
          .where((ingredient) => day1CourseIngredients.any((day1Ingredient) => _matchIngredient(day1Ingredient, ingredient)))
          .toList();

      print("Overlapping ingredients matched to $course on Day 1: ${matchingIngredients.length}");
      if (matchingIngredients.isNotEmpty) {
        print("Matching ingredients: ${matchingIngredients.join(', ')}");

        int totalWeightScore = 0;

        for (var ingredient in matchingIngredients) {
          final categoryMacro = await _getMacroCategory(ingredient); // Await the result of the async function
          final weight = _getMacroWeight(categoryMacro);
          print("Ingredient: $ingredient, Macro Category: $categoryMacro, Weight: $weight");
          totalWeightScore += weight; // Accumulate the weight
        }

        print("Total weight score: $totalWeightScore");
      } else {
        print("No matching ingredients with $course on Day 1.");
      }
    }
  }

  // Suggest top meal based on ingredient overlap and weight scoring
  Future<Meal> suggestTopMeal(String course, int day) async {
    final meals = await DatabaseHelper.instance.getMealsByCourse(course);

    // Prepare list to hold top 10 meals based on overlapping ingredients
    List<Map<String, dynamic>> topMeals = [];

    for (var meal in meals) {
      if (usedMeals.contains(meal.name)) continue; // Skip used meals

      final day1CourseIngredients = day1Ingredients[course] ?? [];
      final matchingIngredients = meal.ingredients
          .where((ingredient) => day1CourseIngredients.any((day1Ingredient) => _matchIngredient(day1Ingredient, ingredient)))
          .toList();

      // If there are matching ingredients, calculate their score
      if (matchingIngredients.isNotEmpty) {
        int totalWeightScore = 0;

        for (var ingredient in matchingIngredients) {
          final categoryMacro = await _getMacroCategory(ingredient);
          final weight = _getMacroWeight(categoryMacro);
          totalWeightScore += weight;
        }

        topMeals.add({
          'meal': meal,
          'overlapCount': matchingIngredients.length,
          'score': totalWeightScore,
        });
      }
    }

    // Sort meals by number of overlapping ingredients, and then by score
    topMeals.sort((a, b) {
      if (a['overlapCount'] != b['overlapCount']) {
        return b['overlapCount'].compareTo(a['overlapCount']); // Sort by overlap count
      } else if (a['score'] != b['score']) {
        return b['score'].compareTo(a['score']); // Sort by score
      } else {
        return a['meal'].name.compareTo(b['meal'].name); // Sort alphabetically if scores are the same
      }
    });

    // If there are fewer than 10 matching meals, or if none match, use a random meal
    if (topMeals.isEmpty) {
      return suggestRandomMeal(course);
    }

    // Get the top meal and return
    final topMeal = topMeals.first['meal'] as Meal;
    usedMeals.add(topMeal.name); // Mark this meal as used
    return topMeal;
  }

  Future<String> _getMacroCategory(String ingredient) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'ingredient_macros',
      where: 'ingredient_name = ?',
      whereArgs: [ingredient.toLowerCase().trim()],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['macro_category'] as String;
    }

    return 'Unknown'; // Return 'Unknown' if the ingredient is not found in the database
  }

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
        return 0; // Default weight if the category is not recognized
    }
  }
}