import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/buy/tutorials/buy_tutorial_fourth_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BuyTutorialThirdScreen extends StatefulWidget {
  bool isConfirm;

  BuyTutorialThirdScreen({
    Key? key,
    this.isConfirm = false,
  }) : super(key: key);

  @override
  State<BuyTutorialThirdScreen> createState() => _BuyTutorialThirdScreenState();
}

class _BuyTutorialThirdScreenState extends State<BuyTutorialThirdScreen>
    with ThemeMixin {
  String titleText = 'Fiat to crypto: How it works!';
  FocusNode checkBoxFocusNode = FocusNode();

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
                  ? DarkColors.scaffoldContainerBgColor
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
                          Container(
                            width: 328,
                            child: Stack(
                              children: [
                                Center(
                                  child: Image.asset(
                                    isDarkTheme()
                                        ? 'assets/images/tutorial_buy_background_dark.png'
                                        : 'assets/images/tutorial_buy_background_light.png',
                                    width: 242.5,
                                    height: 241.75,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 29, top: 57),
                                  child: SvgPicture.asset(
                                    'assets/images/titorial_buy_group_third.svg',
                                  ),
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
                            '3. We will transfer your cryptocurrencies directly into your wallet',
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
                                widget.isConfirm = val!;
                              });
                            },
                            value: widget.isConfirm,
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
                                            BuyTutorialFourthScreen(
                                      isConfirm: widget.isConfirm,
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
