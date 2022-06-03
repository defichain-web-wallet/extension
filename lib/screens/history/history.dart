import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
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
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      AccountCubit accountCubit =
          BlocProvider.of<AccountCubit>(context);
      await accountCubit.loadHistoryNext();
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
      BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
        return BlocBuilder<TokensCubit, TokensState>(
          builder: (context, tokensState) {
            if (tokensState.status == TokensStatusList.success) {
              late Iterable<HistoryModel>? filteredList;

              if (state.historyFilterBy == 'receive') {
                filteredList = state.activeAccount!.historyList!
                    .where((element) => element.type == 'vout');
              } else if (state.historyFilterBy == 'send') {
                filteredList = state.activeAccount!.historyList!
                    .where((element) => element.type == 'vin');
              } else if (state.historyFilterBy == 'swap') {
                filteredList = state.activeAccount!.historyList!
                    .where((element) => element.type == 'PoolSwap');
              } else {
                filteredList = state.activeAccount!.historyList!;
              }

              historyHelper.sortHistoryList(filteredList.toList());

              final historyList = new List.from(filteredList);
              final DateFormat formatter = DateFormat('yyyy.MM.dd HH:mm');

              String currency = SettingsHelper.settings.currency!;

              if (historyList.length > 0) {
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
                              itemCount: historyList.length,
                              itemBuilder: (context, index) {
                                final tokenName = historyList[index].token;
                                final txValue = convertFromSatoshi(
                                    historyList[index].value);
                                final isSend = historyList[index].isSend;
                                final type = historyList[index].type;
                                final date =
                                    (historyList[index].blockTime != null)
                                        ? formatter.format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                    int.parse(historyList[index]
                                                            .blockTime) *
                                                        1000)
                                                .toLocal())
                                        : 'date';
                                final txValuePrefix =
                                    (type == 'vout' || type == 'vin')
                                        ? isSend
                                            ? '-'
                                            : '+'
                                        : '';

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
                                            '$txValuePrefix$txValue $tokenName',
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
                                              "${getBalanceByUsd(tokenName, currency, txValue, tokensState)} $currency")
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
