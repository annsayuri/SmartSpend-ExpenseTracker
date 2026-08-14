import 'package:smartspend_expensetracker/core/database/db_helper.dart';

class ExpenseRepository {
  final DBHelper _dbHelper = DBHelper();

  // 1. Fetch All Transactions
  Future<List<ExpenseModel>> fetchTransactions() async {
    final rawData = await _dbHelper.getAllTransactions();
    return rawData.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  // 2. Add New Transaction
  Future<int> addTransaction(ExpenseModel expense) async {
    final map = expense.toMap();
    return await _dbHelper.insertTransaction(map);
  }

  // 3. Update Existing Transaction
  Future<int> updateTransaction(ExpenseModel expense) async {
    return await _dbHelper.updateTransaction(expense.toMap());
  }

  // 4. Delete Transaction
  Future<int> deleteTransaction(int id) async {
    return await _dbHelper.deleteTransaction(id);
  }

  // 5. Clear All Transactions
  Future<int> clearAllTransactions() async {
    return await _dbHelper.deleteAllTransactions();
  }

  // 6. Get Budget
  Future<double> fetchBudget() async {
    return await _dbHelper.getBudget();
  }

  // 7. Save Budget
  Future<void> saveBudget(double amount) async {
    await _dbHelper.setBudget(amount);
  }
}