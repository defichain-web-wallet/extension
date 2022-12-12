import 'package:defi_wallet/screens/auth/password_screen.dart';
import 'package:defi_wallet/screens/auth/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth/signup/signup_placeholder_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/welcome_positioned_logo.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/client/hive_names.dart';

class WelcomeScreen extends StatelessWidget {

  signUpFlowCallback(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            PasswordScreen(
              onSubmitted: (String password) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder:
                        (context, animation1, animation2) =>
                        SignupPlaceholderScreen(
                          password: password,
                        ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: WelcomePositionedLogo(),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 280,
                  child: AccentButton(
                    label: 'Import using secret Recovery Phrase',
                    isCheckLock: false,
                    callback: () async {
                      var box = await Hive.openBox(HiveBoxes.client);
                      await box.put(HiveNames.openedMnemonic, null);
                      await box.close();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              RecoveryScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  child: NewPrimaryButton(
                    title: 'Create a new wallet',
                    callback: () => signUpFlowCallback(context),
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'By proceeding, you agree to these ',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    InkWell(
                      child: Text(
                        'Terms and Conditions',
                        style: jellyLink,
                      ),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Work in progress')),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
