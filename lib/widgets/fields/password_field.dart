import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController? passwordController;
  final String? hintText;
  final Function(String text)? onChanged;
  final Function()? onIconPressed;
  final Function()? onEditComplete;
  final bool obscureText;
  final bool autofocus;

  const PasswordField(
      {Key? key,
      this.passwordController,
      this.hintText,
      this.onChanged,
      this.onIconPressed,
      this.onEditComplete,
      this.obscureText = false,
      this.autofocus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscureText,
      onEditingComplete: onEditComplete,
      controller: passwordController,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: onIconPressed,
        ),
      ),
      onChanged: onChanged,
    );
  }
}
