import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smartspend_expensetracker/core/database/db_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  final String initialType;

  const AnalyticsScreen({super.key, this.initialType = 'Expense'}); 

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Weekly'; // 'Weekly' ho 'Monthly'
  String _selectedType = 'Expense';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType; 
    _fetchData();
  }

  // 🎯 NEW: Pie Chart එකෙන් එලියෙන් Type එක මාරු කරලා මේ ස්ක්‍රීන් එකට එවද්දී 
  // මේකෙන් තමයි අලුත් අගය අරන් මුළු Page එකම Update කරන්නේ!
  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialType != oldWidget.initialType) {
      setState(() {
        _selectedType = widget.initialType;
      });
      _fetchData(); // 🔄 Data ටික අලුතින් ෆිල්ටර් කරන්න ගන්නවා
    }
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final data = await _dbHelper.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  // 🧮 Category anuwa filter karala map ekak hadagannawa
  Map<String, double> _getCategoryExpenses() {
    Map<String, double> categoryMap = {
      'Food': 0.0,
      'Transport': 0.0,
      'Medical': 0.0,
      'Bills': 0.0,
      'Salary/Allowance': 0.0, 
      'Other': 0.0,
    };

    for (var tx in _transactions) {
      if (tx['type'] == _selectedType) { 
        // 🔍 Title එක වගේම Category හෝ Description එකත් චෙක් කරනවා ආරක්ෂාවට
        String title = (tx['title'] ?? '').toString().toLowerCase();
        String categoryField = (tx['category'] ?? '').toString().toLowerCase();
        
        double amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
        String category = 'Other';
        
        // 🚌 Transport checking (මෙතන title හෝ categoryField දෙකම බලනවා)
        if (title.contains('bus') || title.contains('car') || title.contains('transport') ||
            categoryField.contains('bus') || categoryField.contains('car') || categoryField.contains('transport') ||
            title.contains('train') || title.contains('service')) {
          category = 'Transport';
        } 
        // 🍔 Food checking
        else if (title.contains('food') || title.contains('eat') || title.contains('kottu') ||
                 categoryField.contains('food') || categoryField.contains('eat')) {
          category = 'Food';
        } 
        // 🏥 Medical checking
        else if (title.contains('medicine') || title.contains('doctor') || title.contains('hospital') ||
                 categoryField.contains('medical') || categoryField.contains('medicine')) {
          category = 'Medical';
        } 
        // 💡 Bills checking
        else if (title.contains('bill') || title.contains('current') || title.contains('water') ||
                 categoryField.contains('bill')) {
          category = 'Bills';
        } 
        // 💵 Salary checking
        else if (title.contains('salary') || title.contains('padi') || title.contains('allowance') ||
                 categoryField.contains('salary') || categoryField.contains('income')) {
          category = 'Salary/Allowance';
        }

        categoryMap[category] = (categoryMap[category] ?? 0.0) + amount;
      }
    }
    return categoryMap;
  }

  @override
  Widget build(BuildContext context) {
    final categoryExpenses = _getCategoryExpenses();
    final totalExpense = categoryExpenses.values.fold(0.0, (sum, item) => sum + item);

    final isExpense = _selectedType == 'Expense';
    final themeColor = isExpense ? Colors.red.shade400 : Colors.green.shade500;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Advanced Analytics ($_selectedType) 📊', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isExpense ? Colors.deepPurple.shade700 : Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_selectedType Breakdown', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                          ),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'Weekly', label: Text('Weekly')),
                              ButtonSegment(value: 'Monthly', label: Text('Monthly')),
                            ],
                            selected: {_selectedPeriod},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _selectedPeriod = newSelection.first;
                              });
                            },
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: isExpense ? Colors.deepPurple.shade100 : Colors.teal.shade100,
                              selectedForegroundColor: isExpense ? Colors.deepPurple.shade800 : Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_selectedType Overview (Rs.)', 
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 250,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: totalExpense == 0 ? 1000 : totalExpense * 1.2,
                                    barTouchData: BarTouchData(enabled: true),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            const style = TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 11);
                                            switch (value.toInt()) {
                                              case 0: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Food', style: style));
                                              case 1: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Transport', style: style));
                                              case 2: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Medical', style: style));
                                              case 3: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Bills', style: style));
                                              case 4: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Salary', style: style));
                                              case 5: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Other', style: style));
                                              default: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('', style: style));
                                            }
                                          },
                                        ),
                                      ),
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: [
                                      _makeBarGroup(0, categoryExpenses['Food'] ?? 0, Colors.red.shade400),
                                      _makeBarGroup(1, categoryExpenses['Transport'] ?? 0, Colors.orange.shade600),
                                      _makeBarGroup(2, categoryExpenses['Medical'] ?? 0, Colors.teal.shade600),
                                      _makeBarGroup(3, categoryExpenses['Bills'] ?? 0, Colors.blue.shade600),
                                      _makeBarGroup(4, categoryExpenses['Salary/Allowance'] ?? 0, Colors.green.shade600),
                                      _makeBarGroup(5, categoryExpenses['Other'] ?? 0, Colors.amber.shade700),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Category Spending ($_selectedType)', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                      ),
                      const SizedBox(height: 12),
                      ...categoryExpenses.entries.map((entry) {
                        final percent = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;
                        if (entry.value == 0 && totalExpense > 0) return const SizedBox.shrink();

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE9ECEF)),
                          ),
                          child: ListTile(
                            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${percent.toStringAsFixed(1)}% of total ${_selectedType.toLowerCase()}'), 
                            trailing: Text(
                              'Rs. ${entry.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: themeColor, 
                                fontSize: 15
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}