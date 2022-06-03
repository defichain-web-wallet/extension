import 'package:defi_wallet/screens/auth_screen/secure_wallet/secure_wallet_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/auth_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';

class NotSecureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: AuthAppBar(),
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
        color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              '1/3',
                              style: Theme.of(context).textTheme.headline2,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Secure your wallet',
                              style: Theme.of(context).textTheme.headline1,
                            ),
                            SizedBox(height: 24),
                            Text(
                              "Secure your wallet's seed phrase.",
                              style: Theme.of(context).textTheme.headline2,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(Icons.info_outline,
                                        color: AppTheme.pinkColor),
                                  ),
                                  Text(
                                    'What is a secret recovery phrase?'
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .apply(
                                            fontSizeDelta: 2,
                                            fontWeightDelta: 2),
                                  )
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 18),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).shadowColor,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                    'Your  Secret Recovery Phrase is a set of 24 words that contains all the information about your wallet, including your funds. You need your Secret Recovery Phrase to get access to your funds in case you deinstall JellyWallet, technical issues or you if you want to move your funds to saiive.live wallet.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .apply(
                                          fontWeightDelta: 2,
                                          fontSizeDelta: 2,
                                        )),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      StretchBox(
                        child: PrimaryButton(
                          isCheckLock: false,
                          label: 'Continue',
                          callback: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) => SecureScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
