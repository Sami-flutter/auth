import 'package:flutter/material.dart';

class Transaction {
  final IconData icon; // Icon for the transaction
  final String name; // Name or description of the transaction
  final DateTime date; // Date of the transaction
  final double price; // Price of the transaction

  // Constructor to initialize the transaction fields
  Transaction({
    required this.icon,
    required this.name,
    required this.date,
    required this.price,
  });
}

class TransactionsListTile extends StatelessWidget {
  const TransactionsListTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of transactions
    final transactions = [
      Transaction(
        icon: Icons.food_bank,
        name: 'Food',
        date: DateTime.now(),
        price: 10.0,
      ),
      Transaction(
        icon: Icons.local_gas_station,
        name: 'Gas',
        date: DateTime.now(),
        price: 40.0,
      ),
      Transaction(
        icon: Icons.food_bank,
        name: 'Hanging out',
        date: DateTime.now(),
        price: 160.0,
      ),
      Transaction(
        icon: Icons.local_gas_station,
        name: 'Rent fee',
        date: DateTime.now(),
        price: 270.0,
      ),
      // Add more transactions here
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: Icon(transaction.icon),
                  title: Text(transaction.name),
                  subtitle: Text(transaction.date.toShortDateString()),
                  trailing: Text(
                    '\$${transaction.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    // Format the date to a short string (e.g., "8/5/2024")
    return '$month/$day/$year';
  }
}
