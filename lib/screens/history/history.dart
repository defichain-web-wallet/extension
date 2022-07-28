import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/screens/history/widgets/icon_history_type.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/screens/history/widgets/filter_list.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokenHelper = TokensHelper();
  HistoryHelper historyHelper = HistoryHelper();
  late ScrollController _controller;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  _scrollListener() async {
    if (SettingsHelper.settings.network == 'testnet') {
      if (_controller.offset >= _controller.position.maxScrollExtent &&
          !_controller.position.outOfRange) {
        AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
        await accountCubit.loadHistoryNext();
      }
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
    return BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) => ScaffoldConstrainedBox(
                child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < ScreenSizes.medium) {
                return Scaffold(
                  body: _buildBody(context),
                  appBar: MainAppBar(
                      title: 'History',
                      action: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: FilterList(
                            onSelect: () {},
                          )),
                      isShowBottom: !(state is TransactionInitialState),
                      height: !(state is TransactionInitialState)
                          ? toolbarHeightWithBottom
                          : toolbarHeight),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Scaffold(
                    body: _buildBody(context, isCustomBgColor: true),
                    appBar: MainAppBar(
                      title: 'History',
                      isSmall: true,
                      isShowBottom: !(state is TransactionInitialState),
                      height: !(state is TransactionInitialState)
                          ? toolbarHeightWithBottom
                          : toolbarHeight,
                      action: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: FilterList(
                            onSelect: () {},
                          )),
                    ),
                  ),
                );
              }
            })));
  }

  Widget _buildBody(BuildContext context, {isCustomBgColor = false}) =>
      BlocBuilder<AccountCubit, AccountState>(builder: (context, state) {
        return BlocBuilder<TokensCubit, TokensState>(
          builder: (context, tokensState) {
            if (tokensState.status == TokensStatusList.success) {
              late Iterable<HistoryNew>? filteredList;
              late Iterable<HistoryModel>? testnetFilteredList;

              var historyList = [];
              var testnetHistoryList = [];

              if (SettingsHelper.settings.network == 'testnet') {
                if (state.historyFilterBy == 'receive') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'vout');
                } else if (state.historyFilterBy == 'send') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'vin');
                } else if (state.historyFilterBy == 'swap') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'PoolSwap');
                } else if (state.historyFilterBy == 'add liquidity') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'AddPoolLiquidity');
                } else if (state.historyFilterBy == 'remove liquidity') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'RemovePoolLiquidity');
                } else if (state.historyFilterBy == 'account to utxos') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'AccountToUtxos');
                } else if (state.historyFilterBy == 'utxos to account') {
                  testnetFilteredList = state.activeAccount!.testnetHistoryList!
                      .where((element) => element.type == 'UtxosToAccount');
                } else {
                  testnetFilteredList =
                      state.activeAccount!.testnetHistoryList!;
                }
                testnetHistoryList =
                    new List.from(testnetFilteredList.toList());
              } else {
                if (state.historyFilterBy == 'receive') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'RECEIVE');
                } else if (state.historyFilterBy == 'send') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'SEND');
                } else if (state.historyFilterBy == 'swap') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'PoolSwap');
                } else if (state.historyFilterBy == 'add liquidity') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'AddPoolLiquidity');
                } else if (state.historyFilterBy == 'remove liquidity') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'RemovePoolLiquidity');
                } else if (state.historyFilterBy == 'account to utxos') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'AccountToUtxos');
                } else if (state.historyFilterBy == 'utxos to account') {
                  filteredList = state.activeAccount!.historyList!
                      .where((element) => element.category == 'UtxosToAccount');
                } else {
                  filteredList = state.activeAccount!.historyList!;
                }
                historyList = new List.from(filteredList.toList());
              }

              final DateFormat formatter = DateFormat('yyyy.MM.dd HH:mm');

              String currency = SettingsHelper.settings.currency!;

              if (historyList.length > 0 || testnetHistoryList.length > 0) {
                return Container(
                  color: isCustomBgColor
                      ? Theme.of(context).dialogBackgroundColor
                      : null,
                  child: Center(
                    child: StretchBox(
                      child: Container(
                        child: Column(
                          children: [
                            Expanded(
                                child: ListView.builder(
                              controller: _controller,
                              itemCount:
                                  SettingsHelper.settings.network == 'mainnet'
                                      ? historyList.length
                                      : testnetHistoryList.length,
                              itemBuilder: (context, index) {
                                var tokenName;
                                var txValue;
                                var isSend;
                                var type;
                                var date;
                                var txValuePrefix;
                                if (SettingsHelper.settings.network ==
                                    'mainnet') {
                                  tokenName =
                                      historyList[index].tokens![0].code;
                                  txValue = historyList[index].value;
                                  isSend =
                                      historyList[index].category == 'SEND';
                                  type = historyList[index].category;
                                  DateTime dateTime =
                                      DateTime.parse(historyList[index].date);
                                  date = formatter.format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                              dateTime.millisecondsSinceEpoch)
                                          .toLocal());
                                  txValuePrefix =
                                      (type == 'SEND' || type == 'RECEIVE')
                                          ? isSend
                                              ? '-'
                                              : '+'
                                          : '';
                                } else {
                                  tokenName = testnetHistoryList[index].token;
                                  txValue = convertFromSatoshi(
                                      testnetHistoryList[index].value);
                                  isSend = testnetHistoryList[index].isSend;
                                  type = testnetHistoryList[index].type;
                                  date = (testnetHistoryList[index].blockTime !=
                                          null)
                                      ? formatter.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                                  int.parse(testnetHistoryList[
                                                              index]
                                                          .blockTime) *
                                                      1000)
                                              .toLocal())
                                      : 'date';
                                  txValuePrefix =
                                      (type == 'vout' || type == 'vin')
                                          ? isSend
                                              ? '-'
                                              : '+'
                                          : '';
                                }

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                                    child: ListTile(
                                      leading: Container(
                                          height: 38,
                                          width: 38,
                                          child: IconHistoryType(
                                            type: type,
                                          )),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            historyHelper
                                                .getTransactionType(type),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                          Text(
                                            '$txValuePrefix${balancesHelper.numberStyling(txValue, fixed: true, fixedCount: 6)} $tokenName',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline4,
                                          ),
                                        ],
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            date.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                          ),
                                          Text(
                                              "${balancesHelper.numberStyling(tokenHelper.getAmountByUsd(tokensState.tokensPairs!, txValue, tokenName, currency), fixed: true, fixedCount: 4)} $currency")
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                            if (state.status == AccountStatusList.loading)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Loader(),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  child: Center(
                    child: Text('Not yet any transaction'),
                  ),
                );
              }
            } else {
              return Container();
            }
          },
        );
      });

  String getBalanceByUsd(tokenName, currency, txValue, tokensState) =>
      balancesHelper.numberStyling(
          tokenHelper.getAmountByUsd(
              tokensState.tokensPairs, txValue, tokenName, currency),
          fixed: true);
}
