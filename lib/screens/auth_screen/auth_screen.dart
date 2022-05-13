import 'package:defi_wallet/screens/auth_screen/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/not_secure_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: WelcomeAppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/jelly_logo.svg',
                  height: 180,
                  width: 220,
                ),
                Text(
                  'Welcome to wallet!',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 20),
                Text(
                  'Your Keys. Your Crypto.',
                  style: Theme.of(context).textTheme.headline2,
                ),
                SizedBox(height: 60),
                Text(
                  'Wallet setup',
                  style: Theme.of(context).textTheme.headline2,
                ),
                SizedBox(height: 16),
                StretchBox(
                    maxWidth: ScreenSizes.xSmall,
                    child: AccentButton(
                      label: 'Import using secret Recovery Phrase',
                      callback: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecoveryScreen(),
                        ),
                      ),
                    )),
                SizedBox(height: 16),
                StretchBox(
                  maxWidth: ScreenSizes.xSmall,
                  child: PrimaryButton(
                    isCheckLock: false,
                    label: 'Create a new wallet',
                    callback: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotSecureScreen(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
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
          ),
        ),
      );
}
