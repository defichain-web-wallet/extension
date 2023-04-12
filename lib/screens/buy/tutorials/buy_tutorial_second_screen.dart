import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/buy/tutorials/buy_tutorial_third_screen.dart';
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

class BuyTutorialSecondScreen extends StatefulWidget {
  bool isConfirm;

  BuyTutorialSecondScreen({
    Key? key,
    this.isConfirm = false,
  }) : super(key: key);

  @override
  _BuyTutorialSecondScreenState createState() =>
      _BuyTutorialSecondScreenState();
}

class _BuyTutorialSecondScreenState extends State<BuyTutorialSecondScreen>
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
          drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
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
                                Center(
                                  child: Image.asset(
                                    'assets/images/tutorial_buy_second.png',
                                    width: 204,
                                    height: 229,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 212, top: 2),
                                  child: SvgPicture.asset(
                                    'assets/images/tutorial_dfx_rotate1.svg',
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 59, top: 133),
                                  child: Container(
                                    width: 64.5,
                                    height: 64.5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [
                                        Color(0x29FF00AF),
                                        Color(0x29BF0083),
                                      ]),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/tutorial_buy_bank_build_rotate.svg',
                                      ),
                                    ),
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
                            '2. Make a bank transfer to our partner DFX AG for the purchase.',
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
                                            BuyTutorialThirdScreen(
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
