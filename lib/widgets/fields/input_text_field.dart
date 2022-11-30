import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final Function(String text)? onChanged;
  final Function()? onPressObscure;
  final Function()? onEditComplete;
  final Function(String value)? onSubmitted;
  final bool autofocus;
  final bool isObscure;
  final bool isShowObscureIcon;

  const InputTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.label,
    this.onChanged,
    this.onPressObscure,
    this.onEditComplete,
    this.onSubmitted,
    this.autofocus = false,
    this.isObscure = false,
    this.isShowObscureIcon = false,
  }) : super(key: key);

  final int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headline4,
        ),
        SizedBox(
          height: 8,
        ),
        TextFormField(
          autofocus: autofocus,
          maxLines: maxLines,
          onFieldSubmitted: onSubmitted,
          textAlignVertical: TextAlignVertical.center,
          obscureText: isObscure,
          onEditingComplete: onEditComplete,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isShowObscureIcon
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: onPressObscure,
                  )
                : null,
          ),
          onChanged: onChanged,
          validator: (value) {
            return value == null || value.isEmpty
                ? 'Please enter this field'
                : null;
          },
        )
      ],
    );
  }
}
