import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartspend_expensetracker/core/database/db_helper.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  bool _isLoading = true;

  // Filters sadaha Variables
  String _searchQuery = '';
  String _selectedType = 'All';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  // Database eken all data laba ganeema
  void _loadAllTransactions() async {
    final data = await _dbHelper.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _allTransactions = data;
      _applyFilters();
      _isLoading = false;
    });
  }

  // Search and Filters ක්start krna Function eka
  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((tx) {
        // 1. Search Filter
        final matchesSearch = tx['title'].toLowerCase().contains(_searchQuery.toLowerCase());

        // 2. Type Filter (Income/Expense)
        final matchesType = _selectedType == 'All' || tx['type'] == _selectedType;

        // 3. Date Range Filter
        bool matchesDate = true;
        if (_selectedDateRange != null) {
          try {
            DateTime txDate = DateFormat('dd/MM/yyyy').parse(tx['date']);
            final startDate = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
            final endDate = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);

            matchesDate = txDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
                          txDate.isBefore(endDate.add(const Duration(days: 1)));
          } catch (e) {
            matchesDate = true;
          }
        }

        return matchesSearch && matchesType && matchesDate;
      }).toList();
    });
  }

  // 🗑️ Transaction eka Delete kireeme Function එක
  void _deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted successfully! 🗑️'), backgroundColor: Colors.redAccent),
    );
    _loadAllTransactions();
  }

  // Category Icon සහ පැහැය තීරණය කිරීම
  Map<String, dynamic> _getCategoryStyle(String title, String type) {
    String lowerTitle = title.toLowerCase();
    if (type == 'Income') {
      if (lowerTitle.contains('salary') || lowerTitle.contains('padi')) {
        return {'icon': Icons.payments_rounded, 'color': Colors.green.shade600};
      }
      return {'icon': Icons.add_card_rounded, 'color': Colors.teal.shade600};
    } else {
      if (lowerTitle.contains('medicine') || lowerTitle.contains('care') || lowerTitle.contains('doctor') || lowerTitle.contains('hospital')) {
        return {'icon': Icons.medical_services_rounded, 'color': Colors.teal.shade700};
      }
      if (lowerTitle.contains('bus') || lowerTitle.contains('train') || lowerTitle.contains('car')) {
        return {'icon': Icons.directions_bus_rounded, 'color': Colors.orange.shade700};
      }
      if (lowerTitle.contains('food') || lowerTitle.contains('eat') || lowerTitle.contains('hotel')) {
        return {'icon': Icons.fastfood_rounded, 'color': Colors.red.shade400};
      }
      if (lowerTitle.contains('bill') || lowerTitle.contains('current') || lowerTitle.contains('water')) {
        return {'icon': Icons.receipt_long_rounded, 'color': Colors.blue.shade600};
      }
      return {'icon': Icons.shopping_bag_rounded, 'color': Colors.amber.shade800};
    }
  }

  // Date Range Picker
  void _pickDateRange() async {
    final DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() {
        _selectedDateRange = newRange;
      });
      _applyFilters();
    }
  }

  // Filters Clear කිරීම
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = 'All';
      _selectedDateRange = null;
    });
    _loadAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('History Archive 🗄️', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? Colors.deepPurple.shade900 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _clearFilters,
            tooltip: 'Reset Filters',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _applyFilters();
                    },
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // 🎛️ Filter Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: ['All', 'Income', 'Expense'].map((type) {
                            final isSelected = _selectedType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(type, style: const TextStyle(fontSize: 12)),
                                selected: isSelected,
                                selectedColor: Colors.deepPurple.shade100,
                                onSelected: (val) {
                                  if (val) {
                                    _selectedType = type;
                                    _applyFilters();
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickDateRange,
                        icon: const Icon(Icons.date_range_rounded, size: 16),
                        label: Text(
                          _selectedDateRange == null
                              ? 'Select Date'
                              : '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 🧾 Transactions list eka (Swipe to Delete ekka)
                  Expanded(
                    child: _filteredTransactions.isEmpty
                        ? const Center(
                            child: Text(
                              'No transactions match your filters! 📂',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final tx = _filteredTransactions[index];
                              final isIncome = tx['type'] == 'Income';
                              final style = _getCategoryStyle(tx['title'], tx['type']);
                              final double txAmount = (tx['amount'] as num).toDouble();

                              return Dismissible(
                                key: Key(tx['id'].toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20.0),
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
                                ),
                                onDismissed: (direction) {
                                  _deleteTransaction(tx['id']);
                                },
                                child: Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                    side: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE9ECEF)),
                                  ),
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: style['color'].withOpacity(0.1),
                                      child: Icon(style['icon'], color: style['color']),
                                    ),
                                    title: Text(
                                      tx['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(tx['date']),
                                    trailing: Text(
                                      '${isIncome ? '+' : '-'} Rs. ${txAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}