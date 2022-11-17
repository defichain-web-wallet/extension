import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/password_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';

class PasswordBottomSheet {
  static double _height = 210;
  static TextEditingController _passwordController = TextEditingController();
  static GlobalKey<FormState> _formKey = GlobalKey();

  static void provideWithPassword(
      BuildContext context, AccountModel account, Function(String) callback) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(
            top: 22,
            bottom: 32,
            left: 16,
            right: 16,
          ),
          height: _height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              topLeft: Radius.circular(10.0),
            ),
            color: Theme.of(context).dialogBackgroundColor,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Enter password',
                  style: Theme.of(context).textTheme.headline3,
                ),
                PasswordField(
                  passwordController: _passwordController,
                  obscureText: true,
                  hintText: 'Password',
                  isObscureIcon: false,
                ),
                PrimaryButton(
                  label: 'Confirm transaction',
                  callback: () async {
                    if (_formKey.currentState!.validate()) {
                      String password = _passwordController.text;
                      try {
                        await HDWalletService().getKeypairFromStorage(password, account.index!);
                        _passwordController.text = '';
                        Navigator.pop(context);
                        callback(password);
                      } catch (error) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Wrong password',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
