import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/access_token_helper.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/buy/buy_select_currency_screen.dart';
import 'package:defi_wallet/screens/buy/tutorials/buy_tutorial_first_screen.dart';
import 'package:defi_wallet/screens/error_screen.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_first_screen.dart';
import 'package:defi_wallet/screens/sell/selling_screen.dart';
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
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';

class BuySellScreen extends StatefulWidget {
  const BuySellScreen({Key? key}) : super(key: key);

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> with ThemeMixin {
  String titleText = 'Buy / Sell';
  String subtitleText = 'Choose your next step';
  BalancesHelper balancesHelper = BalancesHelper();
  int iterator = 0;
  late bool hasAccessToken;

  @override
  void initState() {
    super.initState();
    loadDfxData();
  }

  loadDfxData() {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    hasAccessToken = accountCubit.state.accounts!.first.accessToken != null &&
        accountCubit.state.accounts!.first.accessToken!.isNotEmpty;
    if (hasAccessToken) {
      fiatCubit.loadUserDetails(accountCubit.state.accounts!.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (context, fiatState) {
            var isLoading = fiatState.status == FiatStatusList.initial ||
                fiatState.status == FiatStatusList.loading;
            var isExpiredAccessToken =
                fiatState.status == FiatStatusList.expired;
            double limit = 0;
            String period = 'Day';
            if (hasAccessToken && !isLoading && !isExpiredAccessToken) {
              limit = fiatState.limit!.value!;
              period = fiatState.limit!.period!;
            }
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
                  top: 26,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        if (isLoading && hasAccessToken)
                                          Text(
                                            'N/A',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .copyWith(
                                                  fontSize: 40,
                                                ),
                                          )
                                        else ...[
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
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              if (hasAccessToken && !isExpiredAccessToken) ...[
                                Flexible(
                                  child: FlatButton(
                                    title: 'Buy',
                                    iconPath: 'assets/icons/buy.png',
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
                                    iconPath: 'assets/icons/sell.png',
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
                                    iconPath:
                                        'assets/icons/increase_limits.png',
                                    callback: () {
                                      if (hasAccessToken) {
                                        String kycHash = fiatState.kycHash!;
                                        launch(
                                          'https://payment.dfx.swiss/kyc?code=$kycHash',
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  isExpiredAccessToken
                                      ? 'Need to update access token of DFX'
                                      : 'Need to create an account for DFX',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                        color: Colors.red,
                                      ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Flexible(
                                  child: FlatButton(
                                    title: isExpiredAccessToken
                                        ? 'Update DFX token'
                                        : 'Create DFX account',
                                    iconPath:
                                        'assets/icons/increase_limits.png',
                                    callback: () {
                                      FiatCubit fiatCubit =
                                          BlocProvider.of<FiatCubit>(context);
                                      fiatCubit.setLoadingState();

                                      AccessTokenHelper.setupLockAccessToken(
                                        context,
                                        loadDfxData,
                                        needUpdateLock: false,
                                        isExistingAccount: isExpiredAccessToken,
                                        dialogMessage: isExpiredAccessToken
                                            ? 'Please entering your password for update DFX access token'
                                            : 'Please entering your password for create DFX account',
                                      );
                                    },
                                  ),
                                ),
                              ]
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
          pageBuilder: (context, animation1, animation2) =>
              BuySelectCurrencyScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  sellCallback(context, state) async {
    var box = await Hive.openBox(HiveBoxes.client);
    var kycStatus = await box.get(HiveNames.kycStatus);
    bool isSkipKyc = kycStatus == 'skip' || state.kycStatus == 'Completed';
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
