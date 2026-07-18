import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DBHelper {
  // 🔒 Singleton Pattern
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;
  
  // 🌐 Web වලදී දත්ත තාවකාලිකව තබා ගැනීමට Memory List එකක් (Mock SQL Database)
  final List<Map<String, dynamic>> _webMockDatabase = [];
  int _nextWebId = 1;

  // 🗄️ Database Instance එක ලබා ගැනීම
  Future<dynamic> get database async {
    if (kIsWeb) return null; // Web වලදී ඇත්තම DB එකක් ඕපන් කරන්නේ නැහැ
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 📱 Mobile වලදී පමණක් Database එක initialising කිරීම
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smartspend.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 📝 SQLite Table එක නිර්මාණය කිරීම (Mobile)
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

  // ➕ CREATE - අලුත් ගනුදෙනුවක් එකතු කිරීම
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    if (kIsWeb) {
      // 🌐 Web Mock Logic:
      final newRow = Map<String, dynamic>.from(row);
      newRow['id'] = _nextWebId++;
      _webMockDatabase.add(newRow);
      return newRow['id'];
    } else {
      // 📱 Mobile SQLite:
      final db = await database as Database;
      return await db.insert('transactions', row);
    }
  }

  // 📖 READ - සියලුම ගනුදෙනු දත්ත ලබාගැනීම
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    if (kIsWeb) {
      // 🌐 Web Mock Logic: (id එක DESC විදිහට සෝට් කරලා දෙනවා)
      final sortedList = List<Map<String, dynamic>>.from(_webMockDatabase);
      sortedList.sort((a, b) => b['id'].compareTo(a['id']));
      return sortedList;
    } else {
      // 📱 Mobile SQLite:
      final db = await database as Database;
      return await db.query('transactions', orderBy: 'id DESC');
    }
  }

  // 🔄 UPDATE - දත්තයක් වෙනස් කිරීම
  Future<int> updateTransaction(Map<String, dynamic> row) async {
    int id = row['id'];
    if (kIsWeb) {
      // 🌐 Web Mock Logic:
      int index = _webMockDatabase.indexWhere((element) => element['id'] == id);
      if (index != -1) {
        _webMockDatabase[index] = row;
        return 1;
      }
      return 0;
    } else {
      // 📱 Mobile SQLite:
      final db = await database as Database;
      return await db.update(
        'transactions',
        row,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // ❌ DELETE - දත්තයක් මකා දැමීම
  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      // 🌐 Web Mock Logic:
      int initialLength = _webMockDatabase.length;
      _webMockDatabase.removeWhere((element) => element['id'] == id);
      return initialLength - _webMockDatabase.length;
    } else {
      // 📱 Mobile SQLite:
      final db = await database as Database;
      return await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // 🎯 Budget එක සේව් කරන්න හෝ අප්ඩේට් කරන්න
  Future<int> insertOrUpdateBudget(double amount) async {
    if (kIsWeb) {
      // 🌐 Web Mock Logic:
      int index = _webMockDatabase.indexWhere((element) => element['title'] == 'MONTHLY_BUDGET_LIMIT');
      if (index != -1) {
        _webMockDatabase[index]['amount'] = amount;
        return 1;
      } else {
        _webMockDatabase.add({
          'id': _nextWebId++,
          'title': 'MONTHLY_BUDGET_LIMIT',
          'amount': amount,
          'type': 'Budget',
          'date': '01/07/2026',
        });
        return 1;
      }
    } else {
      // 📱 Mobile SQLite Logic:
      final db = await database as Database;
      List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: "title = ?",
        whereArgs: ['MONTHLY_BUDGET_LIMIT'],
      );

      if (maps.isNotEmpty) {
        return await db.update(
          'transactions',
          {'amount': amount},
          where: "title = ?",
          whereArgs: ['MONTHLY_BUDGET_LIMIT'],
        );
      } else {
        return await db.insert('transactions', {
          'title': 'MONTHLY_BUDGET_LIMIT',
          'amount': amount,
          'type': 'Budget',
          'date': '01/07/2026',
        });
      }
    }
  }

  // 🎯 සේව් කරපු Budget එක අරගන්න
  Future<double> getBudget() async {
    if (kIsWeb) {
      // 🌐 Web Mock Logic:
      int index = _webMockDatabase.indexWhere((element) => element['title'] == 'MONTHLY_BUDGET_LIMIT');
      if (index != -1) {
        return _webMockDatabase[index]['amount'] as double;
      }
      return 0.0;
    } else {
      // 📱 Mobile SQLite Logic:
      final db = await database as Database;
      List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: "title = ?",
        whereArgs: ['MONTHLY_BUDGET_LIMIT'],
      );
      if (maps.isNotEmpty) {
        return maps.first['amount'] as double;
      }
      return 0.0;
    }
  }
}