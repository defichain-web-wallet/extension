import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/lock/lock_cubit.dart';
import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/screens/home/home_screen.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defi_wallet/services/lock_service.dart';
import 'package:defi_wallet/services/transaction_service.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/restore_button.dart';
import 'package:defi_wallet/widgets/dialogs/pass_confirm_dialog.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:defi_wallet/widgets/fields/amount_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class YieldMachineActionScreen extends StatefulWidget {
  final bool isDeposit;
  final bool isShowDepositAddress;

  const YieldMachineActionScreen({
    Key? key,
    this.isDeposit = false,
    this.isShowDepositAddress = false,
  }) : super(key: key);

  @override
  State<YieldMachineActionScreen> createState() =>
      _YieldMachineActionScreenState();
}

class _YieldMachineActionScreenState extends State<YieldMachineActionScreen>
    with ThemeMixin, SnackBarMixin {
  final String changeDfiText = 'Please note that currently only DFI UTXO can '
      'be added to staking. You can exchange DFI tokens by pressing here.';
  final String warningText = 'You can also deposit DFI directly from an other '
      'DeFiChain address. Simply send the DFI to this staking deposit address.';
  final FocusNode _focusNode = FocusNode();
  double available = 0;
  String usdAmount = '';
  TextEditingController controller = TextEditingController();
  TransactionService transactionService = TransactionService();
  BalancesHelper balancesHelper = BalancesHelper();
  LockCubit lockCubit = LockCubit();
  LockService lockService = LockService();
  TokensModel? currentAsset;
  bool _onFocused = false;
  double currentSliderValue = 0;
  int i = 0;

  late String titleText;

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    titleText = widget.isDeposit ? 'Deposit' : 'Withdraw';
    controller.text = '0';
    super.initState();
  }

  _onFocusChange() {
    if (controller.text == '') {
      controller.text = '0';
    }
    setState(() {
      _onFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (accountContext, accountState) {
            return BlocBuilder<LockCubit, LockState>(
              builder: (lockContext, lockState) {
                return BlocBuilder<TokensCubit, TokensState>(
                  builder: (tokensContext, tokensState) {
                    List<TokensModel> assets = getTokensList(
                      tokensState,
                      lockState.lockStakingDetails!.balances,
                      accountState: widget.isDeposit ? null : accountState,
                    );
                    currentAsset = currentAsset ?? assets.first;

                    usdAmount = getUsdBalance(
                      context,
                      controller.text,
                      currentAsset!.symbol!,
                    );
                    if (widget.isDeposit) {
                      available = lockState.lockStakingDetails!.balances!
                          .firstWhere(
                              (element) => element.asset == currentAsset!.symbol)
                          .balance!;
                    } else {
                      available = convertFromSatoshi(accountState.balances!
                          .firstWhere((element) =>
                      element.token! == currentAsset!.symbol!)
                          .balance!);
                    }
                    return Scaffold(
                      drawerScrimColor: Color(0x0f180245),
                      endDrawer: AccountDrawer(
                        width: buttonSmallWidth,
                      ),
                      appBar: NewMainAppBar(
                        bgColor: AppColors.viridian.withOpacity(0.16),
                        isShowLogo: false,
                        isShowNetworkSelector: false,
                      ),
                      body: Container(
                        decoration: BoxDecoration(
                          color: AppColors.viridian.withOpacity(0.16),
                        ),
                        child: Container(
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
                          child: StretchBox(
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            titleText,
                                            style: headline2.copyWith(
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      AmountField(
                                        onAssetSelect: (asset) {},
                                        onChanged: (asset) {
                                          setState(() {
                                            usdAmount = getUsdBalance(
                                              context,
                                              controller.text,
                                              currentAsset!.symbol!,
                                            );
                                          });
                                        },
                                        controller: controller,
                                        selectedAsset: currentAsset!,
                                        assets: assets,
                                        suffix: usdAmount,
                                        available: available,
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      if (!widget.isDeposit && widget.isShowDepositAddress) ...[
                                        Row(
                                          children: [
                                            Text(
                                              'DFI Deposit address ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                    fontSize: 16,
                                                  ),
                                            ),
                                            Text(
                                              '(optional)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .headline4!
                                                        .color!
                                                        .withOpacity(0.6),
                                                  ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                  text: lockState
                                                      .lockStakingDetails!
                                                      .depositAddress!),
                                            );
                                          },
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.viridian
                                                    .withOpacity(0.07),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 10),
                                                        child: SvgPicture.asset(
                                                          'assets/icons/copy.svg',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          cutAddress(
                                                            lockState
                                                                .lockStakingDetails!
                                                                .depositAddress!,
                                                          ),
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline5!
                                                                  .copyWith(
                                                                    fontSize:
                                                                        12,
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
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                      right: 10),
                                                  child: SvgPicture.asset(
                                                      'assets/icons/important_icon.svg'),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    warningText,
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
                                          ],
                                        ),
                                      ],
                                      SizedBox(
                                        height: 88,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: buttonSmallWidth,
                                      child: PendingButton(
                                        'Continue',
                                        pendingText: 'Pending...',
                                        callback: (parent) {
                                          if (txState
                                              is! TransactionLoadingState) {
                                            if (double.parse(controller.text
                                                    .replaceAll(',', '')) >=
                                                lockState.lockStakingDetails!
                                                    .minimalDeposit!) {
                                              parent.emitPending(true);
                                              if (widget.isDeposit) {
                                                showDialog(
                                                  barrierColor:
                                                      Color(0x0f180245),
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext
                                                      dialogContext) {
                                                    return PassConfirmDialog(
                                                      onCancel: () {
                                                        parent
                                                            .emitPending(false);
                                                      },
                                                      onSubmit: (password) {
                                                        unstakeCallback(
                                                          password,
                                                          accountState
                                                              .accounts!.first,
                                                          accountState
                                                              .accounts!
                                                              .first
                                                              .lockAccessToken!,
                                                          lockState
                                                              .lockStakingDetails!
                                                              .id!,
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              } else {
                                                showDialog(
                                                  barrierColor:
                                                      Color(0x0f180245),
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext
                                                      dialogContext) {
                                                    return PassConfirmDialog(
                                                      onCancel: () {
                                                        parent
                                                            .emitPending(false);
                                                      },
                                                      onSubmit: (password) {
                                                        stakeCallback(
                                                          password,
                                                          accountState
                                                              .accounts!.first,
                                                          lockState
                                                              .lockStakingDetails!
                                                              .depositAddress!,
                                                          tokensState.tokens!,
                                                          accountState
                                                              .accounts!
                                                              .first
                                                              .lockAccessToken!,
                                                          lockState
                                                              .lockStakingDetails!
                                                              .id!,
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            } else {
                                              showSnackBar(
                                                context,
                                                title: 'Minimal amount: '
                                                    '${lockState.lockStakingDetails!.minimalDeposit}',
                                                color: AppColors.txStatusError
                                                    .withOpacity(0.1),
                                                prefix: Icon(
                                                  Icons.close,
                                                  color:
                                                      AppColors.txStatusError,
                                                ),
                                              );
                                            }
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
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  cutAddress(String s) {
    return s.substring(0, 14) + '...' + s.substring(28, 42);
  }

  stakeCallback(
    String password,
    AccountModel account,
    String address,
    List<TokensModel> tokens,
    String lockAccessToken,
    int stakingId,
  ) async {
    ECPair keyPair = await HDWalletService().getKeypairFromStorage(
      password,
      account.index!,
    );
    TxErrorModel? txResponse;
    txResponse = await transactionService.createAndSendTransaction(
      keyPair: keyPair,
      account: account,
      destinationAddress: address,
      amount: balancesHelper.toSatoshi(controller.text),
      tokens: tokens,
    );
    if (!txResponse.isError!) {
      lockCubit.stake(
        lockAccessToken,
        stakingId,
        double.parse(controller.text.replaceAll(',', '')),
        txResponse.txLoaderList![0].txId!,
      );
    }
    showDialog(
      barrierColor: Color(0x0f180245),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return TxStatusDialog(
          txResponse: txResponse,
          callbackOk: () {
            if (!txResponse!.isError!) {
              TransactionCubit transactionCubit =
                  BlocProvider.of<TransactionCubit>(context);

              transactionCubit.setOngoingTransaction(txResponse);
            }
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => HomeScreen(
                  isLoadTokens: true,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          callbackTryAgain: () async {
            print('TryAgain');
            await stakeCallback(
              password,
              account,
              address,
              tokens,
              lockAccessToken,
              stakingId,
            );
          },
        );
      },
    );
  }

  void _setBalance(LockState lockState, availableAmount) {
    controller.text = balancesHelper.numberStyling(
      (double.parse(availableAmount) * currentSliderValue) / 100,
      fixedCount: 4,
      fixed: true,
    );
  }

  unstakeCallback(
    String password,
    AccountModel account,
    String lockAccessToken,
    int stakingId,
  ) async {
    ECPair keyPair = await HDWalletService().getKeypairFromStorage(
      password,
      account.index!,
    );
    bool isDepositSuccess = await lockService.makeWithdraw(
      keyPair,
      lockAccessToken,
      stakingId,
      double.parse(controller.text.replaceAll(',', '')),
    );
    TxErrorModel txResponse = TxErrorModel(isError: !isDepositSuccess);
    showDialog(
      barrierColor: Color(0x0f180245),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext dialogContext) {
        return TxStatusDialog(
          txResponse: txResponse,
          callbackOk: () {
            if (!txResponse.isError! && !widget.isDeposit) {
              TransactionCubit transactionCubit =
                  BlocProvider.of<TransactionCubit>(context);

              transactionCubit.setOngoingTransaction(txResponse);
            }
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => HomeScreen(
                  isLoadTokens: true,
                ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          callbackTryAgain: () async {
            print('TryAgain');
            await unstakeCallback(
              password,
              account,
              lockAccessToken,
              stakingId,
            );
          },
        );
      },
    );
  }

  String getUsdBalance(
    context,
    String balance,
    String asset,
  ) {
    TokensCubit tokensCubit = BlocProvider.of<TokensCubit>(context);
    try {
      var amount = tokenHelper.getAmountByUsd(
        tokensCubit.state.tokensPairs!,
        double.parse(balance),
        asset,
      );
      return balancesHelper.numberStyling(amount, fixedCount: 2, fixed: true);
    } catch (err) {
      return '0.00';
    }
  }

  getTokensList(tokensState, targetAssets, {AccountState? accountState}) {
    List<TokensModel> resList = [];
    if (accountState != null) {
      List<dynamic> tempList = [];
      accountState.balances!.forEach((element) {
        targetAssets.forEach((el) {
          if (element.token == el.asset) {
            tempList.add(el);
          }
        });
      });
      tempList.forEach((element) {
        tokensState.tokens!.forEach((el) {
          if (element.asset == el.symbol) {
            resList.add(el);
          }
        });
      });
    } else {
      targetAssets.forEach((element) {
        tokensState.tokens!.forEach((el) {
          if (element.asset == el.symbol && element.balance > 0) {
            resList.add(el);
          }
        });
      });
    }

    return resList;
  }
}
