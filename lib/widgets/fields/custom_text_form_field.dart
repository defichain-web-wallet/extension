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

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    widget.addressController!.addListener(() { });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        _focusNode.requestFocus();
        widget.addressController!.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.addressController!.text.length);
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
              prefixIcon: widget.prefix,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hoverColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.isBorder ? AppColors.portage.withOpacity(0.12) : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.pinkColor),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              hintText: widget.hintText,
              hintStyle: TextStyle(fontSize: 14)),
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
                return value == null || value.isEmpty ? "Enter your name" : null;
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
