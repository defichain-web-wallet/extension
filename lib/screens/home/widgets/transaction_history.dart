import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/screens/history/widgets/icon_history_type.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatefulWidget {
  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late ScrollController _controller;
  SettingsHelper settingsHelper = SettingsHelper();

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      print('reach the bottom');
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      print('reach the top');
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
      return BlocBuilder<TokensCubit, TokensState>(
          builder: (context, tokensState) {
        if (state.status == AccountStatusList.success &&
            tokensState.status == TokensStatusList.success) {
          var historyList;
          DateFormat formatter = DateFormat('yyyy.MM.dd HH:mm');
          var balancesHelper = BalancesHelper();
          TokensHelper tokenHelper = TokensHelper();
          HistoryHelper historyHelper = HistoryHelper();
          var currency = SettingsHelper.settings.currency!;
          const int defaultShowItemsCount = 30;
          late int showItemsCount;
          showItemsCount =
              state.activeAccount!.historyList!.length < defaultShowItemsCount
                  ? state.activeAccount!.historyList!.length
                  : defaultShowItemsCount;
          historyList = new List.from(
              state.activeAccount!.historyList!.sublist(0, showItemsCount));

          if (historyList != null && historyList.length != 0) {
            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                var tokenName;
                var tokenAdvancedName;
                var txValue;
                var txAdvancedValue;
                var type;
                var date;
                if (historyList[index].type == null) {
                  txValue = convertFromSatoshi(historyList[index].value);
                  tokenName = 'DFI';
                } else {
                  if (historyList[index].amounts.length == 1) {
                    var amount = historyList[index].amounts[0].split('@');
                    txValue = double.parse(amount[0]);
                    tokenName = amount[1];
                  } else {
                    var amount = historyList[index].amounts[0].split('@');
                    var secondAmount = historyList[index].amounts[1].split('@');
                    txValue = double.parse(amount[0]);
                    tokenName = amount[1];
                    txAdvancedValue = double.parse(secondAmount[0]);
                    tokenAdvancedName = secondAmount[1];
                  }
                }
                if (historyList[index].type == null) {
                  type = historyList[index].value < 0 ? 'SEND' : 'RECEIVE';
                } else {
                  type = historyList[index].type;
                }
                date = (historyList[index].blockTime != null)
                    ? formatter.format(DateTime.fromMillisecondsSinceEpoch(
                            int.parse(historyList[index].blockTime) * 1000)
                        .toLocal())
                    : 'date';

                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8, left: 16, right: 16, top: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 2,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ListTile(
                        onTap: () => historyHelper
                            .openTxOnExplorer(historyList[index].txid),
                        leading: IconHistoryType(
                          type: type,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              historyHelper.getTransactionType(type),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text(
                              '${balancesHelper.numberStyling(txValue, fixed: true, fixedCount: 6)} $tokenName',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date.toString(),
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            if (historyList[index].amounts.length == 2)
                              Text(
                                '${balancesHelper.numberStyling(txAdvancedValue, fixed: true, fixedCount: 6)} $tokenAdvancedName',
                                style: Theme.of(context).textTheme.headline4,
                              )
                            else
                              Text(
                                  "${balancesHelper.numberStyling(tokenHelper.getAmountByUsd(tokensState.tokensPairs!, txValue, tokenName), fixed: true, fixedCount: 4)} $currency")
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('Not yet any transaction'),
            );
          }
        } else {
          return Container();
        }
      });
    });
  }
}
