import 'dart:convert' as convert;
import 'dart:ui';

import 'package:crypt/crypt.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PassConfirmDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const PassConfirmDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<PassConfirmDialog> createState() => _PassConfirmDialogState();
}

class _PassConfirmDialogState extends State<PassConfirmDialog> {
  SettingsHelper settingsHelper = SettingsHelper();
  bool isPasswordObscure = true;
  bool isEnable = true;
  bool isVisiblePasswordField = true;
  String password = '';
  bool isFailed = false;
  convert.Codec<String, String> stringToBase64 =
      convert.utf8.fuse(convert.base64);
  GlobalKey globalKey = GlobalKey();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: AlertDialog(
        insetPadding: EdgeInsets.all(24),
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(20),
        ),
        actionsPadding: EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 14,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 104,
                child: AccentButton(
                  callback: () {
                    Navigator.pop(context);
                  },
                  label: 'Cancel',
                ),
              ),
              NewPrimaryButton(
                width: 104,
                title: 'Confirm',
                callback: () {
                  _restoreWallet();
                },
              ),
            ],
          ),
        ],
        contentPadding: EdgeInsets.only(
          top: 16,
          bottom: 0,
          left: 16,
          right: 16,
        ),
        content: Stack(
          children: [
            Container(
              width: 312,
              height: 200,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color:
                                Theme.of(context).dividerColor.withOpacity(0.5),
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              'Confirmation',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Text(
                              'Please confirm the transaction\nby entering your password',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .color!
                                        .withOpacity(0.6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                              softWrap: true,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        PasswordTextField(
                          controller: _passwordController,
                          status: PasswordStatusList.initial,
                          hint: 'Your password',
                          label: 'Password',
                          isShowObscureIcon: true,
                          isCaptionShown: false,
                          isObscure: isPasswordObscure,
                          onChanged: (String value) {
                            password = value;
                          },
                          onPressObscure: () {
                            setState(
                                () => isPasswordObscure = !isPasswordObscure);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _restoreWallet() async {
    setState(() {
      isFailed = false;
      isEnable = false;
    });
    var box = await Hive.openBox(HiveBoxes.client);
    var encodedPassword = box.get(HiveNames.password);

    if (Crypt(encodedPassword).match(password)) {
      widget.onSubmit(_passwordController.text);
      Navigator.pop(context);
    } else {
      setState(() {
        print('sad');
        isFailed = true;
        isEnable = true;
      });
    }
  }
}
