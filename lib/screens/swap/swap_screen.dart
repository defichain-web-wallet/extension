import 'dart:async';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/dex_helper.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/models/crypto_route_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/screens/dex/widgets/slippage_button.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select_swap.dart';
import 'package:defi_wallet/screens/swap/swap_summary_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/error_placeholder.dart';
import 'package:defi_wallet/widgets/fields/amount_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/bloc/dex/dex_cubit.dart';
import 'package:defi_wallet/bloc/dex/dex_state.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/swap/swap_account_selector_dialog.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> with ThemeMixin {
  final TextEditingController amountFromController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController amountToController = TextEditingController(
    text: '0.00',
  );
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

  List<TokensModel> tokensForSwap = [];
  List<TokensModel> assets = [];
  late AccountModel accountFrom;
  late AccountModel accountTo;
  TokensModel assetFrom = TokensModel(name: 'DefiChain', symbol: 'DFI');
  TokensModel? assetTo;
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

  double rateQuote = 0;
  double rateQuoteUsd = 0;
  TestPoolSwapModel? dexRate;

  List<String> slippageList = ['Custom', '0.5', '1', '3'];

  @override
  void initState() {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    tokensCubit.loadTokens();
    super.initState();
  }

  stateInit(accountState, dexState, tokensState) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    assets = [];
    if (SettingsHelper.isBitcoin()) {
      assetFrom = TokensModel(symbol: 'BTC', name: 'Bitcoin');
      assetTo = TokensModel(symbol: 'dBTC', name: 'Bitcoin');
    } else {
      accountState.activeAccount.balanceList!.forEach((el) {
        if (tokensState.tokensForSwap[el.token] != null &&
            !assets.contains(el.token) &&
            !el.isHidden) {
          assets.add(TokensModel(
            name: el.token!,
            symbol: el.token!,
          ));
        }
      });
      List<dynamic> tokens = tokensState.tokensForSwap[assetFrom.symbol];
      tokensForSwap = List<TokensModel>.generate(
        tokens.length,
            (index) =>
            TokensModel(
              name: tokens[index],
              symbol: tokens[index],
            ),
      );
      assetFrom = assetFrom;

      assetTo = assetTo ?? tokensForSwap[0];

      DexHelper dexHelper = DexHelper();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        dexRate = await dexHelper.calculateDex(
          assetFrom.symbol!,
          assetTo!.symbol!,
          1,
          0,
          address,
          accountState.activeAccount!.addressList!,
          tokensState,
        );
        rateQuoteUsd = tokensHelper.getAmountByUsd(
          tokensCubit.state.tokensPairs!,
          dexRate!.priceFrom!,
          assetTo!.symbol!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (BuildContext context,
          bool isFullScreen,
          TransactionState transactionState,) {
        return BlocBuilder<DexCubit, DexState>(
          builder: (dexContext, dexState) {
            DexCubit dexCubit = BlocProvider.of<DexCubit>(dexContext);
            BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
            return BlocBuilder<AccountCubit, AccountState>(
              builder: (accountContext, accountState) {
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
                          if (SettingsHelper.isBitcoin()) {
                            bitcoinCubit.loadAvailableBalance(
                                accountFrom.bitcoinAddress!);
                          }
                          dexCubit.updateDex(
                            assetFrom.symbol!,
                            assetTo!.symbol!,
                            0,
                            0,
                            address,
                            accountState.activeAccount!.addressList!,
                            tokensState,
                          );
                        }
                      }
                    }
                    return Scaffold(
                      appBar: NewMainAppBar(
                        isShowLogo: false,
                      ),
                      drawerScrimColor: Color(0x0f180245),
                      endDrawer: AccountDrawer(
                        width: buttonSmallWidth,
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
                        child: BlocBuilder<BitcoinCubit, BitcoinState>(
                          builder: (context, bitcoinState) {
                            return _buildBody(
                              context,
                              dexState,
                              dexCubit,
                              accountState,
                              tokensState,
                              transactionState,
                              isFullScreen,
                            );
                          }
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBody(context, dexState, dexCubit, accountState, tokensState,
      transactionState, isFullScreen) {
    double arrowRotateDegAccountFrom = false ? 180 : 0;
    double arrowRotateDegAccountTo = false ? 180 : 0;
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    bool isShowStabilizationFee =
        assetFrom.symbol == 'DUSD' && assetTo!.symbol == 'DFI' ||
            assetFrom.symbol == 'DUSD' && assetTo!.symbol == 'USDT' ||
            assetFrom.symbol == 'DUSD' && assetTo!.symbol == 'USDC';
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
        return StretchBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline3,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    if (SettingsHelper.isBitcoin())
                      ...[
                        Center(
                          child: Container(
                            height: 24,
                            width: 78,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: isDarkTheme()
                                  ? DarkColors.swapNetworkMarkBgColor
                                  : LightColors.swapNetworkMarkBgColor,
                              borderRadius: BorderRadius.circular(36)
                            ),
                            child: Text(
                              'Bitcoin Mainnet',
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                fontSize: 8,
                                color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3)
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Swap from',
                                style: Theme.of(context).textTheme.headline5!.copyWith(
                                  color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.3),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  barrierColor: Color(0x0f180245),
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SwapAccountSelectorDialog(
                                      confirmCallback: (name, address) {},
                                      onSelect: (int index) {
                                      BitcoinCubit bitcoinCubit =
                                          BlocProvider.of<BitcoinCubit>(
                                              context);
                                      setState(() {
                                        accountFrom =
                                            accountState.accounts[index];
                                        bitcoinCubit.loadAvailableBalance(
                                          accountFrom.bitcoinAddress!,
                                        );
                                      });
                                    },
                                  );
                                  },
                                );
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      accountFrom.name!,
                                      style: Theme.of(context).textTheme.headline5!.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    RotationTransition(
                                      turns: AlwaysStoppedAnimation(arrowRotateDegAccountFrom / 360),
                                      child: SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: SvgPicture.asset(
                                          'assets/icons/arrow_down.svg',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        )
                      ],
                    AmountField(
                      suffix: amountFromInUsd,
                      isDisabledSelector: SettingsHelper.isBitcoin(),
                      available: getAvailableAmount(
                        accountState,
                        assetFrom.symbol,
                        dexState,
                        isBitcoin: SettingsHelper.isBitcoin()
                      ),
                      onAssetSelect: (asset) {
                        onSelectFromAsset(
                          asset,
                          tokensState,
                          accountState,
                          dexCubit,
                        );
                      },
                      onChanged: (value) {
                        calculateSecondAmount(value, tokensState);
                        onChangeFromAsset(
                          value,
                          accountState,
                          dexState,
                          dexCubit,
                          tokensState,
                        );
                      },
                      controller: amountFromController,
                      selectedAsset: assetFrom,
                      assets: assets,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (SettingsHelper.isBitcoin())
                      ...[
                        SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Container(
                            height: 24,
                            width: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: isDarkTheme()
                                    ? DarkColors.swapNetworkMarkBgColor
                                    : LightColors.swapNetworkMarkBgColor,
                                borderRadius: BorderRadius.circular(36)
                            ),
                            child: Text(
                              'DeFiChain Mainnet',
                              style: Theme.of(context).textTheme.headline6!.copyWith(
                                  fontSize: 8,
                                  color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3)
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Swap to',
                                style: Theme.of(context).textTheme.headline5!.copyWith(
                                  color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.3),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  barrierColor: Color(0x0f180245),
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SwapAccountSelectorDialog(
                                      confirmCallback: (name, address) {},
                                      onSelect: (int index) {
                                        FiatCubit fiatCubit =
                                          BlocProvider.of<FiatCubit>(context);
                                        setState(() {
                                          accountTo = accountState.accounts[index];
                                        });
                                        fiatCubit.loadCryptoRoute(accountTo);
                                      },
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    accountTo.name!,
                                    style: Theme.of(context).textTheme.headline5!.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  RotationTransition(
                                    turns: AlwaysStoppedAnimation(arrowRotateDegAccountFrom / 360),
                                    child: SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: SvgPicture.asset(
                                        'assets/icons/arrow_down.svg',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        )
                      ],
                    AmountField(
                      suffix: amountToInUsd,
                      isDisabledSelector: SettingsHelper.isBitcoin(),
                      available: getAvailableAmount(
                        accountState,
                        assetTo!.symbol,
                        dexState,
                      ),
                      onAssetSelect: (asset) {
                        onSelectToAsset(
                          asset,
                          tokensState,
                          accountState,
                          dexCubit,
                        );
                      },
                      onChanged: (value) {
                        try {
                          var amount = tokensHelper.getAmountByUsd(
                            tokensCubit.state.tokensPairs!,
                            double.parse(value.replaceAll(',', '.')),
                            assetTo!.symbol!,
                          );
                          setState(() {
                            amountToInUsd = balancesHelper.numberStyling(amount,
                                fixedCount: 2, fixed: true);
                            if (SettingsHelper.isBitcoin()) {
                              amountFromInUsd =
                                  getUdsAmount(
                                      double.parse(value), tokensState);
                            } else {
                              amountFromInUsd = amountToInUsd;
                            }
                          });
                        } catch (err) {
                          print(err);
                        }
                        onChangeToAsset(
                          value,
                          accountState,
                          dexState,
                          dexCubit,
                          tokensState,
                        );
                      },
                      controller: amountToController,
                      selectedAsset: assetTo!,
                      assets: tokensForSwap,
                    ),
                    if (!SettingsHelper.isBitcoin())
                      ...[
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'Slippage tolerance',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline5!
                              .copyWith(
                            fontSize: 12,
                            color: Theme
                                .of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.3),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        if (isShowSlippageField)
                          Container(
                            height: 28,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'(^-?\d*\.?d*\,?\d*)')),
                              ],
                              controller: slippageController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Theme
                                    .of(context)
                                    .cardColor,
                                hoverColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppTheme.pinkColor),
                                ),
                                contentPadding: const EdgeInsets.all(8),
                                hintText: 'Type in percent..',
                                suffixIcon: IconButton(
                                  splashRadius: 16,
                                  icon: Icon(
                                    Icons.clear,
                                    size: 14,
                                  ),
                                  onPressed: () =>
                                      setState(() {
                                        slippage = 0.03;
                                        isShowSlippageField = false;
                                        hideOverlay();
                                      }),
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  try {
                                    slippage = double.parse(value) / 100;
                                  } catch (err) {
                                    slippage = 0.03;
                                  }
                                });
                              },
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ...List<Widget>.generate(
                                  slippageList.length, (index) {
                                return Expanded(
                                  flex: 1,
                                  child: SlippageButton(
                                    isFirst: true,
                                    isPadding: index != 0,
                                    isBorder: true,
                                    label:
                                    '${slippageList[index]} ${slippageList[index] !=
                                        'Custom' ? '%' : ''}',
                                    isActive: slippageList[index] != 'Custom' &&
                                        slippage ==
                                            double.parse(slippageList[index]) / 100,
                                    callback: () {
                                      if (slippageList[index] == 'Custom') {
                                        setState(() {
                                          isShowSlippageField = true;
                                        });
                                      } else {
                                        setState(() {
                                          slippage =
                                              double.parse(slippageList[index]) /
                                                  100;
                                        });
                                      }
                                    },
                                  ),
                                );
                              })
                            ],
                          ),
                        SizedBox(
                          height: 12,
                        ),
                        Divider(
                          color: AppColors.lavenderPurple.withOpacity(0.16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Rate',
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .headline5!
                                      .copyWith(
                                    fontSize: 12,
                                    color: Theme
                                        .of(context)
                                        .textTheme
                                        .headline5!
                                        .color!
                                        .withOpacity(0.3),
                                  ),
                                ),
                              ),
                              Text(
                                getRateStringFormat(dexState),
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ' (\$${balancesHelper.numberStyling(rateQuoteUsd, fixedCount: 2, fixed: true)})',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                  fontSize: 12,
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .headline5!
                                      .color!
                                      .withOpacity(0.3),
                                ),
                              )
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
                                'Platform Fee',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                  fontSize: 12,
                                  color: Theme
                                      .of(context)
                                      .textTheme
                                      .headline5!
                                      .color!
                                      .withOpacity(0.3),
                                ),
                              ),
                              Text(
                                '${balancesHelper.fromSatohi(12000)} DFI',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: AppColors.lavenderPurple.withOpacity(0.16),
                        ),
                        if (isShowStabilizationFee)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: SvgPicture.asset(
                                          '/icons/important_icon.svg',
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Stabilization fee',
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                          fontSize: 12,
                                          color: Theme
                                              .of(context)
                                              .textTheme
                                              .headline5!
                                              .color!
                                              .withOpacity(0.3),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Text(
                                  '${stabilizationFee.toString()}%',
                                  style: Theme
                                      .of(context)
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
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    BlocBuilder<FiatCubit, FiatState>(builder: (context, fiatState) {
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
                                padding: const EdgeInsets.only(bottom: 14.0),
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
                                          ?.apply(color: AppTheme.pinkColor),
                                    ),
                                  ),
                                ),
                              ),
                            NewPrimaryButton(
                              titleWidget: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: SvgPicture.asset(
                                      'assets/icons/change_icon.svg',
                                      color: AppColors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Preview Change',
                                    style: Theme.of(context)
                                        .textTheme
                                        .button!
                                        .copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.white,
                                          fontSize: 14,
                                        ),
                                  )
                                ],
                              ),
                              callback: !isDisableSubmit() &&
                                      fiatState.isKycDataComplete!
                                  ? () => submitReviewSwap(
                                        accountState,
                                        transactionState,
                                        context,
                                        isFullScreen,
                                        cryptoRoute: fiatState.cryptoRoute,
                                      )
                                  : null,
                            ),
                          ],
                        );
                      } else {
                        return NewPrimaryButton(
                          titleWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: SvgPicture.asset(
                                  'assets/icons/change_icon.svg',
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Preview Change',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .button!
                                    .copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                          callback: !isDisableSubmit()
                              ? () =>
                              submitReviewSwap(
                                accountState,
                                transactionState,
                                context,
                                isFullScreen,
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
        );
      }
    }
  }

  getRateStringFormat(dexState) {
    double priceFrom =
        (dexState is DexInitialState) ? 0.00 : dexState.initModel.priceFrom;
    return '1 ${assetFrom.symbol} = $priceFrom ${assetTo!.symbol}';
  }

  putAvailableBalance(String asset,
      TextEditingController controller,
      TokensState tokensState,
      AccountState accountState,
      DexState dexState,) {
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
    if (asset == assetFrom.symbol) {
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
        assetFrom.symbol!,
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
        .firstWhere((el) => el.token! == assetFrom.symbol && !el.isHidden)
        .balance!;
    return convertFromSatoshi(balance) <
        double.parse(amountFromController.text);
  }

  submitReviewSwap(
    state,
    transactionState,
    context,
    bool isFullScreen, {
    CryptoRouteModel? cryptoRoute,
  }) async {
    hideOverlay();
    if (SettingsHelper.isBitcoin()) {
      double minDeposit = convertFromSatoshi(cryptoRoute!.minDeposit!);
      if (minDeposit >= double.parse(amountFromController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Min amount must be more than $minDeposit BTC',
              style: Theme
                  .of(context)
                  .textTheme
                  .headline5,
            ),
            backgroundColor: Theme
                .of(context)
                .snackBarTheme
                .backgroundColor,
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
            style: Theme
                .of(context)
                .textTheme
                .headline5,
          ),
          backgroundColor: Theme
              .of(context)
              .snackBarTheme
              .backgroundColor,
        ),
      );
      return;
    }
    if (isEnoughBalance(state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient funds',
            style: Theme
                .of(context)
                .textTheme
                .headline5,
          ),
          backgroundColor: Theme
              .of(context)
              .snackBarTheme
              .backgroundColor,
        ),
      );
      return;
    }
    if (isNumeric(amountFromController.text)) {
      if (SettingsHelper.isBitcoin() && cryptoRoute != null) {
        showDialog(
          barrierColor: Color(0x0f180245),
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context1) {
            return PassConfirmDialog(
                onSubmit: (password) async {
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
                              SwapSummaryScreen(
                                assetFrom.symbol!,
                                assetTo!.symbol!.replaceAll('d', ''),
                                double.parse(amountFromController.text),
                                double.parse(amountToController.text),
                                slippage,
                                btcTx: tx,
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
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline5,
                        ),
                        backgroundColor:
                        Theme
                            .of(context)
                            .snackBarTheme
                            .backgroundColor,
                      ),
                    );
                  }
                }
            );
          },
        );
      } else {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SwapSummaryScreen(
                    assetFrom.symbol!,
                    assetTo!.symbol!,
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
    List<dynamic> tokens = tokensState.tokensForSwap[asset.symbol];
    tokensForSwap = List<TokensModel>.generate(
      tokens.length,
          (index) =>
          TokensModel(
            name: tokens[index],
            symbol: tokens[index],
          ),
    );
    setState(() {
      assetFrom = asset;
      assetTo = tokensForSwap[0];
    });
    if (assetFrom.symbol == assetTo!.symbol) {
      amountFromController.text = amountToController.text;
    } else {
      dexCubit.updateDex(
        assetFrom.symbol,
        assetTo!.symbol,
        null,
        double.parse(amountToController.text),
        address,
        accountState.activeAccount.addressList!,
        tokensState,
      );
    }
  }

  onSelectToAsset(asset, tokensState, accountState, dexCubit) {
    setState(() => {assetTo = asset});
    if (assetFrom.symbol == assetTo!.symbol) {
      amountFromController.text = amountToController.text;
    } else {
      dexCubit.updateDex(
          assetFrom.symbol,
          assetTo!.symbol,
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

  getFieldMsg(accountState,
      dexState,) {
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
          getAvailableAmount(accountState, assetFrom.symbol, dexState);
      availableAmountTo =
          getAvailableAmount(accountState, assetTo!.symbol, dexState);
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
    return '${balancesHelper.numberStyling(
        price, fixedCount: 8, fixed: true)} ${tokensHelper.getTokenWithPrefix(
        tokenTo)} per ${tokensHelper.getTokenWithPrefix(tokenFrom)}';
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

  onFromInputChanged(String query, dexState, dexCubit, accountState,
      tokensState) {
    double amount = (query == '') ? 0 : double.parse(query);

    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      waitingFrom = true;
      if (assetFrom.symbol! == assetTo!.symbol!) {
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
          dexCubit.updateBtcDex(assetFrom.symbol, assetTo!.symbol, amount,
              double.parse(amountToController.text));
        } else {
          dexCubit.updateDex(
              assetFrom.symbol,
              assetTo!.symbol,
              amount,
              null,
              address,
              accountState.activeAccount.addressList!,
              tokensState);
        }
      }
      //TODO: add validation
    });
  }

  onToInputChanged(String query, dexState, dexCubit, accountState,
      tokensState) {
    double amount = (query == '') ? 0 : double.parse(query);
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 800), () {
      waitingTo = true;
      if (assetFrom.symbol! == assetTo!.symbol!) {
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
        dexCubit.updateDex(
            assetFrom.symbol,
            assetTo!.symbol,
            null,
            amount,
            address,
            accountState.activeAccount.addressList!,
            tokensState);
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

  double getAvailableAmount(
    accountState,
    assetFrom,
    dexState, {
    bool isBitcoin = false,
  }) {
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);
    int amount = 0;
    int fee = 0;

    if (isBitcoin) {
      return convertFromSatoshi(bitcoinCubit.state.availableBalance);
    }

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
