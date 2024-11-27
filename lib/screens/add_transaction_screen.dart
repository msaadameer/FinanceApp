import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _amount;
  String _type = 'Income';
  String _category = 'Salary'; // Default value for income category
  String? _transactionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      _transactionId = arguments['transactionId'];
      _amount = arguments['amount'];
      _type = arguments['type'];
      _category = arguments['category'] ??
          (_type == 'Income' ? 'Salary' : 'Food'); // Handle null category
    }
  }

  // Save the transaction (either create or update)
  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Map<String, dynamic> transactionData = {
        'amount': _amount,
        'type': _type,
        'category': _category,
        'date': Timestamp.now(),
      };

      if (_transactionId == null) {
        await FirebaseFirestore.instance
            .collection('transactions')
            .add(transactionData);
      } else {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(_transactionId)
            .update(transactionData);
      }

      Navigator.pop(context);
    }
  }

  // Get category options based on transaction type
  List<DropdownMenuItem<String>> _getCategoryOptions() {
    if (_type == 'Income') {
      return [
        DropdownMenuItem<String>(
          value: 'Salary',
          child: Row(
            children: [
              Icon(Icons.money, color: Colors.green),
              SizedBox(width: 8),
              Text('Salary'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Business',
          child: Row(
            children: [
              Icon(Icons.business_center, color: Colors.blue),
              SizedBox(width: 8),
              Text('Business'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Investment',
          child: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.purple),
              SizedBox(width: 8),
              Text('Investment'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Other Income',
          child: Row(
            children: [
              Icon(Icons.miscellaneous_services, color: Colors.grey),
              SizedBox(width: 8),
              Text('Other Income'),
            ],
          ),
        ),
      ];
    } else {
      return [
        DropdownMenuItem<String>(
          value: 'Food',
          child: Row(
            children: [
              Icon(Icons.fastfood, color: Colors.orange),
              SizedBox(width: 8),
              Text('Food'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Transport',
          child: Row(
            children: [
              Icon(Icons.directions_car, color: Colors.blue),
              SizedBox(width: 8),
              Text('Transport'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Shopping',
          child: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.green),
              SizedBox(width: 8),
              Text('Shopping'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Entertainment',
          child: Row(
            children: [
              Icon(Icons.movie, color: Colors.purple),
              SizedBox(width: 8),
              Text('Entertainment'),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Others',
          child: Row(
            children: [
              Icon(Icons.miscellaneous_services, color: Colors.grey),
              SizedBox(width: 8),
              Text('Others'),
            ],
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _transactionId == null ? 'Add Transaction' : 'Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _amount != null ? _amount.toString() : '',
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter an amount' : null,
                onSaved: (value) => _amount = double.tryParse(value!),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _type = 'Income';
                      _category = 'Salary'; // Reset category for income
                    }),
                    child: Text('Income'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _type == 'Income' ? Colors.green : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _type = 'Expense';
                      _category = 'Food'; // Reset category for expense
                    }),
                    child: Text('Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _type == 'Expense' ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),

              // Dropdown with icons for categories
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: _category,
                items: _getCategoryOptions(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                onSaved: (value) {
                  _category = value!;
                },
                validator: (value) {
                  return value == null || value.isEmpty
                      ? 'Select a category'
                      : null;
                },
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(_transactionId == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}