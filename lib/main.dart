import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/db_helper.dart';
import 'core/theme/theme_provider.dart';
import 'features/expenses/views/login_screen.dart';
import 'features/expenses/views/expense_list_screen.dart';

void main() {
  // 1. Flutter Widgets Binding Initialize kireema
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // 🎨 ThemeProvider eka whole App ekatama Provider ekak widihata Wrap kireema
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SmartSpend',
      debugShowCheckedModeBanner: false,

      // ☀️ Light Theme Configuration
      theme: ThemeProvider.lightTheme,

      // 🌙 Dark Theme Configuration
      darkTheme: ThemeProvider.darkTheme,

      // 🔑 Provider එකේ තියෙන ThemeMode එක භාවිත කිරීම
      themeMode: themeProvider.themeMode,

      // 🎯 FutureBuilder භාවිතයෙන් Async ලෙස Session එක Check කිරීම
      home: FutureBuilder<Map<String, dynamic>?>(
        future: DBHelper().getCurrentUserSession(),
        builder: (context, snapshot) {
          // Database එකෙන් Data ලැබෙන තෙක් Loading Indicator එකක් පෙන්වයි
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // User Session eka thiynwanm ExpenseListScreen ekata, nathinm LoginScreen ekata Redirect kireema
          if (snapshot.hasData && snapshot.data != null) {
            return const ExpenseListScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}