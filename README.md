# SmartSpend-ExpenseTracker
SmartSpend is a comprehensive mobile expense tracking application built with Flutter that helps users monitor their daily spending, set budgets, and gain insights into their financial habits through visual analytics.

[![Flutter](https://img.shields.io/badge/Flutter-3.10.0-blue.svg)](https://flutter.dev)
[![SQLite](https://img.shields.io/badge/Database-SQLite-green.svg)](https://sqlite.org)
[![Provider](https://img.shields.io/badge/State%20Management-Provider-purple.svg)](https://pub.dev/packages/provider)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)]()
[![CRUD](https://img.shields.io/badge/CRUD-Fully%20Implemented-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/Version-1.0.0-orange.svg)]()

---
## 📱 About SmartSpend

SmartSpend is a mobile expense tracking application built with Flutter that helps users monitor their daily spending, set budgets, and gain insights into their financial habits through visual analytics.

---
## ✨ Features

- ✅ **Create** - Add expenses with amount, category, date, and notes
- 📖 **Read** - View all transactions with search and filter capabilities
- ✏️ **Update** - Edit existing expense details
- 🗑️ **Delete** - Remove unwanted expense entries
- 📊 **Analytics** - Visual charts for spending by category
- 💰 **Budget Management** - Set monthly budgets and track progress
- 🔍 **Search & Filter** - Find expenses by category, date, or amount
---

## 🛠️ Technologies Used

- **Framework:** Flutter (Dart)
- **Database:** SQLite (sqflite)
- **State Management:** Provider
- **Charts:** fl_chart
- **Date Handling:** intl

---

## 🏗️ Project Structure

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/SmartSpend.git
cd SmartSpend

```
2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### 📊 Database Schema

```sql
CREATE TABLE expenses(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  note TEXT,
  created_at TEXT,
  updated_at TEXT
);

CREATE TABLE budget(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  month TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT
);

```

--- 
### 📝 Screens Overview

    - Home - Dashboard with spending summary and quick add button
    - Add/Edit Expense - Form for creating/updating expenses
    - Transaction List - All expenses with search/filter
    - Analytics - Category-wise pie chart and trend bar char
    - Budget - Monthly budget setting and tracking
    - Settings - Currency preference and data export

---
 ### 📅 Timeline

    - Project Proposal: 15 July 2026
    - Final Submission: 4 August 2026

----

### 👨‍💻 Author

[Your Name]
[Your Student ID]
📄 License

This project is developed for academic purposes as part of [Your Course/Module Name].

---

**My Final Recommendation:**

```bash
# Use this for your GitHub repository:
SmartSpend 
