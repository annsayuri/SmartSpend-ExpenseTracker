import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 👈 Date එක format කරගන්න intl package එක දාගන්න (pubspec.yaml එකට intl දාන්න)
import '../../../core/database/db_helper.dart'; 
import 'add_transaction_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final DBHelper _dbHelper = DBHelper(); 
  List<Map<String, dynamic>> _transactions = []; 
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _refreshTransactions(); 
  }

  void _refreshTransactions() async {
    final data = await _dbHelper.getAllTransactions();
    
    if (!mounted) return;

    setState(() {
      _transactions = data;
      _isLoading = false; 
    });
  }

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

  // 💡 _addNewTransaction එක මෙතනින් අයින් කරලා AddTransactionScreen එක ඇතුළෙන්ම DB එකට සේව් කරන එක වඩාත් සුදුසුයි.
  // හැබැයි ඔයාට මෙතනම ඕන නම්, Date එක dynamic කලේ මෙහෙමයි:
  void _addNewTransaction(String title, double amount, String type) async {
    // 📅 හැමදාටම හරියන විදිහට dynamic date එකක් ගත්තා
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    await _dbHelper.insertTransaction({
      'title': title,
      'amount': amount,
      'type': type,
      'date': currentDate, 
    });
    
    if (!mounted) return; // 🛡️ Safety check එකක් දැම්මා
    setState(() => _isLoading = true);
    _refreshTransactions(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartSpend 💰'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : Column( // 💡 SingleChildScrollView එක අයින් කරලා Column + Expanded දැම්මා Performance හොඳ වෙන්න
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        const Text('Available Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 8.0),
                        Text(
                          'Rs. ${_totalBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // 📊 ඩේටා ලිස්ට් එක smooth වෙන්න Expanded එකක් ඇතුළට ListView එක දැම්මා
                Expanded(
                  child: _transactions.isEmpty
                      ? const Center(child: Text('No transactions found. Add some! 🛍️'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () async {
          // 💡 Navigation එක await කිරීමෙන්, අනිත් Screen එක close වෙලා මෙහාට ආපු ගමන් data refresh කරගන්න පුළුවන්!
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                onAddTransaction: _addNewTransaction,
              ),
            ),
          );
          
          // ආපහු මේ screen එකට ආවම data ටික auto refresh වෙනවා!
          _refreshTransactions();
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