import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_confirmation_screen.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoveLiquidityScreen extends StatefulWidget {
  final AssetPairModel assetPair;
  final int balance;

  const RemoveLiquidityScreen(
      {Key? key, required this.assetPair, required this.balance})
      : super(key: key);

  @override
  _RemoveLiquidityScreenState createState() => _RemoveLiquidityScreenState();
}

class _RemoveLiquidityScreenState extends State<RemoveLiquidityScreen> {
  TokensHelper tokensHelper = TokensHelper();

  double currentSliderValue = 0;
  double shareOfPool = 0;
  double amountUSD = 0;
  double balanceUSD = 0;
  double amountA = 0;
  double amountB = 0;
  double balanceA = 0;
  double balanceB = 0;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

  @override
  void initState() {
    super.initState();
    TokensState tokensState = BlocProvider.of<TokensCubit>(context).state;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _setShareOfPool();
      _setAmountA();
      _setAmountB();
      _setBalanceA();
      _setBalanceB();
      _setBalanceAndAmountUSD(tokensState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: MainAppBar(
            title: 'Remove liquidity',
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? toolbarHeightWithBottom
                : toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: Container(
            color: Theme.of(context).dialogBackgroundColor,
            padding: AppTheme.screenPadding,
            child: Center(
              child: StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: isFullScreen
                          ? const EdgeInsets.only(top: 40.0)
                          : const EdgeInsets.only(top: 0),
                      child: Container(
                        padding: const EdgeInsets.only(
                          top: 12,
                          right: 16,
                          bottom: 42,
                          left: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Amount',
                                    style: TextStyle(
                                      color: Color(0xffAFAFAF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  AssetPair(
                                    pair: widget.assetPair.symbol!,
                                    isRotate: isFullScreen,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${getCurrentSliderValue()}%',
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                            Container(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  inactiveTrackColor: AppTheme.pinkColor,
                                  trackHeight: 1,
                                  trackShape: RectangularSliderTrackShape(),
                                  thumbColor: isFullScreen
                                      ? AppTheme.pinkColor
                                      : Colors.black,
                                ),
                                child: Slider(
                                  value: currentSliderValue,
                                  max: 100,
                                  divisions: 100,
                                  label: currentSliderValue.round().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      currentSliderValue = value;
                                    });
                                    _setShareOfPool();
                                    _setAmountA();
                                    _setAmountB();
                                  },
                                ),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SliderButton(
                                    isFullSize: isFullScreen,
                                    value: 25,
                                    onPressed: () {
                                      setState(() {
                                        currentSliderValue = 25;
                                      });
                                      _setShareOfPool();
                                      _setAmountA();
                                      _setAmountB();
                                    },
                                  ),
                                  SliderButton(
                                    isFullSize: isFullScreen,
                                    value: 50,
                                    onPressed: () {
                                      setState(() {
                                        currentSliderValue = 50;
                                      });
                                      _setShareOfPool();
                                      _setAmountA();
                                      _setAmountB();
                                    },
                                  ),
                                  SliderButton(
                                    isFullSize: isFullScreen,
                                    value: 75,
                                    onPressed: () {
                                      setState(() {
                                        currentSliderValue = 75;
                                      });
                                      _setShareOfPool();
                                      _setAmountA();
                                      _setAmountB();
                                    },
                                  ),
                                  SliderButton(
                                    isFullSize: isFullScreen,
                                    value: 100,
                                    onPressed: () {
                                      setState(() {
                                        currentSliderValue = 100;
                                      });
                                      _setShareOfPool();
                                      _setAmountA();
                                      _setAmountB();
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 42.0,
                          bottom: 42,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your output',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${amountA.toStringAsFixed(6)} ${TokensHelper().getTokenFormat(widget.assetPair.tokenA)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${amountB.toStringAsFixed(6)} ${TokensHelper().getTokenFormat(widget.assetPair.tokenB)}',
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share of pool',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Text(
                                    '${shareOfPool.toStringAsFixed(8)} %',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              child: AccentButton(
                                label: 'Cancel',
                                callback: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                          ),
                          Expanded(
                            child: Container(
                              child: PrimaryButton(
                                label: 'Continue',
                                globalKey: GlobalKey(),
                                callback: () => Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (
                                      context,
                                      animation1,
                                      animation2,
                                    ) =>
                                        LiquidityConfirmationScreen(
                                      assetPair: widget.assetPair,
                                      baseAmount: amountA,
                                      quoteAmount: amountB,
                                      shareOfPool: shareOfPool,
                                      amountUSD: amountUSD,
                                      balanceUSD: balanceUSD,
                                      balanceA: balanceA,
                                      balanceB: balanceB,
                                      amount: 0,
                                      removeLT: getRemoveAmount(),
                                    ),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int getCurrentSliderValue() => currentSliderValue.round();

  double getRemoveAmount() {
    return (convertFromSatoshi(widget.balance) * currentSliderValue / 100);
  }

  void _setShareOfPool() {
    setState(() {
      shareOfPool = (widget.balance *
          (currentSliderValue / 100) /
          widget.assetPair.totalLiquidityRaw!);
    });
  }

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
          amountB,
          widget.assetPair.tokenA!,
        ) +
        tokensHelper.getAmountByUsd(
          tokensState.tokensPairs,
          amountB,
          widget.assetPair.tokenB!,
        );
    setState(() {
      balanceUSD = totalBalanceInUsd;
      amountUSD = totalAmountInUsd;
    });
  }

  void _setAmountA() {
    setState(() {
      amountA = (shareOfPool * widget.assetPair.reserveA!);
    });
  }

  void _setAmountB() {
    setState(() {
      amountB = (shareOfPool * widget.assetPair.reserveB!);
    });
  }

  void _setBalanceA() {
    setState(() {
      balanceA = (widget.balance / widget.assetPair.totalLiquidityRaw!) *
          widget.assetPair.reserveA!;
    });
  }

  void _setBalanceB() {
    setState(() {
      balanceB = (widget.balance / widget.assetPair.totalLiquidityRaw!) *
          widget.assetPair.reserveB!;
    });
  }
}

class SliderButton extends StatelessWidget {
  final double value;
  final onPressed;
  final isFullSize;

  const SliderButton({
    Key? key,
    required this.value,
    required this.onPressed,
    required this.isFullSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        '${value.round().toString()}%',
        style: Theme.of(context).textTheme.headline3!.apply(
              color: AppTheme.pinkColor,
              fontWeightDelta: 2,
            ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        shadowColor: Colors.transparent,
        primary: isFullSize ? Colors.transparent : Color(0xfff1f1f1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
        side: BorderSide(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
