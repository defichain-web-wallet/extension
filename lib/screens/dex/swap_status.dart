import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/toolbar/icon_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/services/logger_service.dart';

class SwapStatusScreen extends StatelessWidget {
  final balancesHelper = BalancesHelper();
  final TxErrorModel? txResponse;
  final double amount;
  final String assetFrom;
  final String assetTo;

  SwapStatusScreen(
      {Key? key,
      required this.txResponse,
      required this.amount,
      required this.assetFrom,
      required this.assetTo})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ScaffoldConstrainedBox(
          child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < ScreenSizes.medium) {
          return Scaffold(
            body: _buildBody(context),
            appBar: IconAppBar(
              title: 'Decentralized Exchange',
              cancel: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              ),
              isShownLogo: false,
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.only(top: 20),
            child: Scaffold(
              body: _buildBody(context, isCustomBgColor: true),
              appBar: IconAppBar(
                title: 'Decentralized Exchange',
                isSmall: true,
                isShownLogo: false,
                cancel: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ),
                ),
              ),
            ),
          );
        }
      }));

  Widget _buildBody(context, {isCustomBgColor = false}) {
    if (txResponse!.isError) {
      LoggerService.invokeInfoLogg('user was swap token failed ${txResponse!.error}');
    } else {
      LoggerService.invokeInfoLogg('user was swap token successfully');

      TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);

      transactionCubit.setOngoingTransaction(txResponse!.txid!);
    }
    return Container(
      color: isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  Image.asset(
                    txResponse!.isError
                        ? 'assets/error_gif.gif'
                        : 'assets/status_reload_icon.png',
                    height: 126,
                    width: 124,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          txResponse!.isError
                              ? 'Swap failed'
                              : 'Swap successful!',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                        SizedBox(height: 24),
                        Text(
                          txResponse!.isError
                              ? 'Were not swapped successfully'
                              : 'Your transaction will now be processed in the background. Your account balance will be updated in a few minutes.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline5!.apply(
                            fontWeightDelta: 2,
                            color: Color(0xFFC4C4C4)
                          ),
                        ),
                      ],
                    ),
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
