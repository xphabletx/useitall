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

    return await openDatabase(path, version: 1, onCreate: _createDB);
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
      course TEXT
    )
    ''');
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
}