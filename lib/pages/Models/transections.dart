import 'package:auth/pages/Models/expense_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Expenses extends ChangeNotifier {
  List<ExpenseTile> _transactions = [];

  List<ExpenseTile> get transactions => _transactions;

  String? _userId;

  Expenses() {
    initialize();
  }

  Future<void> initialize() async {
    await _initializeUser();
    if (_userId != null) {
      print('User ID: $_userId'); // Debugging line to check user ID
      await fetchTransactions();
    } else {
      print('User is not logged in.');
    }
  }

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  Future<void> fetchTransactions() async {
    if (_userId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: _userId)
          .orderBy('date', descending: true)
          .get();

      _transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        DateTime parsedDate;

        // Handle both String and Timestamp types for the date field
        if (data['date'] is Timestamp) {
          parsedDate = (data['date'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          parsedDate = DateTime.parse(data['date']);
        } else {
          // Handle unexpected types, or throw an error
          throw Exception('Unexpected date format');
        }

        return ExpenseTile(
          id: doc.id,
          name: data['name'],
          price: (data['price'] as num).toDouble(),
          date: parsedDate,
          type: data['type'],
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Failed to fetch transactions: $e');
    }
  }

  Future<bool> addTransaction(ExpenseTile transaction) async {
    if (_userId == null) return false;

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('transactions').add({
        'name': transaction.name,
        'price': transaction.price,
        'date':
            Timestamp.fromDate(transaction.date), // Use Timestamp to store date
        'type': transaction.type,
        'userId': _userId,
      });

      _transactions.add(transaction.copyWith(id: docRef.id));
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to add transaction: $e');
      return false;
    }
  }

  Future<void> removeTransaction(ExpenseTile transaction) async {
    if (_userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .delete();
      _transactions.removeWhere((item) => item.id == transaction.id);
      notifyListeners();
    } catch (e) {
      print('Failed to remove transaction: $e');
    }
  }

  double calculateTotalBalance() {
    double totalIncome = _transactions
        .where((item) => item.type == 'income')
        .fold(0.0, (sum, item) => sum + item.price);
    double totalExpenses = _transactions
        .where((item) => item.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.price);
    return totalIncome - totalExpenses;
  }

  List<ExpenseTile> getCombinedAndSortedTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    return _transactions;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _userId = null;
    _transactions.clear();
    notifyListeners();
  }

  // New method to get the available balance
  double getAvailableBalance() {
    double totalIncome = _transactions
        .where((item) => item.type == 'income')
        .fold(0.0, (sum, item) => sum + item.price);
    double totalExpenses = _transactions
        .where((item) => item.type == 'expense')
        .fold(0.0, (sum, item) => sum + item.price);

    return totalIncome - totalExpenses;
  }
}
