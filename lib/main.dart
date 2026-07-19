import 'package:flutter/material.dart';
import 'features/expenses/views/expense_list_screen.dart'; // 💡 ඔයාගේ expense_list_screen එක තියෙන නිවැරදි path එක දාන්න

// 🌗 මුළු ඇප් එකේම Theme එක පාලනය කරන Global Notifier එක
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder මඟින් Theme එක වෙනස් වන විට මුළු ඇප් එකම Re-build කරයි
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'SmartSpend',
          debugShowCheckedModeBanner: false,
          
          // ☀️ Light Theme එක
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
          ),
          
          // 🌙 Dark Theme එක
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            useMaterial3: true,
          ),
          
          // 🎛️ දැනට ක්‍රියාත්මක තේමාව
          themeMode: currentMode,
          
          home: const ExpenseListScreen(),
        );
      },
    );
  }
}