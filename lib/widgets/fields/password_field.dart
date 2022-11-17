import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController? passwordController;
  final String? hintText;
  final Function(String text)? onChanged;
  final Function()? onIconPressed;
  final Function()? onEditComplete;
  final bool obscureText;
  final bool autofocus;
  final bool isObscureIcon;

  const PasswordField({
    Key? key,
    this.passwordController,
    this.hintText,
    this.onChanged,
    this.onIconPressed,
    this.onEditComplete,
    this.obscureText = false,
    this.autofocus = false,
    this.isObscureIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscureText,
      onEditingComplete: onEditComplete,
      controller: passwordController,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: isObscureIcon
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: onIconPressed,
              )
            : null,
      ),
      onChanged: onChanged,
        validator: (value) {
          return value == null || value.isEmpty
              ? 'Please enter password'
              : null;
        }
    );
  }
}
