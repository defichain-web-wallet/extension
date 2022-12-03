import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_confirmation.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:defi_wallet/widgets/fields/decoration_text_field.dart';

class SelectPool extends StatefulWidget {
  final AssetPairModel assetPair;

  const SelectPool({Key? key, required this.assetPair}) : super(key: key);

  @override
  _SelectPoolState createState() => _SelectPoolState();
}

class _SelectPoolState extends State<SelectPool> {
  TokensHelper tokensHelper = TokensHelper();
  final TextEditingController _amountBaseController =
      TextEditingController(text: '0');
  final TextEditingController _amountQuoteController =
      TextEditingController(text: '0');
  FocusNode _focusBase = new FocusNode();
  FocusNode _focusQuote = new FocusNode();
  FocusModel _baseAmountFocusModel = new FocusModel();
  FocusModel _quoteAmountFocusModel = new FocusModel();
  TokensHelper tokenHelper = TokensHelper();
  List<String> tokensForSwap = [];
  String assetFrom = '';
  String assetTo = '';
  bool waitingTo = true;
  List<String> assets = [];
  double shareOfPool = 0;
  double amount = 0;
  int balance = 0;
  double balanceB = 0;
  double balanceA = 0;
  double balanceUSD = 0;
  double amountUSD = 0;
  bool isErrorBalance = false;
  bool isEnoughBalance = false;
  int balanceFrom = 0;
  int balanceTo = 0;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  double minShareOfPool = 0.00000001;

  @override
  void initState() {
    super.initState();
    TokensState tokensState = BlocProvider.of<TokensCubit>(context).state;
    _focusBase.addListener(onFocusBaseField);
    _focusQuote.addListener(onFocusQuoteField);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _setShareOfPool();
      _setAmount(tokensState);
    });
  }

  onFocusBaseField() {
    if (_amountBaseController.text == '0') {
      _amountBaseController.text = '';
    }
  }

  onFocusQuoteField() {
    if (_amountQuoteController.text == '0') {
      _amountQuoteController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) => ScaffoldConstrainedBox(
              child: LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                        title: 'Select Pool Pair',
                        isShowBottom: !(state is TransactionInitialState),
                        height: !(state is TransactionInitialState)
                            ? toolbarHeightWithBottom
                            : toolbarHeight),
                    body: _buildBody(context),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'Select Pool Pair',
                        action: null,
                        isShowBottom: !(state is TransactionInitialState),
                        height: !(state is TransactionInitialState)
                            ? toolbarHeightWithBottom
                            : toolbarHeight,
                        isSmall: true,
                      ),
                      body: _buildBody(context, isFullSize: true),
                    ),
                  );
                }
              }),
            ));
  }

  Widget _buildBody(context, {isFullSize = false}) =>
      BlocBuilder<TokensCubit, TokensState>(
        builder: (context, tokensState) {
          return BlocBuilder<AccountCubit, AccountState>(
              builder: (accountContext, accountState) {
            if (tokensState.status == TokensStatusList.success) {
              if (accountState.status == AccountStatusList.success) {
                assetFrom = widget.assetPair.symbol!.split('-')[0];
                assetTo = widget.assetPair.symbol!.split('-')[1];
                accountState.activeAccount!.balanceList!.forEach((el) {
                  if (el.token == widget.assetPair.symbol!) {
                    balance = el.balance!;
                  }
                  if (el.token == assetFrom) {
                    balanceFrom = el.balance!;
                  }
                  if (el.token == assetTo) {
                    balanceTo = el.balance!;
                  }
                });

                try {
                  var baseBalance = List.from(accountState
                      .activeAccount!.balanceList!
                      .where((element) =>
                          element.token == widget.assetPair.tokenA))[0];
                  var quoteBalance = List.from(accountState
                      .activeAccount!.balanceList!
                      .where((element) =>
                          element.token == widget.assetPair.tokenB))[0];
                  isErrorBalance = balanceA > baseBalance.balance ||
                      balanceB > quoteBalance.balance;
                } catch (err) {
                  isErrorBalance = true;
                }

                List<Widget> _listWidgets = [
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 46,
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 22),
                                decoration: BoxDecoration(
                                  color:
                                  Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft:
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        tokenHelper
                                            .getImageNameByTokenName(
                                            assetFrom),
                                        height: 24,
                                        width: 24,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 12.0),
                                        child: Text(
                                            TokensHelper()
                                                .getTokenFormat(
                                                assetFrom),
                                            style:
                                            Theme.of(context)
                                                .textTheme
                                                .headline6),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: DecorationTextField(
                                controller: _amountBaseController,
                                focusNode: _focusBase,
                                focusModel: _baseAmountFocusModel,
                                suffixIcon: Container(
                                  padding: EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    right: 6,
                                  ),
                                  child: SizedBox(
                                    width: 40,
                                    child: TextButton(
                                        child: Text('MAX',
                                            style: TextStyle(
                                                fontSize: 10)),
                                        onPressed: () => setMaxAmount(
                                            _amountBaseController,
                                            _amountQuoteController,
                                            assetFrom,
                                            widget.assetPair
                                                .reserveBDivReserveA!,
                                            accountState,
                                            tokensState)),
                                  ),
                                ),
                                onChanged: (value) => onChanged(
                                    _amountQuoteController,
                                    value,
                                    widget.assetPair
                                        .reserveBDivReserveA!,
                                    tokensState),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                              getAvailableAmount(
                                  balanceFrom, assetFrom),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .color!
                                      .withOpacity(0.5))),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 46,
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 22),
                                decoration: BoxDecoration(
                                  color:
                                  Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft:
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                ),
                                child: Container(
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        tokenHelper
                                            .getImageNameByTokenName(
                                            assetTo),
                                        height: 24,
                                        width: 24,
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            left: 12.0),
                                        child: Text(
                                            TokensHelper()
                                                .getTokenFormat(
                                                assetTo),
                                            style:
                                            Theme.of(context)
                                                .textTheme
                                                .headline6),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: DecorationTextField(
                                isBorder: isFullSize,
                                controller:
                                _amountQuoteController,
                                focusNode: _focusQuote,
                                focusModel:
                                _quoteAmountFocusModel,
                                suffixIcon: Container(
                                  padding: EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    right: 6,
                                  ),
                                  child: SizedBox(
                                    width: 40,
                                    child: TextButton(
                                      child: Text('MAX',
                                          style: TextStyle(
                                              fontSize: 10)),
                                      onPressed: () => setMaxAmount(
                                          _amountQuoteController,
                                          _amountBaseController,
                                          assetTo,
                                          widget.assetPair
                                              .reserveADivReserveB!,
                                          accountState,
                                          tokensState),
                                    ),
                                  ),
                                ),
                                onChanged: (value) => onChanged(
                                    _amountBaseController,
                                    value,
                                    widget.assetPair
                                        .reserveADivReserveB!,
                                    tokensState),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                              getAvailableAmount(
                                  balanceTo, assetTo),
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .apply(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .color!
                                      .withOpacity(0.5))),
                        )
                      ],
                    ),
                  ),
                ];



                return Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Column(
                              children: [
                                if(isFullSize) SizedBox(height: 50,),
                                assetTo != 'DFI' ? _listWidgets[0] : _listWidgets[1],
                                SizedBox(height: 24,),
                                assetTo != 'DFI' ? _listWidgets[1] : _listWidgets[0],
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 42.0, bottom: 42),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Your input',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '${_amountBaseController.text} ${TokensHelper().getTokenFormat(assetFrom)}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '${_amountQuoteController.text} ${TokensHelper().getTokenFormat(assetTo)}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline5,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(),
                                        if (shareOfPool > minShareOfPool)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Share of pool',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline6,
                                                ),
                                                Text(
                                                  '${shareOfPool.toStringAsFixed(8)}%',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Insufficient funds',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                          color: isEnoughBalance
                                              ? AppTheme.redErrorColor
                                              : Colors.transparent,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: PrimaryButton(
                              label: 'Continue',
                              callback: isErrorBalance || isDisableSubmit()
                                  ? () {
                                      setState(() {
                                        isEnoughBalance = true;
                                      });
                                    }
                                  : () => Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation1,
                                                  animation2) =>
                                              LiquidityConfirmation(
                                                  assetPair: widget.assetPair,
                                                  baseAmount: double.parse(
                                                      _amountBaseController.text
                                                          .replaceAll(
                                                              ',', '.')),
                                                  quoteAmount: double.parse(
                                                      _amountQuoteController
                                                          .text
                                                          .replaceAll(
                                                              ',', '.')),
                                                  shareOfPool: shareOfPool,
                                                  amountUSD: amountUSD,
                                                  balanceUSD: balanceUSD,
                                                  balanceA: balanceA,
                                                  balanceB: balanceB,
                                                  amount: amount),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          });
        },
      );

  void _setBalanceAndAmountUSD(tokensState) {
    var totalBalanceInUsd = tokensHelper.getAmountByUsd(
          tokensState.tokensPairs,
          balanceA,
          widget.assetPair.tokenA!,
        ) +
        tokensHelper.getAmountByUsd(
          tokensState.tokensPairs,
          balanceB,
          widget.assetPair.tokenB!,
        );

    var totalAmountInUsd = tokensHelper.getAmountByUsd(
          tokensState.tokensPairs,
          double.parse(_amountBaseController.text.replaceAll(',', '.')),
          widget.assetPair.tokenA!,
        ) +
        tokensHelper.getAmountByUsd(
          tokensState.tokensPairs,
          double.parse(_amountQuoteController.text.replaceAll(',', '.')),
          widget.assetPair.tokenB!,
        );

    setState(() {
      balanceUSD = totalBalanceInUsd;
      amountUSD = totalAmountInUsd;
    });
  }

  void _setAmount(tokensState) {
    _setBalances();
    _setBalanceAndAmountUSD(tokensState);
    setState(() {
      amount = double.parse(_amountBaseController.text.replaceAll(',', '.')) /
          (widget.assetPair.reserveA! / widget.assetPair.totalLiquidity!);
    });
  }

  void _setBalances() {
    setState(() {
      balanceA = (balance / widget.assetPair.totalLiquidityRaw!) *
          widget.assetPair.reserveA!;
      balanceB = (balance / widget.assetPair.totalLiquidityRaw!) *
          widget.assetPair.reserveB!;
    });
  }

  void _setShareOfPool() {
    setState(() {
      if (widget.assetPair.totalLiquidityRaw! != 0) {
        shareOfPool = (convertToSatoshi(
                double.parse(_amountBaseController.text.replaceAll(',', '.'))) /
            widget.assetPair.totalLiquidityRaw!);
      }
    });
  }

  String getAvailableAmount(balance, assetCode) {
    return '${getAmountByFee(balance, assetCode)} $assetCode available';
  }

  bool isDisableSubmit() {
    int amountFrom = convertToSatoshi(
        double.parse(_amountBaseController.text.replaceAll(',', '.')));
    int amountTo = convertToSatoshi(
        double.parse(_amountQuoteController.text.replaceAll(',', '.')));

    return balanceFrom == 0 ||
        balanceTo == 0 ||
        amountFrom > balanceFrom ||
        amountTo > balanceTo;
  }

  setMaxAmount(
      TextEditingController controller,
      TextEditingController toController,
      String asset,
      double reserve,
      state,
      tokensState) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        int balance = state.activeAccount!.balanceList!
            .firstWhere((el) => el.token! == asset)
            .balance!;
        double amount = getAmountByFee(balance, asset);
        controller.text = amount.toString();

        onChanged(toController, controller.text, reserve, tokensState);
      });
    });
  }

  double getAmountByFee(int balance, String token) {
    int fee = token == 'DFI' ? 21000 : 0;
    int amount = balance - fee;
    return (amount > 0) ? convertFromSatoshi(balance - fee) : 0.0;
  }

  onChanged(TextEditingController controller, String value, double reserve,
      tokensState) {
    try {
      double baseAmount = double.parse(value.replaceAll(',', '.'));
      if (!(baseAmount * reserve).isNaN) {
        controller.text = (baseAmount * reserve).toStringAsFixed(8);
        _setShareOfPool();
      }
      _setAmount(tokensState);
    } catch (_) {
      controller.text = '0';
    }
  }
}
