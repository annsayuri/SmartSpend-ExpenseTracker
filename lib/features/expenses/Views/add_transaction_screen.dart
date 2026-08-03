import 'package:flutter/material.dart';
import '../model/expense_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(ExpenseModel) onAddTransaction;
  final Map<String, dynamic>? initialTransaction;

  const AddTransactionScreen({
    super.key,
    required this.onAddTransaction,
    this.initialTransaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  String _selectedType = 'Expense';
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  bool _isEditing = false;

  List<ExpenseCategory> get _availableCategories {
    if (_selectedType == 'Income') {
      return [
        ExpenseCategory.salary,
        ExpenseCategory.allowance,
        ExpenseCategory.business,
        ExpenseCategory.gift,
        ExpenseCategory.bonus,
        ExpenseCategory.wage,
        ExpenseCategory.other,
      ];
    } else {
      return [
        ExpenseCategory.food,
        ExpenseCategory.transport,
        ExpenseCategory.bills,
        ExpenseCategory.shopping,
        ExpenseCategory.education,
        ExpenseCategory.entertainment,
        ExpenseCategory.healthcare,
        ExpenseCategory.other,
      ];
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialTransaction != null) {
      _isEditing = true;
      _titleController =
          TextEditingController(text: widget.initialTransaction!['title']);
      _amountController = TextEditingController(
          text: widget.initialTransaction!['amount'].toString());
      _selectedType = widget.initialTransaction!['type'] ?? 'Expense';

      if (widget.initialTransaction!['category'] != null) {
        _selectedCategory =
            ExpenseModel.parseCategory(widget.initialTransaction!['category']);
      }
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.title_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 2) {
                    return 'Title must be at least 2 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.attach_money_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsedAmount = double.tryParse(value.trim());
                  if (parsedAmount == null) {
                    return 'Please enter a valid number';
                  }
                  if (parsedAmount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Transaction Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Transaction Type',
                  prefixIcon: const Icon(Icons.swap_horiz_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                items: ['Income', 'Expense'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                      _selectedCategory = _availableCategories.first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16.0),

              // Category Dropdown
              DropdownButtonFormField<ExpenseCategory>(
                value: _availableCategories.contains(_selectedCategory)
                    ? _selectedCategory
                    : _availableCategories.first,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                items: _availableCategories.map((ExpenseCategory category) {
                  return DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Text(ExpenseModel.getCategoryDisplayName(category)),
                  );
                }).toList(),
                onChanged: (ExpenseCategory? newCategory) {
                  if (newCategory != null) {
                    setState(() {
                      _selectedCategory = newCategory;
                    });
                  }
                },
              ),
              const SizedBox(height: 28.0),

              // Submit Button
              SizedBox(
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create ExpenseModel object
                      final expense = ExpenseModel(
                        title: _titleController.text.trim(),
                        amount: double.parse(_amountController.text.trim()),
                        date: DateTime.now(),
                        category: _selectedCategory,
                        type: _selectedType == 'Income'
                            ? TransactionType.income
                            : TransactionType.expense,
                      );

                      // Pass the full ExpenseModel to parent
                      widget.onAddTransaction(expense);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isEditing
                                ? 'Transaction updated successfully!'
                                : 'Transaction added successfully!',
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    _isEditing ? 'Update Transaction' : 'Add Transaction',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}