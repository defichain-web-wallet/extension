import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/buy/contact_screen.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThirdStepBuyScreen extends StatefulWidget {
  bool isConfirm;

  ThirdStepBuyScreen({
    Key? key,
    this.isConfirm = false,
  }) : super(key: key);

  @override
  _ThirdStepBuyScreenState createState() => _ThirdStepBuyScreenState();
}

class _ThirdStepBuyScreenState extends State<ThirdStepBuyScreen> {
  double smallSizeLogoWidth = 200;
  double fullSizeLogoWidth = 400;
  double buttonWidth = 217;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: MainAppBar(
            title: 'How does it work?',
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: AppTheme.screenPadding,
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: !isFullScreen
                                  ? smallSizeLogoWidth
                                  : fullSizeLogoWidth,
                              padding: EdgeInsets.only(
                                top: 44,
                              ),
                              child: Image(
                                image: AssetImage(
                                  'assets/third_step_buy_logo.png',
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                top: 44,
                              ),
                              child: Text(
                                '3. We will transfer your cryptocurrencies directly into your wallet',
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    ?.apply(
                                      fontSizeFactor: 1.6,
                                    ),
                              ),
                            ),
                            Container(
                              width: 320,
                              padding: EdgeInsets.only(
                                top: 44,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: buttonWidth,
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: 'Next',
                            isCheckLock: false,
                            callback: () async {
                              FiatCubit fiatCubit =
                                  BlocProvider.of<FiatCubit>(context);
                              await fiatCubit
                                  .changeStatusTutorial(!widget.isConfirm);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          ContactScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            },
                          ),
                          Container(
                            height: 48,
                            padding: EdgeInsets.only(top: 10),
                            child: StretchBox(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: widget.isConfirm,
                                    activeColor: AppTheme.pinkColor,
                                    onChanged: (newValue) {
                                      setState(() {
                                        widget.isConfirm = !widget.isConfirm;
                                      });
                                    },
                                  ),
                                  Flexible(
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    'Don´t show this guide next time',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          setState(
                                            () {
                                              widget.isConfirm =
                                                  !widget.isConfirm;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
