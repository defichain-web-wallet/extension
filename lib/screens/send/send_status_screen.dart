import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/status/status_transaction.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/services/logger_service.dart';

class SendStatusScreen extends StatelessWidget {
  final BalancesHelper balancesHelper = BalancesHelper();
  final TxErrorModel? txResponse;
  final double amount;
  final String token;
  final String address;
  final String appBarTitle;
  final String? errorBTC;
  final double homeButtonWidth;

  SendStatusScreen({
    Key? key,
    required this.txResponse,
    required this.amount,
    required this.token,
    required this.address,
    required this.appBarTitle,
    this.errorBTC = '',
    this.homeButtonWidth = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        if (errorBTC!.isEmpty) {
          if (txResponse!.isError!) {
            LoggerService.invokeInfoLogg(
                'user was send token failed: ${txResponse!.error}');
          } else {
            LoggerService.invokeInfoLogg('user was send token successfully');
            if (!SettingsHelper.isBitcoin()) {
              TransactionCubit transactionCubit =
                  BlocProvider.of<TransactionCubit>(context);

              // transactionCubit.setOngoingTransaction(txResponse!.txid!);
            }
          }
        }
        return Scaffold(
          appBar: MainAppBar(
            title: appBarTitle,
            isShowNavButton: false,
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? ToolbarSizes.toolbarHeightWithBottom
                : ToolbarSizes.toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusTransaction(
                      isBTCError: errorBTC!.isNotEmpty,
                      txResponse: txResponse,
                    ),
                    errorBTC!.isEmpty
                        ? Flexible(
                            child: txResponse!.isError!
                                ? Flexible(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          txResponse!.error.toString() ==
                                                  'txn-mempool-conflict (code 18)'
                                              ? 'Wait for approval the previous tx'
                                              : txResponse!.error.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .button,
                                        ),
                                        SizedBox(
                                          width: homeButtonWidth,
                                          child: PrimaryButton(
                                            label: 'Home',
                                            callback: () =>
                                                Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation1,
                                                        animation2) =>
                                                    HomeScreen(),
                                                transitionDuration:
                                                    Duration.zero,
                                                reverseTransitionDuration:
                                                    Duration.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: homeButtonWidth,
                                        child: PrimaryButton(
                                          label: 'Home',
                                          callback: () =>
                                              Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation1,
                                                      animation2) =>
                                                  HomeScreen(),
                                              transitionDuration: Duration.zero,
                                              reverseTransitionDuration:
                                                  Duration.zero,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/explorer_icon.svg',
                                            color: AppTheme.pinkColor,
                                          ),
                                          SizedBox(width: 10),
                                          InkWell(
                                            child: Text(
                                              'View on Explorer',
                                              style: AppTheme.defiUnderlineText,
                                            ),
                                            onTap: () {
                                              // if (SettingsHelper.isBitcoin()) {
                                              //   if (SettingsHelper
                                              //           .settings.network! ==
                                              //       'mainnet') {
                                              //     launch(
                                              //         'https://live.blockcypher.com/btc/tx/${txResponse!.txid}');
                                              //   } else {
                                              //     launch(
                                              //         'https://live.blockcypher.com/btc-testnet/tx/${txResponse!.txid}');
                                              //   }
                                              // } else {
                                              //   launch(
                                              //       'https://defiscan.live/transactions/${txResponse!.txid}?network=${SettingsHelper.settings.network!}');
                                              // }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          )
                        : Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  errorBTC!,
                                  style: Theme.of(context).textTheme.button,
                                ),
                                SizedBox(
                                  width: homeButtonWidth,
                                  child: PrimaryButton(
                                    label: 'Home',
                                    callback: () => Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                HomeScreen(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
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
