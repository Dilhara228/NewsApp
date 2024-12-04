import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/new_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'news_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bookmarks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT UNIQUE,
            description TEXT,
            urlToImage TEXT,
            author TEXT,
            content TEXT,
            publishedAt TEXT
          )
        ''');
      },
    );
  }

  // Add a new bookmark
  Future<int> addBookmark(NewsModel article) async {
    final db = await database;

    // Check if the article already exists in the database by title
    final List<Map<String, dynamic>> existingBookmarks = await db.query(
      'bookmarks',
      where: 'title = ?',
      whereArgs: [article.title],
    );

    // If the article already exists, do not add it again
    if (existingBookmarks.isNotEmpty) {
      return 0; // Indicate no new record was inserted
    }

    // Insert the article if it's not already in the database
    return await db.insert('bookmarks', {
      'title': article.title,
      'description': article.description,
      'urlToImage': article.urlToImage,
      'author': article.author,
      'content': article.content,
      'publishedAt': article.publishedAt,
    });
  }

  // Fetch all saved bookmarks
  Future<List<NewsModel>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');
    return List.generate(maps.length, (i) {
      return NewsModel(
        title: maps[i]['title'],
        description: maps[i]['description'],
        urlToImage: maps[i]['urlToImage'],
        author: maps[i]['author'],
        content: maps[i]['content'],
        publishedAt: maps[i]['publishedAt'],
      );
    });
  }

  // Remove a bookmark by its title
  Future<int> removeBookmark(String title) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'title = ?', whereArgs: [title]);
  }
}
