import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/db_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Weekly'; // 'Weekly' ho 'Monthly'

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    final data = await _dbHelper.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  // 🧮 Category anuwa wiyadam ekathu karala map ekak hadagannawa
  Map<String, double> _getCategoryExpenses() {
    // Categories default reset ekak ekka thiyagannawa dynamic adu paadu novenna
    Map<String, double> categoryMap = {
      'Food': 0.0,
      'Transport': 0.0,
      'Medical': 0.0,
      'Bills': 0.0,
      'Other': 0.0,
    };

    for (var tx in _transactions) {
      if (tx['type'] == 'Expense') {
        String title = tx['title'].toString().toLowerCase();
        double amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
        String category = 'Other';
        
        // 🔍 Spelling mistakes (insuarance/insurance) okkoma cover wana lesa
        if (title.contains('bus') || 
            title.contains('car') || 
            title.contains('train') || 
            title.contains('service') || 
            title.contains('insuarance') || 
            title.contains('insurance')) {
          category = 'Transport';
        } else if (title.contains('food') || title.contains('eat') || title.contains('kottu')) {
          category = 'Food';
        } else if (title.contains('medicine') || title.contains('doctor') || title.contains('hospital')) {
          category = 'Medical';
        } else if (title.contains('bill') || title.contains('current') || title.contains('water') || title.contains('recharge')) {
          category = 'Bills';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Advanced Analytics 📊', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade700,
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
                      // 🎛️ Period Selector (Weekly / Monthly)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Expense Breakdown',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
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
                              selectedBackgroundColor: Colors.deepPurple.shade100,
                              selectedForegroundColor: Colors.deepPurple.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 📈 1. THE BAR CHART CARD
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
                              const Text(
                                'Expense Overview (Rs.)',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
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
                                              case 4: return const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Other', style: style));
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
                                      _makeBarGroup(4, categoryExpenses['Other'] ?? 0, Colors.amber.shade700),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 📜 2. CATEGORY WISE DETAILS LIST
                      const Text(
                        'Category Spending',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212529)),
                      ),
                      const SizedBox(height: 12),
                      ...categoryExpenses.entries.map((entry) {
                        final percent = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0.0;
                        // 0 ta wada wadi wiyadam thiyena ewath, wiyadam zero nam okkoma categories methana pennanawa
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
                            subtitle: Text('${percent.toStringAsFixed(1)}% of total expenses'),
                            trailing: Text(
                              'Rs. ${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
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