import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
         enabledBorder:const  OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
         ),
          focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white)
      
        ),
      fillColor:Colors.grey[200],
      filled: true,
      hintText: hintText,
      hintStyle:  const TextStyle(
      color: Colors.black,
      )
      ),
      obscureText: obscureText,
      ),
    );
  }
}
