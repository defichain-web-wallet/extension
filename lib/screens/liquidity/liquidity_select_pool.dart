import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/lm/lm_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/token/lp_pool_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_confirmation.dart';
import 'package:defi_wallet/widgets/refactoring/fields/amount_field.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:defi_wallet/models/focus_model.dart';

class LiquiditySelectPool extends StatefulWidget {
  final LmPoolModel assetPair;

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
  List<BalanceModel> balances = [];
  LmCubit? lmCubit;

  @override
  void dispose() {
    _amountBaseController.dispose();
    _amountQuoteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    lmCubit = BlocProvider.of<LmCubit>(context);
    balances = lmCubit!.getBalances(widget.assetPair, context);
    lmCubit!.getAvailableBalances(widget.assetPair, context);
    balance = lmCubit!.getPoolBalance(widget.assetPair, context);
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
    _focusBase.addListener(onFocusBaseField);
    _focusQuote.addListener(onFocusQuoteField);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _setShareOfPool(lmCubit!);
      _setAmount();
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
              bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
              bottomRight: Radius.circular(isFullScreen ? 20 : 0),
            ),
          ),
          child: _buildBody(context, transactionState, isFullScreen),
        ),
      );
    });
  }

  Widget _buildBody(context, transactionState, isFullScreen) {
    double arrowRotateDeg = isShowDetails ? 180.0 : 0.0;
              assetFrom = widget.assetPair.tokens[0].symbol;
              assetTo =  widget.assetPair.tokens[1].symbol;
                // if (el.token == widget.assetPair.symbol!) {
                //   balance = el.balance!;
                // }
                // if (el.token == assetFrom) {
                //   balanceFrom = el.balance!;
                // }
                // if (el.token == assetTo) {
                //   balanceTo = el.balance!;
                // }

              // try {
              //   var baseBalance = List.from(
              //       accountState.activeAccount!.balanceList!.where((element) =>
              //           element.token == widget.assetPair.tokens[0]))[0];
              //   var quoteBalance = List.from(
              //       accountState.activeAccount!.balanceList!.where((element) =>
              //           element.token == widget.assetPair.tokens[1]))[0];
              //   isErrorBalance = balanceA > baseBalance.balance ||
              //       balanceB > quoteBalance.balance;
              // } catch (err) {
              //   isErrorBalance = true;
              // }
    return BlocBuilder<LmCubit, LmState>(
        builder: (lmContext, lmState) => StretchBox(
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
                            type: TxType.addLiq,
                            // suffix: balancesHelper.numberStyling(amountFromUSD,
                            //     fixedCount: 2, fixed: true),
                            available:
                                lmState.status == LmStatusList.success ? lmState.availableBalances![0] : 0,
                            onAssetSelect: (asset) {},
                            onChanged: (value) {
                              // try {
                              //   var amountFrom = tokensHelper.getAmountByUsd(
                              //     tokensCubit.state.tokensPairs!,
                              //     double.parse(value.replaceAll(',', '.')),
                              //     assetFrom,
                              //   );
                              //   setState(() {
                              //     amountFromUSD = amountFrom;
                              //     amountToUSD = amountFromUSD;
                                  onChanged(
                                    _amountQuoteController,
                                    value,
                                    widget.assetPair.percentages![1] / widget.assetPair.percentages![0],
                                      lmCubit!
                                  );
                              //   });
                              // } catch (err) {
                              //   print(err);
                              // }
                            },
                            controller: _amountBaseController,
                            assets: [balances[0]],
                            balance: balances[0],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          AmountField(
                            type: TxType.addLiq,
                            isAvailableTo: false,
                            // suffix: balancesHelper.numberStyling(amountToUSD,
                            //     fixedCount: 2, fixed: true),
                            available:
                            lmState.status == LmStatusList.success ? lmState.availableBalances![1] : 0,
                            onAssetSelect: (asset) {},
                            onChanged: (value) {
                              // try {
                              //   var amountTo = tokensHelper.getAmountByUsd(
                              //     tokensCubit.state.tokensPairs!,
                              //     double.parse(value.replaceAll(',', '.')),
                              //     assetTo,
                              //   );
                              //   setState(() {
                              //     amountToUSD = amountTo;
                              //     amountFromUSD = amountToUSD;
                                  onChanged(
                                    _amountBaseController,
                                    value,
                                    widget.assetPair.percentages![0] / widget.assetPair.percentages![1],
                                    lmCubit!,
                                  );
                              //   });
                              // } catch (err) {
                              //   print(err);
                              // }
                            },
                            controller: _amountQuoteController,
                            assets: [balances[1]],
                            balance: balances[1],
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
                                                '1 $assetFrom = ${(widget.assetPair.percentages![1]/widget.assetPair.percentages![0]).toStringAsFixed(4)} $assetTo',
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
                                                '1 $assetTo = ${(widget.assetPair.percentages![0]/widget.assetPair.percentages![1]).toStringAsFixed(4)} $assetFrom',
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
              ));
  }

  void _setAmount() {
    _setBalances();
    // _setBalanceAndAmountUSD(tokensState);
    setState(() {
      amount = double.parse(_amountBaseController.text.replaceAll(',', '.')) /
          (widget.assetPair.percentages![0] / widget.assetPair.percentages![2]);
    });
  }

  void _setBalances() {
    setState(() {
      balanceA = (convertFromSatoshi(balance) / widget.assetPair.percentages![2]) *
          widget.assetPair.percentages![0];
      balanceB = (convertFromSatoshi(balance) / widget.assetPair.percentages![2]) *
          widget.assetPair.percentages![1];
    });
  }
  //
  void _setShareOfPool(LmCubit lmCubit) {
    setState(() {
      shareOfPool = lmCubit.calculateShareOfPool(convertToSatoshi(double.parse(_amountBaseController.text.replaceAll(',', '.'))), 100, widget.assetPair);
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
    double amountFrom =
        double.parse(_amountBaseController.text.replaceAll(',', '.'));
    double amountTo =
        double.parse(_amountQuoteController.text.replaceAll(',', '.'));

    return lmCubit!.state.availableBalances![0] == 0 ||
    lmCubit!.state.availableBalances![1] == 0 ||
        amountFrom > lmCubit!.state.availableBalances![0] ||
        amountTo > lmCubit!.state.availableBalances![1];
  }


  double getAmountByFee(int balance, String token) {
    int fee = token == 'DFI' ? 21000 : 0;
    int amount = balance - fee;
    return (amount > 0) ? convertFromSatoshi(balance - fee) : 0.0;
  }

  onChanged(TextEditingController controller, String value, double reserve, LmCubit lmCubit) {
    print(controller.text);
    try {
      double baseAmount = double.parse(value.replaceAll(',', '.'));
      if (!(baseAmount * reserve).isNaN) {
        controller.text = (baseAmount * reserve).toStringAsFixed(8);
        _setShareOfPool(lmCubit);
      }
      _setAmount();
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
