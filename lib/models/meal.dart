import 'profile.dart'; 

class Meal {
  String name;
  String description;
  String cuisine;
  String diet;
  int ingredientsCount;
  int prepTime;
  int cookTime;
  String imageUrl;
  String course;
  List<String> ingredients; // Existing field to store ingredients as a list
  String ingredientsString; // New field to store ingredients as a comma-separated string
  List<Profile>? profiles;

  Meal({
    required this.name,
    required this.description,
    required this.cuisine,
    required this.diet,
    required this.ingredientsCount,
    required this.prepTime,
    required this.cookTime,
    required this.imageUrl,
    required this.course,
    required this.ingredients, 
    required this.ingredientsString, // Initialize ingredientsString
    this.profiles,
  });

  factory Meal.fromCsv(List<dynamic> row) {
    final ingredientsString = row[5] as String;
    return Meal(
      name: row[0] as String,
      description: row[1] as String,
      cuisine: row[2] as String,
      diet: row[4] as String,
      ingredientsCount: ingredientsString.split(',').length,
      prepTime: int.tryParse(row[7].toString()) ?? 0,
      cookTime: int.tryParse(row[8].toString()) ?? 0,
      imageUrl: row[10] as String,
      course: row[3] as String,
      ingredients: ingredientsString.split(',').map((ingredient) => ingredient.trim()).toList(), // Trim each ingredient 
      ingredientsString: ingredientsString, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'cuisine': cuisine,
      'diet': diet,
      'ingredientsCount': ingredientsCount,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'imageUrl': imageUrl,
      'course': course,
      'ingredients': ingredients.join(','), // Store the comma-separated string
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    final ingredientsString = map['ingredients'] as String;
    return Meal(
      name: map['name'],
      description: map['description'],
      cuisine: map['cuisine'],
      diet: map['diet'],
      ingredientsCount: map['ingredientsCount'],
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      imageUrl: map['imageUrl'],
      course: map['course'],
      ingredients: ingredientsString.split(','), 
      ingredientsString: ingredientsString, 
    );
  }
}