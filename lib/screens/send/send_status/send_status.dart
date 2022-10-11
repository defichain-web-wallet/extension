import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/status/status_transaction.dart';
import 'package:defi_wallet/widgets/toolbar/icon_app_bar.dart';
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
  double homeButtonWidth;

  SendStatusScreen({
    Key? key,
    required this.txResponse,
    required this.amount,
    required this.token,
    required this.address,
    required this.appBarTitle,
    this.homeButtonWidth = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < ScreenSizes.medium) {
              return Scaffold(
                appBar: MainAppBar(
                  title: appBarTitle,
                  isShowNavButton: false,
                ),
                body: _buildBody(context),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: Scaffold(
                  appBar: MainAppBar(
                    title: appBarTitle,
                    isSmall: true,
                    isShowNavButton: false,
                  ),
                  body: _buildBody(context, isCustomBgColor: true),
                ),
              );
            }
          },
        ),
      );

  Widget _buildBody(context, {isCustomBgColor = false}) {
    if (txResponse!.isError) {
      LoggerService.invokeInfoLogg(
          'user was send token failed: ${txResponse!.error}');
    } else {
      LoggerService.invokeInfoLogg('user was send token successfully');
      if (!SettingsHelper.isBitcoin()) {
        TransactionCubit transactionCubit =
            BlocProvider.of<TransactionCubit>(context);

        transactionCubit.setOngoingTransaction(txResponse!.txid!);
      }
    }
    String tokenName = (token != 'DFI') ? 'd' + token : token;
    return Container(
      color: Theme.of(context).dialogBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatusTransaction(
              txResponse: txResponse,
            ),
            Flexible(
              child: txResponse!.isError
                  ? Text(
                      txResponse!.error.toString() ==
                              'txn-mempool-conflict (code 18)'
                          ? 'Wait for approval the previous tx'
                          : txResponse!.error.toString(),
                      style: Theme.of(context).textTheme.button,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                if (SettingsHelper.isBitcoin()) {
                                  if (SettingsHelper.settings.network! ==
                                      'mainnet') {
                                    launch(
                                        'https://live.blockcypher.com/btc/tx/${txResponse!.txid}');
                                  } else {
                                    launch(
                                        'https://live.blockcypher.com/btc-testnet/tx/${txResponse!.txid}');
                                  }
                                } else {
                                  launch(
                                      'https://defiscan.live/transactions/${txResponse!.txid}?network=${SettingsHelper.settings.network!}');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
