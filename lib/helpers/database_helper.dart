import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/meal.dart';
import '../models/profile.dart';
import '../utilities/csv_util.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
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
      macro_category TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE ingredient_synonyms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ingredient_name TEXT,
      synonyms TEXT
    )
    ''');

    // Load meals and macros from CSV as part of the database creation only if needed
    await _checkDatabase(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE ingredient_macros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_name TEXT,
        macro_category TEXT
      )
      ''');

      await db.execute('''
      CREATE TABLE ingredient_synonyms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_name TEXT,
        synonyms TEXT
      )
      ''');

      await _checkDatabase(db);  // Load data if needed during an upgrade
    }
  }

  Future<void> _checkDatabase(Database db) async {
    final mealCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM meals')) ?? 0;
    final macroCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ingredient_macros')) ?? 0;

    if (mealCount < 1177) {
      print('No or insufficient meals found in the database. Loading from CSV...');
      await _loadMealsFromCsv(db);
    }

    if (macroCount < 681) {
      print('No or insufficient ingredient macros found in the database. Loading from CSV...');
      await _loadMacrosFromCsv(db);
    } else {
      print('Meals already loaded: $mealCount');
      print('Ingredient macros already loaded: $macroCount');
    }
  }

  Future<void> _loadMacrosFromCsv(Database db) async {
    try {
      final macroData = await loadIngredientMacrosFromCsv();
      print('Loaded ${macroData.length} ingredient macros from CSV');

      for (final macro in macroData) {
        await db.insert('ingredient_macros', macro);
        print('Inserted ingredient macro: ${macro['ingredient_name']}');
      }
    } catch (e) {
      print('Error loading ingredient macros from CSV: $e');
    }
  }

  Future<void> _loadMealsFromCsv(Database db) async {
    try {
      final meals = await loadMealsFromCsv();
      print('Loaded ${meals.length} meals from CSV');

      for (final meal in meals) {
        await db.insert('meals', meal.toMap());
        print('Inserted meal: ${meal.name}');
      }
    } catch (e) {
      print('Error loading meals from CSV: $e');
    }
  }

  Future<int> createMeal(Meal meal) async {
    final db = await instance.database;

    if (meal.name.toLowerCase() != 'name') {
      final mealMap = meal.toMap();
      mealMap['ingredientsCount'] ??= meal.ingredients.length;
      return await db.insert('meals', mealMap);
    }
    return 0;
  }

  Future<int> getMealsCount() async {
    final db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM meals'));
    return count ?? 0;
  }

  Future<List<Meal>> getMealsByCourse(String course) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'meals',
      where: 'course = ?',
      whereArgs: [course],
    );
    return results.map((json) => Meal.fromMap(json)).toList();
  }

  Future<int> createProfile(Profile profile) async {
    final db = await instance.database;

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
}