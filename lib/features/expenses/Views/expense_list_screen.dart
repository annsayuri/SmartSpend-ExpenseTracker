import 'package:flutter/material.dart';
import '../model/expense_model.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📝 පරීක්ෂා කරලා බලන්න අපි තාවකාලිකව හදාගත්ත Dummy Expenses ලැයිස්තුවක්
    final List<Expense> dummyExpenses = [
      Expense(
        id: '1',
        title: 'Rice & Curry',
        amount: 450.00,
        date: DateTime.now(),
        category: ExpenseCategory.food,
      ),
      Expense(
        id: '2',
        title: 'Bus Fare',
        amount: 120.00,
        date: DateTime.now(),
        category: ExpenseCategory.transport,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartSpend 💰',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: dummyExpenses.length,
        itemBuilder: (context, index) {
          final expense = dummyExpenses[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.monetization_on, color: Colors.white),
              ),
              title: Text(
                expense.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${expense.date.day}/${expense.date.month}/${expense.date.year}',
              ),
              trailing: Text(
                'Rs. ${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}