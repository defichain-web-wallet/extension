import 'dart:async';
import 'dart:ui';

import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/address_book/address_book_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/history_helper.dart';
import 'package:defi_wallet/helpers/history_new.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/netwrok_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/history/widgets/history_icon_type.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/screens/send/send_status_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryDetails extends StatefulWidget {
  final HistoryNew? dfxHistoryModel;
  final HistoryModel? generalHistoryModel;

  const HistoryDetails({
    Key? key,
    this.dfxHistoryModel,
    this.generalHistoryModel,
  }) : super(key: key);

  @override
  State<HistoryDetails> createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails>
    with ThemeMixin, NetworkMixin {
  HistoryHelper historyHelper = HistoryHelper();
  BalancesHelper balancesHelper = BalancesHelper();
  TokensHelper tokensHelper = TokensHelper();
  DateFormat formatter = DateFormat('d MMMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
  }

  cutAddress(String s) {
    return s.substring(0, 12) + '...' + s.substring(30, 42);
  }

  @override
  Widget build(BuildContext context) {
    String txCategory = widget.dfxHistoryModel!.category!;
    String txId = widget.dfxHistoryModel!.txid!;
    var txValueFirst;
    var txValueSecond;
    var isMultipleAmounts = txCategory != 'SEND' &&
        txCategory != 'RECEIVE' &&
        txCategory != 'UtxosToAccount';
    var isSend = txCategory == 'SEND';
    var txValuePrefix = isSend ? '-' : '';
    var txValue = balancesHelper.numberStyling(
      widget.dfxHistoryModel!.value!,
      fixed: true,
      fixedCount: 4,
    );
    if (isMultipleAmounts) {
      txValueFirst = balancesHelper.numberStyling(
        widget.dfxHistoryModel!.tokens![0].value!.abs(),
        fixed: true,
        fixedCount: 6,
      );
      txValueSecond = balancesHelper.numberStyling(
        widget.dfxHistoryModel!.tokens![1].value!.abs(),
        fixed: true,
        fixedCount: 6,
      );
    }
    var tokenNameFirst = widget.dfxHistoryModel!.tokens![0].code;
    var tokenNameSecond =
        isMultipleAmounts ? widget.dfxHistoryModel!.tokens![1].code : '';
    DateTime dateTime = DateTime.parse(widget.dfxHistoryModel!.date!);
    String date = formatter.format(
        DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch)
            .toLocal());
    late double totalBalanceByUsd;

    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          drawerScrimColor: Color(0x0f180245),
          endDrawer: AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: NewMainAppBar(
            isShowLogo: false,
          ),
          body: BlocBuilder<TokensCubit, TokensState>(
            builder: (context, tokensState) {
              AssetPairModel? assetPairModel;
              if (txCategory == 'PoolSwap') {
                assetPairModel = tokensState.tokensPairs!
                    .firstWhere((element) =>
                element.tokenB == tokenNameFirst &&
                    element.tokenA == tokenNameSecond);
              }
              totalBalanceByUsd = tokensHelper.getAmountByUsd(
                tokensState.tokensPairs!,
                widget.dfxHistoryModel!.value!,
                tokenNameFirst!,
              );
              String totalBalanceByUsdFormat = balancesHelper.numberStyling(
                totalBalanceByUsd,
                fixed: true,
                fixedCount: 6,
              );

              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 34),
                    padding: EdgeInsets.only(
                      top: 22,
                      bottom: 24,
                      left: 16,
                      right: 16,
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkTheme()
                          ? DarkColors.scaffoldContainerBgColor
                          : LightColors.scaffoldContainerBgColor,
                      border: isDarkTheme()
                          ? Border.all(
                              width: 1.0,
                              color: Colors.white.withOpacity(0.05),
                            )
                          : null,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: StretchBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.historyTypeMark
                                          .withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      historyHelper.getTransactionType(
                                        txCategory,
                                      ),
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    date,
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
                                  SizedBox(
                                    height: 12,
                                  ),
                                  if (isMultipleAmounts)
                                    Column(
                                      children: [
                                        Text(
                                          '$txValueFirst $tokenNameFirst',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3!
                                              .copyWith(
                                                fontSize: 36,
                                              ),
                                        ),
                                        if (txCategory != 'AddPoolLiquidity' && txCategory != 'RemovePoolLiquidity')
                                          SvgPicture.asset(
                                            'assets/history/changed.svg',
                                            width: 20,
                                            height: 20,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline1!
                                                .color!,
                                          ),
                                        Text(
                                          '$txValueSecond $tokenNameSecond',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline3!
                                              .copyWith(
                                                fontSize: 36,
                                              ),
                                        )
                                      ],
                                    )
                                  else
                                    Text(
                                      '$txValuePrefix$txValue $tokenNameFirst',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline3!
                                          .copyWith(
                                            fontSize: 42,
                                          ),
                                    ),
                                  Text(
                                    '\$$totalBalanceByUsdFormat',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .color!
                                              .withOpacity(0.3),
                                        ),
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Summary',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 24,
                                  ),
                                  if (txCategory == 'AddPoolLiquidity' || txCategory == 'RemovePoolLiquidity')
                                    ...[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Added Liquidity',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .color!
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          Text(
                                            '$txValue ${widget.dfxHistoryModel!.tokens![2].code}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.16),
                                        ),
                                      ),
                                    ],
                                  if (txCategory == 'PoolSwap')
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.3),
                                              ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$txValueFirst $tokenNameFirst',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!,
                                            ),
                                            Text(
                                              '$txValueSecond $tokenNameSecond',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!,
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  else
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isSend ? 'Send to' : 'Received from',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.3),
                                              ),
                                        ),
                                        Text(
                                          cutAddress(
                                              widget.dfxHistoryModel!.address!),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!,
                                        ),
                                      ],
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Divider(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.16),
                                    ),
                                  ),
                                  if (txCategory == 'PoolSwap')
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Price',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .color!
                                                    .withOpacity(0.3),
                                              ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${assetPairModel!.reserveBDivReserveA!.toStringAsFixed(6)} $tokenNameFirst per $tokenNameSecond',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!,
                                            ),
                                            Text(
                                              '${assetPairModel.reserveADivReserveB!.toStringAsFixed(6)} $tokenNameSecond per $tokenNameFirst',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline5!,
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  else if (txCategory != 'AddPoolLiquidity' && txCategory != 'RemovePoolLiquidity')
                                    ...[
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Amount',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .color!
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          Text(
                                            '$txValue $tokenNameFirst',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.16),
                                        ),
                                      ),
                                    ],
                                  if (txCategory != 'AddPoolLiquidity' && txCategory != 'RemovePoolLiquidity')
                                    Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Fee',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline5!
                                                  .color!
                                                  .withOpacity(0.3),
                                            ),
                                      ),
                                      Text(
                                        '${widget.dfxHistoryModel!.feeValue!.toStringAsFixed(8)} $tokenNameFirst',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
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
                                  onTap: () {
                                    if (SettingsHelper.isBitcoin()) {
                                      if (SettingsHelper.settings.network! ==
                                          'mainnet') {
                                        launch(
                                          'https://live.blockcypher.com/btc/tx/$txId',
                                        );
                                      } else {
                                        launch(
                                          'https://live.blockcypher.com/btc-testnet/tx/$txId',
                                        );
                                      }
                                    } else {
                                      launch(
                                        'https://defiscan.live/transactions/$txId?network=${SettingsHelper.settings.network}',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: HistoryIconType(
                        type: txCategory,
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}
