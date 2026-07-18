import 'package:flutter/material.dart';
import 'package:smartspend_expensetracker/core/database/db_helper.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _budgetController = TextEditingController();
  
  double _budgetLimit = 0.0;
  double _totalExpenses = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  void _loadBudgetData() async {
    final budget = await _dbHelper.getBudget();
    final transactions = await _dbHelper.getAllTransactions();
    
    // මුළු වියදම් (Expenses) විතරක් එකතු කරන්න (Budget limit එක අතහැර)
    double expensesSum = 0.0;
    for (var tx in transactions) {
      if (tx['type'] == 'Expense' && tx['title'] != 'MONTHLY_BUDGET_LIMIT') {
        expensesSum += tx['amount'];
      }
    }

    if (!mounted) return;
    setState(() {
      _budgetLimit = budget;
      _totalExpenses = expensesSum;
      _budgetController.text = budget > 0 ? budget.toStringAsFixed(0) : '';
      _isLoading = false;
    });
  }

  void _saveBudget() async {
    double amount = double.tryParse(_budgetController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount! ⚠️')),
      );
      return;
    }

    await _dbHelper.insertOrUpdateBudget(amount);
    _loadBudgetData();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Budget Limit Updated Successfully! 🎯 🎉'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double progress = _budgetLimit > 0 ? (_totalExpenses / _budgetLimit) : 0.0;
    if (progress > 1.0) progress = 1.0; // 100% ට වඩා වැඩි වෙන්න නොදීමට

    final remainingBudget = _budgetLimit - _totalExpenses;
    final isOverBudget = remainingBudget < 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Budget Goals 🎯', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Budget Setup Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF))
                        ),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SET MONTHLY BUDGET LIMIT',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.blueGrey, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _budgetController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'Enter Budget Amount (Rs.)',
                                  labelStyle: const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.grey),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark ? Colors.deepPurple.shade600 : Colors.deepPurple.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _saveBudget,
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text('Save Budget Limit', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Budget Progress Tracking Card
                      if (_budgetLimit > 0) ...[
                        Text('Budget Status Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          color: isOverBudget 
                              ? (isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50)
                              : (isDark ? Colors.green.shade900.withOpacity(0.2) : Colors.green.shade50),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Monthly Limit:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text('Rs. ${_budgetLimit.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Expenses:', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text('Rs. ${_totalExpenses.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade600)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // 📊 Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 12,
                                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress >= 0.9 ? Colors.red.shade600 : (progress >= 0.7 ? Colors.orange.shade500 : Colors.green.shade500)
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Divider(color: isDark ? Colors.white12 : Colors.black12),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(isOverBudget ? 'Over Budget By:' : 'Remaining Budget:', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      'Rs. ${remainingBudget.abs().toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: isOverBudget ? Colors.red.shade600 : Colors.green.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}