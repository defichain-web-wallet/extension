import 'dart:math';

import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/create_password_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/widgets/text_fields.dart';
import 'package:defi_wallet/services/mnemonic_service.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/auth_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';

class ConfirmationMnemonic extends StatefulWidget {
  final List<String> mnemonic;

  const ConfirmationMnemonic({Key? key, required this.mnemonic})
      : super(key: key);

  @override
  State<ConfirmationMnemonic> createState() => _ConfirmationMnemonicState();
}

class _ConfirmationMnemonicState extends State<ConfirmationMnemonic> {
  final int fieldsLength = 24;
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;
  List<int> invalidControllerIndexes = [];
  GlobalKey globalKey = GlobalKey();
  List<int> hideMnemonicIds = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23];

  @override
  void initState() {
    super.initState();
    controllers = List.generate(fieldsLength, (i) {
      if (hideMnemonicIds.contains(i)) {
        return TextEditingController(text: '');
      } else {
        return TextEditingController(text: widget.mnemonic[i]);
      }
    });
    focusNodes = List.generate(fieldsLength, (i) => FocusNode());
  }

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: AuthAppBar(
                isShowFullScreen: true,
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: AuthAppBar(
                  isSmall: false,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        }),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) => Container(
        color: Theme.of(context).dialogBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      '3/4',
                      style: Theme.of(context).textTheme.headline2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Confirm your seed',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(height: 24),
                    Text(
                      "Please enter the missing words from the seed",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
                TextFields(
                  controllers: controllers,
                  focusNodes: focusNodes,
                  globalKey: globalKey,
                  invalidControllerIndexes: invalidControllerIndexes,
                ),
                StretchBox(
                  child: PendingButton(
                    'Continue',
                    isCheckLock: false,
                    globalKey: globalKey,
                    callback: (parent) {
                      var phrase = _getPhrase(controllers);
                      if (phrase.length >= fieldsLength) {
                        parent.emitPending(true);

                        var isValidPhrase = validateMnemonic(phrase.join(' '));
                        if (isValidPhrase) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  CreatePasswordScreen(
                                      mnemonic: widget.mnemonic),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          setState(() {
                            invalidControllerIndexes =
                                getInvalidControllerIndexes(controllers);
                          });
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Invalid phrase',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              backgroundColor: Theme.of(context)
                                  .snackBarTheme
                                  .backgroundColor,
                            ),
                          );
                        }

                        parent.emitPending(false);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please, input all fields',
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            backgroundColor:
                                Theme.of(context).snackBarTheme.backgroundColor,
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );

  List<String> _getPhrase(controllers) =>
      List.generate(controllers.length, (i) => controllers[i].text);

  List<int> getInvalidControllerIndexes(controllers) {
    List<int> indexes = [];
    for (int i = 0; i < controllers.length; i++) {
      if (!isCorrectWord(controllers[i].text)) {
        indexes.add(i);
      }
    }
    return indexes;
  }
}
