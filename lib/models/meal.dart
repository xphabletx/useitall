import 'profile.dart'; // Import Profile model

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
    this.profiles,
  });

  factory Meal.fromCsv(List<dynamic> row) {
    return Meal(
      name: row[0] as String,
      description: row[1] as String,
      cuisine: row[2] as String,
      diet: row[4] as String,
      ingredientsCount: (row[5] as String).split(',').length,
      prepTime: int.tryParse(row[7].toString()) ?? 0,
      cookTime: int.tryParse(row[8].toString()) ?? 0,
      imageUrl: row[10] as String,
      course: row[3] as String,
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
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
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
    );
  }
}