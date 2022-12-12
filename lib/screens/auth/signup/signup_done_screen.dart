import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';

class SignupDoneScreen extends StatelessWidget {
  const SignupDoneScreen({Key? key}) : super(key: key);

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
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 64,
                      ),
                      Image.asset(
                        'assets/images/defi_cake_hacking_1.png',
                        width: 180,
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Container(
                        height: 34,
                        child: Text(
                          'Congratulations',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        width: 280,
                        child: Text(
                          text,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xff12052F).withOpacity(0.6),
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
                  width: 280,
                  title: 'Continue',
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
