import 'package:flutter/material.dart';
import 'features/expenses/views/expense_list_screen.dart';

void main() {
  runApp(const SmartSpendApp());
}

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseListScreen(), // 👈 ඔන්න අපි හදපු Screen එක මෙතනට සම්බන්ධ කළා
    );
  }
}