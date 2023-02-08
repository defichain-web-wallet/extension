import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionStatusBar extends StatefulWidget {
  const TransactionStatusBar({Key? key}) : super(key: key);

  @override
  State<TransactionStatusBar> createState() => _TransactionStatusBarState();
}

class _TransactionStatusBarState extends State<TransactionStatusBar>
    with SnackBarMixin, TickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16.0,
      left: 16.0,
      right: 16.0,
      child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, txState) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        TransactionCubit transactionCubit =
            BlocProvider.of<TransactionCubit>(context);
        late String title;
        late Widget prefixWidget;
        late Color snackBarBgColor;

        if (txState is TransactionLoadingState) {
          title = 'Transactions (${txState.txIndex}'
              '/${txState.txErrorModel!.txLoaderList!.length})';
          prefixWidget = Opacity(
            opacity: 0.4,
            child: RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(animationController),
              child: SvgPicture.asset(
                'assets/icons/circular_spinner.svg',
              ),
            ),
          );
          snackBarBgColor = AppColors.txStatusPending.withOpacity(0.15);
        } else if (txState is TransactionLoadedState) {
          title = 'Transaction successful!';
          prefixWidget = Icon(
            Icons.done,
            color: AppColors.txStatusDone,
          );
          snackBarBgColor = AppColors.txStatusDone.withOpacity(0.08);
        } else {
          title = 'Transaction unsuccessful. Please try again';
          prefixWidget = prefixWidget = Icon(
            Icons.clear,
            color: AppColors.txStatusError,
          );
          snackBarBgColor = AppColors.txStatusError.withOpacity(0.08);
        }

        return getSnackBarContent(
          context,
          color: snackBarBgColor,
          title: title,
          subtitle: txState.txErrorModel!.txLoaderList![txState.txIndex!].txId,
          prefix: prefixWidget,
          suffix: InkWell(
            onTap: () => launch(
              '${Hosts.defiScanLiveTx}/${txState.txErrorModel!.txLoaderList![txState.txIndex!].txId}' +
                  '?network=${SettingsHelper.settings.network!}',
            ),
            child: SizedBox(
              width: 18,
              height: 18,
              child: SvgPicture.asset(
                'assets/icons/open_in_new.svg',
                color: Theme.of(context).textTheme.headline1!.color!,
              ),
            ),
          ),
          onTapCallback: () async {
            await accountCubit.updateAccountDetails();
            await transactionCubit.confirmTransactionStatus();
          }
        );
      }),
    );
  }
}
