import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📝 දැන් අපිට ආදායම් සහ වියදම් දෙකම තියෙන Dummy ලැයිස්තුවක් තියෙනවා
    final List<TransactionModel> dummyTransactions = [
      TransactionModel(
        id: '1',
        title: 'Monthly Salary',
        amount: 85000.00,
        date: DateTime.now(),
        category: ExpenseCategory.salary,
        type: TransactionType.income,
      ),
      TransactionModel(
        id: '2',
        title: 'Rice & Curry',
        amount: 450.00,
        date: DateTime.now(),
        category: ExpenseCategory.food,
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: '3',
        title: 'Bus Fare',
        amount: 120.00,
        date: DateTime.now(),
        category: ExpenseCategory.transport,
        type: TransactionType.expense,
      ),
    ];

    // 🧮 මුළු ආදායම, වියදම සහ ඉතිරි ගණන ගණනය කරමු
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in dummyTransactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    double availableBalance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SmartSpend 💰',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🏠 Dashboard Balance Card
          Card(
            margin: const EdgeInsets.all(16.0),
            color: Colors.deepPurple.shade50,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Income Row
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.green),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Income', style: TextStyle(color: Colors.black54)),
                              Text(
                                'Rs. ${totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Expense Row
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.red),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Expense', style: TextStyle(color: Colors.black54)),
                              Text(
                                'Rs. ${totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // 📜 Transactions List
          Expanded(
            child: ListView.builder(
              itemCount: dummyTransactions.length,
              itemBuilder: (context, index) {
                final tx = dummyTransactions[index];
                final isIncome = tx.type == TransactionType.income;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isIncome ? Icons.account_balance_wallet : Icons.money_off, 
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      tx.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year}'),
                    trailing: Text(
                      '${isIncome ? "+ " : "- "}Rs. ${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}