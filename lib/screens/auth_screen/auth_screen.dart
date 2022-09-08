import 'package:defi_wallet/screens/auth_screen/recovery/recovery_screen.dart';
import 'package:defi_wallet/screens/auth_screen/secure_wallet/not_secure_screen.dart';
import 'package:defi_wallet/screens/ledger_screen/ledger_init_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/client/hive_names.dart';

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
                SizedBox(height: 16),
                Text(
                  'Your Keys. Your Crypto.',
                  style: Theme.of(context).textTheme.headline2,
                ),
                SizedBox(height: 50),
                Text(
                  'Wallet setup',
                  style: Theme.of(context).textTheme.headline2,
                ),
                SizedBox(height: 16),
                StretchBox(
                  maxWidth: ScreenSizes.xSmall,
                  child: PrimaryButton(
                    label: 'Ledger Setup',
                    callback: () async {
                      var box = await Hive.openBox(HiveBoxes.client);
                      await box.put(HiveNames.openedLedger, null);
                      await box.close();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => LedgerInitScreen(),
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
                  child: AccentButton(
                    label: 'Import using secret Recovery Phrase',
                    callback: () async {
                      var box = await Hive.openBox(HiveBoxes.client);
                      await box.put(HiveNames.openedMnemonic, null);
                      await box.close();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => RecoveryScreen(),
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
                  child: PrimaryButton(
                    isCheckLock: false,
                    label: 'Create a new wallet',
                    callback: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => NotSecureScreen(),
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
          ),
        ),
      );
}
