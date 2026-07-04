import 'dart:io'; // Platform එක check කරන්න (Windows/Mac/Linux සඳහා)
import 'package:flutter/foundation.dart'; // kIsWeb එක පාවිච්චි කරන්න
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'features/expenses/views/expense_list_screen.dart';

void main() {
  // 1. Flutter bindings ටික initialize වී ඇති බව තහවුරු කරගන්න
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Web (Chrome) එකේදී SQLite වැඩ කරන්න අවශ්‍ය කරන factory එක සෙට් කිරීම
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop වලදී run කරනවා නම් ffi initialize කරනවා
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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