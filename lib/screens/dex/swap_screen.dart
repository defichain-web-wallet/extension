import 'dart:async';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/screens/dex/widgets/slippage_button.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select_swap.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/password_bottom_sheet.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/bloc/dex/dex_cubit.dart';
import 'package:defi_wallet/bloc/dex/dex_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/screens/dex/review_swap_screen.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:url_launcher/url_launcher.dart';
import './widgets/amount_selector_field.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final TextEditingController amountFromController = TextEditingController();
  final TextEditingController amountToController = TextEditingController();
  final TextEditingController slippageController = TextEditingController();
  final GlobalKey<AssetSelectSwapState> selectKeyFrom =
      GlobalKey<AssetSelectSwapState>();
  final GlobalKey<PendingButtonState> pendingButton =
      GlobalKey<PendingButtonState>();
  final GlobalKey<AssetSelectSwapState> selectKeyTo =
      GlobalKey<AssetSelectSwapState>();

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
  late AccountModel accountFrom;
  late AccountModel accountTo;
  String assetFrom = '';
  String assetTo = '';
  String address = '';
  String swapFromMsg = '';
  String swapToMsg = '';
  int iteratorUpdate = 0;
  int iterator = 0;
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
  String amountFromInUsd = '0.0';
  String amountToInUsd = '0.0';

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
        BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
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
                  accountFrom = accountState.accounts![0];
                  accountTo = accountState.accounts![0];
                  bitcoinCubit
                      .loadAvailableBalance(accountFrom.bitcoinAddress!);
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
                          title: 'Swap',
                          hideOverlay: () => hideOverlay(),
                          isShowBottom:
                              !(transactionState is TransactionInitialState),
                          height: !(transactionState is TransactionInitialState)
                              ? toolbarHeightWithBottom
                              : toolbarHeight,
                          action: Container(),
                        ),
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
                            title: 'Swap',
                            hideOverlay: () => hideOverlay(),
                            isShowBottom:
                                !(transactionState is TransactionInitialState),
                            height:
                                !(transactionState is TransactionInitialState)
                                    ? toolbarHeightWithBottom
                                    : toolbarHeight,
                            isSmall: true,
                            action: Container(),
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
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
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
          color: Theme.of(context).dialogBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          child: Center(
            child: StretchBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AmountSelectorField(
                            isSwap: true,
                            isBorder: isCustomBgColor,
                            label: 'Swap from',
                            selectedAsset: assetFrom,
                            account: accountFrom,
                            assets: assets,
                            selectSwapKey: selectKeyFrom,
                            amountController: amountFromController,
                            onAnotherSelect: hideOverlay,
                            amountInUsd: amountFromInUsd,
                            onSelect: (String asset) {
                              onSelectFromAsset(
                                  asset, tokensState, accountState, dexCubit);
                            },
                            onChanged: (value) {
                              calculateSecondAmount(value, tokensState);
                              onChangeFromAsset(value, accountState, dexState,
                                  dexCubit, tokensState);
                            },
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
                                child: Container(
                                  color: Theme.of(context).cardColor,
                                  child: TextButton(
                                    child: Text('MAX',
                                        style: TextStyle(fontSize: 10)),
                                    onPressed: () {
                                      double maxAmount = getAvailableAmount(
                                          accountState, assetFrom, dexState);
                                      amountFromController.text =
                                          maxAmount.toString();
                                      onChangeFromAsset(
                                          amountFromController.text,
                                          accountState,
                                          dexState,
                                          dexCubit,
                                          tokensState);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            onChangeAccount: (index) {
                              BitcoinCubit bitcoinCubit =
                                  BlocProvider.of<BitcoinCubit>(context);
                              setState(() {
                                accountFrom = accountState.accounts[index];
                                bitcoinCubit.loadAvailableBalance(
                                    accountFrom.bitcoinAddress!);
                              });
                            },
                          ),
                          SizedBox(height: 6),
                          InkWell(
                            onTap: () => putAvailableBalance(
                              assetFrom,
                              amountFromController,
                              tokensState,
                              accountState,
                              dexState,
                            ),
                            child: Text(
                              'Available balance: $swapFromMsg',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4!
                                  .apply(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .color!
                                          .withOpacity(0.5)),
                            ),
                          ),
                          SizedBox(height: 30),
                          AmountSelectorField(
                            isSwap: true,
                            isBorder: isCustomBgColor,
                            label: 'Swap to',
                            selectedAsset: assetTo,
                            account: accountTo,
                            assets: tokensForSwap,
                            selectSwapKey: selectKeyTo,
                            amountController: amountToController,
                            onAnotherSelect: hideOverlay,
                            amountInUsd: amountToInUsd,
                            onSelect: (String asset) {
                              onSelectToAsset(
                                  asset, tokensState, accountState, dexCubit);
                            },
                            onChanged: (value) {
                              try {
                                var amount = tokensHelper.getAmountByUsd(
                                  tokensCubit.state.tokensPairs!,
                                  double.parse(value.replaceAll(',', '.')),
                                  assetTo,
                                );
                                setState(() {
                                  amountToInUsd = balancesHelper.numberStyling(
                                      amount,
                                      fixedCount: 2,
                                      fixed: true);
                                  if (SettingsHelper.isBitcoin()) {
                                    amountFromInUsd = getUdsAmount(
                                        double.parse(value), tokensState);
                                  } else {
                                    amountFromInUsd = amountToInUsd;
                                  }
                                });
                              } catch (err) {
                                print(err);
                              }
                              onChangeToAsset(value, accountState, dexState,
                                  dexCubit, tokensState);
                            },
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
                            onChangeAccount: (index) {
                              FiatCubit fiatCubit =
                                  BlocProvider.of<FiatCubit>(context);
                              setState(() {
                                accountTo = accountState.accounts[index];
                              });
                              fiatCubit.loadCryptoRoute(accountTo);
                            },
                          ),
                          SizedBox(height: 6),
                          if (!SettingsHelper.isBitcoin())
                            InkWell(
                              onTap: () => putAvailableBalance(
                                assetTo,
                                amountToController,
                                tokensState,
                                accountState,
                                dexState,
                              ),
                              child: Text(
                                'Available balance: $swapToMsg',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .apply(
                                        color: Theme.of(context)
                                            .textTheme
                                            .headline4!
                                            .color!
                                            .withOpacity(0.5)),
                              ),
                            ),
                          SizedBox(height: 24),
                          if (!SettingsHelper.isBitcoin())
                            SizedBox(
                              height: 30,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Slippage tolerance',
                                      style:
                                          Theme.of(context).textTheme.headline2,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: isShowSlippageField
                                        ? Container(
                                            height: 30,
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'(^-?\d*\.?d*\,?\d*)')),
                                              ],
                                              controller: slippageController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    Theme.of(context).cardColor,
                                                hoverColor: Colors.transparent,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color:
                                                          AppTheme.pinkColor),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.all(8),
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
                                                    hideOverlay();
                                                  }),
                                                ),
                                              ),
                                              onChanged: (String value) {
                                                setState(() {
                                                  try {
                                                    slippage =
                                                        double.parse(value) /
                                                            100;
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
                                                Expanded(
                                                  flex: 1,
                                                  child: SlippageButton(
                                                    isFirst: true,
                                                    isBorder: isCustomBgColor,
                                                    label: '0.5%',
                                                    isActive: slippage == 0.005,
                                                    callback: () =>
                                                        setState(() {
                                                      slippage = 0.005;
                                                      hideOverlay();
                                                    }),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: SlippageButton(
                                                    isBorder: isCustomBgColor,
                                                    label: '1%',
                                                    isActive: slippage == 0.01,
                                                    callback: () =>
                                                        setState(() {
                                                      slippage = 0.01;
                                                      hideOverlay();
                                                    }),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: SlippageButton(
                                                    isBorder: isCustomBgColor,
                                                    label: '3%',
                                                    isActive: slippage == 0.03,
                                                    callback: () =>
                                                        setState(() {
                                                      slippage = 0.03;
                                                      hideOverlay();
                                                    }),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: SlippageButton(
                                                    isBorder: isCustomBgColor,
                                                    label: '5%',
                                                    isActive: slippage == 0.05,
                                                    callback: () =>
                                                        setState(() {
                                                      slippage = 0.05;
                                                      hideOverlay();
                                                    }),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 1,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: 20,
                                                    child: TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .cardColor,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        elevation: 2,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                          side: BorderSide(
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 16,
                                                      ),
                                                      onPressed: () =>
                                                          setState(() {
                                                        isShowSlippageField =
                                                            true;
                                                        hideOverlay();
                                                      }),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 22),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        BlocBuilder<FiatCubit, FiatState>(
                            builder: (context, fiatState) {
                          FiatCubit fiatCubit =
                              BlocProvider.of<FiatCubit>(context);
                          if (iterator == 0 && SettingsHelper.isBitcoin()) {
                            fiatCubit.loadCryptoRoute(accountTo);
                            iterator++;
                          }
                          if (fiatState.status == FiatStatusList.success &&
                              SettingsHelper.isBitcoin()) {
                            return Column(
                              children: [
                                if (!fiatState.isKycDataComplete!)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 14.0),
                                    child: InkWell(
                                        onTap: () {
                                          String kycHash = fiatState.kycHash!;
                                          launch(
                                              'https://payment.dfx.swiss/kyc?code=$kycHash');
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text:
                                                'Please complete the KYC process to enable this feature',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3
                                                ?.apply(
                                                    color: AppTheme.pinkColor),
                                          ),
                                        )),
                                  ),
                                PendingButton(
                                  'Next',
                                  isCheckLock: false,
                                  key: pendingButton,
                                  callback: !isDisableSubmit() &&
                                          fiatState.isKycDataComplete!
                                      ? (parent) => submitReviewSwap(
                                            parent,
                                            accountState,
                                            transactionState,
                                            context,
                                            isCustomBgColor,
                                            cryptoRoute: fiatState.cryptoRoute,
                                          )
                                      : null,
                                ),
                              ],
                            );
                          } else {
                            return PendingButton(
                              'Next',
                              isCheckLock: false,
                              key: pendingButton,
                              callback: !isDisableSubmit()
                                  ? (parent) => submitReviewSwap(
                                        parent,
                                        accountState,
                                        transactionState,
                                        context,
                                        isCustomBgColor,
                                      )
                                  : null,
                            );
                          }
                        }),
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

  putAvailableBalance(
    String asset,
    TextEditingController controller,
    TokensState tokensState,
    AccountState accountState,
    DexState dexState,
  ) {
    DexCubit dexCubit = BlocProvider.of<DexCubit>(context);
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    late double balance;
    if (SettingsHelper.isBitcoin()) {
      balance = convertFromSatoshi(bitcoinCubit.state.totalBalance);
      amountFromController.text = balance.toString();
    } else {
      balance = getAvailableAmount(accountState, asset, dexState);
    }

    calculateSecondAmount(balance.toString(), tokensState);
    if (asset == assetFrom) {
      onChangeFromAsset(
          balance.toString(), accountState, dexState, dexCubit, tokensState);
    } else {
      onChangeToAsset(
          balance.toString(), accountState, dexState, dexCubit, tokensState);
    }
  }

  calculateSecondAmount(String value, TokensState tokensState) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    try {
      double dValue = double.parse(value.replaceAll(',', '.'));
      var amount = tokensHelper.getAmountByUsd(
        tokensCubit.state.tokensPairs!,
        dValue,
        assetFrom,
      );
      setState(() {
        amountFromInUsd =
            balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
        if (SettingsHelper.isBitcoin()) {
          amountToInUsd = getUdsAmount(dValue, tokensState);
        } else {
          amountToInUsd = amountFromInUsd;
        }
      });
    } catch (err) {
      print(err);
    }
  }

  stateInit(accountState, dexState, tokensState) {
    getFieldMsg(
      accountState,
      dexState,
    );
    if (SettingsHelper.isBitcoin()) {
      assetFrom = 'BTC';
      assetTo = 'dBTC';
      assets = [];
    } else {
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
    if (SettingsHelper.isBitcoin()) {
      BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
      var amount = convertFromSatoshi(bitcoinCubit.state.totalBalance);
      return amount < double.parse(amountFromController.text);
    }
    int balance = state.activeAccount.balanceList!
        .firstWhere((el) => el.token! == assetFrom && !el.isHidden)
        .balance!;
    return convertFromSatoshi(balance) <
        double.parse(amountFromController.text);
  }

  submitReviewSwap(parent, state, transactionState, context, bool isFullScreen,
      {CryptoRouteModel? cryptoRoute}) async {
    hideOverlay();
    if (SettingsHelper.isBitcoin()) {
      double minDeposit = convertFromSatoshi(cryptoRoute!.minDeposit!);
      if (minDeposit >= double.parse(amountFromController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Min amount must be more than $minDeposit BTC',
              style: Theme.of(context).textTheme.headline5,
            ),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
        return;
      }
    }
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
      if (SettingsHelper.isBitcoin() && cryptoRoute != null) {
        isFullScreen
            ? PasswordBottomSheet.provideWithPasswordFullScreen(
                context, state.activeAccount, (password) async {
                try {
                  BitcoinCubit bitcoinCubit =
                      BlocProvider.of<BitcoinCubit>(context);
                  ECPair keyPair = await HDWalletService()
                      .getKeypairFromStorage(
                          password, state.activeAccount.index!);
                  var tx = await transactionService.createBTCTransaction(
                    keyPair: keyPair,
                    account: state.activeAccount,
                    destinationAddress: cryptoRoute.address!,
                    amount: balancesHelper.toSatoshi(amountFromController.text),
                    satPerByte: bitcoinCubit.state.networkFee!.medium!,
                  );
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            ReviewSwapScreen(
                          assetFrom,
                          assetTo.replaceAll('d', ''),
                          double.parse(amountFromController.text),
                          double.parse(amountToController.text),
                          slippage,
                          btcTx: tx.txLoaderList![0].txHex!,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ));
                } catch (err) {
                  print(err);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      backgroundColor:
                          Theme.of(context).snackBarTheme.backgroundColor,
                    ),
                  );
                }
              })
            : PasswordBottomSheet.provideWithPassword(
                context, state.activeAccount, (password) async {
                try {
                  BitcoinCubit bitcoinCubit =
                      BlocProvider.of<BitcoinCubit>(context);
                  ECPair keyPair = await HDWalletService()
                      .getKeypairFromStorage(
                          password, state.activeAccount.index!);
                  var tx = await transactionService.createBTCTransaction(
                    keyPair: keyPair,
                    account: state.activeAccount,
                    destinationAddress: cryptoRoute.address!,
                    amount: balancesHelper.toSatoshi(amountFromController.text),
                    satPerByte: bitcoinCubit.state.networkFee!.medium!,
                  );
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            ReviewSwapScreen(
                          assetFrom,
                          assetTo.replaceAll('d', ''),
                          double.parse(amountFromController.text),
                          double.parse(amountToController.text),
                          slippage,
                          btcTx: tx.txLoaderList![0].txHex!,
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ));
                } catch (err) {
                  print(err);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      backgroundColor:
                          Theme.of(context).snackBarTheme.backgroundColor,
                    ),
                  );
                }
              });
      } else {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  ReviewSwapScreen(
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

  onChangeFromAsset(value, accountState, dexState, dexCubit, tokensState) {
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
    onFromInputChanged(
        valueFormat, dexState, dexCubit, accountState, tokensState);
  }

  onChangeToAsset(value, accountState, dexState, dexCubit, tokensState) {
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
    onToInputChanged(
        valueFormat, dexState, dexCubit, accountState, tokensState);
  }

  getFieldMsg(
    accountState,
    dexState,
  ) {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);

    var availableAmountFrom;
    var availableAmountTo;
    if (SettingsHelper.isBitcoin()) {
      double balance = convertFromSatoshi(bitcoinCubit.state.totalBalance);
      String balanceFormat;
      if (balance > 0) {
        balanceFormat =
            balancesHelper.numberStyling(balance, fixed: true, fixedCount: 6);
      } else {
        balanceFormat =
            balancesHelper.numberStyling(0, fixed: true, fixedCount: 6);
      }
      swapFromMsg = '$balanceFormat $assetFrom';
      swapToMsg = '$balanceFormat $assetTo';
    } else {
      availableAmountFrom =
          getAvailableAmount(accountState, assetFrom, dexState);
      availableAmountTo = getAvailableAmount(accountState, assetTo, dexState);
      swapFromMsg =
          '${balancesHelper.numberStyling(availableAmountFrom)} $assetFrom';
      swapToMsg = '${balancesHelper.numberStyling(availableAmountTo)} $assetTo';
    }
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

  onFromInputChanged(
      String query, dexState, dexCubit, accountState, tokensState) {
    double amount = (query == '') ? 0 : double.parse(query);

    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      waitingFrom = true;
      if (assetFrom == assetTo) {
        amountToController.text = amountFromController.text;
      } else {
        if (SettingsHelper.isBitcoin()) {
          FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
          double amount = double.parse(amountFromController.text);

          var a = (amount - (fiatCubit.state.cryptoRoute!.fee! / 100 * amount))
              .toString();
          amountToController.text = balancesHelper.numberStyling(
            double.parse(a),
            fixedCount: 4,
            fixed: true,
          );
          dexCubit.updateBtcDex(assetFrom, assetTo, amount,
              double.parse(amountToController.text));
        } else {
          dexCubit.updateDex(assetFrom, assetTo, amount, null, address,
              accountState.activeAccount.addressList!, tokensState);
        }
      }
      //TODO: add validation
    });
  }

  onToInputChanged(
      String query, dexState, dexCubit, accountState, tokensState) {
    double amount = (query == '') ? 0 : double.parse(query);
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      waitingTo = true;
      if (assetFrom == assetTo) {
        if (SettingsHelper.isBitcoin()) {
          FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
          double amount = double.parse(amountToController.text);

          amountFromController.text =
              (amount - (fiatCubit.state.cryptoRoute!.fee! / 100 * amount))
                  .toString();
          amountFromController.text = balancesHelper.numberStyling(
            double.parse(amountToController.text),
            fixedCount: 4,
            fixed: true,
          );
        } else {
          amountFromController.text = amountToController.text;
        }
      } else {
        dexCubit.updateDex(assetFrom, assetTo, null, amount, address,
            accountState.activeAccount.addressList!, tokensState);
      }
    });
  }

  String getUdsAmount(double amount, tokensState) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

    var targetAmount =
        (amount - (fiatCubit.state.cryptoRoute!.fee! / 100 * amount))
            .toString();

    var result = tokensHelper.getAmountByUsd(
      tokensState.tokensPairs!,
      double.parse(targetAmount.replaceAll(',', '.')),
      'BTC',
    );
    return balancesHelper.numberStyling(
      result,
      fixedCount: 2,
      fixed: true,
    );
  }

  onFocusToChange() {
    hideOverlay();
    if (amountToController.text == '0') {
      amountToController.text = '';
    }
  }

  onFocusFromChange() {
    hideOverlay();
    if (amountFromController.text == '0') {
      amountFromController.text = '';
    }
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
