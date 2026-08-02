import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(String title, double amount, String type) onAddTransaction;
  
  // 👈 සංස්කරණය කිරීමේදී පැරණි දත්ත ලබා ගැනීමට Map එකක් constructor එකට එකතු කළා
  final Map<String, dynamic>? initialTransaction;

  const AddTransactionScreen({
    super.key, 
    required this.onAddTransaction,
    this.initialTransaction, // 👈 මෙය අනිවාර්ය නැත (null විය හැක), අලුතින් ඇතුළත් කිරීමේදී මෙය හිස්ව පවතී
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  String _selectedType = 'Income';
  bool _isEditing = false; // 👈 දැනට කරන්නේ සංස්කරණයක්ද නැද්ද යන්න හඳුනා ගැනීමට බූලියන් අගයක්

  @override
  void initState() {
    super.initState();
    
    // සංස්කරණය සඳහා දත්ත ලැබී ඇත්දැයි පරීක්ෂා කිරීම
    if (widget.initialTransaction != null) {
      _isEditing = true;
      _titleController = TextEditingController(text: widget.initialTransaction!['title']);
      _amountController = TextEditingController(text: widget.initialTransaction!['amount'].toString());
      _selectedType = widget.initialTransaction!['type'];
    } else {
      // අලුතින් ඇතුළත් කරන්නේ නම් හිස්ව ආරම්භ කිරීම
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
        // 👈 කරන්නේ කුමන කාර්යයද යන්න මත පදනම්ව මාතෘකාව වෙනස් වේ
        title: Text(_isEditing ? 'Edit Transaction ✏️' : 'Add Transaction 💰'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Income', 'Expense'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // 🚀 දත්ත ටික Callback එක හරහා මව් තිරය වෙත යැවීම
                      widget.onAddTransaction(
                        _titleController.text,
                        double.parse(_amountController.text),
                        _selectedType,
                      );
                      
                      // 🔙 දත්ත යැවීමෙන් පසු මෙම තිරය වසා දැමීම
                      Navigator.pop(context);
                    }
                  },
                  // 👈 කරන්නේ කුමන කාර්යයද යන්න මත පදනම්ව බොත්තමේ අකුරු වෙනස් වේ
                  child: Text(
                    _isEditing ? 'Update Transaction' : 'Add Transaction',
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