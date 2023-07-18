import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';

class PasswordService with SnackBarMixin {
  static RegExp targetRegExp = RegExp(
    "^[0-9a-zA-Z-_+=?!@#\$%:;^&*(){}<>\"',.\/|]*\$",
  );
  static RegExp matchRegExp = RegExp(
    "[0-9a-zA-Z-_+=?!@#\$%:;^&*(){}<>\"',.\/|]",
  );

  Future handleCorrectAndRun(
    BuildContext context,
    String password,
    Function() callback, {
    bool isLockScreen = false,
  }) async {
    if (targetRegExp.hasMatch(password)) {
      await callback();
    } else {
      String disallowedCharacters = getDisallowedCharacters(password);

      showSnackBar(
        context,
        title: 'Error: character(s) \'$disallowedCharacters\' are not allowed. '
            'Only english alphabet characters are allowed in the password.',
        color: AppColors.txStatusError.withOpacity(0.1),
        duration: 6,
        isLockScreen: isLockScreen,
        prefix: Icon(
          Icons.close,
          color: AppColors.txStatusError,
        ),
      );
    }
  }

  String getDisallowedCharacters(String password) {
    String characters = password.split('').toSet().join('');
    characters = characters.replaceAll(matchRegExp, '');
    return characters.split('').join(',');
  }
}
