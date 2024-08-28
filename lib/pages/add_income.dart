// import 'package:flutter/material.dart';

// class AddIncome extends StatelessWidget {
//   const AddIncome({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Expense Form',
//       theme: ThemeData(
//         primaryColor: Color(0xFF4A5BC1),
//       ),
//       debugShowCheckedModeBanner: false,
//       home: ExpenseFormPage(),
//     );
//   }
// }

// class ExpenseFormPage extends StatefulWidget {
//   @override
//   _ExpenseFormPageState createState() => _ExpenseFormPageState();
// }

// class _ExpenseFormPageState extends State<ExpenseFormPage> {
//   TextEditingController _amountController = TextEditingController();
//   TextEditingController _dateController = TextEditingController();
//   TextEditingController _invoiceController = TextEditingController();
//   String _selectedName = 'Wendy Technology Inc.';
//   DateTime _selectedDate = DateTime.now();

//   _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _dateController.text = "${picked.toLocal()}".split(' ')[0];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Expense'),
//         backgroundColor: Color(0xFF4A5BC1),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButtonFormField<String>(
//               value: _selectedName,
//               decoration: InputDecoration(
//                 labelText: 'Name',
//                 border: OutlineInputBorder(),
//               ),
//               items: <String>['Wendy Technology Inc.', 'Another Company']
//                   .map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedName = newValue!;
//                 });
//               },
//             ),
//             SizedBox(height: 16.0),
//             TextFormField(
//               controller: _amountController,
//               decoration: InputDecoration(
//                 labelText: 'Amount',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16.0),
//             TextFormField(
//               controller: _dateController,
//               decoration: InputDecoration(
//                 labelText: 'Date',
//                 border: OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.calendar_today),
//                   onPressed: () => _selectDate(context),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             TextFormField(
//               controller: _invoiceController,
//               decoration: InputDecoration(
//                 labelText: 'Add Invoice',
//                 border: OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.add),
//                   onPressed: () {
//                     // Add your logic to add invoice here
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(AddIncome());
// }
