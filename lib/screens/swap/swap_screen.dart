import 'package:defi_wallet/bloc/refactoring/exchange/exchange_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/transaction/tx_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/format_mixin.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_loader_model.dart';
import 'package:defi_wallet/screens/dex/widgets/slippage_button.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select_swap.dart';
import 'package:defi_wallet/screens/swap/swap_summary_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/refactoring/fields/amount_field.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/models/focus_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({Key? key}) : super(key: key);

  @override
  _SwapScreenState createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen>
    with ThemeMixin, SnackBarMixin, FormatMixin {
  static const completeKycType = 'Completed';

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

  FocusNode focusFrom = new FocusNode();
  FocusNode focusTo = new FocusNode();
  FocusModel focusAmountFromModel = new FocusModel();
  FocusModel focusAmountToModel = new FocusModel();

  List<TokensModel> tokensForSwap = [];
  List<TokensModel> assets = [];
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
  String stabilizationFee = '30';
  String amountFromInUsd = '0.0';
  String amountToInUsd = '0.0';

  double rateQuote = 0;
  double rateQuoteUsd = 0;
  TestPoolSwapModel? dexRate;

  List<String> slippageList = ['Custom', '0.5', '1', '3'];

  @override
  void initState() {
    ExchangeCubit txCubit = BlocProvider.of<ExchangeCubit>(context);
    txCubit.setInitial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return ScaffoldWrapper(
          builder: (BuildContext context,
              bool isFullScreen,
              TransactionState transactionState,) {
            return BlocBuilder<ExchangeCubit, ExchangeState>(
              builder: (exchangeContext, exchangeState) {
                ExchangeCubit exchangeCubit = BlocProvider.of<ExchangeCubit>(
                    context);
                if (exchangeState.status == ExchangeStatusList.initial) {
                  exchangeCubit.init(context);
                  return Loader();
                } else if (exchangeState.status == ExchangeStatusList.success) {
                  return Scaffold(
                  appBar: isFullScreen ? null : NewMainAppBar(
                  isShowLogo: false,
                  ),
                  drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                  endDrawer: isFullScreen ? null : AccountDrawer(
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
                            ? DarkColors.networkDropdownBgColor
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
                      child: _buildBody(
                        context,
                        exchangeCubit,
                        exchangeState,
                        isFullScreen,
                      ),
                    ),
                  );
                } else {
                  return Loader();
                }
                // assets = tokensHelper.getTokensList(
                //   accountState,
                //   tokensState,
                //   targetList: assets,
                // );
                // tokensForSwap = tokensHelper.getTokensList(
                //   accountState,
                //   tokensState,
                //   targetList: tokensForSwap,
                // );
              },
            );
          });
    } catch(e){
      print(e);
      return Container();
    }
  }

  Widget _buildBody(context, ExchangeCubit exchangeCubit, ExchangeState exchangeState, isFullScreen) {
    final walletCubit = BlocProvider.of<WalletCubit>(context);
    double arrowRotateDegAccountFrom = false ? 180 : 0;
    double arrowRotateDegAccountTo = false ? 180 : 0;
    bool isShowStabilizationFee =
        exchangeState.selectedBalance!.token!.symbol == 'DUSD' && exchangeState.selectedSecondInputBalance!.token!.symbol == 'DFI' ||
            exchangeState.selectedBalance!.token!.symbol == 'DUSD' && exchangeState.selectedSecondInputBalance!.token!.symbol == 'USDT' ||
            exchangeState.selectedBalance!.token!.symbol == 'DUSD' && exchangeState.selectedSecondInputBalance!.token!.symbol == 'USDC';

        // if (isShowStabilizationFee) {
        //   try {
        //     // var targetPair = exchangeState.availablePairs!
        //     //     .firstWhere((e) => e.quote.displaySymbol == 'DUSD' && e.base.displaySymbol == 'DFI');
        //     // stabilizationFee = balancesHelper.numberStyling(
        //     //     ((1 / (1 - targetPair.fee!)) - 1) * 100,
        //     //     fixedCount: 2,
        //     //     fixed: true);
        //   } catch (err) {
        //     print(err);
        //   }
        // }
        return StretchBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitle(
                      title: 'Change',
                      isFullScreen: isFullScreen,
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    //TODO:This is block for bitcoin network. Comment this because bitcoin currently is unavailable
                      // ...[
                      //   Center(
                      //     child: Container(
                      //       height: 24,
                      //       width: 78,
                      //       alignment: Alignment.center,
                      //       decoration: BoxDecoration(
                      //           color: isDarkTheme()
                      //             ? DarkColors.swapNetworkMarkBgColor
                      //             : LightColors.swapNetworkMarkBgColor,
                      //         borderRadius: BorderRadius.circular(36)
                      //       ),
                      //       child: Text(
                      //         'Bitcoin Mainnet',
                      //         style: Theme.of(context).textTheme.headline6!.copyWith(
                      //           fontSize: 8,
                      //           color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3)
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Flexible(
                      //         child: Text(
                      //           'Swap from',
                      //           style: Theme.of(context).textTheme.headline5!.copyWith(
                      //             color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.3),
                      //           ),
                      //         ),
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           showDialog(
                      //             barrierColor: AppColors.tolopea.withOpacity(0.06),
                      //             barrierDismissible: false,
                      //             context: context,
                      //             builder: (BuildContext context) {
                      //               return SwapAccountSelectorDialog(
                      //                 confirmCallback: (name, address) {},
                      //                 onSelect: (int index) {
                      //                 BitcoinCubit bitcoinCubit =
                      //                     BlocProvider.of<BitcoinCubit>(
                      //                         context);
                      //                 setState(() {
                      //                   accountFrom =
                      //                       accountState.accounts[index];
                      //                   bitcoinCubit.loadAvailableBalance(
                      //                     accountFrom.bitcoinAddress!,
                      //                   );
                      //                 });
                      //               },
                      //             );
                      //             },
                      //           );
                      //         },
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.end,
                      //           children: [
                      //             Container(
                      //               constraints: BoxConstraints(maxWidth: 150),
                      //               child: TickerText(
                      //                 isSpecialDuration: true,
                      //                 child: Text(
                      //                   accountFrom.name!,
                      //                   style: Theme.of(context).textTheme.headline5!.copyWith(
                      //                     fontSize: 13,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               width: 8,
                      //             ),
                      //             RotationTransition(
                      //               turns: AlwaysStoppedAnimation(arrowRotateDegAccountFrom / 360),
                      //               child: SizedBox(
                      //                 width: 10,
                      //                 height: 10,
                      //                 child: SvgPicture.asset(
                      //                   'assets/icons/arrow_down.svg',
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      //   SizedBox(
                      //     height: 6,
                      //   )
                      // ],
                    AmountField(
                      type: TxType.swap,
                      suffix: amountFromInUsd,
                      isDisabledSelector: false,
                      available: exchangeState.availableFrom,
                      onAssetSelect: (asset) {
                        exchangeCubit.updateBalance(context, asset);
                      },
                      onChanged: (value) {
                        double amount = double.parse(formatNumberStyling(
                          double.parse(value),
                          fixedCount: 8,
                        ));
                        double amountToInput = exchangeCubit.calculateRate(exchangeState.selectedSecondInputBalance!.token!, exchangeState.selectedBalance!.token!, amount);
                        amountToInput = double.parse(formatNumberStyling(
                          amountToInput,
                          fixedCount: 8,
                        ));
                          setState(() {
                            amountToController.text = amountToInput.toString();
                          });
                          exchangeCubit.updateAmountsAndSlipage(amountFrom: amount, amountTo: amountToInput);
                      },
                      controller: amountFromController,
                      balance: exchangeState.selectedBalance,
                      assets: exchangeState.balances!,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    //TODO:This is block for bitcoin network. Comment this because bitcoin currently is unavailable
                      // ...[
                      //   SizedBox(
                      //     height: 8,
                      //   ),
                      //   Center(
                      //     child: Container(
                      //       height: 24,
                      //       width: 90,
                      //       alignment: Alignment.center,
                      //       decoration: BoxDecoration(
                      //           color: isDarkTheme()
                      //               ? DarkColors.swapNetworkMarkBgColor
                      //               : LightColors.swapNetworkMarkBgColor,
                      //           borderRadius: BorderRadius.circular(36)
                      //       ),
                      //       child: Text(
                      //         'DeFiChain Mainnet',
                      //         style: Theme.of(context).textTheme.headline6!.copyWith(
                      //             fontSize: 8,
                      //             color: Theme.of(context).textTheme.headline6!.color!.withOpacity(0.3)
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Flexible(
                      //         child: Text(
                      //           'Swap to',
                      //           style: Theme.of(context).textTheme.headline5!.copyWith(
                      //             color: Theme.of(context).textTheme.headline5!.color!.withOpacity(0.3),
                      //           ),
                      //         ),
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           showDialog(
                      //             barrierColor: AppColors.tolopea.withOpacity(0.06),
                      //             barrierDismissible: false,
                      //             context: context,
                      //             builder: (BuildContext context) {
                      //               return SwapAccountSelectorDialog(
                      //                 confirmCallback: (name, address) {},
                      //                 onSelect: (int index) {
                      //                   FiatCubit fiatCubit =
                      //                     BlocProvider.of<FiatCubit>(context);
                      //                   setState(() {
                      //                     accountTo = accountState.accounts[index];
                      //                   });
                      //                   fiatCubit.loadCryptoRoute(accountTo);
                      //                 },
                      //               );
                      //             },
                      //           );
                      //         },
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.end,
                      //           children: [
                      //             Container(
                      //               constraints: BoxConstraints(maxWidth: 150),
                      //               child: TickerText(
                      //                 isSpecialDuration: true,
                      //                 child: Text(
                      //                   accountTo.name!,
                      //                   style: Theme.of(context).textTheme.headline5!.copyWith(
                      //                     fontSize: 13,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(
                      //               width: 8,
                      //             ),
                      //             RotationTransition(
                      //               turns: AlwaysStoppedAnimation(arrowRotateDegAccountFrom / 360),
                      //               child: SizedBox(
                      //                 width: 10,
                      //                 height: 10,
                      //                 child: SvgPicture.asset(
                      //                   'assets/icons/arrow_down.svg',
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       )
                      //     ],
                      //   ),
                      //   SizedBox(
                      //     height: 6,
                      //   )
                      // ],
                    AmountField(
                      isDisableAvailable: true,
                      type: TxType.swap,
                      suffix: amountToInUsd,
                      available: 0,
                      onAssetSelect: (asset) {
                        exchangeCubit.updateBalanceTo(context, asset);
                      },
                      onChanged: (value) {
                        double amount = double.parse(value);

                        var amountFromInput = exchangeCubit.calculateRate(exchangeState.selectedBalance!.token!, exchangeState.selectedSecondInputBalance!.token!, amount);
                        exchangeCubit.updateAmountsAndSlipage(amountFrom: amountFromInput, amountTo: amount);
                        setState(() {
                          final amount = formatNumberStyling(
                            amountFromInput,
                            fixedCount: 8,
                          );
                          amountFromController.text = amount.toString();
                        });
                      },
                      balance: exchangeState.selectedSecondInputBalance,
                      controller: amountToController,
                      assets: exchangeState.secondInputBalances!,
                    ),
                    //TODO:This is block for bitcoin network. Comment this because bitcoin currently is unavailable
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
                                        exchangeCubit.updateAmountsAndSlipage(slippage: 0.03);
                                        isShowSlippageField = false;
                                        // hideOverlay();
                                      }),
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  try {
                                    var slippage = double.parse(value) / 100;
                                    exchangeCubit.updateAmountsAndSlipage(slippage: slippage);
                                  } catch (err) {
                                    exchangeCubit.updateAmountsAndSlipage(slippage: 0.03);
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
                                        exchangeState.slippage ==
                                            double.parse(slippageList[index]) / 100,
                                    callback: () {
                                      if (slippageList[index] == 'Custom') {
                                        setState(() {
                                          isShowSlippageField = true;
                                        });
                                      } else {
                                        setState(() {
                                          exchangeCubit.updateAmountsAndSlipage(slippage: double.parse(slippageList[index]) /
                                              100);
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
                                exchangeCubit.getRateStringFormat(),
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              // Text(
                              //   ' (\$${balancesHelper.numberStyling(rateQuoteUsd, fixedCount: 2, fixed: true)})',
                              //   style: Theme
                              //       .of(context)
                              //       .textTheme
                              //       .headline5!
                              //       .copyWith(
                              //     fontSize: 12,
                              //     color: Theme
                              //         .of(context)
                              //         .textTheme
                              //         .headline5!
                              //         .color!
                              //         .withOpacity(0.3),
                              //   ),
                              // )
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
                                '${walletCubit.fromSatoshi(12000)} DFI',
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
                        //TODO:This is block for bitcoin network. Comment this because bitcoin currently is unavailable
                        //if bitcoin{
                        // return Column(
                        //   children: [
                        //     if (fiatState.status == FiatStatusList.success && fiatState.kycStatus != completeKycType)
                        //       Padding(
                        //         padding: const EdgeInsets.only(bottom: 14.0),
                        //         child: InkWell(
                        //           onTap: () {
                        //             String kycHash = fiatState.kycHash!;
                        //             launch(
                        //                 'https://payment.dfx.swiss/kyc?code=$kycHash');
                        //           },
                        //           child: RichText(
                        //             text: TextSpan(
                        //               text:
                        //                   'Please complete the KYC process to enable this feature',
                        //               style: Theme.of(context)
                        //                   .textTheme
                        //                   .headline5
                        //                   ?.apply(color: AppTheme.pinkColor),
                        //             ),
                        //           ),
                        //         ),
                        //       )
                        //     else if (fiatState.errorMessage == "\"Missing bank transaction\"")
                        //       Padding(
                        //         padding: const EdgeInsets.only(bottom: 14.0),
                        //         child: Text(
                        //           'Please do buy or sell first',
                        //           style: Theme.of(context)
                        //               .textTheme
                        //               .headline5
                        //               ?.apply(color: Theme.of(context)
                        //               .textTheme
                        //               .headline5!.color!.withOpacity(0.6)),
                        //         ),
                        //       ),
                        //     NewPrimaryButton(
                        //       titleWidget: Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           SizedBox(
                        //             width: 16,
                        //             height: 16,
                        //             child: SvgPicture.asset(
                        //               'assets/icons/change_icon.svg',
                        //               color: AppColors.white,
                        //             ),
                        //           ),
                        //           SizedBox(
                        //             width: 8,
                        //           ),
                        //           Text(
                        //             'Preview Change',
                        //             style: Theme.of(context)
                        //                 .textTheme
                        //                 .button!
                        //                 .copyWith(
                        //                   fontWeight: FontWeight.w800,
                        //                   color: AppColors.white,
                        //                   fontSize: 14,
                        //                 ),
                        //           )
                        //         ],
                        //       ),
                        //       callback: !isDisableSubmit() &&
                        //               (fiatState.kycStatus ==
                        //                   completeKycType) &&
                        //               fiatState.errorMessage == null
                        //           ? () => submitReviewSwap(
                        //                 accountState,
                        //                 transactionState,
                        //                 context,
                        //                 isFullScreen,
                        //                 cryptoRoute: fiatState.cryptoRoute,
                        //               )
                        //           : null,
                        //     ),
                        //   ],
                        // );
                        // else
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
                          callback: isDisableSubmit()
                              ? () {
                            TxCubit txCubit = BlocProvider.of<TxCubit>(context);
                            if (txCubit.transactionState is! TransactionLoadingState) {
                                    submitReviewSwap(
                                      context,
                                      isFullScreen,
                                    );
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
                  ],
                ),
              ),
            ],
          ),
        );

    }

  bool isNumeric(String string) {
    final numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(string);
  }

  submitReviewSwap(
    context,
    bool isFullScreen,
  ) async {
    if (isNumeric(amountFromController.text)) {
      NavigatorService.push(
        context,
        SwapSummaryScreen(),
      );
    }
  }

  bool isDisableSubmit() {
    try {
      return double.parse(amountFromController.text) > 0 && double.parse(amountToController.text) > 0;
    } catch (err) {
      return false;
    }
  }
}
