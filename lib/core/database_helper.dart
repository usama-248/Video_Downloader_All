import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'video_downloads.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT,
        filePath TEXT,
        videoUrl TEXT,
        quality TEXT,
        fileSize TEXT,
        dateTime TEXT
      )
    ''');
  }

  Future<int> insertDownload(Map<String, dynamic> download) async {
    Database db = await database;
    return await db.insert('downloads', download);
  }

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    Database db = await database;
    return await db.query('downloads', orderBy: 'dateTime DESC');
  }

  Future<int> deleteDownload(int id) async {
    Database db = await database;
    return await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllDownloads() async {
    Database db = await database;
    await db.delete('downloads');
  }
}