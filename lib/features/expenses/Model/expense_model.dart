enum TransactionType { income, expense }

enum ExpenseCategory { food, transport, entertainment, bills, education, salary, savings, others }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
  });
}