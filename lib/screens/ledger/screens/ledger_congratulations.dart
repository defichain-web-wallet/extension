import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';

class LedgerCongratulations extends StatelessWidget {
  const LedgerCongratulations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String congratulationsTitle = 'Congratulations';
    String congratulationsText =
        'You’ve successfully connected Jellywallet to your Ledger device. Remember to keep your Secret Recovery Phrase safe!';
    return Scaffold(
      appBar: WelcomeAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                congratulationsTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline1,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                congratulationsText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
