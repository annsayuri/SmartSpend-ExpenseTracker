import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  // 🔒 Singleton Pattern එක මඟින් එකම instance එකක් පමණක් පවත්වා ගනී
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // 🗄️ Database එක දැනටමත් open වෙලාද නැද්ද කියා පරීක්ෂා කිරීම
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 🚀 Database එක initialising කිරීම සහ දුරකථනයේ path එක සෙවීම
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartspend.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 📝 SQLite Table එක නිර්මාණය කිරීම (පළමු වතාවේදී පමණක් ක්‍රියාත්මක වේ)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ➕ CREATE (C) - අලුත් ගනුදෙනුවක් එකතු කිරීම
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('transactions', row);
  }

  // 📖 READ (R) - සියලුම ගනුදෙනු දත්ත ලබාගැනීම
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    // අලුත්ම දත්ත ලිස්ට් එකේ උඩටම එන්න id එක DESC විදිහට sort කරලා තියෙන්නේ
    return await db.query('transactions', orderBy: 'id DESC');
  }

  // 🔄 UPDATE (U) - දත්තයක් වෙනස් කිරීම
  Future<int> updateTransaction(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update(
      'transactions',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ❌ DELETE (D) - දත්තයක් මකා දැමීම
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}