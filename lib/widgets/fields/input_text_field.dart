import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/fields/suffix_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputTextField extends StatefulWidget {
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

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  final int maxLines = 1;

  @override
  Widget build(BuildContext context) {
    print('input text field');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.headline4,
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 16.0,
                spreadRadius: 0,
                offset: Offset(0.0, 4.0),
                color: Color(0xFF6843FD).withOpacity(0.08),
              ),
            ],
          ),
          child: TextFormField(
            autofocus: widget.autofocus,
            maxLines: maxLines,
            onFieldSubmitted: widget.onSubmitted,
            textAlignVertical: TextAlignVertical.center,
            obscureText: widget.isObscure,
            onEditingComplete: widget.onEditComplete,
            controller: widget.controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              enabledBorder:
                  Theme.of(context).inputDecorationTheme.enabledBorder,
              focusedBorder:
                  Theme.of(context).inputDecorationTheme.focusedBorder,
              hintText: widget.hint,
              suffixIconConstraints:
                  BoxConstraints(minHeight: 24, minWidth: 24),
              suffixIcon: widget.isShowObscureIcon
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16.0),
                      child: SuffixIcon(
                        isObscure: widget.isObscure,
                        callback: widget.onPressObscure!,
                      ),
                    )
                  : null,
            ),
            onChanged: widget.onChanged,
            validator: (value) {
              return value == null || value.isEmpty
                  ? 'Please enter this field'
                  : null;
            },
          ),
        ),
        if (widget.isShowObscureIcon) ...[
          SizedBox(
            height: 8,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xFF12052F).withOpacity(0.08),
            ),
            child: Text(
              'Must be at least 8 characters',
              style: Theme.of(context).textTheme.caption,
            ),
          )
        ]
      ],
    );
  }
}
