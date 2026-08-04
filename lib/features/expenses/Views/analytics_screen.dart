import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/database/db_helper.dart';
import '../../../core/services/export_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DBHelper _dbHelper = DBHelper();
  
  bool _isLoading = true;
  bool _isWeekly = true;
  bool _isExpenseMode = true;

  Map<String, double> _categoryData = {};
  double _totalAmount = 0.0;
  List<Map<String, dynamic>> _rawTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> allTx = await _dbHelper.getAllTransactions();
    _rawTransactions = allTx;
    
    Map<String, double> tempCategoryMap = _isExpenseMode
        ? {
            'Food': 0.0,
            'Transport': 0.0,
            'Medical': 0.0,
            'Bills': 0.0,
            'Other': 0.0,
          }
        : {
            'Salary': 0.0,
            'Business': 0.0,
            'Investment': 0.0,
            'Gift': 0.0,
            'Other': 0.0,
          };

    double total = 0.0;
    DateTime now = DateTime.now();
    String targetType = _isExpenseMode ? 'Expense' : 'Income';

    for (var tx in allTx) {
      if (tx['type'] == targetType) {
        DateTime txDate;
        try {
          List<String> parts = tx['date'].toString().split('/');
          if (parts.length == 3) {
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);
            txDate = DateTime(year, month, day);
          } else {
            txDate = DateTime.parse(tx['date']);
          }
        } catch (e) {
          txDate = DateTime.now();
        }

        bool includeTx = false;
        if (_isWeekly) {
          Duration difference = now.difference(txDate);
          if (difference.inDays <= 7 && difference.inDays >= 0) {
            includeTx = true;
          }
        } else {
          if (txDate.month == now.month && txDate.year == now.year) {
            includeTx = true;
          }
        }

        if (includeTx) {
          double amount = (tx['amount'] as num).toDouble();
          String title = (tx['title'] as String).toLowerCase();
          
          total += amount;

          if (_isExpenseMode) {
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
          } else {
            if (title.contains('salary') || title.contains('pay') || title.contains('wage')) {
              tempCategoryMap['Salary'] = (tempCategoryMap['Salary'] ?? 0) + amount;
            } else if (title.contains('business') || title.contains('profit') || title.contains('sale')) {
              tempCategoryMap['Business'] = (tempCategoryMap['Business'] ?? 0) + amount;
            } else if (title.contains('invest') || title.contains('stock') || title.contains('crypto') || title.contains('dividend')) {
              tempCategoryMap['Investment'] = (tempCategoryMap['Investment'] ?? 0) + amount;
            } else if (title.contains('gift') || title.contains('bonus')) {
              tempCategoryMap['Gift'] = (tempCategoryMap['Gift'] ?? 0) + amount;
            } else {
              tempCategoryMap['Other'] = (tempCategoryMap['Other'] ?? 0) + amount;
            }
          }
        }
      }
    }

    setState(() {
      _categoryData = tempCategoryMap;
      _totalAmount = total;
      _isLoading = false;
    });
  }

  // Export Options Modal Sheet Dialog
  void _showExportOptions(BuildContext context) {
    if (_rawTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions available to export!')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Transactions 📄',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
                title: const Text('Export as PDF Document', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Download or print formatted PDF report'),
                onTap: () {
                  Navigator.pop(context);
                  ExportService.exportToPDF(_rawTransactions);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green, size: 30),
                title: const Text('Export as CSV Spreadsheet', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Compatible with Microsoft Excel & Google Sheets'),
                onTap: () async {
                  Navigator.pop(context);
                  await ExportService.exportAndShareCSV(_rawTransactions);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey : Colors.grey.shade600;

    final List<String> categories = _categoryData.keys.toList();
    final Color activeThemeColor = _isExpenseMode ? Colors.redAccent : Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Advanced Analytics 📊', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export PDF / CSV',
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expenses / Income Main Toggle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isExpenseMode) {
                                setState(() => _isExpenseMode = true);
                                _loadAnalyticsData();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isExpenseMode ? Colors.redAccent.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _isExpenseMode ? Colors.redAccent : Colors.transparent),
                              ),
                              child: Center(
                                child: Text(
                                  'Expenses 💸',
                                  style: TextStyle(
                                    color: _isExpenseMode ? Colors.redAccent : subTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isExpenseMode) {
                                setState(() => _isExpenseMode = false);
                                _loadAnalyticsData();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isExpenseMode ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: !_isExpenseMode ? Colors.green : Colors.transparent),
                              ),
                              child: Center(
                                child: Text(
                                  'Income 💰',
                                  style: TextStyle(
                                    color: !_isExpenseMode ? Colors.green : subTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Toggle (Weekly / Monthly)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isWeekly
                            ? (_isExpenseMode ? 'LAST 7 DAYS EXPENSES' : 'LAST 7 DAYS INCOME')
                            : (_isExpenseMode ? 'THIS MONTH EXPENSES' : 'THIS MONTH INCOME'),
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
                                  _loadAnalyticsData();
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
                                  _loadAnalyticsData();
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

                  // Bar Chart Card
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
                                _isExpenseMode ? 'Expense Overview' : 'Income Overview',
                                style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total: Rs. ${_totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: activeThemeColor, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: (_totalAmount > 0 ? _totalAmount * 1.2 : 1000),
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
                                        color: _isExpenseMode ? Colors.orangeAccent : Colors.greenAccent.shade700,
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

                  // Category Breakdown List Title
                  Text(
                    _isExpenseMode ? 'CATEGORY SPENDING (EXPENSE)' : 'INCOME SOURCES',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category Cards
                  if (_totalAmount == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _isExpenseMode
                              ? 'No expense records found for this period! 📉'
                              : 'No income records found for this period! 📈',
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: categories.map((category) {
                        double amount = _categoryData[category] ?? 0.0;
                        if (amount == 0) return const SizedBox.shrink();

                        double percentage = (_totalAmount > 0) ? (amount / _totalAmount) * 100 : 0.0;

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
                              '${percentage.toStringAsFixed(1)}% of total ${_isExpenseMode ? 'expense' : 'income'}',
                              style: TextStyle(color: subTextColor, fontSize: 12),
                            ),
                            trailing: Text(
                              'Rs. ${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: activeThemeColor,
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
