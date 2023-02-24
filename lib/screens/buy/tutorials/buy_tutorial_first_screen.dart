import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/buy/tutorials/buy_tutorial_second_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BuyTutorialFirstScreen extends StatefulWidget {
  const BuyTutorialFirstScreen({Key? key}) : super(key: key);

  @override
  _BuyTutorialFirstScreenState createState() => _BuyTutorialFirstScreenState();
}

class _BuyTutorialFirstScreenState extends State<BuyTutorialFirstScreen>
    with ThemeMixin {
  FocusNode checkBoxFocusNode = FocusNode();
  bool isConfirm = false;
  String titleText = 'Fiat to crypto: How it works!';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          drawerScrimColor: Color(0x0f180245),
          endDrawer: AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: NewMainAppBar(
            isShowLogo: false,
          ),
          body: Container(
            padding: EdgeInsets.only(
              top: 22,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDarkTheme()
                  ? DarkColors.drawerBgColor
                  : LightColors.scaffoldContainerBgColor,
              border: isDarkTheme()
                  ? Border.all(
                      width: 1.0,
                      color: Colors.white.withOpacity(0.05),
                    )
                  : null,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
            ),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 68,
                            child: Text(
                              titleText,
                              style: headline2.copyWith(
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            width: 328,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 52, top: 30),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [
                                        Color(0x29FF00AF),
                                        Color(0x29BF0083),
                                      ]),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/tutorial_buy_dfi.svg',
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Image.asset(
                                    'assets/images/tutorial_buy_first.png',
                                    width: 204,
                                    height: 229,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 244, top: 40),
                                  child: Container(
                                    width: 74,
                                    height: 74,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [
                                        Color(0x29F7931A),
                                        Color(0x29E2820F),
                                      ]),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/tutorial_buy_btc.svg',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 61, top: 160),
                                  child: Container(
                                    width: 51.5,
                                    height: 51.5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [
                                        Color(0x29627EEA),
                                        Color(0x293C61F1),
                                      ]),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/tutorial_buy_eth.svg',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 123, left: 197),
                                  child: SvgPicture.asset(
                                      'assets/tutorial_buy_cursor.svg'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 94,
                          child: Text(
                            '1. Select the asset you want to buy.',
                            style:
                                Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 20,
                                    ),
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Center(
                          child: DefiCheckbox(
                            width: 224,
                            callback: (val) {
                              setState(() {
                                isConfirm = val!;
                              });
                            },
                            value: isConfirm,
                            focusNode: checkBoxFocusNode,
                            isShowLabel: false,
                            textWidget: Text(
                              'Don´t show this guide next time',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .color!
                                        .withOpacity(0.8),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 104,
                              child: AccentButton(
                                callback: () {
                                  Navigator.pop(context);
                                },
                                label: 'Back',
                              ),
                            ),
                            NewPrimaryButton(
                              width: 104,
                              callback: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            BuyTutorialSecondScreen(
                                      isConfirm: isConfirm,
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                              title: 'Next',
                            ),
                          ],
                        ),
                      ],
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
