import 'package:flutter/services.dart';

List<TextInputFormatter> inputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(
    RegExp("[0-9\.-]"),
    replacementString: ('.'),
  ),
  FilteringTextInputFormatter.deny(
    RegExp(r'\.\.+'),
    replacementString: '.',
  ),
  FilteringTextInputFormatter.deny(
    RegExp(r'^\.'),
    replacementString: '0.',
  ),
  FilteringTextInputFormatter.deny(
    RegExp(r'\.\d+\.'),
  ),
  FilteringTextInputFormatter.deny(
    RegExp(r'\d+-'),
  ),
  FilteringTextInputFormatter.deny(
    RegExp(r'-\.+'),
  ),
  FilteringTextInputFormatter.deny(
    RegExp(r'^0\d+'),
  ),
];