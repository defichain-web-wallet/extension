import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? addressController;
  final Function(String)? onChanged;
  final String? hintText;
  final String? validationRule;

  const CustomTextFormField({
    Key? key,
    this.addressController,
    this.onChanged,
    this.hintText,
    this.validationRule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 46,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppTheme.shadowColor.withOpacity(0.1),
        //     spreadRadius: 2,
        //     blurRadius: 3,
        //   ),
        // ],
      ),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.button,
        decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.pinkColor),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 14)),
        onChanged: onChanged,
        controller: addressController,
        validator: (value) {
          switch (validationRule) {
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
    );
  }
}
