import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';

class BillReminderScreen extends StatefulWidget {
  const BillReminderScreen({Key? key}) : super(key: key);

  @override
  State<BillReminderScreen> createState() => _BillReminderScreenState();
}

class _BillReminderScreenState extends State<BillReminderScreen> {
  final DBHelper _dbHelper = DBHelper();

  // Dummy / Initial Bills Data List
  List<Map<String, dynamic>> _bills = [
    {
      'id': 1,
      'title': 'Electricity Bill',
      'amount': 4500.0,
      'date': '25/07/2026',
      'isPaid': false,
    },
    {
      'id': 2,
      'title': 'Dialog Broadband',
      'amount': 2990.0,
      'date': '28/07/2026',
      'isPaid': false,
    },
    {
      'id': 3,
      'title': 'Water Bill',
      'amount': 850.0,
      'date': '02/08/2026',
      'isPaid': true,
    },
  ];

  // 💳 Bill එකක් Paid කරලා Main Expense DB එකට Add කිරීමේ Logic එක
  Future<void> _markAsPaid(int index) async {
    final bill = _bills[index];

    // 1. Transaction Record එකක් විදියට DB එකට Insert කිරීම
    await _dbHelper.insertTransaction({
      'title': bill['title'],
      'amount': bill['amount'],
      'type': 'Expense',
      'date': bill['date'],
    });

    // 2. UI එකේ Bill එක 'Paid' විදිහට Update කිරීම
    setState(() {
      _bills[index]['isPaid'] = true;
    });

    // 3. User ට Confirmation Message එකක් දීම
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bill['title']} Paid & Added to Expenses! 🎉'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Bill Reminders 🔔', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPCOMING BILLS',
              style: TextStyle(
                color: subTextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _bills.length,
                itemBuilder: (context, index) {
                  final bill = _bills[index];
                  final isPaid = bill['isPaid'] as bool;

                  return Card(
                    color: cardColor,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? Colors.white10 : const Color(0xFFE9ECEF),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Status Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPaid ? Icons.check_circle_rounded : Icons.receipt_long_rounded,
                              color: isPaid ? Colors.green : Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Bill Title & Due Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bill['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    decoration: isPaid ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Due: ${bill['date']}',
                                  style: TextStyle(fontSize: 12, color: subTextColor),
                                ),
                              ],
                            ),
                          ),

                          // Amount & Action Button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. ${(bill['amount'] as double).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isPaid ? Colors.grey : Colors.redAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (!isPaid)
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () => _markAsPaid(index),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Pay Now',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'PAID',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}