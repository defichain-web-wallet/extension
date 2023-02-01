import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? suffix;
  final FocusNode? focusNode;
  final Function(String)? onSubmited;
  final Function(String)? onChanged;

  InputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onSubmited,
    this.onChanged,
    this.focusNode,
    this.suffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        onChanged: onChanged,
        focusNode: focusNode,
        controller: controller,
        decoration: InputDecoration(
          hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
          focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
          hintText: hintText,
          suffixIconConstraints: BoxConstraints(minHeight: 24, minWidth: 24),
          suffixIcon: suffix,
        ),
        style: passwordField.apply(
          color: Theme.of(context).textTheme.headline1!.color!,
        ),
        onFieldSubmitted: onSubmited,
      ),
    );
  }
}
