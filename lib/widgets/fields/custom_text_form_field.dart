import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? addressController;
  final Function(String)? onChanged;
  final Widget? prefix;
  final String? hintText;
  final String? validationRule;
  final isBorder;

  const CustomTextFormField({
    Key? key,
    this.addressController,
    this.onChanged,
    this.prefix,
    this.hintText,
    this.validationRule,
    this.isBorder = false,
  }) : super(key: key);

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> with ThemeMixin{
  final _focusNode = FocusNode();

  @override
  void initState() {
    widget.addressController!.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _focusNode.requestFocus();
        widget.addressController!.selection = TextSelection(
            baseOffset: 0, extentOffset: widget.addressController!.text.length);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          style: Theme.of(context).textTheme.button,
          decoration: InputDecoration(
            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
            hintStyle: passwordField.copyWith(
              color: isDarkTheme() ? DarkColors.hintTextColor : LightColors.hintTextColor,
            ),
            prefixIcon: widget.prefix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            hintText: widget.hintText,
          ),
          onChanged: widget.onChanged,
          focusNode: _focusNode,
          controller: widget.addressController,
          validator: (value) {
            switch (widget.validationRule) {
              case 'email':
                return value != null && !EmailValidator.validate(value)
                    ? 'Enter a valid email'
                    : null;
              case 'password':
                return value != null && value.length < 6
                    ? "Enter min. 6 characters"
                    : null;
              case 'name':
                return value == null || value.isEmpty
                    ? "Enter your name"
                    : null;
              case 'surname':
                return value == null || value.isEmpty
                    ? "Enter your surname"
                    : null;
              default:
                return value == null || value.isEmpty
                    ? 'Please enter this field'
                    : null;
            }
          },
        ),
      ),
    );
  }
}
