import 'package:flutter/material.dart';
import 'features/expenses/views/expense_list_screen.dart';
import 'core/database/db_helper.dart';

// 🌗 Global Theme Notifier
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧹 Database එක clear කිරීමට අවශ්‍ය වූ විට පමණක් පහත පේළිය un-comment කරන්න:
  // await DBHelper().deleteAllTransactions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SmartSpend',
          debugShowCheckedModeBanner: false,
          
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
          ),
          
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
          ),
          
          themeMode: currentMode,
          
          home: const ExpenseListScreen(),
        );
      },
    );
  }
}