import 'package:flutter/material.dart';
import 'package:smartspend_expensetracker/features/expenses/model/expense_model.dart';
import 'package:smartspend_expensetracker/features/expenses/repository/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();

  List<ExpenseModel> _transactions = [];
  double _budgetLimit = 0.0;
  bool _isLoading = false;

  // Getters
  List<ExpenseModel> get transactions => _transactions;
  double get budgetLimit => _budgetLimit;
  bool get isLoading => _isLoading;

  // Calculated Properties
  double get totalIncome => _transactions
      .where((item) => item.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => _transactions
      .where((item) => item.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalBalance => totalIncome - totalExpenses;

  // 1. Initial Data Loading
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _repository.fetchTransactions();
      _budgetLimit = await _repository.fetchBudget();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Add Expense / Income
  Future<bool> addTransaction(ExpenseModel expense) async {
    final result = await _repository.addTransaction(expense);
    if (result > 0) {
      await loadInitialData();
      return true;
    }
    return false;
  }

  // 3. Update Transaction
  Future<bool> updateTransaction(ExpenseModel expense) async {
    final result = await _repository.updateTransaction(expense);
    if (result > 0) {
      await loadInitialData();
      return true;
    }
    return false;
  }

  // 4. Delete Transaction
  Future<bool> deleteTransaction(int id) async {
    final result = await _repository.deleteTransaction(id);
    if (result > 0) {
      await loadInitialData();
      return true;
    }
    return false;
  }

  // 5. Update Budget Limit
  Future<void> setBudget(double amount) async {
    await _repository.saveBudget(amount);
    _budgetLimit = amount;
    notifyListeners();
  }
}