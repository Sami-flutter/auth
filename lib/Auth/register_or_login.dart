import 'package:flutter/material.dart';
import 'package:auth/pages/components/register.dart';
import 'package:auth/pages/login_page.dart';

class LoginRegister extends StatefulWidget {

const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
// initial show the login page
  bool showLoginPage = true;

  // Toggle method between login page and register
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap:togglePages);

    } else {
      return RegisterNow(onTap: togglePages);
    }

    }
    }
  
