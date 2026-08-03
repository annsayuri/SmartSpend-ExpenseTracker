import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smartspend_expensetracker/core/services/export_service.dart';
import 'package:smartspend_expensetracker/features/expenses/model/expense_model.dart';
import 'package:smartspend_expensetracker/features/expenses/provider/expense_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isWeekly = true;
  bool _isExpenseMode = true;
  int _touchedIndex = -1;

  // Category Name Resolver (Fix for Enum / String / SQLite mismatch)
  String _getCategoryName(dynamic category) {
    if (category == null) return 'Other';

    // String එකක් හෝ Enum එකක් ආවත් clean string එකක් බවට හරවගැනීම
    String catStr = category
        .toString()
        .replaceAll('ExpenseCategory.', '')
        .trim()
        .toLowerCase();

    switch (catStr) {
      // Expenses
      case 'food':
      case 'eat':
      case 'kottu':
      case 'hotel':
      case 'restaurant':
        return 'Food';

      case 'transport':
      case 'bus':
      case 'train':
      case 'car':
      case 'pickme':
      case 'uber':
      case 'fuel':
        return 'Transport';

      case 'bills':
      case 'bill':
      case 'current':
      case 'water':
      case 'recharge':
      case 'utility':
        return 'Bills';

      case 'shopping':
      case 'clothes':
      case 'daraz':
        return 'Shopping';

      case 'education':
      case 'school':
      case 'campus':
      case 'course':
      case 'books':
        return 'Education';

      case 'healthcare':
      case 'medical':
      case 'medicine':
      case 'doctor':
      case 'hospital':
      case 'clinic':
        return 'Medical';

      case 'entertainment':
      case 'movie':
      case 'game':
      case 'leisure':
        return 'Entertainment';

      // Income
      case 'salary':
      case 'padi':
      case 'job':
        return 'Salary';

      case 'allowance':
      case 'pocketmoney':
        return 'Allowance';

      case 'business':
      case 'profit':
      case 'trade':
        return 'Business';

      case 'gift':
      case 'present':
        return 'Gift';

      case 'bonus':
        return 'Bonus';

      case 'wage':
        return 'Wage';

      default:
        // Text එකක් ඇතුළේ මෙම වචන තිබේදැයි පරීක්ෂා කිරීම (Partial match fallback)
        if (catStr.contains('food') || catStr.contains('eat')) return 'Food';
        if (catStr.contains('trans') || catStr.contains('bus') || catStr.contains('train')) return 'Transport';
        if (catStr.contains('bill') || catStr.contains('water') || catStr.contains('elect')) return 'Bills';
        if (catStr.contains('shop')) return 'Shopping';
        if (catStr.contains('edu') || catStr.contains('school')) return 'Education';
        if (catStr.contains('medic') || catStr.contains('health') || catStr.contains('doctor')) return 'Medical';
        if (catStr.contains('sal') || catStr.contains('padi')) return 'Salary';
        if (catStr.contains('allow')) return 'Allowance';
        if (catStr.contains('busin')) return 'Business';
        if (catStr.contains('gift')) return 'Gift';

        return 'Other';
    }
  }

  // Get display categories based on mode
  List<String> _getDisplayCategories() {
    if (_isExpenseMode) {
      return [
        'Food',
        'Transport',
        'Bills',
        'Shopping',
        'Education',
        'Medical',
        'Entertainment',
        'Other'
      ];
    } else {
      return [
        'Salary',
        'Allowance',
        'Business',
        'Gift',
        'Bonus',
        'Wage',
        'Other'
      ];
    }
  }

  // Get category color
  Color _getCategoryColor(String category, bool isDark) {
    final colors = {
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Bills': Colors.red,
      'Shopping': Colors.purple,
      'Education': Colors.teal,
      'Medical': Colors.pink,
      'Entertainment': Colors.amber,
      'Salary': Colors.green,
      'Allowance': Colors.cyan,
      'Business': Colors.indigo,
      'Gift': Colors.pink.shade300,
      'Bonus': Colors.yellow.shade700,
      'Wage': Colors.brown,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  void _showExportOptions(
      BuildContext context, List<ExpenseModel> rawTransactions) {
    if (rawTransactions.isEmpty) {
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
                'Export Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf,
                    color: Colors.redAccent, size: 30),
                title: const Text('Export as PDF Document',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Download formatted PDF report'),
                onTap: () {
                  Navigator.pop(context);
                  ExportService.exportToPDF(
                    rawTransactions.map((tx) => tx.toMap()).toList(),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart,
                    color: Colors.green, size: 30),
                title: const Text('Export as CSV Spreadsheet',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Compatible with Excel & Google Sheets'),
                onTap: () async {
                  Navigator.pop(context);
                  await ExportService.exportAndShareCSV(
                    rawTransactions.map((tx) => tx.toMap()).toList(),
                  );
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
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey : Colors.grey.shade600;

    final provider = Provider.of<ExpenseProvider>(context);
    final allTx = provider.transactions;

    // Get display categories
    final displayCategories = _getDisplayCategories();

    // Initialize Category Map with all display categories
    Map<String, double> categoryMap = {};
    for (var cat in displayCategories) {
      categoryMap[cat] = 0.0;
    }

    double total = 0.0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetType =
        _isExpenseMode ? TransactionType.expense : TransactionType.income;

    // Filter & Calculate totals
    for (var tx in allTx) {
      if (tx.type == targetType) {
        bool includeTx = false;
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

        if (_isWeekly) {
          final differenceInDays = today.difference(txDate).inDays;
          if (differenceInDays >= 0 && differenceInDays < 7) {
            includeTx = true;
          }
        } else {
          if (tx.date.month == now.month && tx.date.year == now.year) {
            includeTx = true;
          }
        }

        if (includeTx) {
          total += tx.amount;
          String categoryLabel = _getCategoryName(tx.category);
          if (categoryMap.containsKey(categoryLabel)) {
            categoryMap[categoryLabel] =
                (categoryMap[categoryLabel] ?? 0.0) + tx.amount;
          } else {
            // If category not in map, add to "Other"
            categoryMap['Other'] = (categoryMap['Other'] ?? 0.0) + tx.amount;
          }
        }
      }
    }

    // Get non-zero categories for bar chart
    final List<MapEntry<String, double>> nonZeroEntries =
        categoryMap.entries.where((e) => e.value > 0).toList();

    // Sort by amount descending
    nonZeroEntries.sort((a, b) => b.value.compareTo(a.value));

    final List<String> categories =
        nonZeroEntries.map((e) => e.key).toList();
    final List<double> amounts = nonZeroEntries.map((e) => e.value).toList();

    final Color activeThemeColor =
        _isExpenseMode ? Colors.orangeAccent : Colors.greenAccent.shade700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Advanced Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor:
            isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export PDF / CSV',
            onPressed: () => _showExportOptions(context, allTx),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense / Income Mode Toggle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFE9ECEF)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isExpenseMode) {
                                setState(() => _isExpenseMode = true);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isExpenseMode
                                    ? Colors.redAccent.withAlpha(38)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _isExpenseMode
                                        ? Colors.redAccent
                                        : Colors.transparent,
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  'Expenses',
                                  style: TextStyle(
                                    color: _isExpenseMode
                                        ? Colors.redAccent
                                        : subTextColor,
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
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isExpenseMode
                                    ? Colors.green.withAlpha(38)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: !_isExpenseMode
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  'Income',
                                  style: TextStyle(
                                    color: !_isExpenseMode
                                        ? Colors.green
                                        : subTextColor,
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

                  // Time Period Header & Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isWeekly
                            ? (_isExpenseMode
                                ? 'LAST 7 DAYS EXPENSES'
                                : 'LAST 7 DAYS INCOME')
                            : (_isExpenseMode
                                ? 'THIS MONTH EXPENSES'
                                : 'THIS MONTH INCOME'),
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
                          border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : const Color(0xFFE9ECEF)),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (!_isWeekly) {
                                  setState(() => _isWeekly = true);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isWeekly
                                      ? Colors.deepPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Weekly',
                                  style: TextStyle(
                                    color:
                                        _isWeekly ? Colors.white : subTextColor,
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
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: !_isWeekly
                                      ? Colors.deepPurple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Monthly',
                                  style: TextStyle(
                                    color: !_isWeekly
                                        ? Colors.white
                                        : subTextColor,
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

                  // ═══════════════════════════════════════
                  // 🔥 IMPROVED BAR CHART WITH ALL CATEGORIES
                  // ═══════════════════════════════════════
                  Card(
                    color: cardColor,
                    elevation: 2,
                    shadowColor: isDark ? Colors.black54 : Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: isDark
                              ? Colors.white10
                              : const Color(0xFFE9ECEF)),
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
                                _isExpenseMode
                                    ? 'Expense Overview'
                                    : 'Income Overview',
                                style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total: Rs. ${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: activeThemeColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // If no data, show empty state
                          if (total == 0)
                            SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isExpenseMode
                                          ? Icons.money_off
                                          : Icons.attach_money,
                                      size: 48,
                                      color: subTextColor.withAlpha(128),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _isExpenseMode
                                          ? 'No expenses recorded in this period'
                                          : 'No income recorded in this period',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 280,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (amounts.isNotEmpty
                                          ? amounts.reduce((a, b) => a > b ? a : b)
                                          : 0) *
                                      1.4,
                                  minY: 0,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (group) => isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                      getTooltipItem: (group, groupIndex, rod,
                                          rodIndex) {
                                        return BarTooltipItem(
                                          '${categories[group.x.toInt()]}\n',
                                          const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  'Rs. ${rod.toY.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    touchCallback:
                                        (FlTouchEvent event, barTouchResponse) {
                                      setState(() {
                                        if (event is FlTapUpEvent &&
                                            barTouchResponse != null &&
                                            barTouchResponse.spot != null) {
                                          _touchedIndex = barTouchResponse
                                              .spot!.touchedBarGroupIndex;
                                        } else {
                                          _touchedIndex = -1;
                                        }
                                      });
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 55,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          int index = value.toInt();
                                          if (index >= 0 &&
                                              index < categories.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Transform.rotate(
                                                angle: -0.5,
                                                child: Text(
                                                  categories[index],
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          if (value == 0) {
                                            return const SizedBox.shrink();
                                          }
                                          return Text(
                                            'Rs.${value.toInt()}',
                                            style: TextStyle(
                                              color: subTextColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: amounts.isNotEmpty
                                        ? (amounts.reduce((a, b) => a > b ? a : b) *
                                            1.4) /
                                            5
                                        : 100,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.grey.shade200,
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      left: BorderSide(
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      right: BorderSide.none,
                                      top: BorderSide.none,
                                    ),
                                  ),
                                  barGroups: List.generate(categories.length,
                                      (index) {
                                    double val = amounts[index];
                                    bool isTouched = _touchedIndex == index;
                                    String category = categories[index];
                                    Color barColor =
                                        _getCategoryColor(category, isDark);

                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: val,
                                          color: isTouched
                                              ? Colors.deepPurple
                                              : barColor,
                                          width: isTouched ? 30 : 24,
                                          borderRadius:
                                              const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                      ],
                                      showingTooltipIndicators: isTouched
                                          ? [0]
                                          : [],
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

                  // Category Details List
                  Text(
                    _isExpenseMode
                        ? 'CATEGORY SPENDING (EXPENSE)'
                        : 'INCOME SOURCES',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (total == 0)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _isExpenseMode
                              ? 'No expense records found for this period!'
                              : 'No income records found for this period!',
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: categories.asMap().entries.map((entry) {
                        int index = entry.key;
                        String category = entry.value;
                        double amount = amounts[index];
                        double percentage = (total > 0) ? (amount / total) : 0.0;
                        Color barColor =
                            _getCategoryColor(category, isDark);

                        return Card(
                          color: cardColor,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: isDark
                                    ? Colors.white10
                                    : const Color(0xFFE9ECEF)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: index == _touchedIndex
                                                ? Colors.deepPurple
                                                : barColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Rs. ${amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: barColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percentage,
                                          backgroundColor: isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  barColor),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${(percentage * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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