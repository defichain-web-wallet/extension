import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/auth/name_account_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class SecurePlaceholderScreen extends StatefulWidget {
  const SecurePlaceholderScreen({Key? key}) : super(key: key);

  @override
  State<SecurePlaceholderScreen> createState() =>
      _SecurePlaceholderScreenState();
}

class _SecurePlaceholderScreenState extends State<SecurePlaceholderScreen> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: WelcomeAppBar(
            progress: 0.7,
          ),
          body: Container(
            padding: authPaddingContainer,
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Text(
                          'Secure your wallet',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Secure your wallet’s seed phrase.',
                          style: Theme.of(context).textTheme.headline5!.apply(
                                color: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .color!
                                    .withOpacity(0.6),
                              ),
                        ),
                        SizedBox(
                          height: 21,
                        ),
                        Stack(
                          children: [
                            Positioned(
                              child: SvgPicture.asset(
                                'assets/secure_placeholder.svg',
                                width: 296,
                                height: 258,
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Transform.rotate(
                                  angle: -math.pi / 17.5,
                                  child: Container(
                                    height: 210,
                                    width: 200,
                                    child: Image(
                                      image: AssetImage(
                                        'assets/welcome_logo.png',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                child: Text(
                                  'Remind me later ',
                                  style: jellyLink,
                                ),
                                onTap: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Work in progress')),
                                ),
                              ),
                              Text(
                                ' (not recommented)',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .apply(
                                      color: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .color!
                                          .withOpacity(0.3),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: NewPrimaryButton(
                            title: 'Continue',
                            callback: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        NameAccountScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
