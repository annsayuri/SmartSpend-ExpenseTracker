import 'package:flutter/material.dart';
import '../../../core/database/db_helper.dart';

class BillReminderScreen extends StatefulWidget {
  const BillReminderScreen({super.key});

  @override
  State<BillReminderScreen> createState() => _BillReminderScreenState();
}

class _BillReminderScreenState extends State<BillReminderScreen> with WidgetsBindingObserver {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBills();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // App Lifecycle wenas wenkota (ex: Navigation Back aa wita) Data Auto-Refresh wenwa 🔄
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadBills();
    }
  }

  // 1. Database eken  Bills Fetch kireema 📥
  Future<void> _loadBills() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await _dbHelper.getUserBills();
    if (!mounted) return;
    setState(() {
      _bills = data;
      _isLoading = false;
    });
  }

  // 2. Bill ekak Pay kala pasu DB eka Update kireema 💳
  Future<void> _markAsPaid(Map<String, dynamic> bill) async {
    try {
      await _dbHelper.markBillAsPaid(
        bill['id'],
        bill['title'],
        (bill['amount'] as num).toDouble(),
        bill['due_date'],
      );

      // UI eka Refresh kireema
      await _loadBills();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${bill['title']} Paid & Added to Expenses! '),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process payment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 3. aluth Bill ekak Add kireeme Modal Dialog eka ➕
  void _showAddBillDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Bill Reminder ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Bill Title (e.g., Water Bill)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (Rs.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Due Date',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  dateController.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      amountController.text.isNotEmpty &&
                      dateController.text.isNotEmpty) {
                    final double? amt = double.tryParse(amountController.text);
                    if (amt != null) {
                      await _dbHelper.insertBill(
                        titleController.text.trim(),
                        amt,
                        dateController.text.trim(),
                      );
                      if (mounted) Navigator.pop(ctx);
                      _loadBills(); // Refresh List
                    }
                  }
                },
                child: const Text('Save Bill Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Bill ekak Delete kirrema 🗑️
  Future<void> _deleteBill(int id) async {
    await _dbHelper.deleteBill(id);
    _loadBills();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBills,
            tooltip: 'Refresh Bills',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBillDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Bill'),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bills.isEmpty
                      ? Center(
                          child: Text(
                            'No bills added yet! ✨\nClick "+ Add Bill" to create one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subTextColor, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _bills.length,
                          itemBuilder: (context, index) {
                            final bill = _bills[index];
                            final isPaid = bill['is_paid'] == 1;

                            return Dismissible(
                              key: Key(bill['id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) => _deleteBill(bill['id']),
                              child: Card(
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
                                              ? Colors.green.withValues(alpha: 0.15)
                                              : Colors.orange.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPaid
                                              ? Icons.check_circle_rounded
                                              : Icons.receipt_long_rounded,
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
                                                decoration:
                                                    isPaid ? TextDecoration.lineThrough : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Due: ${bill['due_date']}',
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
                                            'Rs. ${(bill['amount'] as num).toDouble().toStringAsFixed(2)}',
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
                                                onPressed: () => _markAsPaid(bill),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(horizontal: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Pay Now',
                                                  style: TextStyle(
                                                      fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.15),
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
