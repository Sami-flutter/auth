import 'dart:io';
import 'package:flutter/material.dart';
import 'package:auth/pages/components/button.dart';
import 'package:auth/pages/components/text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_list_pick/country_list_pick.dart';

class RegisterNow extends StatefulWidget {
  final Function()? onTap;
  const RegisterNow({super.key, required this.onTap});

  @override
  State<RegisterNow> createState() => _RegisterNowState();
}

class _RegisterNowState extends State<RegisterNow> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final dobTextController = TextEditingController();
  final phoneTextController =
      TextEditingController(); // New controller for phone

  String? selectedCountry;
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(User user) async {
    if (_image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user.uid}.jpg');

      UploadTask uploadTask = storageRef.putFile(_image!);
      await uploadTask;

      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error during image upload: $e');
      return null;
    }
  }

  void signUp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordTextController.text != confirmTextController.text) {
      Navigator.pop(context);
      displayMessage('Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      User? user = userCredential.user;

      if (user == null) {
        Navigator.pop(context);
        displayMessage('User creation failed. Please try again.');
        return;
      }

      String? imageUrl = await _uploadImageToFirebase(user);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameTextController.text,
        'email': emailTextController.text,
        'dob': dobTextController.text,
        'phone': phoneTextController.text, // Save the phone number
        'country': selectedCountry,
        'imageUrl': imageUrl ?? '',
      });

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.message ?? 'An error occurred. Please try again.');
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        dobTextController.text =
            "${selectedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
      });
    }
  }

  void _showCountryPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Country'),
          content: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: Column(
              children: [
                Expanded(
                  child: CountryListPick(
                    appBar: AppBar(
                      title: const Text('Select Country'),
                      backgroundColor: Colors.blue,
                    ),
                    onChanged: (CountryCode? code) {
                      setState(() {
                        selectedCountry = code!.name;
                      });
                      Navigator.pop(context);
                    },
                    initialSelection: '+1',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: const Text('Register Now'),
      // ),
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
                  const Text(
                    'Register Now!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(97, 97, 97, 1),
                    ),
                  ),
                  const SizedBox(height: 25),
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
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: MyTextField(
                        controller: dobTextController,
                        hintText: 'Date of Birth',
                        obscureText: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCountry ?? 'Select Country',
                            style: TextStyle(
                              color: selectedCountry == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    onTap: () {
                      signUp(context);
                    },
                    text: 'Sign up',
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Already have an account? Log in',
                      style: TextStyle(
                        color: Color.fromRGBO(97, 97, 97, 1),
                      ),
                    ),
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
