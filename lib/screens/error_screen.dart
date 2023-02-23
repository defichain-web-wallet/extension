import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorScreen({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(
            top: 44,
            bottom: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16),
                    child: Image.asset('assets/images/jelly_oops.png'),
                  ),
                  Text(
                    'Oops!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text:
                              'Something went wrong, it looks like API is not responding. Please, report the issue ',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color!
                                        .withOpacity(0.6),
                                  ),
                        ),
                        TextSpan(
                            text: 'here',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: AppColors.pinkColor,
                                    ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launch(
                                'https://t.me/jellywallet_en',
                              )),
                        TextSpan(
                          text: ' and try again later.',
                          style:
                              Theme.of(context).textTheme.headline5!.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .color!
                                        .withOpacity(0.6),
                                  ),
                        ),
                      ]))
                ],
              ),
              NewPrimaryButton(
                title: 'Go back',
                callback: () => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        HomeScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
