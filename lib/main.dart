import 'package:flutter/material.dart';
import 'core/database/db_helper.dart';
import 'features/expenses/views/login_screen.dart';
import 'features/expenses/views/expense_list_screen.dart';

// 🌗 Global Theme Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // 1. Flutter Widgets Binding Initialize කිරීම
  WidgetsFlutterBinding.ensureInitialized();

  // 🧹 Database එක clear කිරීමට අවශ්‍ය වූ විට පමණක් පහත පේළිය un-comment කරන්න:
  // await DBHelper().deleteAllTransactions();

  // 2. User දැනටමත් Login වී ඇත්දැයි SharedPreferences හරහා පරීක්ෂා කිරීම 🔐
  final dbHelper = DBHelper();
  final userSession = await dbHelper.getCurrentUserSession();

  runApp(MyApp(isLoggedIn: userSession != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'SmartSpend',
          debugShowCheckedModeBanner: false,

          // ☀️ Light Theme Configuration
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),

          // 🌙 Dark Theme Configuration
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          themeMode: currentMode,

          // 🎯 User Login වී සිටී නම් ExpenseListScreen එකට, නැතහොත් LoginScreen එකට යොමු කරයි
          home: isLoggedIn ? const ExpenseListScreen() : const LoginScreen(),
        );
      },
    );
  }
}