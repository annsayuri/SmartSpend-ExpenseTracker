import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  // 📊 දත්ත තාවකාලිකව තබා ගන්නා ප්‍රධාන List එක
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Monthly Salary',
      'date': '30/6/2026',
      'amount': 85000.00,
      'type': 'Income'
    },
    {
      'title': 'Rice & Curry',
      'date': '30/6/2026',
      'amount': 450.00,
      'type': 'Expense'
    },
    {
      'title': 'Bus Fare',
      'date': '30/6/2026',
      'amount': 120.00,
      'type': 'Expense'
    },
  ];

  // 💰 මුළු බැලන්ස් එක සහ Income/Expense ගණනය කරන Function එක
  double get _totalBalance {
    double balance = 0.0;
    for (var tx in _transactions) {
      if (tx['type'] == 'Income') {
        balance += tx['amount'];
      } else {
        balance -= tx['amount'];
      }
    }
    return balance;
  }

  double get _totalIncome {
    return _transactions
        .where((tx) => tx['type'] == 'Income')
        .fold(0.0, (sum, tx) => sum + tx['amount']);
  }

  double get _totalExpense {
    return _transactions
        .where((tx) => tx['type'] == 'Expense')
        .fold(0.0, (sum, tx) => sum + tx['amount']);
  }

  // ➕ අලුත් ගනුදෙනුවක් ලිස්ට් එකට එකතු කරන ශ්‍රිතය (Function)
  void _addNewTransaction(String title, double amount, String type) {
    setState(() {
      _transactions.add({
        'title': title,
        'date': '03/7/2026', // 👈 අද දවස තාවකාලිකව දැම්මා
        'amount': amount,
        'type': type,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSpend 💰'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Rs. ${_totalBalance.toStringAsFixed(2)}', // 👈 ගණනය කළ බැලන්ස් එක පෙන්වයි
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.green),
                            const SizedBox(width: 4.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Income', style: TextStyle(color: Colors.grey)),
                                Text('Rs. ${_totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.arrow_upward, color: Colors.red),
                            const SizedBox(width: 4.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expense', style: TextStyle(color: Colors.grey)),
                                Text('Rs. ${_totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              
              // 🔄 ඩේටා ලිස්ට් එක dynamic ලෙස පෙන්වන කොටස
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];
                  final isIncome = tx['type'] == 'Income';
                  return _buildTransactionItem(
                    tx['title'],
                    tx['date'],
                    '${isIncome ? '+' : '-'} Rs. ${tx['amount'].toStringAsFixed(2)}',
                    isIncome ? Colors.green : Colors.red,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          // 🚀 මෙන්න අපි අලුත් Screen එකට Data එකතු කරන Function එක පාස් කළා!
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                onAddTransaction: _addNewTransaction, // 👈 Callback එක සම්බන්ධ කළා
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(color == Colors.green ? Icons.account_balance_wallet : Icons.money_off, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}