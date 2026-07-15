import 'package:flutter/foundation.dart' show kIsWeb; // 👈 kIsWeb එක පාවිච්චි කරන්න
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // 👈 වෙබ් එක සඳහා
import 'features/expenses/views/expense_list_screen.dart';
import 'package:smartspend_expensetracker/core/Theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // 🌐 වෙබ් එක සඳහා databaseFactory එක සෙට් කිරීම (සරලවම මෙහෙම දැම්මම ඇති!)
    databaseFactory = databaseFactoryFfiWeb;
  }

  // ✅ MyApp() වෙනුවට ඔයාගේ ඇප් එකේ නම වන SmartSpendApp() දැම්මා
  runApp(const SmartSpendApp());
}

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseListScreen(), // 👈 ඔන්න අපි හදපු Screen එක මෙතනට සම්බන්ධ කළා
    ); // MaterialApp
  }
}