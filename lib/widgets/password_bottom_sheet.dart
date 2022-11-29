import 'dart:async';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/password_field.dart';
import 'package:flutter/material.dart';

class PasswordBottomSheet {
  static double _height = 210;
  static double _width = 410;
  static TextEditingController _passwordController = TextEditingController();
  static GlobalKey<FormState> _formKey = GlobalKey();

  static void provideWithPassword(
    BuildContext context,
    AccountModel account,
    Function(String) callback,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      constraints: BoxConstraints(
        maxWidth: ScreenSizes.medium,
      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          'Enter password',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => closeSheet(context),
                            icon: Icon(Icons.close),
                            iconSize: 16,
                            splashRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: PasswordField(
                    passwordController: _passwordController,
                    obscureText: true,
                    hintText: 'Password',
                    isObscureIcon: false,
                    onSubmitted: (value) async => onSubmit(
                      context,
                      account,
                      callback,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: PrimaryButton(
                    label: 'Confirm transaction',
                    callback: () async => onSubmit(context, account, callback),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void provideWithPasswordFullScreen(
    BuildContext context,
    AccountModel account,
    Function(String) callback,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          content: Container(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 25,
              left: 5,
              right: 5,
            ),
            height: _height,
            width: _width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).dialogBackgroundColor,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            'Enter password',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => closeSheet(context),
                              icon: Icon(Icons.close),
                              iconSize: 16,
                              splashRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: PasswordField(
                      passwordController: _passwordController,
                      obscureText: true,
                      hintText: 'Password',
                      isObscureIcon: false,
                      onSubmitted: (value) async => onSubmit(
                        context,
                        account,
                        callback,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: PrimaryButton(
                      label: 'Confirm transaction',
                      callback: () async =>
                          onSubmit(context, account, callback),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static onSubmit(
    BuildContext context,
    AccountModel account,
    Function(String) callback,
  ) async {
    if (_formKey.currentState!.validate()) {
      String password = _passwordController.text;
      try {
        await HDWalletService().getKeypairFromStorage(password, account.index!);
        closeSheet(context);
        callback(password);
      } catch (error) {
        closeSheet(context);
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
  }

  static closeSheet(BuildContext context) {
    _passwordController.text = '';
    Navigator.pop(context);
  }
}
