import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  double _budgetLimit = 0.0;
  double _totalExpense = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

                                       // 🔄 DB eken Budget Limit eka ha Transactions aran Total Expense eka hadanwa
  Future<void> _loadBudgetData() async {
    setState(() => _isLoading = true);

    // 1. Budget Limit eka gannwa
    double savedBudget = await _dbHelper.getBudget();

                                          // 2. Transactions okkoma aran Expense wla ekathuwa hadanwa
    List<Map<String, dynamic>> allTx = await _dbHelper.getAllTransactions();
    double expenseSum = 0.0;

    for (var tx in allTx) {
      if (tx['type'] == 'Expense') {
        expenseSum += (tx['amount'] as num).toDouble();
      }
    }

    setState(() {
      _budgetLimit = savedBudget;
      _totalExpense = expenseSum;
      if (savedBudget > 0) {
        _budgetController.text = savedBudget.toStringAsFixed(0);
      }
      _isLoading = false;
    });
  }

                                                   // 💾 aluth Budget ekak Save kireema
  Future<void> _saveBudget() async {
    double? amount = double.tryParse(_budgetController.text);
    if (amount != null && amount > 0) {
      await _dbHelper.setBudget(amount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget Limit Updated Successfully! '),
          backgroundColor: Colors.green,
        ),
      );
      _loadBudgetData(); // Data Refresh kireema
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ☀️/🌙 Dynamic Theme Colors (Light & Dark Mode Support)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey : Colors.grey.shade600;
    final inputFillColor = isDark ? const Color(0xFF121212) : const Color(0xFFF1F3F5);

    // 📊 Percentage & Color Logic
    double progress = _budgetLimit > 0 ? (_totalExpense / _budgetLimit) : 0.0;
    double remaining = _budgetLimit - _totalExpense;

    Color progressColor = Colors.deepPurpleAccent;
    if (progress >= 1.0) {
      progressColor = Colors.redAccent;
    } else if (progress >= 0.8) {
      progressColor = Colors.orangeAccent;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Budget Goals ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  // 1️⃣ Monthly Budget Progress Card
                  if (_budgetLimit > 0) ...[
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
                            Text(
                              'MONTHLY BUDGET OVERVIEW',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rs. ${_totalExpense.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: progressColor,
                                  ),
                                ),
                                Text(
                                  'of Rs. ${_budgetLimit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: subTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress > 1.0 ? 1.0 : progress,
                                minHeight: 12,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Details Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Spent: ${(progress * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(color: subTextColor, fontSize: 13),
                                ),
                                Text(
                                  remaining >= 0
                                      ? 'Remaining: Rs. ${remaining.toStringAsFixed(2)}'
                                      : 'Exceeded: Rs. ${(-remaining).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: remaining >= 0 ? Colors.green.shade600 : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ⚠️ Budget Warning Banners
                    if (progress >= 1.0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Alert: You have exceeded your monthly budget limit!',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (progress >= 0.8)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.orangeAccent),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Warning: You have spent over 80% of your budget!',
                                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],

                  // 2️⃣ Set / Update Budget Input Field
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
                          Text(
                            'SET MONTHLY BUDGET LIMIT',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.account_balance_wallet, color: subTextColor),
                              hintText: 'Enter Budget Amount (Rs.)',
                              hintStyle: TextStyle(color: subTextColor),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _saveBudget,
                              icon: const Icon(Icons.save_rounded, color: Colors.white),
                              label: const Text(
                                'Save Budget Limit',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}