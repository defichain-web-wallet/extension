import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/widgets/toolbar/icon_app_bar.dart';
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

  SendStatusScreen(
      {Key? key,
      required this.txResponse,
      required this.amount,
      required this.token,
      required this.address})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
          child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < ScreenSizes.medium) {
          return Scaffold(
            appBar: IconAppBar(
              title: 'Send',
              cancel: () => Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),
            body: _buildBody(context),
          );
        } else {
          return Container(
            padding: const EdgeInsets.only(top: 20),
            child: Scaffold(
              appBar: IconAppBar(
                title: 'Send',
                isSmall: true,
                cancel: () => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => HomeScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),
              body: _buildBody(context, isCustomBgColor: true),
            ),
          );
        }
      }));

  Widget _buildBody(context, {isCustomBgColor = false}) {
    if (txResponse!.isError) {
      LoggerService.invokeInfoLogg(
          'user was send token failed: ${txResponse!.error}');
    } else {
      LoggerService.invokeInfoLogg('user was send token successfully');
      TransactionCubit transactionCubit =
          BlocProvider.of<TransactionCubit>(context);

      transactionCubit.setOngoingTransaction(txResponse!.txid!);
    }
    String tokenName = (token != 'DFI') ? 'd' + token : token;
    return Container(
      color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              txResponse!.isError
                  ? 'assets/error_gif.gif'
                  : 'assets/success_gif.gif',
              height: 126,
              width: 124,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${balancesHelper.numberStyling(amount)} ',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Text(
                        tokenName,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    txResponse!.isError
                        ? 'Were not sent successfully'
                        : 'Have been sent successfully!',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Address',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$address',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ],
              ),
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
                  : Row(
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
                          onTap: () => launch(
                              'https://defiscan.live/transactions/${txResponse!.txid}?network=${SettingsHelper.settings.network!}'),
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
