// Import the Expenses class for logout functionality
import 'package:auth/pages/Models/transections.dart';
import 'package:auth/pages/add_expense.dart';
import 'package:auth/pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider to access Expenses class
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = 'Loading...';
  String userImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'No Name';
          userImageUrl = userDoc['imageUrl'] ?? '';
        });
      }
    }
  }

  // Method to map categories to icons
  IconData _getIconForCategory(String category) {
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
        return Icons.category; // Default icon for other categories
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // Light background color
      body: FutureBuilder(
        future: Provider.of<Expenses>(context, listen: false).initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else {
            return Consumer<Expenses>(
              builder: (context, expensesProvider, child) {
                double totalBalance = expensesProvider
                    .calculateTotalBalance(); // Calculate total balance

                double totalIncome = expensesProvider.transactions
                    .where((item) => item.type == 'income')
                    .fold(0.0, (sum, item) => sum + item.price);

                double totalExpenses = expensesProvider.transactions
                    .where((item) => item.type == 'expense')
                    .fold(0.0, (sum, item) => sum + item.price);

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Add space at the top of the AppBar
                      SizedBox(
                          height: 50), // Adjust the height to the desired space

                      // Custom AppBar with User Info
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: userImageUrl.isNotEmpty
                                      ? NetworkImage(userImageUrl)
                                      : AssetImage('assets/default_avatar.png')
                                          as ImageProvider,
                                  radius: 24,
                                ),
                                SizedBox(width: 22),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome!',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.logout,
                                      color:
                                          Colors.grey), // Change to logout icon
                                  onPressed: () async {
                                    // Call the logout method from the Expenses class
                                    await Provider.of<Expenses>(context,
                                            listen: false)
                                        .logout();

                                    // Navigate to the login screen or any other appropriate screen
                                    Navigator.of(context)
                                        .pushReplacementNamed('/login');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Add spacing between the AppBar and Balance Container
                      // Balance Container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: EdgeInsets.all(25.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3E60E9), Color(0xFFED6A5A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '\$${totalBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Income',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        '\$${totalIncome.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expenses',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        '\$${totalExpenses.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Transactions List
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transactions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all transactions
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(color: Color(0xFF3498DB)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (expensesProvider.transactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No transactions found.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      if (expensesProvider.transactions.isNotEmpty)
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: expensesProvider.transactions.length,
                          itemBuilder: (context, index) {
                            final item = expensesProvider.transactions[index];
                            final isIncome = item.type == 'income';
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFFF5F5F5),
                                  child: Icon(
                                    _getIconForCategory(item.name),
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(item.date
                                    .toString()
                                    .split(' ')[0]), // Show the date
                                trailing: Text(
                                  '\$${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransactionPage()),
          );
        },
        backgroundColor: Color(0xFF3E60E9),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.grey),
              onPressed: () {
                // Navigate to Home
              },
            ),
            IconButton(
              icon: Icon(Icons.bar_chart, color: Colors.grey),
              onPressed: () {
                // Navigate to statistics
              },
            ),
            SizedBox(width: 48), // The dummy child for the FAB
            IconButton(
              icon: Icon(Icons.person, color: Colors.grey),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
