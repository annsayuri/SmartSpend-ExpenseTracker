import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart'; // 📊 ඔන්න ප්‍රස්ථාර අඳින පැකේජ් එක Import කළා!
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

  void _addNewTransaction(String title, double amount, String type) async {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    await _dbHelper.insertTransaction({
      'title': title,
      'amount': amount,
      'type': type,
      'date': currentDate, 
    });
    if (!mounted) return;
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
          : Column( 
              children: [
                // 📊 1. SECTION: NEW PIE CHART 
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _transactions.isEmpty
                        ? const Center(
                            child: Text(
                              '📊 Add transactions to visualize analytics',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          )
                        : Row(
                            children: [
                              // Chart එක පැත්ත
                              Expanded(
                                flex: 2,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 30,
                                    sections: _getPieChartSections(),
                                  ),
                                ),
                              ),
                              // Indicators (විස්තරය) පැත්ත
                              Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildChartIndicator(Colors.green, 'Income'),
                                    const SizedBox(height: 8.0),
                                    _buildChartIndicator(Colors.red, 'Expense'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // 💰 2. SECTION: AVAILABLE BALANCE CARD
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        const Text('Available Balance', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 4.0),
                        Text(
                          'Rs. ${_totalBalance.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                                const SizedBox(width: 4.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Income', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text('Rs. ${_totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                                const SizedBox(width: 4.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Expense', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text('Rs. ${_totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
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
                const SizedBox(height: 12.0),
                
                // 📑 3. SECTION: RECENT TRANSACTIONS LIST
                Expanded(
                  child: _transactions.isEmpty
                      ? const Center(child: Text('No transactions found. Add some! 🛍️'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            final isIncome = tx['type'] == 'Income';
                            
                            return Dismissible(
                              key: Key(tx['id'].toString()), 
                              direction: DismissDirection.endToStart, 
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400, 
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) async {
                                await _dbHelper.deleteTransaction(tx['id']);
                                _refreshTransactions();

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${tx['title']}" deleted successfully!'),
                                    backgroundColor: Colors.red.shade400,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: _buildTransactionItem(
                                tx['title'],
                                tx['date'],
                                '${isIncome ? '+' : '-'} Rs. ${tx['amount'].toStringAsFixed(2)}',
                                isIncome ? Colors.green : Colors.red,
                              ),
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                onAddTransaction: _addNewTransaction,
              ),
            ),
          );
          _refreshTransactions();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🥧 Pie Chart එකට දත්ත සකස් කරන Helper ශ්‍රිතය
  List<PieChartSectionData> _getPieChartSections() {
    final double total = _totalIncome + _totalExpense;
    if (total == 0) return [];

    final double incomePercent = (_totalIncome / total) * 100;
    final double expensePercent = (_totalExpense / total) * 100;

    return [
      if (_totalIncome > 0)
        PieChartSectionData(
          color: Colors.green.shade400,
          value: _totalIncome,
          title: '${incomePercent.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (_totalExpense > 0)
        PieChartSectionData(
          color: Colors.red.shade400,
          value: _totalExpense,
          title: '${expensePercent.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
  }

  // 🟢🔴 Chart එකේ පාට සහ විස්තර පෙන්වන කුඩා Widget එක
  Widget _buildChartIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
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