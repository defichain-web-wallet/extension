import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LedgerCongratulations extends StatelessWidget {
  const LedgerCongratulations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String congratulationsTitle = 'Congratulations';
    String congratulationsText =
        'You’ve successfully connected Jellywallet to your Ledger device. Remember to keep your Secret Recovery Phrase safe!';
    return Scaffold(
      appBar: WelcomeAppBar(),
      body: Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 64),
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
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StretchBox(
                    maxWidth: ScreenSizes.xSmall,
                    child: PrimaryButton(
                      isCheckLock: false,
                      label: 'Done',
                      callback: () async {
                        var box = await Hive.openBox(HiveBoxes.client);
                        await box.put(HiveNames.openedMnemonic, null);
                        await box.close();

                        Navigator.push(
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
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
