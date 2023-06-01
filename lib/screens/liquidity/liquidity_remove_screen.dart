import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_confirmation.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/sliders/polygon_slider_thumb.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class LiquidityRemoveScreen extends StatefulWidget {
  final AssetPairModel assetPair;
  final int balance;

  const LiquidityRemoveScreen({
    Key? key,
    required this.assetPair,
    required this.balance,
  }) : super(key: key);

  @override
  State<LiquidityRemoveScreen> createState() => _LiquidityRemoveScreenState();
}

class _LiquidityRemoveScreenState extends State<LiquidityRemoveScreen>
    with ThemeMixin, SnackBarMixin {
  String titleText = 'Remove liquidity';
  TokensHelper tokensHelper = TokensHelper();

  double currentSliderValue = 0;
  double shareOfPool = 0;
  double amountUSD = 0;
  double balanceUSD = 0;
  double amountA = 0;
  double amountB = 0;
  double balanceA = 0;
  double balanceB = 0;

  bool isShowDetails = true;

  @override
  void initState() {
    super.initState();
    TokensState tokensState = BlocProvider.of<TokensCubit>(context).state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setShareOfPool();
      _setAmountA();
      _setAmountB();
      _setBalanceA();
      _setBalanceB();
      _setBalanceAndAmountUSD(tokensState);
    });
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        double arrowRotateDeg = isShowDetails ? 180.0 : 0.0;
        return Scaffold(
          drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
          endDrawer: AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: NewMainAppBar(
            isShowLogo: false,
          ),
          body: Container(
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
                  ? DarkColors.drawerBgColor
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              titleText,
                              style: headline2.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.8),
                            border: Border.all(
                              color: AppColors.lavenderPurple.withOpacity(0.35),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .color!
                                                .withOpacity(0.3),
                                          ),
                                    ),
                                    Row(
                                      children: [
                                        AssetPair(
                                          pair: widget.assetPair.symbol!,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          widget.assetPair.symbol!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4!
                                              .copyWith(
                                                fontSize: 16,
                                              ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${getCurrentSliderValue()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .copyWith(
                                          fontSize: 24,
                                        ),
                                  ),
                                ),
                              ),
                              Container(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbShape: PolygonSliderThumb(
                                      thumbRadius: 16.0,
                                    ),
                                  ),
                                  child: Slider(
                                    value: currentSliderValue,
                                    max: 100,
                                    divisions: 100,
                                    label:
                                        currentSliderValue.round().toString(),
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
                        SizedBox(
                          height: 24,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isShowDetails = !isShowDetails;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Show less',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              RotationTransition(
                                turns: AlwaysStoppedAnimation(
                                    arrowRotateDeg / 360),
                                child: SizedBox(
                                  width: 8,
                                  height: 8,
                                  child: SvgPicture.asset(
                                    'assets/icons/arrow_down.svg',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        if (isShowDetails) ...[
                          SizedBox(
                            height: 24,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your output',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.3),
                                      ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text:
                                              '${amountA.toStringAsFixed(6)} ${TokensHelper().getTokenFormat(widget.assetPair.tokenA)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontSize: 12,
                                              ),
                                        ),
                                      ]),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text:
                                              '${amountB.toStringAsFixed(6)} ${TokensHelper().getTokenFormat(widget.assetPair.tokenB)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline5!
                                              .copyWith(
                                                fontSize: 12,
                                              ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: AppColors.lavenderPurple.withOpacity(0.16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Share of pool',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .color!
                                            .withOpacity(0.3),
                                      ),
                                ),
                                Text(
                                  '${shareOfPool.toStringAsFixed(8)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                    NewPrimaryButton(
                      width: buttonSmallWidth,
                      callback: () {
                        if (txState is! TransactionLoadingState) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  LiquidityConfirmation(
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
                          );
                        } else {
                          showSnackBar(
                            context,
                            title: 'Please wait for the previous '
                                'transaction',
                            color: AppColors.txStatusError.withOpacity(0.1),
                            prefix: Icon(
                              Icons.close,
                              color: AppColors.txStatusError,
                            ),
                          );
                        }
                      },
                      title: 'Continue',
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
        style: Theme.of(context).textTheme.headline5!.copyWith(
              fontSize: 12,
            ),
      ),
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.transparent,
        primary: Colors.transparent,
        onSurface: Colors.transparent,
        elevation: 0,
        fixedSize: Size(74, 28),
        padding: const EdgeInsets.all(0),
        shadowColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        disabledForegroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        side: BorderSide(
          color: AppColors.lavenderPurple.withOpacity(0.35),
        ),
      ),
    );
  }
}
