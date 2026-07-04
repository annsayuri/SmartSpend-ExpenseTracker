// This is a basic Flutter widget test for SmartSpend Expense Tracker.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend_expensetracker/main.dart';

void main() {
  testWidgets('SmartSpend app basic render smoke test', (WidgetTester tester) async {
    // 🚀 ඇප් එක build කරලා frame එකක් trigger කරනවා
    await tester.pumpWidget(const MyApp());

    // 💰 ඇප් එක මුලින්ම load වෙද්දී 'SmartSpend 💰' කියන AppBar Title එක තියෙනවාද කියා සෙවීම
    expect(find.text('SmartSpend 💰'), findsOneWidget);

    // ➕ ඇප් එකේ අලුත් transaction එකක් දාන්න තියෙන Floating Action Button (Add Icon) එක තියෙනවාද කියා සෙවීම
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}