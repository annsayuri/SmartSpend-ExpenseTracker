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

    // Match exact category string or fallback to 'other'
    final catRaw = (map['category'] ?? '').toString().toLowerCase().trim();
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == catRaw,
      orElse: () => ExpenseCategory.other,
    );

    final typeRaw = (map['type'] ?? '').toString().toLowerCase().trim();
    final type = (typeRaw == 'income')
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