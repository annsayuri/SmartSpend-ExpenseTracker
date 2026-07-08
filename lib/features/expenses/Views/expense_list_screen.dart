import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart'; 

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text('SmartSpend 💰', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200), 
                padding: const EdgeInsets.all(16.0),
                child: isWeb 
                    ? Row( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildBalanceCard(),
                                  const SizedBox(height: 16.0),
                                  _buildPieChartCard(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24.0),
                          Expanded(
                            flex: 6,
                            child: _buildTransactionListSection(),
                          ),
                        ],
                      )
                    : Column( 
                        children: [
                          _buildBalanceCard(),
                          const SizedBox(height: 16.0),
                          _buildPieChartCard(),
                          const SizedBox(height: 20.0),
                          Expanded(child: _buildTransactionListSection()),
                        ],
                      ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
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
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple.shade50.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('AVAILABLE BALANCE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
            const SizedBox(height: 8.0),
            Text(
              'Rs. ${_totalBalance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.deepPurple.shade800),
            ),
            const SizedBox(height: 20.0),
            const Divider(color: Colors.black12), // 🛠️ Fixed Colors.black10 error
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceStat(Icons.arrow_downward_rounded, Colors.green.shade600, 'Income', _totalIncome), // 🛠️ Fixed Colors.emerald error
                Container(height: 30, width: 1, color: Colors.black12), // 🛠️ Fixed Colors.black10 error
                _buildBalanceStat(Icons.arrow_upward_rounded, Colors.orange.shade700, 'Expense', _totalExpense), // 🛠️ Fixed Colors.orangeAccent error
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceStat(IconData icon, Color color, String label, double amount) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
            Text('Rs. ${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: const BorderSide(color: Color(0xFFE9ECEF))),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ANALYTICS OVERVIEW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
            const SizedBox(height: 24.0),
            _transactions.isEmpty
                ? const SizedBox(
                    height: 140,
                    child: Center(child: Text('📊 Add transactions for analytics', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 130,
                        width: 130,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 5,
                            centerSpaceRadius: 35,
                            sections: _getPieChartSections(),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChartIndicator(Colors.green.shade600, 'Income'), // 🛠️ Fixed Error
                          const SizedBox(height: 12.0),
                          _buildChartIndicator(Colors.orange.shade700, 'Expense'), // 🛠️ Fixed Error
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: _transactions.isEmpty
              ? const Card(
                  elevation: 0,
                  child: Center(child: Text('No transactions found. Add some! 🛍️', style: TextStyle(color: Colors.grey))),
                )
              : ListView.builder(
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
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                      ),
                      onDismissed: (direction) async {
                        await _dbHelper.deleteTransaction(tx['id']);
                        _refreshTransactions();

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"${tx['title']}" deleted successfully!'),
                            backgroundColor: Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: _buildTransactionItem(
                        tx['title'],
                        tx['date'],
                        '${isIncome ? '+' : '-'} Rs. ${tx['amount'].toStringAsFixed(2)}',
                        isIncome ? Colors.green.shade600 : Colors.orange.shade700, // 🛠️ Fixed Error
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final double total = _totalIncome + _totalExpense;
    if (total == 0) return [];

    final double incomePercent = (_totalIncome / total) * 100;
    final double expensePercent = (_totalExpense / total) * 100;

    return [
      if (_totalIncome > 0)
        PieChartSectionData(
          color: Colors.green.shade600, // 🛠️ Fixed Error
          value: _totalIncome,
          title: '${incomePercent.toStringAsFixed(0)}%',
          radius: 32,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (_totalExpense > 0)
        PieChartSectionData(
          color: Colors.orange.shade700, // 🛠️ Fixed Error
          value: _totalExpense,
          title: '${expensePercent.toStringAsFixed(0)}%',
          radius: 32,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
  }

  Widget _buildChartIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.08),
          child: Icon(color == Colors.green.shade600 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF212529), fontSize: 15)),
        subtitle: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
      ),
    );
  }
}