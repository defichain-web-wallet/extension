import 'package:defi_wallet/screens/auth/password_screen.dart';
import 'package:defi_wallet/screens/auth_screen/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/ui_kit.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/auth/welcome_text_cover.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/client/hive_names.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).dialogBackgroundColor,
        child: Stack(
          children: [
            Positioned(
              left: -320,
              top: 42.0,
              child: WelcomeTextCover(
                '欢迎,Bem-vindo,Witamy,欢迎,Bem-vindo,Witamy',
              ),
            ),
            Positioned(
              left: -290,
              top: 90.0,
              child: WelcomeTextCover(
                'Welcome,欢迎,Willkommen,Welcome,欢迎,Willkommen',
                wordSelectId: 3,
              ),
            ),
            Positioned(
              left: -380,
              top: 132.0,
              child: WelcomeTextCover(
                'Bonjour,Benvenuto,어서 오십시오,Bonjour,Benvenuto,어서 오십시오',
              ),
            ),
            Positioned(
              top: 114,
              left: 40,
              child: Container(
                width: 295,
                height: 312,
                child: Image(
                  image: AssetImage(
                    'assets/welcome_logo.png',
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: AccentButton(
                      label: 'Import using secret Recovery Phrase',
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
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: NewPrimaryButton(
                      title: 'Create a new wallet',
                      callback: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              PasswordScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
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
            )
          ],
        ),
      ),
    );
  }
}
