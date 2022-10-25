import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/auth_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SecureDoneScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < ScreenSizes.medium) {
            return Scaffold(
              appBar: AuthAppBar(
                isWidgetBack: false,
              ),
              body: _buildBody(context),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 20),
              child: Scaffold(
                appBar: AuthAppBar(
                  isSmall: false,
                  isWidgetBack: false,
                ),
                body: _buildBody(context, isCustomBgColor: true),
              ),
            );
          }
        }),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) => Container(
        color: Theme.of(context).dialogBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        Text(
                          'Congratulations',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'You’ve successfully protected your wallet.',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        'Remember to keep your Secret Recovery',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        'Phrase safe, it’s your responsibility!',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      SizedBox(height: 8),
                      Image.asset(
                        'assets/success_gif.gif',
                        height: 126,
                        width: 124,
                      ),
                    ],
                  ),
                  StretchBox(
                    child: PrimaryButton(
                      label: 'Done',
                      isCheckLock: false,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
