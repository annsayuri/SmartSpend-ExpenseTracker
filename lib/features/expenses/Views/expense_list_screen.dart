import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart';
import '../../analytics_screen.dart';

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

  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'

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

  // 🧠 SMART ICON PICKER: පරණ බග් ඔක්කොම ස්ථිරවම පිරිසිදු කරලා හැදුවා!
  Map<String, dynamic> _getCategoryStyle(String title, String type) {
    String lowerTitle = title.toLowerCase();
    
    if (type == 'Income') {
      if (lowerTitle.contains('salary') || lowerTitle.contains('padi')) {
        return {'icon': Icons.payments_rounded, 'color': Colors.green.shade600};
      }
      return {'icon': Icons.add_card_rounded, 'color': Colors.teal.shade600};
    } else {
      // 🏥 Fixed Typos: clinic, care, insurance
      if (lowerTitle.contains('medicine') || lowerTitle.contains('care') || lowerTitle.contains('doctor') || lowerTitle.contains('hospital') || lowerTitle.contains('clinic')) {
        return {'icon': Icons.medical_services_rounded, 'color': Colors.teal.shade700};
      }
      if (lowerTitle.contains('bus') || lowerTitle.contains('train') || lowerTitle.contains('car') || lowerTitle.contains('service') || lowerTitle.contains('insurance')) {
        return {'icon': Icons.directions_bus_rounded, 'color': Colors.orange.shade700};
      }
      if (lowerTitle.contains('food') || lowerTitle.contains('eat') || lowerTitle.contains('kottu') || lowerTitle.contains('hotel')) {
        return {'icon': Icons.fastfood_rounded, 'color': Colors.red.shade400};
      }
      if (lowerTitle.contains('bill') || lowerTitle.contains('current') || lowerTitle.contains('water') || lowerTitle.contains('recharge')) {
        return {'icon': Icons.receipt_long_rounded, 'color': Colors.blue.shade600};
      }
      return {'icon': Icons.shopping_bag_rounded, 'color': Colors.amber.shade800};
    }
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

    final filteredTransactions = _transactions.where((tx) {
      final matchesSearch = tx['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || tx['type'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

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
                            child: _buildTransactionListSection(filteredTransactions),
                          ),
                        ],
                      )
                    : Column( 
                        children: [
                          _buildBalanceCard(),
                          const SizedBox(height: 16.0),
                          _buildPieChartCard(),
                          const SizedBox(height: 20.0),
                          Expanded(child: _buildTransactionListSection(filteredTransactions)),
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
    final isNegative = _totalBalance < 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: isNegative 
          ? Colors.red.shade50.withOpacity(0.8) 
          : Colors.deepPurple.shade50.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isNegative ? 'OVERDRAFT / DEBT' : 'AVAILABLE BALANCE', 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: isNegative ? Colors.red.shade900 : Colors.blueGrey, 
                letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              isNegative 
                  ? '-Rs. ${_totalBalance.abs().toStringAsFixed(2)}' 
                  : 'Rs. ${_totalBalance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 34, 
                fontWeight: FontWeight.w900, 
                color: isNegative ? Colors.red.shade800 : Colors.deepPurple.shade800
              ),
            ),
            const SizedBox(height: 20.0),
            const Divider(color: Colors.black12), 
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceStat(Icons.arrow_downward_rounded, Colors.green.shade600, 'Income', _totalIncome), 
                Container(height: 30, width: 1, color: Colors.black12), 
                _buildBalanceStat(Icons.arrow_upward_rounded, Colors.orange.shade700, 'Expense', _totalExpense), 
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
        );
      },
      child: Card(
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
                            PieChart(
                              PieChartData(
                                sectionsSpace: 5,
                                centerSpaceRadius: 35,
                                sections: _getPieChartSections(),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChartIndicator(Colors.green.shade600, 'Income'), 
                            const SizedBox(height: 12.0),
                            _buildChartIndicator(Colors.orange.shade700, 'Expense'), 
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionListSection(List<Map<String, dynamic>> filteredList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529))),
        const SizedBox(height: 12.0),
        
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
          ),
        ),
        const SizedBox(height: 12.0),

        Row(
          children: ['All', 'Income', 'Expense'].map((filterType) {
            final isSelected = _selectedFilter == filterType;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filterType),
                selected: isSelected,
                selectedColor: Colors.deepPurple.shade100,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.deepPurple.shade800 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() => _selectedFilter = filterType);
                  }
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12.0),

        Expanded(
          child: filteredList.isEmpty
              ? const Center(child: Text('No matching transactions found! 🔍', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final tx = filteredList[index];
                    final isIncome = tx['type'] == 'Income';
                    
                    // 🎨 Smart Category Style එක මෙතනින් ගන්නවා
                    final style = _getCategoryStyle(tx['title'], tx['type']);

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
                        title: tx['title'],
                        date: tx['date'],
                        amount: '${isIncome ? '+' : '-'} Rs. ${tx['amount'].toStringAsFixed(2)}',
                        amountColor: isIncome ? Colors.green.shade600 : Colors.red.shade600, 
                        iconColor: style['color'], // ✅ දැන් Icon එකට හරියටම Category Color එක යනවා!
                        icon: style['icon'], 
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
          color: Colors.green.shade600, 
          value: _totalIncome,
          title: '${incomePercent.toStringAsFixed(0)}%',
          radius: 32,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (_totalExpense > 0)
        PieChartSectionData(
          color: Colors.orange.shade700, 
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

  // 🛠️ Named Parameters දාලා මේක සුපිරියටම Clean කළා!
  Widget _buildTransactionItem({
    required String title, 
    required String date, 
    required String amount, 
    required Color amountColor, 
    required Color iconColor, 
    required IconData icon
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0), side: const BorderSide(color: Color(0xFFE9ECEF))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: iconColor.withOpacity(0.08), // ✅ Category Color එකෙන් ලස්සන වෙනවා
          child: Icon(icon, color: iconColor, size: 20), // ✅ Icon එකත් ඒ පාටම වෙනවා
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF212529), fontSize: 15)),
        subtitle: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.w700, fontSize: 15)), // ✅ ගාණ විතරක් Red/Green වෙනවා
      ),
    );
  }
}