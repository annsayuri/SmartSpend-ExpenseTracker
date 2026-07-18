import 'package:flutter/material.dart';

class BillReminderScreen extends StatefulWidget {
  const BillReminderScreen({super.key});

  @override
  State<BillReminderScreen> createState() => _BillReminderScreenState();
}

class _BillReminderScreenState extends State<BillReminderScreen> {
  // Dummy data ලිස්ට් එකක් (පස්සේ Database එකට සෙට් කරමු)
  final List<Map<String, dynamic>> _reminders = [
    {'title': 'Electricity Bill', 'amount': 4500.0, 'dueDate': '25/07/2026', 'isPaid': false},
    {'title': 'Dialog Broadband', 'amount': 2990.0, 'dueDate': '28/07/2026', 'isPaid': false},
    {'title': 'Water Bill', 'amount': 850.0, 'dueDate': '02/08/2026', 'isPaid': true},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
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
              'Upcoming Bills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: _reminders.isEmpty
                  ? const Center(child: Text('No bill reminders set! 🎉', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _reminders[index];
                        final isPaid = reminder['isPaid'];

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
                          ),
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              child: Icon(
                                isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                color: isPaid ? Colors.green : Colors.orange,
                              ),
                            ),
                            title: Text(
                              reminder['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                decoration: isPaid ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text('Due: ${reminder['dueDate']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${reminder['amount'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isPaid ? Colors.grey : Colors.red.shade400,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPaid ? 'Paid' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isPaid ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? Colors.deepPurple.shade400 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        onPressed: () {
          // බිල්පත් ඇතුළත් කරන්න වෙනම Screen එකක් හදනකල් දැනට SnackBar එකක් පෙන්වමු
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add New Bill feature coming soon! 🚀'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Add Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}