import '../helpers/database_helper.dart';
import '../models/meal.dart';

class MealData {
  static final MealData instance = MealData._init();

  MealData._init();

  Future<List<Meal>> getMeals() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('meals');
    return result.map((json) => Meal.fromMap(json)).toList();
  }

  Future<Meal> suggestRandomMeal(String course) async {
    final meals = await getMeals();
    final filteredMeals = meals.where((meal) => meal.course == course).toList();
    if (filteredMeals.isEmpty) {
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
      );
    }
    filteredMeals.shuffle();
    return filteredMeals.first;
  }
}