import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(String title, double amount, String type) onAddTransaction;
  
  // old data ganna map ekak hadanwa
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
  String _selectedType = 'Income';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    // edit krnna data thiynwda kiyl blnw
    if (widget.initialTransaction != null) {
      _isEditing = true;
      _titleController = TextEditingController(text: widget.initialTransaction!['title']);
      _amountController = TextEditingController(text: widget.initialTransaction!['amount'].toString());
      _selectedType = widget.initialTransaction!['type'];
    } else {
      // aluth add krnwnm his wa ganna
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
        title: Text(_isEditing ? 'Edit Transaction ✏️' : 'Add Transaction 💰'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📝 Title Field Validation
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
                    return 'Please enter a title 📝';
                  }
                  if (value.trim().length < 2) {
                    return 'Title must be at least 2 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // 💰 Amount Field Validation
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.attach_money_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount 💰';
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

              // 🏷️ Transaction Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Transaction Type',
                  prefixIcon: const Icon(Icons.category_outlined),
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
                    });
                  }
                },
              ),
              const SizedBox(height: 28.0),

              // 🚀 Submit Button
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
                      // 🚀 data tika Callback eka haaha yaweema
                      widget.onAddTransaction(
                        _titleController.text.trim(),
                        double.parse(_amountController.text.trim()),
                        _selectedType,
                      );

                      //  Success Message eka penweema
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isEditing 
                              ? 'Transaction updated successfully! ' 
                              : 'Transaction added successfully! ',
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      //  Screen eka Close kireema
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    _isEditing ? 'Update Transaction ' : 'Add Transaction ',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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