import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/db_helper.dart';
import 'core/theme/theme_provider.dart'; // 🎨 Import ThemeProvider
import 'features/expenses/provider/expense_provider.dart'; // 💸 Import ExpenseProvider
import 'features/expenses/views/login_screen.dart';
import 'features/expenses/views/expense_list_screen.dart';

void main() async {
  // 1. Flutter Widgets Binding Initialize කිරීම
  WidgetsFlutterBinding.ensureInitialized();

  // 🧹 Database එක clear කිරීමට අවශ්‍ය වූ විට පමණක් පහත පේළිය un-comment කරන්න:
  // await DBHelper().deleteAllTransactions();

  // 2. User දැනටමත් Login වී ඇත්දැයි SharedPreferences හරහා පරීක්ෂා කිරීම 🔐
  final dbHelper = DBHelper();
  final userSession = await dbHelper.getCurrentUserSession();

  runApp(
    // 🎨 MultiProvider භාවිතයෙන් ThemeProvider සහ ExpenseProvider මුළු App එකටම Wrap කිරීම
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider()..loadInitialData(),
        ),
      ],
      child: MyApp(isLoggedIn: userSession != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // 🎨 ThemeProvider එක හරහා Dynamic ලෙස Theme එක ලබා ගැනීම
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SmartSpend',
      debugShowCheckedModeBanner: false,

      // ☀️ Light Theme Configuration
      theme: ThemeProvider.lightTheme,

      // 🌙 Dark Theme Configuration
      darkTheme: ThemeProvider.darkTheme,

      // 🔑 Provider එකේ තියෙන ThemeMode එක directly භාවිත කිරීම
      themeMode: themeProvider.themeMode,

      // 🎯 User Login වී සිටී නම් ExpenseListScreen එකට, නැතහොත් LoginScreen එකට යොමු කරයි
      home: isLoggedIn ? const ExpenseListScreen() : const LoginScreen(),
    );
  }
}