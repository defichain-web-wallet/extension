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
          if (SettingsHelper.settings.network == 'mainnet') {
            showItemsCount =
                state.activeAccount!.historyList!.length < defaultShowItemsCount
                    ? state.activeAccount!.historyList!.length
                    : defaultShowItemsCount;
            historyList = new List.from(
                state.activeAccount!.historyList!.sublist(0, showItemsCount));
          } else {
            showItemsCount = state.activeAccount!.testnetHistoryList!.length <
                    defaultShowItemsCount
                ? state.activeAccount!.testnetHistoryList!.length
                : defaultShowItemsCount;
            historyList = new List.from(state.activeAccount!.testnetHistoryList!
                .sublist(0, showItemsCount));
          }

          if (historyList != null && historyList.length != 0) {
            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                var tokenName;
                var txValue;
                var isSend;
                var type;
                var date;
                var txValuePrefix;
                if (SettingsHelper.settings.network == 'mainnet') {
                  tokenName = historyList[index].tokens![0].code;
                  txValue = historyList[index].value;
                  isSend = historyList[index].category == 'SEND';
                  type = historyList[index].category;
                  DateTime dateTime = DateTime.parse(historyList[index].date);
                  date = formatter.format(DateTime.fromMillisecondsSinceEpoch(
                          dateTime.millisecondsSinceEpoch)
                      .toLocal());
                  txValuePrefix = (type == 'SEND' || type == 'RECEIVE')
                      ? isSend
                          ? '-'
                          : '+'
                      : '';
                } else {
                  tokenName = historyList[index].token;
                  txValue = convertFromSatoshi(historyList[index].value);
                  isSend = historyList[index].isSend;
                  type = historyList[index].type;
                  date = (historyList[index].blockTime != null)
                      ? formatter.format(DateTime.fromMillisecondsSinceEpoch(
                              int.parse(historyList[index].blockTime) * 1000)
                          .toLocal())
                      : 'date';
                  txValuePrefix = (type == 'vout' || type == 'vin')
                      ? isSend
                          ? '-'
                          : '+'
                      : '';
                }

                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 8, left: 16, right: 16, top: 2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor,
                    ),
                    child: ListTile(
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
                            '$txValuePrefix${balancesHelper.numberStyling(txValue, fixed: true, fixedCount: 6)} $tokenName',
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
                          Text(
                              "${balancesHelper.numberStyling(tokenHelper.getAmountByUsd(tokensState.tokensPairs!, txValue, tokenName), fixed: true, fixedCount: 4)} $currency")
                        ],
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
