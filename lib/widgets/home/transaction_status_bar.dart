import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
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
  late NetworkTypeModel networkType;
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  )..repeat();

  @override
  void initState() {
    super.initState();
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    networkType = walletCubit.state.activeNetwork.networkType;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  String getFormatTxType(String type) {
    switch (type) {
      case 'TxType.swap':
        return 'Swapping';
      case 'TxType.send':
        return 'Sending';
      case 'TxType.addLiq':
        return 'Add Liquidity';
      case 'TxType.removeLiq':
        return 'Remove Liquidity';
      default:
        return 'Converting UTXO';
    }
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
        String txId = '';
        late Widget prefixWidget;
        late Color snackBarBgColor;

        if (txState is TransactionLoadingState) {
          String status = '';
          int txIndex = 0;
          TxLoaderModel loadingTx;

          try {
            loadingTx = txState.txErrorModel!.txLoaderList!.firstWhere(
              (element) => element.status == TxStatus.waiting,
            );
            status = getFormatTxType(
              loadingTx.type!.toString(),
            );
            txId = loadingTx.txId!;
            txIndex = txState.txErrorModel!.txLoaderList!.indexOf(loadingTx);
          } catch (err) {
            print('transaction_status_bar: $err');
            loadingTx = txState.txErrorModel!.txLoaderList!.lastWhere(
              (element) => element.status == TxStatus.success,
            );
            txIndex = txState.txErrorModel!.txLoaderList!.indexOf(loadingTx);
            txId = loadingTx.txId!;
            status = getFormatTxType(
              loadingTx.type!.toString(),
            );
          }
          title = 'Transactions (${txIndex + 1}'
              '/${txState.txErrorModel!.txLoaderList!.length}):'
              ' $status';
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
          TxLoaderModel txLoaderModelSuccess =
              txState.txErrorModel!.txLoaderList!.lastWhere(
            (element) => element.status == TxStatus.success,
          );
          txId = txLoaderModelSuccess.txId!;
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
          subtitle: txId,
          prefix: prefixWidget,
          suffix: InkWell(
            onTap: () async {
              if (txState is TransactionLoadedState) {
                await transactionCubit.confirmTransactionStatus();
                await accountCubit.updateAccountDetails();
              } else {
                launch(
                  '${Hosts.defiScanLiveTx}/$txId?network=${networkType.networkString}',
                );
              }
            },
            child: SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                txState is TransactionLoadedState
                      ? 'assets/icons/cancel_icon.svg'
                      : 'assets/icons/open_in_new.svg',
                  color: Theme.of(context).textTheme.headline1!.color!,
              ),
            ),
          ),
          onTapCallback: () async {
            launch(
              '${Hosts.defiScanLiveTx}/$txId?network=${networkType.networkString}',
            );
          }
        );
      }),
    );
  }
}
