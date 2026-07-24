import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/db_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DBHelper _dbHelper = DBHelper();
  
  bool _isLoading = true;
  bool _isWeekly = true; // Weekly or Monthly Filter Toggle
  
  Map<String, double> _categoryData = {
    'Food': 0.0,
    'Transport': 0.0,
    'Medical': 0.0,
    'Bills': 0.0,
    'Other': 0.0,
  };

  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  // 🔄 DB එකෙන් Expense දත්ත අරන් Date Filter එක අනුව බෙදාගැනීම
  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> allTx = await _dbHelper.getAllTransactions();
    
    Map<String, double> tempCategoryMap = {
      'Food': 0.0,
      'Transport': 0.0,
      'Medical': 0.0,
      'Bills': 0.0,
      'Other': 0.0,
    };

    double total = 0.0;
    DateTime now = DateTime.now();

    for (var tx in allTx) {
      if (tx['type'] == 'Expense') {
        // Date parse කරගැනීම
        DateTime txDate = DateTime.parse(tx['date']);

        // 📅 Filter Logic Check
        bool includeTx = false;
        if (_isWeekly) {
          // පහුගිය දවස් 7 ඇතුළත Transactions විතරක් ගන්න
          Duration difference = now.difference(txDate);
          if (difference.inDays <= 7 && difference.inDays >= 0) {
            includeTx = true;
          }
        } else {
          // මේ මාසේ (Current Month & Year) Transactions විතරක් ගන්න
          if (txDate.month == now.month && txDate.year == now.year) {
            includeTx = true;
          }
        }

        if (includeTx) {
          double amount = (tx['amount'] as num).toDouble();
          String title = (tx['title'] as String).toLowerCase();
          
          total += amount;

          // Categorization Logic based on Title keywords
          if (title.contains('food') || title.contains('eat') || title.contains('rice') || title.contains('lunch')) {
            tempCategoryMap['Food'] = (tempCategoryMap['Food'] ?? 0) + amount;
          } else if (title.contains('bus') || title.contains('train') || title.contains('fuel') || title.contains('transport') || title.contains('cab')) {
            tempCategoryMap['Transport'] = (tempCategoryMap['Transport'] ?? 0) + amount;
          } else if (title.contains('doctor') || title.contains('medicine') || title.contains('medical') || title.contains('hospital')) {
            tempCategoryMap['Medical'] = (tempCategoryMap['Medical'] ?? 0) + amount;
          } else if (title.contains('bill') || title.contains('electricity') || title.contains('water') || title.contains('broadband') || title.contains('dialog')) {
            tempCategoryMap['Bills'] = (tempCategoryMap['Bills'] ?? 0) + amount;
          } else {
            tempCategoryMap['Other'] = (tempCategoryMap['Other'] ?? 0) + amount;
          }
        }
      }
    }

    setState(() {
      _categoryData = tempCategoryMap;
      _totalExpense = total;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey : Colors.grey.shade600;

    final List<String> categories = _categoryData.keys.toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Advanced Analytics 📊', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1️⃣ Header Toggle (Weekly / Monthly)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isWeekly ? 'LAST 7 DAYS EXPENSES' : 'THIS MONTH EXPENSES',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!_isWeekly) {
                                  setState(() => _isWeekly = true);
                                  _loadAnalyticsData(); // Data re-load වෙනවා
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isWeekly ? Colors.deepPurple : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Weekly',
                                  style: TextStyle(
                                    color: _isWeekly ? Colors.white : subTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_isWeekly) {
                                  setState(() => _isWeekly = false);
                                  _loadAnalyticsData(); // Data re-load වෙනවා
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_isWeekly ? Colors.deepPurple : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Monthly',
                                  style: TextStyle(
                                    color: !_isWeekly ? Colors.white : subTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2️⃣ Bar Chart Card
                  Card(
                    color: cardColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Expense Overview',
                                style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total: Rs. ${_totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (_totalExpense > 0 ? _totalExpense * 1.2 : 1000),
                                barTouchData: BarTouchData(enabled: true),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        int index = value.toInt();
                                        if (index >= 0 && index < categories.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              categories[index],
                                              style: TextStyle(
                                                color: subTextColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(categories.length, (index) {
                                  double val = _categoryData[categories[index]] ?? 0.0;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: val,
                                        color: Colors.orangeAccent,
                                        width: 18,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3️⃣ Category Spending List Title
                  Text(
                    'CATEGORY SPENDING (EXPENSE)',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4️⃣ Category Cards
                  if (_totalExpense == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No expense records found for this period! 📉',
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: categories.map((category) {
                        double amount = _categoryData[category] ?? 0.0;
                        if (amount == 0) return const SizedBox.shrink();

                        double percentage = (_totalExpense > 0) ? (amount / _totalExpense) * 100 : 0.0;

                        return Card(
                          color: cardColor,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            title: Text(
                              category,
                              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15),
                            ),
                            subtitle: Text(
                              '${percentage.toStringAsFixed(1)}% of total expense',
                              style: TextStyle(color: subTextColor, fontSize: 12),
                            ),
                            trailing: Text(
                              'Rs. ${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}