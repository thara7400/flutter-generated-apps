import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Book {
  final int? id;
  final String title;
  final String review;
  final double rating;

  const Book({
    this.id,
    required this.title,
    this.review = '',
    this.rating = 0.0,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'review': review,
        'rating': rating,
      };

  factory Book.fromMap(Map<String, Object?> map) => Book(
        id: map['id'] as int?,
        title: map['title'] as String,
        review: (map['review'] as String?) ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      );
}

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => db.execute(
        'CREATE TABLE books('
        'id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'title TEXT NOT NULL, '
        'review TEXT NOT NULL DEFAULT \'\', '
        'rating REAL NOT NULL DEFAULT 0)',
      ),
    );
  }

  Future<Book> insertBook(String title) async {
    final db = await _database;
    final id = await db.insert('books', {
      'title': title,
      'review': '',
      'rating': 0.0,
    });
    return Book(id: id, title: title);
  }

  Future<List<Book>> getAllBooks() async {
    final db = await _database;
    final maps = await db.query('books', orderBy: 'id DESC');
    return maps.map(Book.fromMap).toList();
  }

  Future<void> updateBook(int id, String review, double rating) async {
    final db = await _database;
    await db.update(
      'books',
      {'review': review, 'rating': rating},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
