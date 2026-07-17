import 'package:flutter/foundation.dart' show kIsWeb; // 👈 kIsWeb එක පාවිච්චි කරන්න
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // 👈 වෙබ් එක සඳහා
import 'features/expenses/views/expense_list_screen.dart';
import 'package:smartspend_expensetracker/core/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // 🌐 වෙබ් එක සඳහා databaseFactory එක සෙට් කිරීම
    databaseFactory = databaseFactoryFfiWeb;
  }

  // 🌟 මෙතනින් මුළු App එකටම ThemeProvider එක සම්බන්ධ කරනවා 🌟
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const SmartSpendApp(),
    ),
  );
}

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 මෙතනින් දැනට තියෙන Theme එක (Light හෝ Dark) කියවලා ගන්නවා 🌟
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true), // Light Theme එක
      darkTheme: ThemeData.dark(useMaterial3: true), // Dark Theme එක
      home: const ExpenseListScreen(), // ඔන්න අපි හදපු Screen එක මෙතනට සම්බන්ධ කළා
    );
  }

}