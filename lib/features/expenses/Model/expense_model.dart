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

  /// Robust helper to parse category from any DB format (String, Enum Name, Index, etc.)
  static ExpenseCategory parseCategory(dynamic rawCategory) {
    if (rawCategory == null) return ExpenseCategory.other;

    final String str = rawCategory.toString().trim().toLowerCase();

    // 1. Direct name or Enum string match (e.g., "bills", "expensecategory.bills")
    for (var cat in ExpenseCategory.values) {
      if (cat.name.toLowerCase() == str ||
          'expensecategory.${cat.name.toLowerCase()}' == str) {
        return cat;
      }
    }

    // 2. Custom mappings if saved via Display Titles/Synonyms in DB
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

    // 3. Fallback for Integer Index saved in DB (e.g., 0, 1, 2)
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