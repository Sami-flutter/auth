import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auth/pages/components/button.dart';
import 'package:auth/pages/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegisterNow extends StatefulWidget {
  final Function()? onTap;
  const RegisterNow({super.key, required this.onTap});

  @override
  State<RegisterNow> createState() => _RegisterNowState();
}

class _RegisterNowState extends State<RegisterNow> {
  // Create text controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final dobTextController = TextEditingController();
  final countryTextController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to upload the image to Firebase Storage and get the image URL
  Future<String?> _uploadImageToFirebase(User user) async {
    if (_image == null) return null; // No image selected

    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user.uid}.jpg');

      // Upload the image to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_image!);

      // Wait for the upload to complete
      await uploadTask;

      // Get the download URL of the uploaded image
      String downloadUrl = await storageRef.getDownloadURL();
      print('Image uploaded. Download URL: $downloadUrl');

      // Return the image URL
      return downloadUrl;
    } catch (e) {
      print('Error occurred during image upload: $e');
      return null;
    }
  }

  // Show the loading indicator and handle the sign-up process
  void signUp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Check if passwords match
    if (passwordTextController.text != confirmTextController.text) {
      Navigator.pop(context); // Close the loading indicator
      displayMessage('Passwords do not match');
      return;
    }

    try {
      // Create the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Get the newly created user
      User? user = userCredential.user;

      if (user == null) {
        Navigator.pop(context);
        displayMessage('User creation failed. Please try again.');
        return;
      }

      // Upload the image and get the URL
      String? imageUrl = await _uploadImageToFirebase(user);

      // Store additional user information in Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameTextController.text,
          'email': emailTextController.text,
          'dob': dobTextController.text,
          'country': countryTextController.text,
          'imageUrl': imageUrl ?? '', // Save the image URL in Firestore
        });
      } catch (e) {
        Navigator.pop(context);
        displayMessage('Failed to save user data: $e');
        return;
      }

      // Close the loading indicator and navigate to the home page or another screen
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading indicator
      displayMessage(e.message ?? 'An error occurred. Please try again.');
    }
  }

  // Display error messages
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Profile Image Upload
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image == null
                          ? const NetworkImage(
                              'https://via.placeholder.com/150')
                          : FileImage(_image!) as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Welcome text
                  const Text(
                    'Register Now!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(97, 97, 97, 1),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Text fields for user data
                  MyTextField(
                    controller: nameTextController,
                    hintText: 'Name',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: confirmTextController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: dobTextController,
                    hintText: 'Date of Birth',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: countryTextController,
                    hintText: 'Country/Region',
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  // Sign-up button
                  MyButton(
                    onTap: () {
                      signUp(context);
                    },
                    text: 'Sign up',
                  ),
                  const SizedBox(height: 30),
                  // Go to Sign In button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Have an account?',
                        style: TextStyle(
                          color: Color.fromRGBO(97, 97, 97, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          '  Sign In',
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
      ),
    );
  }
}
