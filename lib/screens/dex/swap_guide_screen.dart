import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/dex/swap_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SwapGuideScreen extends StatefulWidget {
  final String selectedAddress;

  const SwapGuideScreen({
    Key? key,
    this.selectedAddress = '',
  }) : super(key: key);

  @override
  State<SwapGuideScreen> createState() => _SwapGuideScreenState();
}

class _SwapGuideScreenState extends State<SwapGuideScreen> {
  bool isConfirm = false;
  double headerSectionWidth = 300;
  double textSectionWidth = 350;

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
            title: 'How does it works?',
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding:
                const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
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
                              width: headerSectionWidth,
                              padding: EdgeInsets.only(
                                top: 44,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/btc_origin.svg'),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  SvgPicture.asset(
                                      'assets/arrow_right_long.svg'),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  SvgPicture.asset('assets/btc_dfx.svg'),
                                ],
                              ),
                            ),
                            Container(
                              child: SvgPicture.asset('assets/dfx_logo.svg'),
                            ),
                            Container(
                              width: isFullScreen ? double.infinity : textSectionWidth,
                              padding: EdgeInsets.only(
                                top: 44,
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    style: isFullScreen ? Theme.of(context)
                                        .textTheme
                                        .headline2
                                        ?.apply(
                                          fontSizeFactor: 1.6,
                                        ) : Theme.of(context)
                                        .textTheme
                                        .headline2
                                        ?.apply(
                                      fontSizeFactor: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            'This service is provided by DFX Swiss. \n',
                                      ),
                                      TextSpan(
                                        text:
                                            'Swaps may take up to 4 hours to be processed. ',
                                      ),
                                      TextSpan(
                                        text: 'You will not be redirected.',
                                      ),
                                    ]),
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
                      width: 217,
                      child: Column(
                        children: [
                          PrimaryButton(
                            label: 'Next',
                            isCheckLock: false,
                            callback: () async {
                              AccountCubit accountCubit =
                                  BlocProvider.of<AccountCubit>(context);
                              String swapTutorialStatus =
                                  isConfirm ? 'skip' : 'show';
                              var box = await Hive.openBox(HiveBoxes.client);
                              await box.put(HiveNames.swapTutorialStatus,
                                  swapTutorialStatus);
                              await box.close();
                              accountCubit
                                  .updateSwapTutorialStatus(swapTutorialStatus);
                              print(swapTutorialStatus);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          SwapScreen(),
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
                                  Theme(
                                    child: Checkbox(
                                      value: isConfirm,
                                      activeColor: AppTheme.pinkColor,
                                      onChanged: (newValue) {
                                        setState(() {
                                          isConfirm = !isConfirm;
                                        });
                                      },
                                    ),
                                    data: ThemeData(
                                      unselectedWidgetColor: AppTheme.pinkColor,
                                    ),
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
                                              isConfirm = !isConfirm;
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
