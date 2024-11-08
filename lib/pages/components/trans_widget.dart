import 'package:auth/pages/Models/expense_tile.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final ExpenseTile expenseTile;

  const TransactionItem({
    super.key,
    required this.expenseTile,
  });

  @override
  Widget build(BuildContext context) {
    bool isExpense = expenseTile.type ==
        'expense'; // Check if the transaction is an expense based on the type

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        title: Text(
          expenseTile.name,
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          '${expenseTile.date.day} ${_monthName(expenseTile.date.month)}, ${expenseTile.date.year} • ${expenseTile.date.hour}:${expenseTile.date.minute.toString().padLeft(2, '0')} ${expenseTile.date.hour >= 12 ? 'PM' : 'AM'}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          '\$${expenseTile.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: isExpense
                ? Colors.red
                : Colors.green, // Red for expenses, green for incomes
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }
}
