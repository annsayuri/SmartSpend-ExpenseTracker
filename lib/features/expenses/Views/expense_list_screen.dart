import 'package:flutter/material.dart';
import 'add_transaction_screen.dart'; // 👈 අලුත් screen එක import කරගත්තා!

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
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
              // Available Balance Card
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
                    const Text(
                      'Rs. 84430.00',
                      style: TextStyle(
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
                                Text('Rs. 85000.00', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
                                Text('Rs. 570.00', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
              
              // Dummy List Elements
              _buildTransactionItem('Monthly Salary', '30/6/2026', '+ Rs. 85000.00', Colors.green),
              _buildTransactionItem('Rice & Curry', '30/6/2026', '- Rs. 450.00', Colors.red),
              _buildTransactionItem('Bus Fare', '30/6/2026', '- Rs. 120.00', Colors.red),
            ],
          ),
        ),
      ),
      
      // ➕ මෙන්න අපි අලුතින්ම එකතු කරපු Floating Action Button එක!
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          // 🚀 Dashboard එකේ ඉඳන් Add Transaction Screen එකට මාරු වෙන කේතය
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
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
          child: Icon(title == 'Monthly Salary' ? Icons.account_balance_wallet : Icons.money_off, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ),
    );
  }
}