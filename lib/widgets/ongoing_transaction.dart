import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class OngoingTransaction extends StatelessWidget with PreferredSizeWidget {
  static const double height = 55;

  const OngoingTransaction({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    TransactionCubit transactionCubit =
        BlocProvider.of<TransactionCubit>(context);
    return BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: height,
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (state is TransactionLoadingState)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (state is TransactionLoadedState)
              Container(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.done_all, color: Colors.green, size: 20),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state is TransactionLoadingState
                          ? 'Waiting for transaction'
                          : 'Transaction done',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 2)),
                    SingleChildScrollView(
                      child: InkWell(
                        child: Text(state.txId!,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.defiUnderlineText
                                .apply(decoration: TextDecoration.none)),
                        onTap: () => launch(
                            'https://defiscan.live/transactions/${state.txId}?network=${SettingsHelper.settings.network!}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state is TransactionLoadingState)
              InkWell(
                child: Icon(Icons.open_in_new,
                    color: AppTheme.pinkColor, size: 25),
                hoverColor: Colors.transparent,
                onTap: () => launch(
                    'https://defiscan.live/transactions/${state.txId}?network=${SettingsHelper.settings.network!}'),
              ),
            if (state is TransactionLoadedState)
              InkWell(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text('OK',
                        style: Theme.of(context).textTheme.headline4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).dividerColor))),
                onTap: () {
                  transactionCubit.confirmTransactionStatus();
                },
              )
          ],
        ),
      );
    });
  }
}
