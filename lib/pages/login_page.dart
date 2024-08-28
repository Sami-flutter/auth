import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth/pages/components/button.dart';
import 'package:auth/pages/components/text_field.dart';
class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  void signin() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // If successful, close the loading indicator
      if (context.mounted) {
        Navigator.pop(context); // Close the CircularProgressIndicator
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the CircularProgressIndicator
      displayMessage(e.message ?? "An error occurred. Please try again.");
    }
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 17.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               // const SizedBox(height: 20),
                const Icon(
                  Icons.lock,
                  size: 130,
                  color:Color.fromARGB(255, 3, 135, 196),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(97, 97, 97, 1),
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyButton(onTap: signin, 
                text: 'Sign in'),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Not a Member?',
                      style: TextStyle(
                        color: Color.fromRGBO(97, 97, 97, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        '  Register Now',
                        style: TextStyle(
                          color: Color.fromARGB(255, 10, 103, 179),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Welcome to the home page!'),
      ),
    );
  }
}
