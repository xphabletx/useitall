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
  }

  Future<void> insertProfile(Map<String, dynamic> profile) async {
    final db = await database;
    await db.insert(
      'profiles',
      profile,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await database;
    return await db.query('profiles');
  }

  Future<void> setMainProfile(int id) async {
    final db = await database;
    await db.update('profiles', {'isMain': 0}, where: 'isMain = 1');
    await db.update('profiles', {'isMain': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProfile(int id) async {
    final db = await database;
    await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }
}