import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/widgets/status_logo_and_title.dart';
import 'package:flutter/material.dart';
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
        !_controller.position.outOfRange &&
        !isFullLoadedHistory) {
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

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        color: isFullScreen(context) ? null : Theme.of(context).cardColor,
        child: StatusLogoAndTitle(
          subtitle: 'Not yet any transaction',
          isTitlePosBefore: true,
        ),
      ),
    );
  }
}
