import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('profile.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE profiles (
  id $idType,
  name $textType,
  isOver18 $boolType,
  allergies $textType,
  dietPreferences $textType,
  profileIcon $textType,
  isMain $boolType
)
    ''');
    debugPrint('Database created with table profiles');
  }

  Future<void> insertProfile(Map<String, dynamic> profile) async {
    final db = await database;
    final existingProfiles = await getProfiles();

    // Check if this is the first profile being added
    if (existingProfiles.isEmpty) {
      profile['isMain'] = 1; // Set the first profile as main profile
    } else {
      profile['isMain'] = 0; // Additional profiles are not main profiles
    }

    await db.insert(
      'profiles',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('Inserted profile: $profile');
  }

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await database;
    final profiles = await db.query('profiles');
    debugPrint('Fetched profiles: $profiles');
    return profiles;
  }

  Future<void> setMainProfile(int id) async {
    final db = await instance.database;
    await db.update('profiles', {'isMain': 0}, where: 'isMain = 1');
    await db.update('profiles', {'isMain': 1}, where: 'id = ?', whereArgs: [id]);
    debugPrint('Set profile $id as main profile');
  }

  Future<void> deleteProfile(int id) async {
    final db = await instance.database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
    debugPrint('Deleted profile: $id');
  }
}