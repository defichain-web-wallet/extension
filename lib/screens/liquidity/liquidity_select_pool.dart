import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_confirmation.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/fields/amount_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:defi_wallet/models/focus_model.dart';

class LiquiditySelectPool extends StatefulWidget {
  final AssetPairModel assetPair;

  const LiquiditySelectPool({Key? key, required this.assetPair})
      : super(key: key);

  @override
  _LiquiditySelectPoolState createState() => _LiquiditySelectPoolState();
}

class _LiquiditySelectPoolState extends State<LiquiditySelectPool>
    with ThemeMixin, SnackBarMixin {
  TokensHelper tokensHelper = TokensHelper();
  final TextEditingController _amountBaseController =
      TextEditingController(text: '0');
  final TextEditingController _amountQuoteController =
      TextEditingController(text: '0');
  FocusNode _focusBase = new FocusNode();
  FocusNode _focusQuote = new FocusNode();
  TokensHelper tokenHelper = TokensHelper();
  BalancesHelper balancesHelper = BalancesHelper();
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
  double amountToUSD = 0;
  double amountFromUSD = 0;
  double amountUSD = 0;
  bool isErrorBalance = false;
  bool isEnoughBalance = false;
  bool isNotEmptyAmountQuote = false;
  bool isNotEmptyAmountBase = false;
  int balanceFrom = 0;
  int balanceTo = 0;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  double minShareOfPool = 0.00000001;

  bool isShowDetails = true;
  String rateBalanceFromUsd = '';
  String rateBalanceToUsd = '';

  @override
  void dispose() {
    _amountBaseController.dispose();
    _amountQuoteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountBaseController.addListener(() {
      if (_amountBaseController.text == '') {
        setState(() {
          isNotEmptyAmountBase = false;
        });
      } else {
        isNotEmptyAmountBase = true;
      }
    });
    _amountQuoteController.addListener(() {
      if (_amountQuoteController.text == '') {
        setState(() {
          isNotEmptyAmountQuote = false;
        });
      } else {
        isNotEmptyAmountQuote = true;
      }
    });
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
    return ScaffoldWrapper(builder: (
      BuildContext context,
      bool isFullScreen,
      TransactionState transactionState,
    ) {
      return Scaffold(
        drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
        endDrawer: isFullScreen ? null : AccountDrawer(
          width: buttonSmallWidth,
        ),
        appBar: isFullScreen ? null : NewMainAppBar(
          isShowLogo: false,
        ),
        body: Container(
          padding: EdgeInsets.only(
            top: 22,
            bottom: 22,
            left: 16,
            right: 16,
          ),
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
          child: _buildBody(context, transactionState, isFullScreen),
        ),
      );
    });
  }

  Widget _buildBody(context, transactionState, isFullScreen) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    double arrowRotateDeg = isShowDetails ? 180.0 : 0.0;
    return BlocBuilder<TokensCubit, TokensState>(
      builder: (tokenContext, tokensState) {
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
                var baseBalance = List.from(
                    accountState.activeAccount!.balanceList!.where((element) =>
                        element.token == widget.assetPair.tokenA))[0];
                var quoteBalance = List.from(
                    accountState.activeAccount!.balanceList!.where((element) =>
                        element.token == widget.assetPair.tokenB))[0];
                isErrorBalance = balanceA > baseBalance.balance ||
                    balanceB > quoteBalance.balance;
              } catch (err) {
                isErrorBalance = true;
              }

              return StretchBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PageTitle(
                            title: 'Set the amount',
                            isFullScreen: isFullScreen,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          AmountField(
                            account: accountState.activeAccount,
                            type: TxType.addLiq,
                            suffix: balancesHelper.numberStyling(amountFromUSD,
                                fixedCount: 2, fixed: true),
                            available:
                                getAvailableAmount(accountState, assetFrom),
                            onAssetSelect: (asset) {},
                            onChanged: (value) {
                              try {
                                var amountFrom = tokensHelper.getAmountByUsd(
                                  tokensCubit.state.tokensPairs!,
                                  double.parse(value.replaceAll(',', '.')),
                                  assetFrom,
                                );
                                setState(() {
                                  amountFromUSD = amountFrom;
                                  amountToUSD = amountFromUSD;
                                  onChanged(
                                    _amountQuoteController,
                                    value,
                                    widget.assetPair.reserveBDivReserveA!,
                                    tokensState,
                                  );
                                });
                              } catch (err) {
                                print(err);
                              }
                            },
                            controller: _amountBaseController,
                            selectedAsset: TokensModel(
                              name: assetFrom,
                              symbol: assetFrom,
                            ),
                            assets: [],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          AmountField(
                            account: accountState.activeAccount,
                            type: TxType.addLiq,
                            isAvailableTo: false,
                            suffix: balancesHelper.numberStyling(amountToUSD,
                                fixedCount: 2, fixed: true),
                            available:
                                getAvailableAmount(accountState, assetTo),
                            onAssetSelect: (asset) {},
                            onChanged: (value) {
                              try {
                                var amountTo = tokensHelper.getAmountByUsd(
                                  tokensCubit.state.tokensPairs!,
                                  double.parse(value.replaceAll(',', '.')),
                                  assetTo,
                                );
                                setState(() {
                                  amountToUSD = amountTo;
                                  amountFromUSD = amountToUSD;
                                  onChanged(
                                    _amountBaseController,
                                    value,
                                    widget.assetPair.reserveADivReserveB!,
                                    tokensState,
                                  );
                                });
                              } catch (err) {
                                print(err);
                              }
                            },
                            controller: _amountQuoteController,
                            selectedAsset: TokensModel(
                              name: assetTo,
                              symbol: assetTo,
                            ),
                            assets: [],
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rate',
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
                                                '1 $assetFrom = ${widget.assetPair.reserveBDivReserveA!.toStringAsFixed(4)} $assetTo',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 12,
                                                ),
                                          ),
                                          TextSpan(
                                              text: ' (\$$rateBalanceFromUsd)',
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
                                                  )),
                                        ]),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                            text:
                                                '1 $assetTo = ${widget.assetPair.reserveADivReserveB!.toStringAsFixed(4)} $assetFrom',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5!
                                                .copyWith(
                                                  fontSize: 12,
                                                ),
                                          ),
                                          TextSpan(
                                              text: ' (\$$rateBalanceToUsd)',
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
                                                  )),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 104,
                            child: FlatButton(
                              title: 'Cancel',
                              isPrimary: false,
                              callback: () {
                                NavigatorService.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 104,
                            child: NewPrimaryButton(
                              title: 'Add',
                              callback: isValidAmount()
                                  ? isErrorBalance || isDisableSubmit(context)
                                      ? () {
                                          setState(() {
                                            isEnoughBalance = true;
                                          });
                                          showSnackBar(
                                            context,
                                            title: 'Insufficient funds!',
                                            color: AppColors.txStatusError
                                                .withOpacity(0.1),
                                            prefix: Icon(
                                              Icons.close,
                                              color: AppColors.txStatusError,
                                            ),
                                          );
                                        }
                                      : () {
                                          if (transactionState
                                              is! TransactionLoadingState) {
                                            NavigatorService.push(context, LiquidityConfirmation(
                                                assetPair:
                                                widget.assetPair,
                                                baseAmount: double.parse(
                                                    _amountBaseController
                                                        .text
                                                        .replaceAll(
                                                        ',', '.')),
                                                quoteAmount: double.parse(
                                                    _amountQuoteController
                                                        .text
                                                        .replaceAll(
                                                        ',', '.')),
                                                shareOfPool:
                                                shareOfPool,
                                                amountUSD: amountUSD,
                                                balanceUSD: balanceUSD,
                                                balanceA: balanceA,
                                                balanceB: balanceB,
                                                amount: amount));
                                          } else {
                                            showSnackBar(
                                              context,
                                              title:
                                                  'Please wait for the previous '
                                                  'transaction',
                                              color: AppColors.txStatusError
                                                  .withOpacity(0.1),
                                              prefix: Icon(
                                                Icons.close,
                                                color: AppColors.txStatusError,
                                              ),
                                            );
                                          }
                                        }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

    var rateFrom = tokensHelper.getAmountByUsd(
      tokensState.tokensPairs,
      1,
      widget.assetPair.tokenA!,
    );
    var rateTo = tokensHelper.getAmountByUsd(
      tokensState.tokensPairs,
      1,
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
      rateBalanceFromUsd = rateFrom.toStringAsFixed(4);
      rateBalanceToUsd = rateTo.toStringAsFixed(4);
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

  double getAvailableAmount(accountState, assetCode) {
    int amount = 0;
    accountState.activeAccount.balanceList!.forEach((balance) {
      if (balance.token == assetCode && !balance.isHidden) {
        amount = balance.balance!;
      }
    });
    if (amount < 0) {
      amount = 0;
    }

    return convertFromSatoshi(amount);
  }

  bool isDisableSubmit(context) {
    int amountFrom = convertToSatoshi(
        double.parse(_amountBaseController.text.replaceAll(',', '.')));
    int amountTo = convertToSatoshi(
        double.parse(_amountQuoteController.text.replaceAll(',', '.')));

    bool returnValue = balanceFrom == 0 ||
        balanceTo == 0 ||
        amountFrom > balanceFrom ||
        amountTo > balanceTo;

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
    print(controller.text);
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

  bool isValidAmount() {
    return double.tryParse(_amountBaseController.text) != null &&
        double.tryParse(_amountBaseController.text) != 0.0 &&
        double.tryParse(_amountQuoteController.text) != null &&
        double.tryParse(_amountQuoteController.text) != 0.0 &&
        _amountBaseController.text.isNotEmpty &&
        _amountQuoteController.text.isNotEmpty &&
        isNotEmptyAmountBase &&
        isNotEmptyAmountQuote;
  }
}
