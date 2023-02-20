import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController? passwordController;
  final String? hintText;
  final Function(String text)? onChanged;
  final Function()? onIconPressed;
  final Function()? onEditComplete;
  final Function(String)? onSubmitted;
  final Function(String?)? onSaved;
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
    this.onSubmitted,
    this.onSaved,
    this.obscureText = false,
    this.autofocus = false,
    this.isObscureIcon = true,
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    widget.passwordController!.text = "";
    widget.passwordController!.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _focusNode.requestFocus();
        widget.passwordController!.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.passwordController!.text.length);
      },
      child: TextFormField(
          autofocus: widget.autofocus,
          maxLines: 1,
          onFieldSubmitted: widget.onSubmitted,
          onSaved: widget.onSaved,
          textAlignVertical: TextAlignVertical.center,
          obscureText: widget.obscureText,
          onEditingComplete: widget.onEditComplete,
          controller: widget.passwordController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: widget.isObscureIcon
                ? IconButton(
                    icon: Icon(
                      widget.obscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: widget.onIconPressed,
                  )
                : null,
          ),
          onChanged: widget.onChanged,
          validator: (value) {
            return value == null || value.isEmpty
                ? 'Please enter password'
                : null;
          }),
    );
  }
}
