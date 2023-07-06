import 'package:defi_wallet/bloc/refactoring/ramp/ramp_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/access_token_model.dart';
import 'package:defi_wallet/models/network/account_model.dart';
import 'package:defi_wallet/screens/buy/buy_select_currency_screen.dart';
import 'package:defi_wallet/screens/buy/tutorials/buy_tutorial_first_screen.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_first_screen.dart';
import 'package:defi_wallet/screens/sell/selling_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
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
  String subtitleText = 'Choose your next step';
  BalancesHelper balancesHelper = BalancesHelper();
  late bool hasAccessToken;

  @override
  void initState() {
    super.initState();
    loadDfxData();
  }

  loadDfxData() {
    RampCubit rampCubit = BlocProvider.of<RampCubit>(context);
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    AccessTokenModel? accessToken;
    try {
      accessToken = walletCubit.state.applicationModel!.activeNetwork!
              .rampList[0].accessTokensMap[
          (walletCubit.state.activeAccount as AccountModel).accountIndex]!;
      rampCubit.setAccessToken(accessToken);
      rampCubit.loadUserDetails();
    } catch (err) {
      accessToken = null;
    }
    hasAccessToken = accessToken != null;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            return BlocBuilder<RampCubit, RampState>(
              builder: (context, rampState) {
                final isLoading = rampState.status == RampStatusList.initial ||
                    rampState.status == RampStatusList.loading;
                final isExpiredAccessToken =
                    rampState.status == RampStatusList.expired;
                double limit = 0;
                String period = 'Day';

                if (rampState.rampUserModel != null) {
                  limit = rampState.rampUserModel!.limit!.value!;
                  period = rampState.rampUserModel!.limit!.period!;
                }

                return Scaffold(
                  drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                  endDrawer: isFullScreen
                      ? null
                      : AccountDrawer(
                          width: buttonSmallWidth,
                        ),
                  appBar: isFullScreen
                      ? null
                      : NewMainAppBar(
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
                        bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                        bottomRight: Radius.circular(isFullScreen ? 20 : 0),
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
                                  PageTitle(
                                    title: titleText,
                                    isFullScreen: isFullScreen,
                                    isCenterAlign: true,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            if (isLoading && !hasAccessToken)
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
                                  if (hasAccessToken &&
                                      !isExpiredAccessToken) ...[
                                    Flexible(
                                      child: FlatButton(
                                        title: 'Buy',
                                        iconPath: 'assets/icons/buy.png',
                                        callback: () =>
                                            buyCallback(context, rampState),
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
                                            sellCallback(context, rampState),
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
                                            String kycHash = rampState
                                                .rampUserModel!.kycHash!;
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
                                        callback: () async {
                                          showDialog(
                                            barrierColor: AppColors.tolopea
                                                .withOpacity(0.06),
                                            barrierDismissible: false,
                                            context: context,
                                            builder:
                                                (BuildContext dialogContext) {
                                              return PassConfirmDialog(
                                                onCancel: () {},
                                                onSubmit: (password) async {
                                                  RampCubit rampCubit =
                                                      BlocProvider.of<
                                                          RampCubit>(context);
                                                  WalletCubit walletCubit =
                                                      BlocProvider.of<
                                                          WalletCubit>(context);
                                                  await walletCubit
                                                      .signUpToRamp(
                                                    password,
                                                  );
                                                  loadDfxData();
                                                },
                                              );
                                            },
                                          );

                                          // fiatCubit.setLoadingState();

                                          // AccessTokenHelper.setupLockAccessToken(
                                          //   context,
                                          //   loadDfxData,
                                          //   needUpdateLock: false,
                                          //   isExistingAccount: isExpiredAccessToken,
                                          //   dialogMessage: isExpiredAccessToken
                                          //       ? 'Please entering your password for update DFX access token'
                                          //       : 'Please entering your password for create DFX account',
                                          // );
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
      },
    );
  }

  buyCallback(context, state) {
    if (true) {
      NavigatorService.push(context, BuyTutorialFirstScreen());
    } else {
      NavigatorService.push(context, BuySelectCurrencyScreen());
    }
  }

  sellCallback(BuildContext context, RampState state) async {
    var box = await Hive.openBox(HiveBoxes.client);
    var kycStatus = await box.get(HiveNames.kycStatus);
    bool isSkipKyc =
        kycStatus == 'skip' || state.rampUserModel!.kycStatus == 'Completed';
    await box.close();
    NavigatorService.push(context, isSkipKyc ? Selling() : AccountTypeSell());
  }
}
