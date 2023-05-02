import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/swap/swap_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
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

class _SwapGuideScreenState extends State<SwapGuideScreen> with ThemeMixin {
  FocusNode checkBoxFocusNode = FocusNode();
  bool isConfirm = false;
  double headerSectionWidth = 234;
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
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: headerSectionWidth,
                              child: SvgPicture.asset('assets/btc_guide.svg'),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              child: SvgPicture.asset('assets/dfx_logo.svg'),
                            ),
                            SizedBox(
                              height: 34,
                            ),
                            Text(
                              'This service is provided by DFX Swiss. Swaps may take up to 4 hours to be processed.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline5!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: DefiCheckbox(
                        width: boxSmallWidth,
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
                          style:
                              Theme.of(context).textTheme.subtitle1!.copyWith(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: NewPrimaryButton(
                        title: 'Next',
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
