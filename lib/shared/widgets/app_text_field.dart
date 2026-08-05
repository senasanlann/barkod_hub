import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType,
    this.prefixIcon,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      ),
    );
  }
}
