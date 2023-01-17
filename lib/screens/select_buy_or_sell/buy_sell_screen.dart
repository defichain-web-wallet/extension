import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/buy/buy_select_currency_screen.dart';
import 'package:defi_wallet/screens/buy/tutorials/buy_tutorial_first_screen.dart';
import 'package:defi_wallet/screens/sell/account_type_sell.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class BuySellScreen extends StatefulWidget {
  const BuySellScreen({Key? key}) : super(key: key);

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> with ThemeMixin {
  String titleText = 'Buy / Sell';
  String subtitleText = 'Choose the operation you want to go through';
  BalancesHelper balancesHelper = BalancesHelper();
  int iterator = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        if (iterator == 0) {
          try {
            fiatCubit.loadUserDetails(accountCubit.state.activeAccount!);
          } catch (err) {
            print(err);
          }
          iterator++;
        }
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (context, fiatState) {
            if (fiatState.status == FiatStatusList.success) {
              double limit = fiatState.limit!.value!;
              String period = fiatState.limit!.period!;
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
                    top: 26,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      titleText,
                                      style: headline2.copyWith(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      subtitleText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .apply(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.6),
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 24,
                                ),
                                Container(
                                  height: 134,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.lavenderPurple
                                          .withOpacity(0.32),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Your limit',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${balancesHelper.numberStyling(limit)}€',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .copyWith(
                                                  fontSize: 40,
                                                ),
                                          ),
                                          Text(
                                            ' / $period',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 24,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Flexible(
                                  child: FlatButton(
                                    title: 'Buy',
                                    iconPath: 'assets/icons/buy_icon.svg',
                                    callback: () =>
                                        buyCallback(context, fiatState),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Flexible(
                                  child: FlatButton(
                                    title: 'Sell',
                                    iconPath: 'assets/icons/sell_icon.svg',
                                    callback: () =>
                                        sellCallback(context, fiatState),
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Flexible(
                                  child: FlatButton(
                                    title: 'Increase limit',
                                    iconPath: 'assets/icons/increase_limit.svg',
                                    callback: () {
                                      String kycHash = fiatState.kycHash!;
                                      launch(
                                          'https://payment.dfx.swiss/kyc?code=$kycHash');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                isDarkTheme()
                                    ? 'assets/icons/dfx_logo_dark_theme.svg'
                                    : 'assets/icons/dfx_logo_light_theme.svg',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (fiatState.status == FiatStatusList.failure) {
              return Container(
                child: Center(
                  child: ErrorPlaceholder(
                    description: 'Please check again later',
                    message: 'API is under maintenance',
                  ),
                ),
              );
            } else {
              return Loader();
            }
          },
        );
      },
    );
  }

  buyCallback(context, state) {
    if (state.isShowTutorial) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              BuyTutorialFirstScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SearchBuyToken(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  sellCallback(context, state) async {
    var box = await Hive.openBox(HiveBoxes.client);
    var kycStatus = await box.get(HiveNames.kycStatus);
    bool isSkipKyc = kycStatus == 'skip';
    await box.close();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) =>
            isSkipKyc ? Selling() : AccountTypeSell(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}
