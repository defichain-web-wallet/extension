import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';

class SignupDoneScreen extends StatelessWidget {
  const SignupDoneScreen({Key? key}) : super(key: key);
  final double imageWidth = 180;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        String text =
            'You’ve successfully protected your wallet. Remember to keep your Secret Recovery Phrase safe, it’s your responsibility!';

        return Scaffold(
          appBar: WelcomeAppBar(),
          body: Container(
            padding: authPaddingContainer.copyWith(
              top: 64,
            ),
            child: Center(
              child: StretchBox(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/jelly_success.png',
                            width: 239,
                            height: 211,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Container(
                            height: 34,
                            child: Text(
                              'Congratulations',
                              style: headline3,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: isFullScreen
                                ? buttonFullWidth
                                : buttonSmallWidth,
                            child: Text(
                              text,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headline5!.apply(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.6),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    NewPrimaryButton(
                      callback: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                HomeScreen(
                              isLoadTokens: true,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      width: isFullScreen ? buttonFullWidth : buttonSmallWidth,
                      title: 'Continue',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
