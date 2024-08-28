import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseTile {
  final String? id; // Firestore document ID
  final String name;
  final double price;
  final DateTime date;
  final String type; // New field to indicate 'income' or 'expense'

  ExpenseTile({
    this.id, // ID is optional because it's assigned after creation
    required this.name,
    required this.price,
    required this.date,
    required this.type, // Required type parameter
  });

  // Create a copy of this instance with a different ID
  ExpenseTile copyWith({String? id}) {
    return ExpenseTile(
      id: id ?? this.id,
      name: this.name,
      price: this.price,
      date: this.date,
      type: this.type, // Preserve the type in the copied instance
    );
  }

  // Convert a Firestore document to an ExpenseTile
  factory ExpenseTile.fromMap(Map<String, dynamic> data, String id) {
    return ExpenseTile(
      id: id,
      name: data['name'],
      price: data['price'],
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'], // Map 'type' field from Firestore
    );
  }

  // Convert an ExpenseTile to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'date': date,
      'type': type, // Include 'type' in the Firestore document
    };
  }
}
