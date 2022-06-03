import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';

class AddressField extends StatelessWidget {
  final TextEditingController? addressController;
  final Function(String)? onChanged;

  const AddressField({Key? key, this.addressController, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 3,
          ),
        ],
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.button,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).textTheme.button!.decorationColor!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppTheme.pinkColor),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onChanged: onChanged,
        controller: addressController,
      ),
    );
  }
}
