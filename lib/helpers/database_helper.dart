import 'package:flutter/services.dart'; // To load the CSV file
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/meal.dart';
import '../models/profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE profiles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      ageGroup TEXT,
      icon TEXT,
      dietPreferences TEXT,
      allergies TEXT,
      isMain INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE meals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      cuisine TEXT,
      diet TEXT,
      ingredientsCount INTEGER,
      prepTime INTEGER,
      cookTime INTEGER,
      imageUrl TEXT,
      course TEXT,
      ingredients TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE ingredient_macros (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ingredient_name TEXT,
      macro_category TEXT,
      macro_weight INTEGER
    )
    ''');

    await _loadIngredientMacros(db); // Load the CSV data into the database
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE ingredient_macros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_name TEXT,
        macro_category TEXT,
        macro_weight INTEGER
      )
      ''');

      await _loadIngredientMacros(db); // Load the CSV data into the database
    }
  }

  Future<void> _loadIngredientMacros(Database db) async {
    final csvData = await rootBundle.loadString('assets/ingredient_category_macros.csv');
    final lines = csvData.split('\n');

    // Debug print to ensure the CSV data is loaded
    print('Loaded ${lines.length} lines from ingredient macros CSV');

    for (var line in lines.skip(1)) { // Skip header row
      final values = line.split(',');
      if (values.length >= 5) {
        await db.insert('ingredient_macros', {
          'ingredient_name': values[1].trim(), // Column B
          'macro_category': values[4].trim(),  // Column E
          'macro_weight': _getMacroWeight(values[4].trim()) // Assign weights
        });

        // Debug print to confirm each insert
        print('Inserted ingredient macro: ${values[1].trim()} with weight ${_getMacroWeight(values[4].trim())}');
      }
    }
  }

  int _getMacroWeight(String category) {
    const weights = {
      'Additive': 3,
      'Beverage': 1,
      'Beverage Alcoholic': 2,
      'Carbohydrate': 6,
      'Cereal': 5,
      'Condiment': 1,
      'Dairy': 8,
      'Fat': 7,
      'Fruit': 6,
      'Fungus': 8,
      'Herb': 4,
      'High Sugar': 1,
      'Oil': 1,
      'Protein': 10,
      'Sauce': 1,
      'Spice': 2,
      'Vegetable': 9,
    };
    return weights[category] ?? 0; // Default to 0 if category is not found
  }

  Future<int> createProfile(Profile profile) async {
    final db = await instance.database;

    // If no profiles exist, set this profile as the main profile
    final profiles = await getProfiles();
    if (profiles.isEmpty) {
      profile = profile.copyWith(isMain: true);
    }

    return await db.insert('profiles', profile.toMap());
  }

  Future<List<Profile>> getProfiles() async {
    final db = await instance.database;
    final result = await db.query('profiles');
    return result.map((json) => Profile.fromMap(json)).toList();
  }

  Future<void> deleteProfile(int id) async {
    final db = await instance.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);

    // Ensure there's always one main profile
    final profiles = await getProfiles();
    if (profiles.isNotEmpty && profiles.every((profile) => !profile.isMain)) {
      final earliestProfile = profiles.first;
      await db.update('profiles', {'isMain': 1}, where: 'id = ?', whereArgs: [earliestProfile.id]);
    }
  }

  Future<void> setMainProfile(int id) async {
    final db = await instance.database;
    await db.update('profiles', {'isMain': 0}, where: 'isMain = ?', whereArgs: [1]);
    await db.update('profiles', {'isMain': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createMeal(Meal meal) async {
    final db = await instance.database;
    // Ensure we are not inserting a header row
    if (meal.name.toLowerCase() != 'name') {
      return await db.insert('meals', meal.toMap());
    }
    return 0;
  }

  Future<Map<String, int>> getIngredientWeights(List<String> ingredients) async {
    final db = await instance.database;
    final ingredientWeights = <String, int>{};

    for (final ingredient in ingredients) {
      final result = await db.query(
        'ingredient_macros',
        where: 'ingredient_name = ?',
        whereArgs: [ingredient],
      );

      if (result.isNotEmpty) {
        ingredientWeights[ingredient] = result.first['macro_weight'] as int;
      } else {
        ingredientWeights[ingredient] = 0; // Default weight if not found
      }

      // Debug print for each ingredient weight retrieval
      print('Ingredient: $ingredient, Weight: ${ingredientWeights[ingredient]}');
    }

    return ingredientWeights;
  }
}