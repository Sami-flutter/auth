import 'package:auth/pages/Models/expense_tile.dart';
import 'package:auth/pages/Models/transections.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  DateTimeRange? selectedDateRange;

  // Method to map categories to icons
  IconData? _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.monetization_on;
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt;
      case 'shopping':
        return Icons.shopping_cart;
      case 'freelance':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'school':
        return Icons.school;
      case 'bajaj':
        return Icons.electric_scooter;
      default:
        return Icons.category; // No icon for other categories
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              DateTimeRange? pickedDateRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDateRange: selectedDateRange ??
                    DateTimeRange(
                        start: DateTime.now().subtract(Duration(days: 30)),
                        end: DateTime.now()),
              );
              if (pickedDateRange != null) {
                setState(() {
                  selectedDateRange = pickedDateRange;
                });
              }
            },
            color: Colors.black,
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () {
              _generatePdfAndPrint(context);
            },
            color: Colors.black,
          ),
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Expenses>(context, listen: false).fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Consumer<Expenses>(
              builder: (context, expensesProvider, child) {
                var combinedTransactions =
                    expensesProvider.getCombinedAndSortedTransactions();

                if (selectedDateRange != null) {
                  combinedTransactions = combinedTransactions.where((transaction) {
                    return transaction.date.isAfter(selectedDateRange!.start) &&
                        transaction.date.isBefore(
                            selectedDateRange!.end.add(Duration(days: 1)));
                  }).toList();
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: combinedTransactions.length,
                        itemBuilder: (context, index) {
                          final item = combinedTransactions[index];
                          final icon = _getIconForCategory(item.name);
                          return ListTile(
                            leading: icon != null ? Icon(icon) : null, // Only show icon if it's not null
                            title: Text(
                              item.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(item.date.toString().split(' ')[0]),
                            trailing: Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: item.type == 'income' ? Colors.green : Colors.red,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGradientButton(
                          context: context,
                          text: 'ADD INCOME',
                          onPressed: () {
                            showAddIncomeDialog(context);
                          },
                        ),
                        _buildGradientButton(
                          context: context,
                          text: 'ADD EXPENSE',
                          onPressed: () {
                            showAddExpenseDialog(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: LinearGradient(
          colors: [Color(0xFF3E60E9), Color(0xFFED6A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Use transparent to show gradient
          shadowColor: Colors.transparent, // Remove shadow to keep gradient clear
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _generatePdfAndPrint(BuildContext context) async {
    final pdf = pw.Document();

    final expensesProvider = Provider.of<Expenses>(context, listen: false);
    final transactions = expensesProvider.getCombinedAndSortedTransactions();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Transaction Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Date Range: ${selectedDateRange != null ? '${selectedDateRange!.start.toString().split(' ')[0]} to ${selectedDateRange!.end.toString().split(' ')[0]}' : 'All Time'}',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return pw.Container(
                    margin: pw.EdgeInsets.symmetric(vertical: 4),
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(4),
                      color: PdfColors.grey200,
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              transaction.name,
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              transaction.date.toString().split(' ')[0],
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                        pw.Text(
                          '\$${transaction.price.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: transaction.type == 'income'
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              pw.Divider(),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Income:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.price).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Expenses:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.price).toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.red,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Net Balance:',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${expensesProvider.calculateTotalBalance().toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: expensesProvider.calculateTotalBalance() >= 0
                          ? PdfColors.green
                          : PdfColors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void showAddIncomeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final incomeNameController = TextEditingController();
    String? selectedCategory;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Income'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount greater than zero';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: incomeNameController,
                    decoration: InputDecoration(
                      labelText: 'Income Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the income name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    items: <String>['Salary', 'Freelance', 'Investment', 'Other']
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selectedCategory = newValue;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : 'Selected Date: ${selectedDate.toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a date')),
                    );
                    return;
                  }
                  final income = ExpenseTile(
                    name: incomeNameController.text,
                    price: double.parse(amountController.text),
                    date: selectedDate ?? DateTime.now(),
                    type: 'income', // Set type to 'income'
                  );

                  // Call the addTransaction method from the Expenses class
                  Provider.of<Expenses>(context, listen: false).addTransaction(income);

                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showAddExpenseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final expenseNameController = TextEditingController();
    String? selectedCategory;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount greater than zero';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: expenseNameController,
                    decoration: InputDecoration(
                      labelText: 'Expense Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the expense name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    items: <String>['Food', 'Transport', 'Bills', 'Other']
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      selectedCategory = newValue;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : 'Selected Date: ${selectedDate.toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a date')),
                    );
                    return;
                  }
                  final expense = ExpenseTile(
                    name: expenseNameController.text,
                    price: double.parse(amountController.text),
                    date: selectedDate ?? DateTime.now(),
                    type: 'expense', // Set type to 'expense'
                  );

                  // Attempt to add the transaction
                  bool success = await Provider.of<Expenses>(context, listen: false).addTransaction(expense);

                  if (!success) {
                    // Show an error alert if the expense exceeds the available income
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Insufficient Funds'),
                          content: Text('The expense amount exceeds your available balance.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.of(context).pop(); // Close the dialog if the transaction was added successfully
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
