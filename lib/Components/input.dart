import 'package:flutter/material.dart';

class InputCampo extends StatelessWidget {

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  const InputCampo({super.key, required this.hint, required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10 , vertical: 10),
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon),
          hintText: hint,
        ),
      ),
    );
  }
}