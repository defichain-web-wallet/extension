import 'dart:async';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/dex/widgets/slippage_button.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/bloc/dex/dex_cubit.dart';
import 'package:defi_wallet/bloc/dex/dex_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/screens/dex/review_swap_screen.dart';
import 'package:defi_wallet/screens/dex/swap_status.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './widgets/amount_selector_field.dart';
import './widgets/swap_price_details.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final TextEditingController amountFromController = TextEditingController();
  final TextEditingController amountToController = TextEditingController();
  final TextEditingController slippageController = TextEditingController();
  final GlobalKey<AssetSelectState> selectKeyFrom =
      GlobalKey<AssetSelectState>();
  final GlobalKey<PendingButtonState> pendingButton =
      GlobalKey<PendingButtonState>();
  final GlobalKey<AssetSelectState> selectKeyTo = GlobalKey<AssetSelectState>();

  TransactionService transactionService = TransactionService();
  BalancesHelper balancesHelper = BalancesHelper();
  LockHelper lockHelper = LockHelper();
  TokensHelper tokensHelper = TokensHelper();
  TestPoolSwapModel dexModel = TestPoolSwapModel();
  FocusNode focusFrom = new FocusNode();
  FocusNode focusTo = new FocusNode();
  FocusModel focusAmountFromModel = new FocusModel();
  FocusModel focusAmountToModel = new FocusModel();
  Timer? debounce;

  List<String> tokensForSwap = [];
  List<String> assets = [];
  String assetFrom = '';
  String assetTo = '';
  String address = '';
  String swapFieldMsg = '';
  int iteratorUpdate = 0;
  bool inputFromFocus = false;
  bool inputToFocus = false;
  bool isFailed = false;
  bool isBalanceError = false;
  bool waitingTo = true;
  bool waitingFrom = true;
  bool isEnable = true;
  bool isShowSlippageField = false;
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;
  double slippage = 0.03; //3%
  String stabilizationFee = '';

  @override
  void initState() {
    super.initState();
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);

    focusTo.addListener(onFocusToChange);
    focusFrom.addListener(onFocusFromChange);

    tokensCubit.loadTokens();
  }

  @override
  void dispose() {
    focusTo.unfocus();
    focusFrom.unfocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DexCubit, DexState>(builder: (dexContext, dexState) {
        DexCubit dexCubit = BlocProvider.of<DexCubit>(dexContext);

        return BlocBuilder<AccountCubit, AccountState>(
            builder: (accountContext, accountState) {
          if (accountState.activeToken!.contains('-')) {
            assetFrom = TokensHelper.DefiAccountSymbol;
          }
          return BlocBuilder<TokensCubit, TokensState>(
              builder: (tokensContext, tokensState) {
            if (tokensState.status == TokensStatusList.success) {
              if (accountState.status == AccountStatusList.success) {
                stateInit(accountState, dexState, tokensState);
                if (dexState is DexLoadedState) {
                  dexInit(dexState);
                }
                if (iteratorUpdate == 0) {
                  iteratorUpdate++;
                  dexCubit.updateDex(assetFrom, assetTo, 0, 0, address,
                      accountState.activeAccount!.addressList!, tokensState);
                }
              }
            }

            return BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, transactionState) => ScaffoldConstrainedBox(
                child: GestureDetector(
                  child: LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth < ScreenSizes.medium) {
                      return Scaffold(
                        appBar: MainAppBar(
                            title: 'Decentralized Exchange',
                            hideOverlay: () => hideOverlay(),
                            isShowBottom:
                                !(transactionState is TransactionInitialState),
                            height:
                                !(transactionState is TransactionInitialState)
                                    ? toolbarHeightWithBottom
                                    : toolbarHeight),
                        body: _buildBody(context, dexState, dexCubit,
                            accountState, tokensState, transactionState),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: Scaffold(
                          body: _buildBody(context, dexState, dexCubit,
                              accountState, tokensState, transactionState,
                              isCustomBgColor: true),
                          appBar: MainAppBar(
                            title: 'Decentralized Exchange',
                            hideOverlay: () => hideOverlay(),
                            isShowBottom:
                                !(transactionState is TransactionInitialState),
                            height:
                                !(transactionState is TransactionInitialState)
                                    ? toolbarHeightWithBottom
                                    : toolbarHeight,
                            isSmall: true,
                          ),
                        ),
                      );
                    }
                  }),
                  onTap: () => hideOverlay(),
                ),
              ),
            );
          });
        });
      });

  // TODO: need to review for refactoring
  Widget _buildBody(
      context, dexState, dexCubit, accountState, tokensState, transactionState,
      {isCustomBgColor = false}) {
    bool isShowStabilizationFee = assetFrom == 'DUSD' && assetTo == 'DFI' ||
        assetFrom == 'DUSD' && assetTo == 'USDT' ||
        assetFrom == 'DUSD' && assetTo == 'USDC';
    if (tokensState.status == TokensStatusList.loading) {
      return Container(
        child: Center(
          child: Loader(),
        ),
      );
    } else {
      if (dexState is DexErrorState) {
        return Container(
          child: Center(
            child: ErrorPlaceholder(
              message: 'API error',
              description: 'Please change the API on settings and try again',
            ),
          ),
        );
      } else {
        if (isShowStabilizationFee) {
          try {
            AssetPairModel targetPair = tokensState.tokensPairs
                .firstWhere((e) => e.tokenA == 'DUSD' && e.tokenB == 'DFI');
            stabilizationFee = balancesHelper.numberStyling(
                ((1 / (1 - targetPair.fee!)) - 1) * 100,
                fixedCount: 2,
                fixed: true);
          } catch (err) {
            print(err);
          }
        }

        return Container(
          color:
              isCustomBgColor ? Theme.of(context).dialogBackgroundColor : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmountSelectorField(
                        label: 'Swap from',
                        selectedAsset: assetFrom,
                        assets: assets,
                        selectKey: selectKeyFrom,
                        amountController: amountFromController,
                        onAnotherSelect: hideOverlay,
                        onSelect: (String asset) {
                          onSelectFromAsset(
                              asset, tokensState, accountState, dexCubit);
                        },
                        onChanged: (value) => onChangeFromAsset(
                            value, accountState, dexCubit, tokensState),
                        focusNode: focusFrom,
                        focusModel: focusAmountFromModel,
                        suffixIcon: Container(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            right: 6,
                          ),
                          child: SizedBox(
                            width: 40,
                            child: TextButton(
                              child:
                                  Text('MAX', style: TextStyle(fontSize: 10)),
                              onPressed: () {
                                double maxAmount = getAvailableAmount(
                                    accountState, assetFrom, dexState);
                                amountFromController.text =
                                    maxAmount.toString();
                                onChangeFromAsset(amountFromController.text,
                                    accountState, dexCubit, tokensState);
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        swapFieldMsg,
                        style: Theme.of(context).textTheme.headline4!.apply(
                            color: Theme.of(context)
                                .textTheme
                                .headline4!
                                .color!
                                .withOpacity(0.5)),
                      ),
                      SizedBox(height: 14),
                      AmountSelectorField(
                        label: 'Swap to',
                        selectedAsset: assetTo,
                        assets: tokensForSwap,
                        selectKey: selectKeyTo,
                        amountController: amountToController,
                        onAnotherSelect: hideOverlay,
                        onSelect: (String asset) {
                          onSelectToAsset(
                              asset, tokensState, accountState, dexCubit);
                        },
                        onChanged: (value) => onChangeToAsset(
                            value, accountState, dexCubit, tokensState),
                        focusNode: focusTo,
                        focusModel: focusAmountToModel,
                        suffixIcon: Container(
                          padding: EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            right: 6,
                          ),
                          child: SizedBox(
                            width: 40,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Slippage tolerance',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            isShowSlippageField
                                ? SizedBox(
                                    height: 30,
                                    width: 140,
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'(^-?\d*\.?d*\,?\d*)')),
                                      ],
                                      controller: slippageController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.all(8),
                                        hintText: 'Type in percent..',
                                        suffixIcon: IconButton(
                                          splashRadius: 16,
                                          icon: Icon(
                                            Icons.clear,
                                            size: 14,
                                          ),
                                          onPressed: () => setState(() {
                                            slippage = 0.03;
                                            isShowSlippageField = false;
                                          }),
                                        ),
                                      ),
                                      onChanged: (String value) {
                                        setState(() {
                                          try {
                                            slippage =
                                                double.parse(value) / 100;
                                          } catch (err) {
                                            slippage = 0.03;
                                          }
                                        });
                                      },
                                    ),
                                  )
                                : Container(
                                    child: Row(
                                      children: [
                                        SlippageButton(
                                          label: '0.5%',
                                          isActive: slippage == 0.005,
                                          callback: () =>
                                              setState(() => slippage = 0.005),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        SlippageButton(
                                          label: '1%',
                                          isActive: slippage == 0.01,
                                          callback: () =>
                                              setState(() => slippage = 0.01),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        SlippageButton(
                                          label: '3%',
                                          isActive: slippage == 0.03,
                                          callback: () =>
                                              setState(() => slippage = 0.03),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        SlippageButton(
                                          label: '5%',
                                          isActive: slippage == 0.05,
                                          callback: () =>
                                              setState(() => slippage = 0.05),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        SizedBox(
                                          height: 22,
                                          width: 30,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(0),
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                            ),
                                            onPressed: () => setState(() =>
                                                isShowSlippageField = true),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                          ],
                        ),
                      ),
                      SizedBox(height: 22),
                      // TODO: must be constant so as not to be updated
                      SwapPriceDetails(
                        feeDetails: createFeeString(dexState),
                        priceFromDetails:
                            createPriceString(dexState, assetFrom, assetTo),
                        priceToDetails:
                            createPriceString(dexState, assetTo, assetFrom),
                      ),
                      if (isShowStabilizationFee)
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SvgPicture.asset(
                                  'assets/important.svg',
                                  height: 20,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'There is currently a high DEX stabilization fee imposed on DUSD-DFI, DUSD-USDT, and DUSD-USDC swaps due to DFIP 2206-D and DFIP 2207-B. In order to execute the swap, you need to set your Slippage to at least $stabilizationFee%',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(fontSize: 13, height: 1.1),
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        PendingButton(
                          'Review Swap',
                          isCheckLock: false,
                          key: pendingButton,
                          callback: !isDisableSubmit()
                              ? (parent) => submitReviewSwap(parent,
                                  accountState, transactionState, context)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  stateInit(accountState, dexState, tokensState) {
    getFieldMsg(accountState, dexState);
    accountState.activeAccount.balanceList!.forEach((el) {
      if (tokensState.tokensForSwap[el.token] != null &&
          !assets.contains(el.token) &&
          !el.isHidden) {
        assets.add(el.token!);
      }
    });
    assetFrom = (assetFrom.isEmpty) ? accountState.activeToken : assetFrom;
    address = accountState.activeAccount.getActiveAddress(isChange: false);
    tokensForSwap = tokensState.tokensForSwap[assetFrom].cast<String>();
    assetTo = (assetTo.isEmpty || !tokensForSwap.contains(assetTo))
        ? tokensForSwap[0]
        : assetTo;
  }

  dexInit(dexState) {
    if (waitingFrom && waitingTo) {
      if (dexState.dexModel.amountFrom != null) {
        amountFromController.text = dexState.dexModel.amountFrom.toString();
        amountFromController.selection = TextSelection.fromPosition(
            TextPosition(offset: amountFromController.text.length));
      }
      if (dexState.dexModel.amountTo != null) {
        amountToController.text = dexState.dexModel.amountTo.toString();
        amountToController.selection = TextSelection.fromPosition(
            TextPosition(offset: amountToController.text.length));
      }
    }
  }

  bool isEnoughBalance(state) {
    int balance = state.activeAccount.balanceList!
        .firstWhere((el) => el.token! == assetFrom && !el.isHidden)
        .balance!;
    return convertFromSatoshi(balance) <
        double.parse(amountFromController.text);
  }

  submitReviewSwap(parent, state, transactionState, context) {
    hideOverlay();
    if (transactionState is TransactionLoadingState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wait for the previous transaction to complete',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
      return;
    }
    if (isEnoughBalance(state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient funds',
            style: Theme.of(context).textTheme.headline5,
          ),
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
        ),
      );
      return;
    }
    if (isNumeric(amountFromController.text)) {
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ReviewSwapScreen(
              assetFrom,
              assetTo,
              double.parse(amountFromController.text),
              double.parse(amountToController.text),
              slippage,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    }
  }

  onSelectFromAsset(asset, tokensState, accountState, dexCubit) {
    tokensForSwap = tokensState.tokensForSwap[asset].cast<String>();
    assetTo = (assetTo.isEmpty || !tokensForSwap.contains(assetTo))
        ? tokensForSwap[0]
        : assetTo;
    setState(() => {assetFrom = asset, assetTo = assetTo});
    if (assetFrom == assetTo) {
      amountFromController.text = amountToController.text;
    } else {
      dexCubit.updateDex(
          assetFrom,
          assetTo,
          null,
          double.parse(amountToController.text),
          address,
          accountState.activeAccount.addressList!,
          tokensState);
    }
  }

  onSelectToAsset(asset, tokensState, accountState, dexCubit) {
    setState(() => {assetTo = asset});
    if (assetFrom == assetTo) {
      amountFromController.text = amountToController.text;
    } else {
      dexCubit.updateDex(
          assetFrom,
          assetTo,
          null,
          double.parse(amountToController.text),
          address,
          accountState.activeAccount.addressList!,
          tokensState);
    }
  }

  onChangeFromAsset(value, accountState, dexCubit, tokensState) {
    String valueFormat = value.replaceAll(',', '.');
    if (isFailed) {
      setState(() {
        isFailed = false;
      });
    }
    waitingFrom = false;
    amountFromController.text = valueFormat;
    amountFromController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountFromController.text.length));
    onFromInputChanged(valueFormat, dexCubit, accountState, tokensState);
  }

  onChangeToAsset(value, accountState, dexCubit, tokensState) {
    String valueFormat = value.replaceAll(',', '.');
    if (isFailed) {
      setState(() {
        isFailed = false;
      });
    }
    waitingTo = false;
    amountToController.text = valueFormat;
    amountToController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountToController.text.length));
    onToInputChanged(valueFormat, dexCubit, accountState, tokensState);
  }

  getFieldMsg(accountState, dexState) {
    var availableAmount = getAvailableAmount(accountState, assetFrom, dexState);
    swapFieldMsg =
        '${balancesHelper.numberStyling(availableAmount)} $assetFrom available to swap';
  }

  bool isNumeric(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(string);
  }

  String createPriceString(dexState, tokenFrom, tokenTo) {
    double price = 0;
    if (dexState is DexLoadedState) {
      if (dexState.dexModel.tokenFrom == tokenFrom) {
        price = dexState.dexModel.priceFrom!;
      } else {
        price = dexState.dexModel.priceTo!;
      }
    }
    return '${balancesHelper.numberStyling(price, fixedCount: 8, fixed: true)} ${tokensHelper.getTokenWithPrefix(tokenTo)} per ${tokensHelper.getTokenWithPrefix(tokenFrom)}';
  }

  String createFeeString(dexState) {
    var fee = 0;
    if (dexState is DexLoadedState) {
      if (dexState.dexModel.fee != null) {
        fee = dexState.dexModel.fee!;
      }
    }
    return '${balancesHelper.numberStyling(convertFromSatoshi(fee))} DFI';
  }

  onFromInputChanged(String query, dexCubit, accountState, tokensState) {
    double amount = (query == '') ? 0 : double.parse(query);

    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      waitingFrom = true;
      if (assetFrom == assetTo) {
        amountToController.text = amountFromController.text;
      } else {
        dexCubit.updateDex(assetFrom, assetTo, amount, null, address,
            accountState.activeAccount.addressList!, tokensState);
      }
      //TODO: add validation
    });
  }

  onToInputChanged(String query, dexCubit, accountState, tokensState) {
    double amount = (query == '') ? 0 : double.parse(query);
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      waitingTo = true;
      if (assetFrom == assetTo) {
        amountFromController.text = amountToController.text;
      } else {
        dexCubit.updateDex(assetFrom, assetTo, null, amount, address,
            accountState.activeAccount.addressList!, tokensState);
      }
    });
  }

  onFocusToChange() {
    hideOverlay();
    setState(() {
      inputToFocus = focusTo.hasFocus;
    });
    amountToController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountToController.text.length));
  }

  onFocusFromChange() {
    hideOverlay();
    setState(() {
      inputFromFocus = focusFrom.hasFocus;
    });
    amountFromController.selection = TextSelection.fromPosition(
        TextPosition(offset: amountFromController.text.length));
  }

  hideOverlay() {
    try {
      selectKeyFrom.currentState!.hideOverlay();
    } catch (_) {}
    try {
      selectKeyTo.currentState!.hideOverlay();
    } catch (_) {}
  }

  double getAmountByFee(int balance, String token) {
    int fee = token == 'DFI' ? 12000 : 0;
    int amount = balance - fee;
    return (amount > 0) ? convertFromSatoshi(balance - fee) : 0.0;
  }

  double getAvailableAmount(accountState, assetFrom, dexState) {
    int amount = 0;
    int fee = 0;
    if (accountState.status == AccountStatusList.success &&
        dexState is DexLoadedState) {
      if (dexState.dexModel.fee != null) {
        fee = dexState.dexModel.fee!;
      }
      accountState.activeAccount.balanceList!.forEach((balance) {
        if (balance.token == assetFrom && !balance.isHidden) {
          amount = balance.balance!;
        }
        if (assetFrom == 'DFI' && !balance.isHidden) {
          amount -= fee;
        }
      });
    }
    if (amount < 0) {
      amount = 0;
    }

    return convertFromSatoshi(amount);
  }

  bool isDisableSubmit() {
    try {
      return double.parse(amountFromController.text) <= 0;
    } catch (err) {
      return false;
    }
  }
}
