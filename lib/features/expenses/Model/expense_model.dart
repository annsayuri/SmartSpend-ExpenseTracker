import 'package:flutter/material.dart';

enum TransactionType { income, expense }

// 🟢 All Expense and Income categories
enum ExpenseCategory {
  // Expenses
  food,
  transport,
  bills,
  shopping,
  education,
  entertainment,
  healthcare,

  // Income
  salary,
  allowance,
  business,
  gift,
  bonus,
  wage,

  // Fallback
  other,
}

class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final TransactionType type;

  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = ExpenseCategory.other,
    this.type = TransactionType.expense,
  });

  /// Get display name for category
  static String getCategoryDisplayName(ExpenseCategory category) {
    switch (category) {
      // Expenses
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.healthcare:
        return 'Healthcare';

      // Income
      case ExpenseCategory.salary:
        return 'Salary';
      case ExpenseCategory.allowance:
        return 'Allowance';
      case ExpenseCategory.business:
        return 'Business';
      case ExpenseCategory.gift:
        return 'Gift';
      case ExpenseCategory.bonus:
        return 'Bonus';
      case ExpenseCategory.wage:
        return 'Wage';

      case ExpenseCategory.other:
      default:
        return 'Other';
    }
  }

  /// Get category from display name
  static ExpenseCategory getCategoryFromDisplayName(String displayName) {
    switch (displayName) {
      case 'Food':
        return ExpenseCategory.food;
      case 'Transport':
        return ExpenseCategory.transport;
      case 'Bills':
        return ExpenseCategory.bills;
      case 'Shopping':
        return ExpenseCategory.shopping;
      case 'Education':
        return ExpenseCategory.education;
      case 'Entertainment':
        return ExpenseCategory.entertainment;
      case 'Healthcare':
        return ExpenseCategory.healthcare;
      case 'Salary':
        return ExpenseCategory.salary;
      case 'Allowance':
        return ExpenseCategory.allowance;
      case 'Business':
        return ExpenseCategory.business;
      case 'Gift':
        return ExpenseCategory.gift;
      case 'Bonus':
        return ExpenseCategory.bonus;
      case 'Wage':
        return ExpenseCategory.wage;
      case 'Other':
      default:
        return ExpenseCategory.other;
    }
  }

  /// Robust helper to parse category from any DB format
  static ExpenseCategory parseCategory(dynamic rawCategory) {
    if (rawCategory == null) return ExpenseCategory.other;

    final String str = rawCategory.toString().trim().toLowerCase();

    // 1. Direct name or Enum string match
    for (var cat in ExpenseCategory.values) {
      if (cat.name.toLowerCase() == str ||
          'expensecategory.${cat.name.toLowerCase()}' == str) {
        return cat;
      }
    }

    // 2. Custom mappings
    switch (str) {
      case 'food':
        return ExpenseCategory.food;
      case 'transport':
      case 'bus':
      case 'travel':
        return ExpenseCategory.transport;
      case 'bills':
      case 'electricity bill':
      case 'utility':
        return ExpenseCategory.bills;
      case 'shopping':
        return ExpenseCategory.shopping;
      case 'education':
        return ExpenseCategory.education;
      case 'entertainment':
        return ExpenseCategory.entertainment;
      case 'healthcare':
      case 'medical':
        return ExpenseCategory.healthcare;
      case 'salary':
        return ExpenseCategory.salary;
      case 'allowance':
        return ExpenseCategory.allowance;
      case 'business':
        return ExpenseCategory.business;
      case 'gift':
        return ExpenseCategory.gift;
      case 'bonus':
        return ExpenseCategory.bonus;
      case 'wage':
        return ExpenseCategory.wage;
    }

    // 3. Fallback for Integer Index
    final intIndex = int.tryParse(str);
    if (intIndex != null &&
        intIndex >= 0 &&
        intIndex < ExpenseCategory.values.length) {
      return ExpenseCategory.values[intIndex];
    }

    return ExpenseCategory.other;
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    int? parsedId;
    try {
      if (map['id'] != null) {
        parsedId = (map['id'] is int)
            ? map['id'] as int
            : int.tryParse(map['id'].toString());
      }
    } catch (_) {
      parsedId = null;
    }

    DateTime parsedDate;
    try {
      final rawDate = map['date']?.toString() ?? '';
      if (rawDate.contains('/')) {
        final parts = rawDate.split('/');
        parsedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        parsedDate = DateTime.parse(rawDate);
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    // Advanced Robust Category Parsing
    final category = parseCategory(map['category']);

    final typeRaw = (map['type'] ?? '').toString().toLowerCase().trim();
    final type = (typeRaw == 'income' || typeRaw == 'transactiontype.income')
        ? TransactionType.income
        : TransactionType.expense;

    return ExpenseModel(
      id: parsedId,
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] is num)
          ? (map['amount'] as num).toDouble()
          : double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      date: parsedDate,
      category: category,
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
      'type': type.name,
    };
  }

  ExpenseModel copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    TransactionType? type,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
    );
  }
}

typedef TransactionModel = ExpenseModel;