
// import 'package:samiexpense/pages/components/blance.dart';
// import 'package:samiexpense/pages/components/transections_listtile.dart';
// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget { // Fixed the class name
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.menu),
//           onPressed: () {
//             // Handle the leading icon press
//           },
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.notifications),
//             onPressed: () {
//               // Handle the notifications icon press
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           BalanceBanner(), // Assuming this widget is defined elsewhere
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Transactions', // Fixed the typo in the text
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 Text(
//                   'See All',
//                   style: const TextStyle(color: Colors.blue), // Optional: Add style if needed
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 10,),
//           Expanded(
//             child: TransactionsListTile(), // Wrap in Expanded to take available space
//           ),
//         ],
//       ),
//     );
//   }
// }
