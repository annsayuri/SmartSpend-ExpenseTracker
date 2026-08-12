import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smartspend_expensetracker/features/expenses/model/user_model.dart';

export 'package:smartspend_expensetracker/features/expenses/model/user_model.dart';
export 'package:smartspend_expensetracker/features/expenses/model/expense_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;
  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'smartspend.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUsersTable(db);
        }
        if (oldVersion < 3) {
          await _createBillsTable(db);
        }
        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE transactions ADD COLUMN user_id INTEGER;');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT;');
          } catch (_) {}
        }
        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE transactions ADD COLUMN category TEXT DEFAULT "Other";');
          } catch (_) {}
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await _createUsersTable(db);
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT DEFAULT 'Other',
        date TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    await _createBillsTable(db);
  }

  static Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createBillsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // 🔐 AUTHENTICATION METHODS
  // ---------------------------------------------------------------------------

  Future<bool> registerUser(String name, String email, String password, {Role role = Role.USER}) async {
    try {
      final db = await database;
      final existingUsers = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (existingUsers.isNotEmpty) return false;

      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      UserModel newUser = UserModel(
        name: name.trim(),
        email: email.toLowerCase().trim(),
        password: hashedPassword,
        role: role,
      );

      await db.insert('users', newUser.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (maps.isNotEmpty) {
        UserModel user = UserModel.fromMap(maps.first);
        if (BCrypt.checkpw(password, user.password)) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', user.id!);
          await prefs.setString('user_name', user.name);
          await prefs.setString('user_email', user.email);
          await prefs.setString('user_role', user.role.name);
          await prefs.setBool('is_logged_in', true);
          return user;
        }
      }
    } catch (e) {
      // Log error if needed
    }
    return null;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (maps.isEmpty) return false;

      String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      int count = await db.update(
        'users',
        {'password': hashedPassword},
        where: 'LOWER(email) = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<Map<String, dynamic>?> getCurrentUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('is_logged_in') ?? false)) return null;

    return {
      'id': prefs.getInt('user_id'),
      'name': prefs.getString('user_name'),
      'email': prefs.getString('user_email'),
      'role': prefs.getString('user_role'),
    };
  }

  // ---------------------------------------------------------------------------
  // 💸 EXPENSE / TRANSACTION METHODS
  // ---------------------------------------------------------------------------

  Future<int> deleteAllTransactions() async {
    final db = await database;
    return await db.delete('transactions');
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    final userSession = await getCurrentUserSession();
    final userId = userSession != null ? userSession['id'] : null;

    Map<String, dynamic> data = Map.from(transaction);
    if (!data.containsKey('user_id') || data['user_id'] == null) {
      data['user_id'] = userId;
    }
    if (!data.containsKey('category') || data['category'] == null || data['category'].toString().isEmpty) {
      data['category'] = 'Other';
    }

    return await db.insert('transactions', data);
  }

  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    Map<String, dynamic> data = Map.from(transaction);
    if (!data.containsKey('category') || data['category'] == null || data['category'].toString().isEmpty) {
      data['category'] = 'Other';
    }
    return await db.update(
      'transactions',
      data,
      where: 'id = ?',
      whereArgs: [transaction['id']],
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    final userSession = await getCurrentUserSession();
    final userId = userSession != null ? userSession['id'] : null;

    if (userId != null) {
      return await db.query(
        'transactions',
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [userId],
        orderBy: 'date DESC, id DESC',
      );
    }
    return await db.query('transactions', orderBy: 'date DESC, id DESC');
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ---------------------------------------------------------------------------
  // 🎯 BUDGET METHODS
  // ---------------------------------------------------------------------------
  
  Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('budget_limit') ?? 0.0;
  }

  Future<void> setBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_limit', amount);
  }

  // ---------------------------------------------------------------------------
  // 🔔 BILL REMINDER METHODS
  // ---------------------------------------------------------------------------

  Future<int> insertBill(String title, double amount, String dueDate) async {
    final db = await database;
    final userSession = await getCurrentUserSession();
    final userId = userSession != null ? userSession['id'] : null;

    return await db.insert('bills', {
      'user_id': userId,
      'title': title,
      'amount': amount,
      'due_date': dueDate,
      'is_paid': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUserBills() async {
    final db = await database;
    final userSession = await getCurrentUserSession();
    final userId = userSession != null ? userSession['id'] : null;

    if (userId != null) {
      return await db.query(
        'bills',
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [userId],
        orderBy: 'id DESC',
      );
    }
    return await db.query('bills', orderBy: 'id DESC');
  }

  Future<void> markBillAsPaid(int billId, String title, double amount, String dueDate) async {
    final db = await database;
    final userSession = await getCurrentUserSession();
    final userId = userSession != null ? userSession['id'] : null;

    await db.update(
      'bills',
      {'is_paid': 1},
      where: 'id = ?',
      whereArgs: [billId],
    );

    await db.insert('transactions', {
      'user_id': userId,
      'title': 'Paid: $title',
      'amount': amount,
      'category': 'Bills & Utilities',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'type': 'Expense',
    });
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllBills() async {
    final db = await database;
    return await db.delete('bills');
  }

  // ---------------------------------------------------------------------------
  // 🧹 COMPLETE APP RESET METHOD
  // ---------------------------------------------------------------------------

  /// Clean all app data from Database (Transactions & Bills)
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('bills');
  }
}
