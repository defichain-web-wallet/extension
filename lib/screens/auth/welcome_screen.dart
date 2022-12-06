import 'package:defi_wallet/screens/auth/password_screen.dart';
import 'package:defi_wallet/screens/auth_screen/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/ui_kit.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
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
              left: -420,
              top: 20.0,
              child: WelcomeTextCover(
                '欢迎,Bem-vindo,Witamy,欢迎,Bem-vindo,Witamy',
              ),
            ),
            Positioned(
              left: -425,
              top: 70.0,
              child: WelcomeTextCover(
                'Welcome,欢迎,Willkommen,Welcome,欢迎,Willkommen',
                wordSelectId: 3,
              ),
            ),
            Positioned(
              left: -570,
              top: 120.0,
              child: WelcomeTextCover(
                'Bonjour,Benvenuto,어서 오십시오,Bonjour,Benvenuto,어서 오십시오',
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20, top: 54),
                    width: 390,
                    height: 370,
                    child: Image(
                      image: AssetImage(
                        'assets/welcome_logo.png',
                      ),
                    ),
                  ),
                  StretchBox(
                    maxWidth: ScreenSizes.xSmall,
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
                  SizedBox(height: 16),
                  StretchBox(
                    maxWidth: ScreenSizes.xSmall,
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
                  SizedBox(height: 20),
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
                          style: AppTheme.defiUnderlineText,
                        ),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Work in progress')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
