import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GasField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String value) onChange;

  const GasField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        Container(
          height: 34,
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                  RegExp(r'(^-?\d*\.?d*\,?\d*)')),
            ],
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hoverColor: Colors.transparent,
              enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppTheme.pinkColor),
              ),
              contentPadding: const EdgeInsets.all(8),
              hintText: 'Type amount...',
            ),
            onChanged: (String value) => onChange(value),
          ),
        )
      ],
    );
  }
}
