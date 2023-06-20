import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/history/history_details.dart';
import 'package:defi_wallet/screens/history/widgets/icon_history_type.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/status_logo_and_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatefulWidget {
  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with ThemeMixin {
  static const int defaultShowItemsCount = 30;
  late ScrollController _controller;
  SettingsHelper settingsHelper = SettingsHelper();
  DateFormat formatter = DateFormat('MMM d, yyyy h:mm a');
  DateFormat labelDateFormatter = DateFormat('d MMMM');
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokenHelper = TokensHelper();
  HistoryHelper historyHelper = HistoryHelper();
  String currency = SettingsHelper.settings.currency!;
  int initialTransactionIndex = 0;
  List<dynamic> historyList = [];
  bool isFullLoadedHistory = false;

  bool isScrollPositionOnBottom = false;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange && !isFullLoadedHistory) {
      setState(() {
        isScrollPositionOnBottom = true;
        initialTransactionIndex += defaultShowItemsCount;
        print('reach the bottom');
      });
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      isScrollPositionOnBottom = false;
      print('reach the top');
    }
  }

  _getTypeFormat(String value, String token) {
    return (value == 'AccountToAccount' && token == 'BTC') ? 'RECEIVE' : value;
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
        return BlocBuilder<BitcoinCubit, BitcoinState>(
            builder: (context, bitcoinState) {
          if (state.status == AccountStatusList.success &&
              tokensState.status == TokensStatusList.success) {
            var tempHistoryList;
            late int showItemsCount;
            late int targetHistoryLength;
            if (SettingsHelper.isBitcoin()) {
              historyList = bitcoinState.history ?? [];
            } else {
              if (SettingsHelper.settings.network == 'mainnet') {
                targetHistoryLength = ((initialTransactionIndex + 30) >
                        state.activeAccount!.historyList!.length)
                    ? state.activeAccount!.historyList!.length
                    : initialTransactionIndex + 30;
                historyList.addAll(
                    new List.from(state.activeAccount!.historyList!
                        .sublist(initialTransactionIndex, targetHistoryLength)),
                );
                if (targetHistoryLength == state.activeAccount!.historyList!.length) {
                  isFullLoadedHistory = true;
                }
              } else {
                targetHistoryLength = (initialTransactionIndex + 30 >
                    state.activeAccount!.testnetHistoryList!.length)
                    ? state.activeAccount!.testnetHistoryList!.length
                    : initialTransactionIndex + 30;
                historyList = new List.from(state
                    .activeAccount!.testnetHistoryList!
                    .sublist(initialTransactionIndex, initialTransactionIndex + 30));
              }
            }

            if (historyList != null && historyList.length != 0) {
              return SliverFillRemaining(
                hasScrollBody: true,
                fillOverscroll: true,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _controller,
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        var tokenName;
                        var txValue;
                        var isSend;
                        var type;
                        var date;
                        var txValuePrefix;
                        DateTime currentDate;
                        DateTime nextDate;
                        if (SettingsHelper.isBitcoin()) {
                          tokenName = 'BTC';
                          txValue =
                              convertFromSatoshi(historyList[index].value);
                          isSend = historyList[index].isSend;
                          type = isSend ? 'SEND' : 'RECEIVE';
                          DateTime dateTime =
                              DateTime.parse(historyList[index].blockTime);
                          date = formatter.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                      dateTime.millisecondsSinceEpoch)
                                  .toLocal());
                          txValuePrefix = (type == 'SEND' || type == 'RECEIVE')
                              ? isSend
                                  ? ''
                                  : '+'
                              : '';
                          currentDate =
                              DateTime.parse(historyList[index].blockTime);
                          if (index + 1 == historyList.length) {
                            nextDate =
                                DateTime.parse(historyList[index].blockTime);
                          } else {
                            nextDate = DateTime.parse(
                                historyList[index + 1].blockTime);
                          }
                        } else if (SettingsHelper.settings.network ==
                            'mainnet') {
                          tokenName = historyList[index].tokens![0].code;
                          txValue = historyList[index].value;
                          isSend = historyList[index].category == 'SEND';
                          type = _getTypeFormat(historyList[index].category, historyList[index].tokens[0].code);
                          DateTime dateTime =
                              DateTime.parse(historyList[index].date);
                          date = formatter.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                      dateTime.millisecondsSinceEpoch)
                                  .toLocal());
                          txValuePrefix = (type == 'SEND' || type == 'RECEIVE')
                              ? isSend
                                  ? '-'
                                  : '+'
                              : '';
                          currentDate = DateTime.parse(historyList[index].date);
                          if (index + 1 == historyList.length) {
                            nextDate = DateTime.parse(historyList[index].date);
                          } else {
                            nextDate =
                                DateTime.parse(historyList[index + 1].date);
                          }
                        } else {
                          tokenName = historyList[index].token;
                          txValue =
                              convertFromSatoshi(historyList[index].value);
                          isSend = historyList[index].isSend;
                          type = historyList[index].type;
                          date = (historyList[index].blockTime != null)
                              ? formatter.format(
                                  DateTime.fromMillisecondsSinceEpoch(int.parse(
                                              historyList[index].blockTime) *
                                          1000)
                                      .toLocal())
                              : 'date';
                          txValuePrefix = (type == 'vout' || type == 'vin')
                              ? isSend
                                  ? '-'
                                  : '+'
                              : '';
                          currentDate = DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(historyList[index].blockTime) *
                                      1000)
                              .toLocal();
                          if (index + 1 == historyList.length) {
                            nextDate = DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(historyList[index].blockTime) *
                                        1000)
                                .toLocal();
                          } else {
                            nextDate = DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(historyList[index].blockTime) *
                                        1000)
                                .toLocal();
                          }
                        }
                        return Column(
                          children: [
                            if (currentDate.day < nextDate.day || index == 0)
                              Container(
                                color: Theme.of(context).cardColor,
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Text(
                                  labelDateFormatter
                                      .format(nextDate)
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .color!
                                            .withOpacity(0.3),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            Container(
                              color: Theme.of(context).cardColor,
                              padding: const EdgeInsets.only(
                                bottom: 2,
                                left: 14,
                                right: 14,
                                top: 2,
                              ),
                              child: ListTile(
                                onTap: () {
                                  if (SettingsHelper.settings.network == 'mainnet') {
                                    if (SettingsHelper.isBitcoin() ||
                                        historyList[index].category ==
                                                'AccountToAccount' &&
                                            historyList[index].tokens[0].code ==
                                                'BTC') {
                                      historyHelper.openExplorerLink(historyList[index].txid);
                                    } else {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1, animation2) =>
                                              HistoryDetails(
                                                dfxHistoryModel: historyList[index],
                                              ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration: Duration.zero,
                                        ),
                                      );
                                    }
                                  }
                                },
                                contentPadding: const EdgeInsets.all(0),
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: historyTypeIconGradient,
                                  ),
                                  child: IconHistoryType(
                                    type: type,
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      historyHelper.getTransactionType(type),
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                    Text(
                                      '$txValuePrefix${balancesHelper.numberStyling(txValue, fixed: true, fixedCount: 4)} $tokenName',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                            fontSize: 15,
                                            color: (txValuePrefix == '+')
                                                ? AppColors.receivedIconColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color,
                                          ),
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
                                          .headline6!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline6!
                                                .color!
                                                .withOpacity(0.3),
                                          ),
                                    ),
                                    // Text(
                                    //     "\$${balancesHelper.numberStyling(tokenHelper.getAmountByUsd(tokensState.tokensPairs!, txValue, tokenName).abs(), fixed: true, fixedCount: 2)}",
                                    //     style: Theme.of(context)
                                    //         .textTheme
                                    //         .headline6!
                                    //         .copyWith(
                                    //           fontWeight: FontWeight.w600,
                                    //           color: Theme.of(context)
                                    //               .textTheme
                                    //               .headline6!
                                    //               .color!
                                    //               .withOpacity(0.3),
                                    //         )),
                                  ],
                                ),
                              ),
                            ),
                            if (isFullLoadedHistory && index == historyList.length - 1)
                              Container(
                                width: double.infinity,
                                color: Theme.of(context).cardColor,
                                child: Text('No more transactions', textAlign: TextAlign.center),
                              )
                            else if (isScrollPositionOnBottom && index == historyList.length - 1)
                              Container(
                                width: double.infinity,
                                height: 80,
                                color: Theme.of(context).cardColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: CircularProgressIndicator(
                                        color: AppColors.portage.withOpacity(0.24),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 14,
                                    ),
                                    Text(
                                      'Loading',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.6),
                                      ),
                                    )
                                  ],
                                ),
                              )
                          ],
                        );
                      },
                    ),
                    // TODO: need to update date when scrolling
                    if (false)
                      Align(
                        alignment: Alignment.topCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 4.0,
                              sigmaY: 4.0,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                color: isDarkTheme()
                                    ? DarkColors.historyDataLabel
                                    : LightColors.historyDataLabel,
                              ),
                              child: Text(
                                labelDateFormatter
                                    .format(DateTime.now())
                                    .toString(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .color!
                                          .withOpacity(0.3),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: StatusLogoAndTitle(
                    subtitle: 'Not yet any transaction',
                    isTitlePosBefore: true,
                  ),
                ),
              );
            }
          } else {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Container(),
            );
          }
        });
      });
    });
  }
}
