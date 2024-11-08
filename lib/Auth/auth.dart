import 'package:auth/pages/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth/Auth/register_or_login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Is the user logged in?
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Is the user not logged in?
          else {
            return const LoginRegister();
          }
        },
      ),
    );
  }
}
